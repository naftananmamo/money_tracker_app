import 'package:flutter/material.dart';

class SectionCard extends StatelessWidget {
  final String title;
  final Color cardColor;
  final Color mainColor;
  final Widget content;
  final Widget? headerAction;

  const SectionCard({
    super.key,
    required this.title,
    required this.cardColor,
    required this.mainColor,
    required this.content,
    this.headerAction,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: cardColor,
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title, 
                  style: TextStyle(
                    fontSize: 20, 
                    fontWeight: FontWeight.bold, 
                    color: mainColor
                  )
                ),
                if (headerAction != null) headerAction!,
              ],
            ),
            const SizedBox(height: 16),
            content,
          ],
        ),
      ),
    );
  }
}
