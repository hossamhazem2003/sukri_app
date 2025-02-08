import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sukri/core/routes/app_routes.dart';
import 'package:sukri/model/data/firebase_services.dart';
import 'package:sukri/view/screens/auth/otp_screen.dart';

class AuthController {
  final FirebaseServices _firebaseServices = FirebaseServices();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String? email; // Store user's email for verification
  String? generatedOtp; // Temporary store for the generated OTP

  // State management
  ValueNotifier<bool> isLoading = ValueNotifier(false);

  /// Step 1: Send OTP to Email
  Future<void> sendOtpEmail(String recipientEmail, String otp) async {
    const serviceId = 'service_t7xjf2g'; // Replace with your EmailJS service ID
    const templateId =
        'template_ndbyxvx'; // Replace with your EmailJS template ID
    const publicKey =
        'nUO5h3q5mKAY-74y3'; // Replace with your EmailJS public key

    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');

    try {
      final response = await http.post(
        url,
        headers: {
          'origin': 'http://localhost',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'service_id': serviceId,
          'template_id': templateId,
          'user_id': publicKey,
          'template_params': {
            'otp': otp,
            'user_email': recipientEmail,
          },
        }),
      );

      if (response.statusCode == 200) {
        print('✅ تم ارسال رمز التحقق الي $recipientEmail');
        email = recipientEmail;
        generatedOtp = otp; // Store the OTP for verification
      } else {
        print('❌ فشل ارسال رمز التحقق: ${response.body}');
      }
    } catch (e) {
      print('❌ خطأ في ارسال رمز التحقق: $e');
    }
  }

  /// Step 2: Verify OTP
  Future<bool> verifyOtp(String otp) async {
    if (generatedOtp == null) {
      print('❌ No OTP was generated to verify against.');
      return false;
    }
    if (otp == generatedOtp) {
      print('✅ OTP verification successful.');
      return true;
    } else {
      print('❌ OTP verification failed.');
      return false;
    }
  }

  /// Step 3: Generate OTP
  String generateOtp() {
    final random = Random();
    return List.generate(4, (index) => random.nextInt(10)).join();
  }

  /// Step 4: Create Account After OTP Verification
  Future<void> createAccount({
    required BuildContext context,
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String password,
  }) async {
    isLoading.value = true;
    try {
      // 1. Send OTP to the user's email
      final otp = generateOtp();
      await sendOtpEmail(email, otp);
      // 2. Navigate to OTP verification screen
      bool isVerified = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OtpVerificationScreen(
            email: email,
            onVerifyOtp: verifyOtp,
          ),
        ),
      );
      if (!isVerified) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فشل التحقق من رمز OTP')),
        );
        return;
      }
      // 3. OTP verified, proceed to create the account
      await _firebaseServices.createAccount(
        firstName: firstName,
        lastName: lastName,
        username: username,
        email: email,
        password: password,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إنشاء الحساب بنجاح')),
      );

      // 4. Navigate to main app screen or login
      Navigator.pushReplacementNamed(context, AppRoutes.mainContentScreen);
    } catch (e) {
      debugPrint(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ: ${e.toString()}')),
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Login an existing user
  Future<void> login({
    required BuildContext context,
    required String username,
    required String password,
  }) async {
    isLoading.value = true;
    try {
      // Use the FirebaseServices method to authenticate the user
      await _firebaseServices.login(username: username, password: password);

      // Navigate to the main content screen upon successful login
      Navigator.pushNamed(context, AppRoutes.mainContentScreen);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تسجيل الدخول بنجاح')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ: ${e.toString()}')),
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Cleanup resources
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    isLoading.dispose();
  }
}
