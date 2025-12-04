// widgets/primary_button.dart
import 'package:flutter/material.dart';

class PrimaryButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onPressed;
  final bool filled; // true = botón turquesa sólido, false = borde turquesa

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.filled = true,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final Color base = colorScheme.primary;
    final Color pressed = base.withOpacity(0.8);

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _pressed = true);
      },
      onTapCancel: () {
        setState(() => _pressed = false);
      },
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onPressed();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: widget.filled
              ? (_pressed ? pressed : base)
              : (_pressed ? base.withOpacity(0.06) : Colors.transparent),
          borderRadius: BorderRadius.circular(30),
          border: widget.filled
              ? null
              : Border.all(color: base, width: 1.5),
          boxShadow: widget.filled
              ? [
                  BoxShadow(
                    color: base.withOpacity(0.20),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.icon != null) ...[
              Icon(
                widget.icon,
                size: 18,
                color:
                    widget.filled ? colorScheme.onPrimary : base,
              ),
              const SizedBox(width: 8),
            ],
            Text(
              widget.label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color:
                    widget.filled ? colorScheme.onPrimary : base,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
