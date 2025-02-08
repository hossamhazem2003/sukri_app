import 'package:flutter/material.dart';
import 'package:sukri/core/utils/app_colors.dart';
import 'package:sukri/view%20model/caloria_calculat_controller.dart';
import 'package:sukri/view/widgets/mostPrevlentButton.dart';

class CalorieCalculatorScreen extends StatefulWidget {
  const CalorieCalculatorScreen({super.key});

  @override
  _CalorieCalculatorScreenState createState() =>
      _CalorieCalculatorScreenState();
}

class _CalorieCalculatorScreenState extends State<CalorieCalculatorScreen> {
  final CalorieCalculatorController calorieCalculatorController =
      CalorieCalculatorController();

  @override
  void dispose() {
    calorieCalculatorController.disposeControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: FitnessColors.baseAppColor, // Pinkish background
        appBar: AppBar(
          backgroundColor: FitnessColors.baseAppColor,
          elevation: 0,
          centerTitle: true,
          leading: Container(),
          actions: [
            IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: FitnessColors.arrowBackButton,
                textDirection: TextDirection.ltr,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'حساب السعرات',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const Text(
                  'الحرارية اليومية',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w400,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 30),
                // Weight Input
                TextField(
                  controller: calorieCalculatorController.weightController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'الوزن',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide:
                            BorderSide(color: FitnessColors.buttonsColor)),
                  ),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 15),
                // Height Input
                TextField(
                  controller: calorieCalculatorController.heightController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'طول',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide:
                            BorderSide(color: FitnessColors.buttonsColor)),
                  ),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 15),
                // Age Input
                TextField(
                  controller: calorieCalculatorController.ageController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'العمر',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide:
                            BorderSide(color: FitnessColors.buttonsColor)),
                  ),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 15),
                // Gender Selection
                const Text(
                  'الجنس',
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('ذكر'),
                        value: 'male',
                        groupValue:
                            calorieCalculatorController.selectedGender.value,
                        onChanged: (value) {
                          // value = male
                          setState(() {
                            calorieCalculatorController.selectedGender.value =
                                value;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('أنثى'),
                        value: 'female',
                        groupValue:
                            calorieCalculatorController.selectedGender.value,
                        onChanged: (value) {
                          setState(() {
                            calorieCalculatorController.selectedGender.value =
                                value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Activity Level Selection
                const Text(
                  'درجة النشاط',
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: calorieCalculatorController.activityLevel.value,
                  items: const [
                    DropdownMenuItem(
                      value: 'sedentary',
                      child: Text('نشاط منخفض'),
                    ),
                    DropdownMenuItem(
                      value: 'light',
                      child: Text('نشاط خفيف'),
                    ),
                    DropdownMenuItem(
                      value: 'moderate',
                      child: Text('نشاط متوسط'),
                    ),
                    DropdownMenuItem(
                      value: 'high',
                      child: Text('نشاط عالي'),
                    ),
                    DropdownMenuItem(
                      value: 'very_high',
                      child: Text('نشاط عالي جداً'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      calorieCalculatorController.activityLevel.value = value;
                    });
                  },
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(),
                  ),
                  hint: const Text('اختر درجة النشاط'),
                ),
                const SizedBox(height: 20),
                // Calculate Button
                ValueListenableBuilder<bool>(
                  valueListenable: calorieCalculatorController.isLoading,
                  builder: (context, isLoading, _) {
                    return MostPrevalentButton(
                        width: double.infinity,
                        onPressed: isLoading
                            ? null
                            : () => calorieCalculatorController
                                .calculateAndSaveCalories(),
                        txt: isLoading ? 'جار الحساب...' : 'حساب',
                        backgroundColor: isLoading
                            ? Colors.grey
                            : FitnessColors.buttonsColor);
                  },
                ),
                const SizedBox(height: 20),
                  ValueListenableBuilder<String?>(
                    valueListenable: calorieCalculatorController.calorieResult,
                    builder: (context, calorieResult, _) {
                      return Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: Text(
                          calorieResult ??
                              "لم يتم الحساب بعد",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
