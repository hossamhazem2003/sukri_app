class FitnessAssets {
  static const String calc = 'assets/images/calc.jpg';
  static const String clock = 'assets/images/clock.jpg';
  static const String food = 'assets/images/food.jpg';
  static const String report = 'assets/images/report.jpg';
  static const String person = 'assets/images/R.png';
}

String formatNumber(double number) {
  return number % 1 == 0 ? number.toInt().toString() : number.toStringAsFixed(2);
}
