import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/utils/show_snackbar.dart';
import 'package:frontend/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:frontend/features/task/presentation/bloc/task_bloc.dart';

class AddNewTaskPage extends StatefulWidget {
  static MaterialPageRoute<dynamic> route() =>
      MaterialPageRoute(builder: (context) => const AddNewTaskPage());

  const AddNewTaskPage({super.key});

  @override
  State<AddNewTaskPage> createState() => _AddNewTaskPageState();
}

class _AddNewTaskPageState extends State<AddNewTaskPage> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  // Colores disponibles para elegir
  // Color por defecto
  Color selectedColor = const Color.fromRGBO(246, 222, 194, 1);
  final List<Color> cardColors = const [
    Color.fromRGBO(246, 222, 194, 1), // Crema
    Color.fromRGBO(236, 145, 146, 1), // Salmón
    Color.fromRGBO(173, 216, 230, 1), // Azul claro
    Color.fromRGBO(144, 238, 144, 1), // Verde claro
    Color.fromRGBO(255, 182, 193, 1), // Rosa
  ];

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void uploadTask() {
    if (formKey.currentState!.validate()) {
      // 1. Obtenemos el usuario actual del AuthBloc
      final authState = context.read<AuthBloc>().state;

      if (authState is AuthSuccess) {
        // 2. Disparamos el evento al TaskBloc
        context.read<TaskBloc>().add(
          TaskUpload(
            uid: authState.user.id,
            title: titleController.text.trim(),
            description: descriptionController.text.trim(),
            // Convertimos Color a Hex String: Color(0xFFFF0000) -> "#FF0000"
            hexColor:
                '#${selectedColor.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}',
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
        title: const Text('New Task'),
        actions: [
          IconButton(onPressed: uploadTask, icon: const Icon(Icons.check)),
        ],
      ),
      body: BlocConsumer<TaskBloc, TaskState>(
        listener: (context, state) {
          if (state is TaskFailure) {
            showSnackBar(context, state.error);
          } else if (state is TaskSuccess) {
            showSnackBar(context, 'Task created successfully!');
            Navigator.pop(context); // Volver al Home al terminar
          }
        },
        builder: (context, state) {
          if (state is TaskLoading) {
            return const CircularProgressIndicator();
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  // TÍTULO
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(hintText: 'Title'),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),

                  // DESCRIPCIÓN
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      hintText: 'Description',
                      border: InputBorder
                          .none, // Quitamos bordes para que parezca un bloc de notas
                    ),
                    maxLines: null, // Permite infinitas líneas
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // SELECTOR DE COLOR
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: cardColors.map((color) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedColor = color;
                              });
                            },
                            child: CircleAvatar(
                              backgroundColor: color,
                              radius: 20,
                              child: selectedColor == color
                                  ? const Icon(
                                      Icons.check,
                                      color: Colors.black,
                                    ) // Marca el seleccionado
                                  : null,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
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
