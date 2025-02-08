import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sukri/core/routes/app_routes.dart';
import 'package:sukri/view/screens/auth/create_account_screen.dart';
import 'package:sukri/view/screens/auth/login_screen.dart';
import 'package:sukri/view/screens/auth/opening_screen.dart';
import 'package:sukri/view/screens/auth/otp_screen.dart';
import 'package:sukri/view/screens/calorie%20calculation/calorie_calculation_screen.dart';
import 'package:sukri/view/screens/home/main_content_screen.dart';
import 'package:sukri/view/screens/recipe%20details/recipe_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:sukri/view/screens/timed%20recipes/timed_recipes_screen.dart';
import 'firebase_options.dart';
import 'package:intl/date_symbol_data_local.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initializeDateFormatting('ar_SA', null); // Initialize Arabic locale formatting
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sukri App',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const AuthChecker(),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case AppRoutes.openingScreen:
            return MaterialPageRoute(
                builder: (_) => const OpeningScreen());
          case AppRoutes.createAccountScreen:
            return MaterialPageRoute(
                builder: (_) => const CreateAccountScreen());
          case AppRoutes.loginScreen:
            return MaterialPageRoute(builder: (_) => const LoginScreen());
          case AppRoutes.otpScreen:
            return MaterialPageRoute(
                builder: (_) => const OtpVerificationScreen());
          case AppRoutes.mainContentScreen:
            return MaterialPageRoute(builder: (_) => const MainContentScreen());
          case AppRoutes.recipeDetailsScreen:
            return MaterialPageRoute(
                builder: (_) => const RecipeDetailsScreen());
          case AppRoutes.calorieCalculationScreen:
            return MaterialPageRoute(
                builder: (_) => const CalorieCalculatorScreen());
          case AppRoutes.timedRecipeScreen:
            return MaterialPageRoute(
                builder: (_) => TimedRecipesScreen());
          default:
            return null;
        }
      },
    );
  }
}

class AuthChecker extends StatelessWidget {
  const AuthChecker({super.key});

  @override
  Widget build(BuildContext context) {
    // Check if the user is already logged in
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      // User is logged in, redirect to the main content screen
      return const MainContentScreen();
    } else {
      // User is not logged in, show the opening screen
      return const OpeningScreen();
    }
  }
}
