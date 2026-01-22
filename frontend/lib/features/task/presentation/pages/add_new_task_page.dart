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

  DateTime selectedDate = DateTime.now();
  Color selectedColor = const Color.fromRGBO(
    246,
    222,
    194,
    1,
  ); // Color crema por defecto

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
        context.read<TaskBloc>().add(
          TaskUpload(
            uid: authState.user.id,
            title: titleController.text.trim(),
            description: descriptionController.text.trim(),
            hexColor:
                '#${selectedColor.toARGB32().toRadixString(16).substring(2)}',
            dueDate: selectedDate,
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
          // Botón de guardar en la barra superior (estilo iOS/Moderno)
          IconButton(onPressed: createTask, icon: const Icon(Icons.done)),
        ],
      ),
      body: BlocConsumer<TaskBloc, TaskState>(
        listener: (context, state) {
          if (state is TaskFailure) {
            showSnackBar(context, state.error);
          } else if (state is TaskSuccess) {
            // Si se crea bien, volvemos atrás
            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          if (state is TaskLoading) {
            return Center(child: const CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. SELECTOR DE FECHA (Calendario) 📅
                  //
                  GestureDetector(
                    onTap: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(3000),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          selectedDate = pickedDate;
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
                          Text(
                            DateFormat.yMMMEd().format(
                              selectedDate,
                            ), // Ej: "Thu, Jan 25, 2024"
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 2. INPUT DE TÍTULO 📝
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      hintText: 'Title',
                      border: OutlineInputBorder(), // Borde cuadrado simple
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // 3. INPUT DE DESCRIPCIÓN 📄
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      hintText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 4, // Permite escribir varios párrafos
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // 4. SELECTOR DE COLOR (ColorPicker) 🎨
                  //
                  const Text(
                    'Color',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
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
                    materialNameTextStyle: Theme.of(
                      context,
                    ).textTheme.bodySmall,
                    colorNameTextStyle: Theme.of(context).textTheme.bodySmall,
                    colorCodeTextStyle: Theme.of(context).textTheme.bodySmall,
                    pickersEnabled: const <ColorPickerType, bool>{
                      ColorPickerType.both: false,
                      ColorPickerType.primary: true, // Colores básicos
                      ColorPickerType.accent: true, // Colores vivos
                      ColorPickerType.bw: false,
                      ColorPickerType.custom: false,
                      ColorPickerType.wheel:
                          true, // Rueda RGB (Como en el video)
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
