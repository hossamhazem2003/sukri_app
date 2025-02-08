import 'package:sukri/core/routes/app_routes.dart';
import 'package:sukri/core/utils/app_colors.dart';
import 'package:sukri/view/widgets/mostPrevlentButton.dart';
import 'package:flutter/material.dart';

class OpeningScreen extends StatelessWidget {
  const OpeningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FitnessColors.baseAppColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.asset(
              'assets/images/sokary.jpg',
              height: MediaQuery.of(context).size.height / 1.5,
              width: double.infinity,
              fit: BoxFit.fill,
            ),
            const SizedBox(height: 20),
            MostPrevalentButton(
                width: MediaQuery.of(context).size.width / 2,
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.createAccountScreen);
                },
                txt: 'انشاء حساب',
                backgroundColor:FitnessColors.buttonsColor),
            const SizedBox(height: 20),
            MostPrevalentButton(
              width: MediaQuery.of(context).size.width / 2,
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.loginScreen);
              },
              txt: 'تسجيل الدخول',
              backgroundColor:FitnessColors.buttonsColor
            ),
          ],
        ),
      ),
    );
  }
}

