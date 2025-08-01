import 'package:flutter/material.dart';

class CategoryManagerHoverArrow extends StatefulWidget {
  final Color mainColor;
  const CategoryManagerHoverArrow({super.key, required this.mainColor});

  @override
  State<CategoryManagerHoverArrow> createState() => _CategoryManagerHoverArrowState();
}

class _CategoryManagerHoverArrowState extends State<CategoryManagerHoverArrow> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: Row(
        children: [
          Icon(Icons.arrow_forward_ios, color: widget.mainColor, size: 28),
          AnimatedOpacity(
            opacity: _hovering ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: Padding(
              padding: const EdgeInsets.only(left: 6.0),
              child: Text('Category Manager', style: TextStyle(fontWeight: FontWeight.bold, color: widget.mainColor)),
            ),
          ),
        ],
      ),
    );
  }
}

class AbiyeCategoryHoverButton extends StatefulWidget {
  final VoidCallback onHover;
  final Color mainColor;
  const AbiyeCategoryHoverButton({super.key, required this.onHover, required this.mainColor});

  @override
  State<AbiyeCategoryHoverButton> createState() => _AbiyeCategoryHoverButtonState();
}

class _AbiyeCategoryHoverButtonState extends State<AbiyeCategoryHoverButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _hovering = true);
        widget.onHover();
      },
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: _hovering ? widget.mainColor.withOpacity(0.18) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(Icons.arrow_forward_ios, color: widget.mainColor, size: 28),
      ),
    );
  }
}
