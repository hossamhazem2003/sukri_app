import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sukri/model/models/recipe_model.dart';
import '../models/user_model.dart';

class FirebaseServices {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//*************************************************************AUTH METHODS************************************************************** */
  /// Register a new user
  Future<User?> createAccount({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      // Create a new user with Firebase Auth
      firebase_auth.UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create User object
      User newUser = User(
          id: userCredential.user!.uid, // diffrent id for each user
          firstName: firstName,
          lastName: lastName,
          username: username,
          email: email,
          password: password);

      // Save additional user info to Firestore
      await _firestore.collection('users').doc(newUser.id).set(newUser.toMap());

      return newUser;
    } catch (e) {
      throw Exception('خطأ في انشاء الحساب: ${e.toString()}');
    }
  }

  /// Login an existing user
  Future<User?> login({
    required String username,
    required String password,
  }) async {
    try {
      // Fetch user email by username from Firestore
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('username',
              isEqualTo:
                  username) // لو انا هسجل باسم حسام حازم, ف انت خش ابحثلي في كل الداتا الخاصة بيك لغاية متلاقي اسم حسام حازم
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('لا يوجد مستخدم بهذا الاسم');
      }

      String email = querySnapshot.docs.first.get('email');

      // Log in using Firebase Auth
      firebase_auth.UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      //******************************************************** */

      // Retrieve user info from Firestore
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        throw Exception('معلومات المستخدم مفقودة في قاعدة البيانات.');
      }

      return User.fromDocument(
          userDoc.data() as Map<String, dynamic>, userCredential.user!.uid);
    } catch (e) {
      throw Exception('خطأ في تسجيل الدخول: ${e.toString()}');
    }
  }

  /// Logout the current user
  Future<void> logout() async {
    await _auth.signOut();
  }

//**************************************************************USER METHODS************************************************************* */
  /// Get current user
  Future<User?> getCurrentUser() async {
    try {
      firebase_auth.User? firebaseUser = _auth.currentUser;

      if (firebaseUser != null) {
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(firebaseUser.uid).get();

        if (userDoc.exists) {
          return User.fromDocument(
              userDoc.data() as Map<String, dynamic>, firebaseUser.uid);
        }
      }
      return null;
    } catch (e) {
      throw Exception('خطأ في الحصول علي المستخدم: ${e.toString()}');
    }
  }

  /// Update user data
  Future<void> updateUser({
    required String userId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firestore.collection('users').doc(userId).update(data);
    } catch (e) {
      throw Exception('Error updating user data: $e');
    }
  }

  Future<void> reauthenticateUser(String email, String password) async {
    try {
      final credential = firebase_auth.EmailAuthProvider.credential(
        email: email,
        password: password,
      );

      // Reauthenticate the user
      await _auth.currentUser?.reauthenticateWithCredential(credential);
      debugPrint('Reauthentication successful');
    } on firebase_auth.FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        throw Exception('كلمة المرور غير صحيحة. يرجى المحاولة مرة أخرى.');
      } else if (e.code == 'invalid-credential') {
        throw Exception(
            'بيانات الاعتماد المقدمة غير صحيحة أو منتهية الصلاحية.');
      } else {
        throw Exception('خطأ في إعادة المصادقة: ${e.message}');
      }
    } catch (e) {
      throw Exception('خطأ غير متوقع: $e');
    }
  }

  Future<void> updatePassword(
      String email, String currentPassword, String newPassword) async {
    try {
      // Reauthenticate the user
      await reauthenticateUser(email, currentPassword);

      // Update the password after successful reauthentication
      await _auth.currentUser?.updatePassword(newPassword);

      debugPrint('تم تحديث الباسوورد بنجاح');
    } on firebase_auth.FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw Exception(
            'كلمة المرور الجديدة ضعيفة جداً. يرجى اختيار كلمة أقوى.');
      } else {
        throw Exception('خطأ في تحديث الباسوورد: ${e.message}');
      }
    } catch (e) {
      throw Exception('خطأ غير متوقع: $e');
    }
  }

  Future<void> updateUserDailyCalories(String userId, double dailyCalories) async {
  try {
    final userDoc = _firestore.collection('users').doc(userId);

    // Check if the document exists
    final docSnapshot = await userDoc.get();

    if (docSnapshot.exists) {
      // Update existing dailyCalories field
      await userDoc.update({
        'dailyCalories': dailyCalories,
      });
    } else {
      // If the user document does not exist (which shouldn't happen), create it
      await userDoc.set({
        'dailyCalories': dailyCalories,
      }, SetOptions(merge: true));
    }
  } catch (e) {
    throw Exception('خطأ في تحديث السعرات الحرارية اليومية: $e');
  }
}



