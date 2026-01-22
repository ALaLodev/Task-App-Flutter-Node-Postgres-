import 'dart:convert';
import 'package:frontend/features/task/domain/entities/task.dart';

class TaskModel extends Task {
  TaskModel({
    required super.id,
    required super.title,
    required super.description,
    required super.hexColor,
    required super.uid,
    required super.updatedAt,
    required super.createdAt,
    required super.dueDate,
    required super.isCompleted,
  });

  // 1. fromMap: De Objeto JSON (Map) a Clase Dart
  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      hexColor: map['hexColor'] ?? '',
      uid: map['uid'] ?? '',
      // DateTime.parse convierte el string de fecha "2024-01-01..." a objeto fecha
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'])
          : DateTime.now(),
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      dueDate: map['dueDate'] != null
          ? DateTime.parse(map['dueDate'])
          : DateTime.now(),
      isCompleted: map['isCompleted'] ?? false,
    );
  }

  // 2. toMap: De Clase Dart a Objeto JSON (Map)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'hexColor': hexColor,
      'uid': uid,
      'updatedAt': updatedAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'dueDate': dueDate.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }

  // Helpers para Strings directos (útil para HTTP)
  String toJson() => json.encode(toMap());

  factory TaskModel.fromJson(String source) =>
      TaskModel.fromMap(json.decode(source));

  // 3. copyWith: Para editar una tarea sin mutar la original (Clave para BLoC)
  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    String? hexColor,
    String? uid,
    DateTime? updatedAt,
    DateTime? createdAt,
    DateTime? dueDate,
    bool? isCompleted,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      hexColor: hexColor ?? this.hexColor,
      uid: uid ?? this.uid,
      updatedAt: updatedAt ?? this.updatedAt,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
