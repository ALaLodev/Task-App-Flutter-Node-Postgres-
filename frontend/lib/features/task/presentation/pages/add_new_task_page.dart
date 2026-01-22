import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/utils/show_snackbar.dart';
import 'package:frontend/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:frontend/features/task/presentation/bloc/task_bloc.dart';
import 'package:intl/intl.dart';

class AddNewTaskPage extends StatefulWidget {
  static MaterialPageRoute route() =>
      MaterialPageRoute(builder: (context) => const AddNewTaskPage());

  const AddNewTaskPage({super.key});

  @override
  State<AddNewTaskPage> createState() => _AddNewTaskPageState();
}

class _AddNewTaskPageState extends State<AddNewTaskPage> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  // Fecha por defecto (UTC)
  DateTime selectedDate = DateTime.utc(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  // ⏰ Hora por defecto (La actual)
  TimeOfDay selectedTime = TimeOfDay.now();

  Color selectedColor = const Color.fromRGBO(246, 222, 194, 1);

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void createTask() {
    if (formKey.currentState!.validate()) {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthSuccess) {
        // 🧪 FUSIÓN NUCLEAR: Juntamos Fecha UTC + Hora Elegida
        // Creamos un DateTime UTC con el año/mes/día elegidos Y la hora/minuto elegidos.
        final finalDateTime = DateTime.utc(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          selectedTime.hour,
          selectedTime.minute,
        );

        context.read<TaskBloc>().add(
          TaskUpload(
            uid: authState.user.id,
            title: titleController.text.trim(),
            description: descriptionController.text.trim(),
            hexColor:
                '#${selectedColor.toARGB32().toRadixString(16).substring(2)}',
            dueDate: finalDateTime, // Enviamos la fecha completa
            token: authState.user.token,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Task'),
        actions: [
          IconButton(onPressed: createTask, icon: const Icon(Icons.done)),
        ],
      ),
      body: BlocConsumer<TaskBloc, TaskState>(
        listener: (context, state) {
          if (state is TaskFailure) {
            showSnackBar(context, state.error);
          } else if (state is TaskSuccess) {
            Navigator.pop(context);
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
                  // FILA DE FECHA Y HORA 📅 ⏰
                  Row(
                    children: [
                      // 1. SELECTOR DE FECHA (Expandido)
                      Expanded(
                        flex: 3,
                        child: GestureDetector(
                          onTap: () async {
                            final pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
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
                                // Usamos Expanded + FittedBox para que el texto nunca rompa
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

                      // 2. SELECTOR DE HORA (Nuevo) ⏰
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
                                  selectedTime.format(
                                    context,
                                  ), // Muestra "14:30" o "2:30 PM"
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
