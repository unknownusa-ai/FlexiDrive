// Flutter framework
import 'package:flutter/material.dart';

// Widget reutilizable para cada pestaña de filtros en la pantalla de notificaciones
// Muestra una pestaña seleccionable con estilo personalizado
class ChipPestanaNotificaciones extends StatelessWidget {
  // Constructor con parámetros requeridos
  const ChipPestanaNotificaciones({
    super.key,
    required this.label, // Texto de la pestaña
    required this.isSelected, // Si está seleccionada actualmente
    required this.onTap, // Función al hacer tap
    this.leading, // Widget opcional al inicio
  });

  // Texto que muestra la pestaña
  final String label;
  // Indica si la pestaña está seleccionada
  final bool isSelected;
  // Acción a ejecutar al presionar la pestaña
  final VoidCallback onTap;
  // Widget opcional antes del texto (icono, etc)
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
