import 'package:flutter/material.dart';
import 'color_constants.dart'; // Ensure this includes AppColors.primaryColor and AppColors.prymaryDarkClr

class CustomSegmentedTabBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabChanged;
  final List<String> tabs;

  const CustomSegmentedTabBar({
    Key? key,
    required this.selectedIndex,
    required this.onTabChanged,
    required this.tabs,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(tabs.length, (index) {
          final bool isSelected = index == selectedIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTabChanged(index),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: isSelected ? primaryColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    tabs[index],
                    style: TextStyle(
                      fontSize: width * 0.034, // Responsive font size
                      fontWeight: FontWeight.w600,
                      fontFamily: "Roboto",
                      color: isSelected ? Colors.white : secondaryColor,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis, // Handle long text
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}