import 'package:sukri/view/widgets/mostPrevlentButton.dart';
import 'package:sukri/view%20model/auth_controller.dart';
import 'package:flutter/material.dart';
import '../../../../core/utils/app_colors.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthController _authController = AuthController();

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
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'إنشاء حساب',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 40),
                  buildInputField(
                    hintText: 'الاسم الأول',
                    controller: _authController.firstNameController,
                  ),
                  buildInputField(
                    hintText: 'الاسم الأخير',
                    controller: _authController.lastNameController,
                  ),
                  buildInputField(
                    hintText: 'اسم المستخدم',
                    controller: _authController.usernameController,
                  ),
                  buildInputField(
                    hintText: 'البريد الإلكتروني',
                    controller: _authController.emailController,
                    isEmail: true, // Set email validation
                  ),
                  buildInputField(
                    hintText: 'كلمة المرور',
                    controller: _authController.passwordController,
                    obscureText: true,
                    isPassword: true, // Set password validation
                  ),
                  const SizedBox(height: 30),
                  ValueListenableBuilder<bool>(
                    valueListenable: _authController.isLoading,
                    builder: (context, isLoading, _) {
                      return MostPrevalentButton(
                        width: double.infinity,
                        onPressed: isLoading
                            ? null
                            : () {
                                if (_formKey.currentState!.validate()) {
                                  _authController.createAccount(
                                    context: context,
                                    firstName: _authController
                                        .firstNameController.text
                                        .trim(),
                                    lastName: _authController
                                        .lastNameController.text
                                        .trim(),
                                    username: _authController
                                        .usernameController.text
                                        .trim(),
                                    email: _authController.emailController.text
                                        .trim(),
                                    password: _authController
                                        .passwordController.text
                                        .trim(),
                                  );
                                }
                              },
                        txt: 'حساب جديد',
                        backgroundColor: isLoading
                            ? Colors.grey
                            : FitnessColors.buttonsColor,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// **Reusable Input Field with Validation**
  Widget buildInputField({
    required String hintText,
    required TextEditingController controller,
    bool obscureText = false,
    bool isEmail = false,
    bool isPassword = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'من فضلك أدخل $hintText';
          }
          if (isEmail) {
            final emailRegex =
                RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
            if (!emailRegex.hasMatch(value)) {
              return 'يرجى إدخال بريد إلكتروني صالح';
            }
          }
          if (isPassword) {
            if (value.length < 6) {
              return 'يجب أن تحتوي كلمة المرور على 6 أحرف على الأقل';
            }
          }
          return null;
        },
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
