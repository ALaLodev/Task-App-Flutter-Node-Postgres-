import 'package:flutter/material.dart';
import 'package:frontend/core/utils/date_utils.dart';
import 'package:intl/intl.dart';

class TaskCard extends StatelessWidget {
  final String title;
  final String description;
  final Color color;
  final DateTime dueAt;
  final bool isCompleted;
  final VoidCallback onCheckboxTap;

  const TaskCard({
    super.key,
    required this.title,
    required this.description,
    required this.color,
    required this.dueAt,
    required this.isCompleted,
    required this.onCheckboxTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          // 1. La Tarjeta de Color (Ocupa el espacio disponible)
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.5), // Color suave de fondo
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  // Borde un poco más oscuro
                  color: AppDateUtils.strengthenColor(color, 0.7),
                  width: 2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      decoration: isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      decoration: isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                      overflow: TextOverflow.ellipsis,
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 10),

          // 2. El Checkbox y la Hora (Lado derecho)
          Column(
            children: [
              Checkbox(
                value: isCompleted,
                onChanged: (_) => onCheckboxTap(),
                activeColor: AppDateUtils.strengthenColor(color, 0.7),
                shape: const CircleBorder(),
              ),
              Text(
                DateFormat.jm().format(
                  DateTime(
                    dueAt.year,
                    dueAt.month,
                    dueAt.day,
                    dueAt.hour,
                    dueAt.minute,
                  ),
                ),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
