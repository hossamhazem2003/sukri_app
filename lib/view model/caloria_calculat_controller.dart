import 'package:flutter/material.dart';
import 'package:sukri/model/data/firebase_services.dart';

class CalorieCalculatorController {
  final FirebaseServices firebaseServices = FirebaseServices();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  ValueNotifier<String?> selectedGender = ValueNotifier<String?>(null);
  ValueNotifier<String?> activityLevel = ValueNotifier<String?>(null);
  ValueNotifier<String?> calorieResult = ValueNotifier<String?>(null);
  ValueNotifier<bool> isLoading = ValueNotifier<bool>(false); // Track loading

  /// Calculate daily calorie requirement and save to Firestore
  Future<void> calculateAndSaveCalories() async {
    isLoading.value = true; // Start loading
    final String? gender = selectedGender.value;
    final String? activity = activityLevel.value;

    if (weightController.text.isEmpty ||
        heightController.text.isEmpty ||
        ageController.text.isEmpty ||
        gender == null ||
        activity == null) {
      calorieResult.value = 'من فضلك أدخل كل البيانات';
      isLoading.value = false;
      return;
    }

    final double weight = double.tryParse(weightController.text) ?? 0;
    final double height = double.tryParse(heightController.text) ?? 0;
    final int age = int.tryParse(ageController.text) ?? 0;

    double bmr;
    if (gender == 'male') {
      bmr = 88.36 + (13.4 * weight) + (4.8 * height) - (5.7 * age);
    } else {
      bmr = 447.6 + (9.2 * weight) + (3.1 * height) - (4.3 * age);
    }

    double totalCalories = bmr * _getActivityFactor(activity);
    calorieResult.value =
        'تم تحديث احتياجاتك اليومية من السعرات الحرارية بنجاح: ${totalCalories.toStringAsFixed(2)}';

    // Save to Firestore
    final user = await firebaseServices.getCurrentUser();
    if (user != null) {
      try {
        await firebaseServices.updateUserDailyCalories(user.id, totalCalories);
      } catch (e) {
        calorieResult.value = e.toString();
        isLoading.value = false;
        return;
      }
    }

    isLoading.value = false; // Stop loading
  }

  /// Get activity factor based on selected activity level
  double _getActivityFactor(String activity) {
    switch (activity) {
      case 'sedentary':
        return 1.2;
      case 'light':
        return 1.375;
      case 'moderate':
        return 1.55;
      case 'high':
        return 1.725;
      case 'very_high':
        return 1.9;
      default:
        return 1.2;
    }
  }

  void disposeControllers() {
    weightController.dispose();
    heightController.dispose();
    ageController.dispose();
    selectedGender.dispose();
    activityLevel.dispose();
    calorieResult.dispose();
    isLoading.dispose();
  }
}
