import 'package:sukri/core/utils/app_colors.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class MostPrevalentButton extends StatelessWidget {
  double width;
  void Function()? onPressed;
  String txt;
  MostPrevalentButton(
      {super.key,
      required this.width,
      required this.onPressed,
      required this.txt, required Color backgroundColor});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: FitnessColors.buttonsColor, // لون الزرار
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // مقدار الاستدارة
          ),
          minimumSize: const Size(double.infinity, 50), // الديفولت للنص اللي داخل الزرار
        ),
        child: Text(
          txt,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}