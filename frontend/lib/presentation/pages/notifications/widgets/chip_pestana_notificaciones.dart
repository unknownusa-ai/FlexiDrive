import 'package:flutter/material.dart';

// Widget reutilizable para cada pestaña de filtros en la pantalla de notificaciones.
class ChipPestanaNotificaciones extends StatelessWidget {
  const ChipPestanaNotificaciones({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.leading,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF5B6FED) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leading != null) ...[
              leading!,
              SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade600,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}