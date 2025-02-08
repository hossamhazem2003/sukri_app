import 'dart:async';

import 'package:sukri/core/utils/app_colors.dart';
import 'package:sukri/view%20model/auth_controller.dart';
import 'package:flutter/material.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String? email; // Pass the user's email to this screen
  final Future<bool> Function(String otp)? onVerifyOtp; // Callback to verify OTP

  const OtpVerificationScreen({
    super.key,
    this.email,
    this.onVerifyOtp,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<FocusNode> _focusNodes = List.generate(4, (index) => FocusNode());
  final List<TextEditingController> _otpControllers =
      List.generate(4, (index) => TextEditingController());
  AuthController authController = AuthController();
  bool isVerifying = false;

  @override
  void initState() {
    super.initState();
    authController.sendOtpEmail;
  }

  Future<void> _verifyOtp() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isVerifying = true;
      });

      String otp = _otpControllers.map((controller) => controller.text).join();

      try {
        // Call the provided onVerifyOtp callback
        bool isValid = await widget.onVerifyOtp!(otp);

        if (isValid) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم التحقق من الرمز بنجاح!')),
          );

          // Pass back the success to the caller
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('رمز التحقق خاطئ.')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to verify OTP: ${e.toString()}')),
        );
      } finally {
        setState(() {
          isVerifying = false;
        });
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  Widget _buildOtpField({required int index}) {
    return SizedBox(
      width: 50,
      height: 60,
      child: TextFormField(
        controller: _otpControllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        decoration: InputDecoration(
          counterText: "",
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.grey),
          ),
        ),
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        onChanged: (value) {
          if (value.isNotEmpty) {
            if (index < _otpControllers.length - 1) {
              FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
            } else {
              FocusScope.of(context).unfocus();
            }
          }
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '';
          }
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FitnessColors.baseAppColor,
      appBar: AppBar(
        backgroundColor: FitnessColors.baseAppColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: FitnessColors.arrowBackButton,
            textDirection: TextDirection.ltr,
          ),
          onPressed: () {
            Navigator.pop(context, false); // Return false if back button is pressed
          },
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'رمز التحقق',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'تم ارسال رمز تحقق على البريد الإلكتروني',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 40),
                Form(
                  key: _formKey,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(
                      4,
                      (index) => _buildOtpField(index: index),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isVerifying ? null : _verifyOtp,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      backgroundColor: FitnessColors.buttonsColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      isVerifying ? 'جاري التحقق...' : 'تحقق',
                      style: const TextStyle(fontWeight: FontWeight.bold,color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
