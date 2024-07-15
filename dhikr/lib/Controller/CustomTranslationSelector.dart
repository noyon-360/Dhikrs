import 'package:flutter/material.dart';

class CustomTranslationSelector extends StatelessWidget {
  final bool isEnglishSelected;
  final VoidCallback onEnglishSelected;
  final VoidCallback onBanglaSelected;

  const CustomTranslationSelector({
    super.key,
    required this.isEnglishSelected,
    required this.onEnglishSelected,
    required this.onBanglaSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEnglishSelected ? onBanglaSelected : onEnglishSelected,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 60,
        height: 30,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.green.shade200,
        ),
        child: Stack(
          alignment:
              isEnglishSelected ? Alignment.centerLeft : Alignment.centerRight,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 30,
                  alignment: Alignment.center,
                  child: Text(
                    'EN',
                    style: TextStyle(
                      color: isEnglishSelected
                          ? Colors.green.shade200
                          : Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                Container(
                  width: 30,
                  alignment: Alignment.center,
                  child: Text(
                    'BN',
                    style: TextStyle(
                      color: isEnglishSelected
                          ? Colors.black
                          : Colors.green.shade200,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            AnimatedAlign(
              duration: const Duration(milliseconds: 300),
              alignment: isEnglishSelected
                  ? Alignment.centerLeft
                  : Alignment.centerRight,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: Colors.green.shade700,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.translate,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