//**************************************************************FAVOURITE METHODS********************************************************* */
  /// Add recipe to favorites
  Future<void> addFavoriteRecipe(String recipeId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('هذا المستخدم غير مسجل في التطبيق');
      }
      final userDoc = _firestore.collection('users').doc(user.uid);
      // Add the recipeId to the 'favorites' array
      await userDoc.update({
        'favorites': FieldValue.arrayUnion([recipeId]),
      });
    } catch (e) {
      throw Exception('خطأ في اضافة الوصفة المفضلة: $e');
    }
  }

  /// Remove recipe from favorites
  Future<void> removeFavoriteRecipe(String recipeId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('هذا المستخدم غير مسجل في التطبيق');
      }
      final userDoc = _firestore.collection('users').doc(user.uid);
      // Remove the recipeId from the 'favorites' array
      await userDoc.update({
        'favorites': FieldValue.arrayRemove([recipeId]),
      });
    } catch (e) {
      throw Exception('خطأ في ازالة الوصفة من المفضلة: $e');
    }
  }

  /// Fetch user's favorite recipes
  Future<List<String>> getFavoriteRecipes() async {
  try {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('هذا المستخدم غير مسجل في التطبيق');
    }

    final userDoc = await _firestore.collection('users').doc(user.uid).get();

    if (userDoc.exists) {
      // Check if the "favorites" field exists in the document
      if (userDoc.data() != null && userDoc.data()!.containsKey('favorites')) {
        return List<String>.from(userDoc['favorites']);
      } else {
        return []; // Return an empty list if "favorites" does not exist
      }
    } else {
      return [];
    }
  } catch (e) {
    throw Exception('خطأ في الحصول علي الوصفات المفضلة: $e');
  }
}

  /// Fetch last 5 favourites
  Future<List<String>> getLast5FavoriteRecipes() async {
  try {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('هذا المستخدم غير مسجل في التطبيق');
    }

    final userDoc = await _firestore.collection('users').doc(user.uid).get();

    if (userDoc.exists) {
      // Safely retrieve the 'favorites' field
      List<String> allFavorites = [];
      if (userDoc.data() != null && userDoc['favorites'] != null) {
        allFavorites = List<String>.from(userDoc['favorites']);
      }

      // Return the last 5 favorites
      return allFavorites.reversed.take(5).toList();
    } else {
      return [];
    }
  } catch (e) {
    throw Exception('خطأ في الحصول علي الوصفات المفضلة: $e');
  }
}

  // **********************************************TIMED RECIPES**********************************************************

  Future<void> addTimedRecipe(
      String recipeId, String recipeName, DateTime? scheduledTime) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('هذا المستخدم غير مسجل في التطبيق');
      }

      final userDoc = _firestore.collection('users').doc(user.uid);

      // Create a new object containing the recipeId and the scheduledTime
      final newTimedRecipe = {
        'recipeId': recipeId,
        'resipeName': recipeName,
        'scheduledTime': scheduledTime,
      };

      // Add the new object to the 'timed_recipes' array
      await userDoc.update({
        'timed_recipes': FieldValue.arrayUnion([newTimedRecipe]),
      });
    } catch (e) {
      throw Exception('خطأ في اضافة الوصفة المجدولة: $e');
    }
  }

  // **********************************************GET UNSCHEDULED RECIPES*******************************************
  Future<List<Map<String, dynamic>>> getUnscheduledRecipes() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('هذا المستخدم غير مسجل في التطبيق');
      }

      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        // Retrieve all recipes where scheduledTime is null
        final timedRecipes =
            List<Map<String, dynamic>>.from(userDoc['timed_recipes'] ?? []);
        return timedRecipes
            .where((recipe) => recipe['scheduledTime'] == null)
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      throw Exception('خطأ في الحصول على الوصفات غير المجدولة: $e');
    }
  }

  // **********************************************GET RECIPES FOR A SPECIFIC DAY************************************
  Future<List<Map<String, dynamic>>> getRecipesForDay(DateTime day) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('هذا المستخدم غير مسجل في التطبيق');
      }

      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        final timedRecipes =
            List<Map<String, dynamic>>.from(userDoc['timed_recipes'] ?? []);
        final startOfDay = DateTime(day.year, day.month, day.day);
        final endOfDay = startOfDay.add(const Duration(days: 1));

        return timedRecipes.where((recipe) {
          final scheduledTime = recipe['scheduledTime'];
          if (scheduledTime == null) return false;
          /// String ==> int
          /// int.tryParse(String)
          /// int.parse(String)

          final parsedTime = DateTime.parse(scheduledTime);

          return (parsedTime.isAtSameMomentAs(startOfDay) ||
                  parsedTime.isAfter(startOfDay)) &&
              parsedTime.isBefore(endOfDay);
        }).toList()..sort((a, b) => DateTime.parse(a['scheduledTime']).compareTo(DateTime.parse(b['scheduledTime'])));
      } else {
        return [];
      }
    } catch (e) {
      throw Exception('خطأ في الحصول على الوصفات اليومية: $e');
    }
  }

  // **********************************************GET RECIPES FOR A SPECIFIC WEEK***********************************
  Future<List<Map<String, dynamic>>> getRecipesForWeek(
      DateTime weekStart) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('هذا المستخدم غير مسجل في التطبيق');
      }

      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        final timedRecipes =
            List<Map<String, dynamic>>.from(userDoc['timed_recipes'] ?? []);
        final endOfWeek = weekStart.add(const Duration(days: 7));

        return timedRecipes
            .where((recipe) =>
                recipe['scheduledTime'] != null &&
                DateTime.parse(recipe['scheduledTime']).isAfter(weekStart) &&
                DateTime.parse(recipe['scheduledTime']).isBefore(endOfWeek))
            .toList()..sort((a, b) => DateTime.parse(a['scheduledTime']).compareTo(DateTime.parse(b['scheduledTime'])));
      } else {
        return [];
      }
    } catch (e) {
      throw Exception('خطأ في الحصول على الوصفات الأسبوعية: $e');
    }
  }

  // **********************************************UPDATE RECIPE SCHEDULE********************************************
  Future<void> updateRecipeSchedule(
    String recipeId, DateTime scheduledTime) async {
  try {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('هذا المستخدم غير مسجل في التطبيق');
    }

    final userDoc = _firestore.collection('users').doc(user.uid);

    // Fetch the current user document
    final userData = await userDoc.get();
    if (!userData.exists) {
      throw Exception('المستخدم غير موجود');
    }

    // Get the current timed_recipes array
    final List<dynamic> timedRecipes = userData['timed_recipes'] ?? [];

    // Find the object with the given recipeId
    final index =
        timedRecipes.indexWhere((recipe) => recipe['recipeId'] == recipeId);
    if (index == -1) {
      throw Exception('الوصفة غير موجودة في القائمة المجدولة');
    }

    // Ensure `scheduledTime` includes both date and time
    DateTime fullScheduledTime = DateTime(
      scheduledTime.year,
      scheduledTime.month,
      scheduledTime.day,
      scheduledTime.hour,
      scheduledTime.minute,
      scheduledTime.second,
    );

    // Update the scheduled time for the specific recipe
    timedRecipes[index]['scheduledTime'] = fullScheduledTime.toIso8601String();

    // Update the timed_recipes array in Firestore
    await userDoc.update({
      'timed_recipes': timedRecipes,
    });
  } catch (e) {
    throw Exception('خطأ في تحديث جدول الوصفة: $e');
  }
}


  // **********************************************REMOVE TIMED RECIPE***********************************************
  Future<void> removeTimedRecipe(String recipeId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('هذا المستخدم غير مسجل في التطبيق');
      }

      final userDoc = _firestore.collection('users').doc(user.uid);

      // Fetch the current user document
      final userData = await userDoc.get();
      if (!userData.exists) {
        throw Exception('المستخدم غير موجود');
      }

      // Get the current timed_recipes array
      final List<dynamic> timedRecipes = userData['timed_recipes'] ?? [];

      // Find the object that contains the recipeId
      final recipeToRemove = timedRecipes.firstWhere(
        (recipe) => recipe['recipeId'] == recipeId,
      );

      if (recipeToRemove == null) {
        throw Exception('الوصفة غير موجودة في القائمة المجدولة');
      }

      // Remove the recipe from the array
      await userDoc.update({
        'timed_recipes': FieldValue.arrayRemove([recipeToRemove]),
      });
    } catch (e) {
      throw Exception('خطأ في إزالة الوصفة من القائمة المجدولة: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getTimedRecipes() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('هذا المستخدم غير مسجل في التطبيق');
      }

      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        // Retrieve the 'timed_recipes' array
        final timedRecipes =
            List<Map<String, dynamic>>.from(userDoc['timed_recipes'] ?? []);
        return timedRecipes;
      } else {
        return [];
      }
    } catch (e) {
      throw Exception('خطأ في الحصول على الوصفات المجدولة: $e');
    }
  }

  // **********************************************GET RECIPES************************************************************
  Future<List<Recipe>> getAllRecipes() async {
  try {
    List<Recipe> recipes = [];
    var recipesSnapshot = await _firestore.collection('recipes').get();

    for (var doc in recipesSnapshot.docs) {
      if (doc.exists) {
        try {
          var recipeMap = doc.data();

          // Validate and parse the recipe data
          recipes.add(Recipe.fromJson(recipeMap));
                } catch (e) {
          debugPrint("Error parsing recipe document: ${doc.id}, Error: $e");
        }
      }
    }
    return recipes;
  } catch (e) {
    throw Exception("خطأ في الحصول علي الوصفات: ${e.toString()}");
  }
}


  // Fetch a recipe by its ID
  Future<Recipe?> getRecipeById(String recipeId) async {
    try {
      // Fetch the document with the specified ID
      var doc = await _firestore.collection('recipes').doc(recipeId).get();

      if (doc.exists) {
        // Convert the document data to a Recipe object
        return Recipe.fromJson(doc.data()!);
      } else {
        return null;
      }
    } catch (e) {
      throw Exception("خطأ في الحصول علي الوصفة: ${e.toString()}");
    }
  }
}
