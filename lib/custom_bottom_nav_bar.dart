// custom_bottom_nav_bar.dart
import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomBottomNavBar({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(
            icon: Icons.home,
            index: 0,
            isSelected: selectedIndex == 0,
            isBlueCircle: true,
          ),
          _buildNavItem(
            icon: Icons.medical_services,
            index: 1,
            isSelected: selectedIndex == 1,
            isBlueCircle: true,
          ),
          _buildNavItem(
            icon: Icons.science,
            index: 2,
            isSelected: selectedIndex == 2,
            isBlueCircle: true,
          ),
          _buildNavItem(
            icon: Icons.description,
            index: 3,
            isSelected: selectedIndex == 3,
            isBlueCircle: true,
          ),
          _buildNavItem(
            icon: Icons.person,
            index: 4,
            isSelected: selectedIndex == 4,
            isBlueCircle: true,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required int index,
    required bool isSelected,
    required bool isBlueCircle,
  }) {
    return GestureDetector(
      onTap: () => onItemTapped(index),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : const Color(0xFF0288D1),
          shape: BoxShape.circle,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      // spreadRadius: 1,
                      blurRadius: 3,
                      offset: const Offset(2, 3),
                    ),
                  ]
                : null,
          ),
          child: Icon(
            icon,
            color: isSelected ? const Color(0xFF0288D1) : Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }
}
