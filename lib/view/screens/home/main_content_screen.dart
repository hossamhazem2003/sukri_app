import 'package:sukri/core/utils/app_colors.dart';
import 'package:sukri/view/screens/home/home_tab.dart';
import 'package:sukri/view/screens/home/profile_tab.dart';
import 'package:sukri/view/screens/home/search_tab.dart';
import 'package:sukri/view%20model/main_controller.dart';
import 'package:flutter/material.dart';

class MainContentScreen extends StatefulWidget {
  const MainContentScreen({super.key});

  @override
  _MainContentScreenState createState() => _MainContentScreenState();
}

class _MainContentScreenState extends State<MainContentScreen> {
  int _selectedIndex = 1; // Set default to Home tab
  late final MainTabsController _mainController;
@override
  void initState() {
    super.initState();
    _mainController = MainTabsController(context);
  }
  @override
  void dispose() {
    _mainController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: FitnessColors.baseAppColor,
          elevation: 0,
          leading: Container(),
        ),
        backgroundColor: FitnessColors.baseAppColor,
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            ProfileTab(controller: _mainController),
            HomeTab(controller: _mainController),
            RecipeSearchTab(controller: _mainController),
          ],
        ),
        bottomNavigationBar: buildBottomNavigationBar(),
      ),
    );
  }

  Widget buildBottomNavigationBar() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          buildNavItem(Icons.person, 0), // Profile
          buildNavItem(Icons.home, 1), // Home
          buildNavItem(Icons.search, 2), // Search
        ],
      ),
    );
  }

  Widget buildNavItem(IconData icon, int index) {
    bool isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding:
            EdgeInsets.symmetric(vertical: 5, horizontal: isSelected ? 10 : 5),
        decoration: BoxDecoration(
          color:
              isSelected ? FitnessColors.arrowBackButton : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(icon,
            color: isSelected
                ? FitnessColors.buttonsColor
                : FitnessColors.arrowBackButton,
            size: 28),
      ),
    );
  }
}
