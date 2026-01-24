import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/utils/date_utils.dart';
import 'package:frontend/core/utils/show_snackbar.dart';
import 'package:frontend/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:frontend/features/task/data/models/task_model.dart';
import 'package:frontend/features/task/domain/entities/task.dart';
import 'package:frontend/features/task/presentation/bloc/task_bloc.dart';
import 'package:intl/intl.dart';

class EditTaskPage extends StatefulWidget {
  final Task task;

  static MaterialPageRoute route(Task task) =>
      MaterialPageRoute(builder: (context) => EditTaskPage(task: task));

  const EditTaskPage({super.key, required this.task});

  @override
  State<EditTaskPage> createState() => _EditTaskPageState();
}

class _EditTaskPageState extends State<EditTaskPage> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  final formKey = GlobalKey<FormState>();

  late DateTime selectedDate;
  late TimeOfDay selectedTime;
  late Color selectedColor;

  @override
  void initState() {
    super.initState();
    // 1. RELLENAMOS LOS DATOS INICIALES
    titleController = TextEditingController(text: widget.task.title);
    descriptionController = TextEditingController(
      text: widget.task.description,
    );

    // Recuperamos Fecha y Hora de la tarea existente
    // (Asumimos que viene en UTC, lo mostramos tal cual)
    selectedDate = widget.task.dueDate;
    selectedTime = TimeOfDay(
      hour: widget.task.dueDate.hour,
      minute: widget.task.dueDate.minute,
    );

    // Convertimos el HexString a Color
    selectedColor = AppDateUtils.hexToColor(widget.task.hexColor);
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void editTask() {
    if (formKey.currentState!.validate()) {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthSuccess) {
        final finalDateTime = DateTime.utc(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          selectedTime.hour,
          selectedTime.minute,
        );

        // Creamos el modelo actualizado
        final editedTask = TaskModel(
          id: widget.task.id, // Mantenemos el MISMO ID
          uid: authState.user.id,
          title: titleController.text.trim(),
          description: descriptionController.text.trim(),
          hexColor: AppDateUtils.colorToHex(selectedColor),
          dueDate: finalDateTime,
          isCompleted: widget.task.isCompleted,
          createdAt: widget.task.createdAt,
          updatedAt: DateTime.now(), // Actualizamos la fecha de modificación
        );

        // Enviamos al Bloc (Evento: TaskUpdate)
        context.read<TaskBloc>().add(
          TaskEdit(task: editedTask, token: authState.user.token),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Task'),
        actions: [
          IconButton(onPressed: editTask, icon: const Icon(Icons.done)),
        ],
      ),
      body: BlocConsumer<TaskBloc, TaskState>(
        listener: (context, state) {
          if (state is TaskFailure) {
            showSnackBar(context, state.error);
          } else if (state is TaskSuccess) {
            Navigator.pop(context); // Volver al Home al terminar
          }
        },
        builder: (context, state) {
          if (state is TaskLoading) {
            return const CircularProgressIndicator();
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // FILA DE FECHA Y HORA
                  Row(
                    children: [
                      // 1. SELECTOR DE FECHA
                      Expanded(
                        flex: 3,
                        child: GestureDetector(
                          onTap: () async {
                            final pickedDate = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(3000),
                            );
                            if (pickedDate != null) {
                              setState(() {
                                selectedDate = DateTime.utc(
                                  pickedDate.year,
                                  pickedDate.month,
                                  pickedDate.day,
                                );
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_month),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      DateFormat.yMMMEd().format(selectedDate),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      // 2. SELECTOR DE HORA
                      Expanded(
                        flex: 2,
                        child: GestureDetector(
                          onTap: () async {
                            final pickedTime = await showTimePicker(
                              context: context,
                              initialTime: selectedTime,
                            );
                            if (pickedTime != null) {
                              setState(() {
                                selectedTime = pickedTime;
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.access_time_filled),
                                const SizedBox(width: 10),
                                Text(
                                  selectedTime.format(context),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // INPUTS DE TEXTO
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      hintText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) => val!.isEmpty ? 'Enter a title' : null,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      hintText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 4,
                    validator: (val) =>
                        val!.isEmpty ? 'Enter a description' : null,
                  ),
                  const SizedBox(height: 20),

                  // SELECTOR DE COLOR
                  ColorPicker(
                    color: selectedColor,
                    onColorChanged: (Color color) {
                      setState(() {
                        selectedColor = color;
                      });
                    },
                    heading: const Text('Select color'),
                    subheading: const Text('Select color shade'),
                    wheelSubheading: const Text(
                      'Selected color and its shades',
                    ),
                    showMaterialName: true,
                    showColorName: true,
                    showColorCode: true,
                    copyPasteBehavior: const ColorPickerCopyPasteBehavior(
                      longPressMenu: true,
                    ),
                    pickersEnabled: const <ColorPickerType, bool>{
                      ColorPickerType.both: false,
                      ColorPickerType.primary: true,
                      ColorPickerType.accent: true,
                      ColorPickerType.wheel: true,
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
