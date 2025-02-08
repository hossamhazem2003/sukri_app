import 'package:sukri/view/widgets/mostPrevlentButton.dart';
import 'package:sukri/view%20model/auth_controller.dart';
import 'package:flutter/material.dart';
import '../../../../core/utils/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthController _authController = AuthController();

  // Input controllers
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: FitnessColors.baseAppColor,
        appBar: AppBar(
          backgroundColor: FitnessColors.baseAppColor,
          elevation: 0,
          leading: Container(),
          actions: [
            IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: FitnessColors.arrowBackButton,
                textDirection: TextDirection.ltr,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'تسجيل الدخول',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 40),
                    buildInputField(
                      hintText: 'اسم المستخدم',
                      controller: _usernameController,
                    ),
                    buildInputField(
                      hintText: 'كلمة المرور',
                      controller: _passwordController,
                      obscureText: true,
                    ),
                    const SizedBox(height: 30),
                    ValueListenableBuilder<bool>(
                      valueListenable: _authController.isLoading,
                      builder: (context, isLoading, _) {
                        return MostPrevalentButton(width: double.infinity, onPressed:  isLoading
                              ? null
                              : () {
                                  if (_formKey.currentState!.validate()) {
                                  // يبقا الميثود دي مستدعيها منين؟!
                                  // من الكونترولر طبعا لاننا في كود الديزاين بنستدعي الميثودز بتاعتنا من الكونترولر الخاص بعمليات تسجل الدخول مش من السيرفس الخاص بالداتا
                                    _authController.login(
                                      context: context,
                                      username: _usernameController.text.trim(),
                                      password: _passwordController.text.trim(),
                                    );
                                  }
                                }, txt: isLoading? 'جار التسجيل...': 'تسجيل الدخول',backgroundColor:isLoading? Colors.grey:FitnessColors.buttonsColor);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildInputField({
    required String hintText,
    required TextEditingController controller,
    bool obscureText = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hintText,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
