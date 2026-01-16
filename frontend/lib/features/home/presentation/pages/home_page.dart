import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/utils/show_snackbar.dart';
import 'package:frontend/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:frontend/features/task/presentation/bloc/task_bloc.dart';
import 'package:frontend/features/task/presentation/pages/add_new_task_page.dart';

class HomePage extends StatefulWidget {
  static MaterialPageRoute<dynamic> route() =>
      MaterialPageRoute(builder: (context) => const HomePage());

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();

    _fetchAllTasks();
  }

  void _fetchAllTasks() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthSuccess) {
      context.read<TaskBloc>().add(
        TaskFetchAllTasks(token: authState.user.token),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        actions: [
          IconButton(
            onPressed: () {
              context.read<AuthBloc>().add(AuthLogout());
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // 2. Esperamos a que el usuario termine de crear la tarea
          await Navigator.push(context, AddNewTaskPage.route());

          // 3. Al volver, forzamos la recarga inmediatamente
          _fetchAllTasks();
        },
        child: const Icon(Icons.add, size: 30),
      ),
      body: BlocConsumer<TaskBloc, TaskState>(
        listener: (context, state) {
          if (state is TaskFailure) {
            showSnackBar(context, state.error);
          }
        },
        builder: (context, state) {
          if (state is TaskLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TaskSuccess) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TasksDisplaySuccess) {
            if (state.tasks.isEmpty) {
              return const Center(child: Text('No tienes tareas aún! 📝'));
            }

            return ListView.builder(
              itemCount: state.tasks.length,
              itemBuilder: (context, index) {
                final task = state.tasks[index];
                return ListTile(
                  title: Text(
                    task.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    task.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: Color(
                      int.parse(task.hexColor.replaceAll('#', '0xFF')),
                    ),
                    radius: 10,
                  ),
                );
              },
            );
          }

          // CASO 4: Fallback inicial (para evitar pantalla blanca al inicio)
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
