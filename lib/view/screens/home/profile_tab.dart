// ignore_for_file: use_build_context_synchronously

import 'package:sukri/core/utils/app_colors.dart';
import 'package:sukri/model/models/user_model.dart';
import 'package:sukri/view/screens/favourie/favourit_screen.dart';
import 'package:sukri/view/widgets/mostPrevlentButton.dart';
import 'package:sukri/view%20model/main_controller.dart';
import 'package:flutter/material.dart';

class ProfileTab extends StatefulWidget {
  final MainTabsController controller;
  const ProfileTab({super.key, required this.controller});

  @override
  // ignore: library_private_types_in_public_api
  _ProfileTabState createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  bool _isPasswordVisible = false; // Toggle password visibility

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();

    // Load user data into fields
    widget.controller.currentUser.addListener(() {
      final user = widget.controller.currentUser.value;
      if (user != null) {
        setState(() {
          _firstNameController.text = user.firstName;
          _lastNameController.text = user.lastName;
          _passwordController.text = user.password;
        });
      }
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    setState(() {
      _isUpdating = true;
    });

    try {
      await widget.controller.updateUser(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        password: _passwordController.text.isNotEmpty
            ? _passwordController.text
            : null, // Only update password if provided
      );
      await widget.controller
          .fetchCurrentUser(); // Ensure UI updates with the latest data
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تحديث البيانات بنجاح')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء تحديث البيانات: $e')),
      );
    } finally {
      setState(() {
        _isUpdating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // Right-to-left layout
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'بيانات الحساب',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ValueListenableBuilder<User?>(
                valueListenable: widget.controller.currentUser,
                builder: (context, user, _) {
                  if (user == null) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: FitnessColors.buttonsColor,
                      ),
                    );
                  }
                  return Column(
                    children: [
                      buildProfileField(
                        icon: Icons.abc,
                        label: "الاسم الأول",
                        controller: _firstNameController,
                      ),
                      const SizedBox(height: 16),
                      buildProfileField(
                        icon: Icons.abc_outlined,
                        label: "الاسم الأخير",
                        controller: _lastNameController,
                      ),
                      const SizedBox(height: 16),
                      buildProfileField(
                        icon: Icons.person,
                        label: "اسم المستخدم",
                        controller: TextEditingController(text: user.username),
                        isReadOnly: true,
                      ),
                      const SizedBox(height: 16),
                      buildProfileField(
                        icon: Icons.email,
                        label: "البريد الالكتروني",
                        controller: TextEditingController(text: user.email),
                        isReadOnly: true,
                      ),
                      const SizedBox(height: 16),
                      buildProfileField(
                        icon: Icons.lock,
                        label: "كلمة المرور",
                        controller: _passwordController,
                        isPassword: true,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 32),

              // Update Profile Button
              MostPrevalentButton(
                width: double.infinity,
                onPressed: _isUpdating ? null : _updateProfile,
                txt: _isUpdating ? 'جاري التحديث...' : 'تحديث البيانات',
                backgroundColor:
                    _isUpdating ? Colors.grey : FitnessColors.buttonsColor,
              ),
              const SizedBox(height: 16),
              // Go to favourite screen
              MostPrevalentButton(
                width: double.infinity,
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_)=> FavouritScreen()));
                },
                txt: "الذهاب للمفضلة",
                backgroundColor: FitnessColors.buttonsColor,
              ),
              const SizedBox(height: 16),
              // Logout Button
              MostPrevalentButton(
                width: double.infinity,
                onPressed: () async {
                  await widget.controller.logout(context);
                },
                txt: 'تسجيل الخروج',
                backgroundColor: FitnessColors.buttonsColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildProfileField({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    bool isReadOnly = false,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          readOnly: isReadOnly,
          obscureText: isPassword && !_isPasswordVisible,
          textAlign: TextAlign.start,
          style: TextStyle(
              fontSize: 16, color: isReadOnly ? Colors.grey : Colors.black),
          decoration: InputDecoration(
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.pink[200],
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  )
                : null,
            prefixIcon: Icon(icon, color: Colors.pink),
            hintText: label,
            hintStyle: const TextStyle(color: Colors.black54),
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
