import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/utils/date_utils.dart';
import 'package:frontend/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:frontend/features/auth/presentation/pages/login_page.dart';
import 'package:frontend/features/task/presentation/bloc/task_bloc.dart';
import 'package:frontend/features/task/presentation/pages/add_new_task_page.dart';
import 'package:frontend/features/task/presentation/pages/edit_task_page.dart';
import 'package:frontend/features/task/presentation/widgets/task_card.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  static MaterialPageRoute<dynamic> route() =>
      MaterialPageRoute(builder: (context) => const HomePage());

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime selectedDate = DateTime.now();
  int weekOffset = 0; // Para movernos entre semanas

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
    // Generamos las fechas de la semana actual
    List<DateTime> weekDates = AppDateUtils.generateWeekDates(weekOffset);
    String monthName = DateFormat('MMMM').format(weekDates.first);

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthInitial) {
          Navigator.pushAndRemoveUntil(
            context,
            LoginPage.route(),
            (route) => false,
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'My Tasks',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(context, AddNewTaskPage.route());
              },
              icon: const Icon(CupertinoIcons.add_circled_solid, size: 35),
            ),
            IconButton(
              onPressed: () {
                context.read<AuthBloc>().add(AuthLogout());
              },
              icon: const Icon(Icons.logout),
            ),
          ],
        ),
        body: Column(
          children: [
            // --------------------------
            // 1. SELECTOR DE FECHAS
            // --------------------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => setState(() => weekOffset--),
                    icon: const Icon(Icons.arrow_back_ios),
                  ),
                  Text(
                    monthName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() => weekOffset++),
                    icon: const Icon(Icons.arrow_forward_ios),
                  ),
                ],
              ),
            ),

            // Lista horizontal de días (L M X J V S D)
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: weekDates.length,
                itemBuilder: (context, index) {
                  final date = weekDates[index];
                  // Comparamos si es el día seleccionado (ignorando la hora)
                  final isSelected = DateUtils.isSameDay(selectedDate, date);

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedDate = date;
                      });
                    },
                    child: Container(
                      width: 65,
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.deepOrangeAccent
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? Colors.deepOrangeAccent
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            DateFormat('d').format(date), // Día número (24)
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : Colors.black,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            DateFormat('E').format(date), // Día letra (Mon)
                            style: TextStyle(
                              fontSize: 14,
                              color: isSelected ? Colors.white : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // --------------------------
            // 2. LISTA DE TAREAS (Filtrada por fecha)
            // --------------------------
            Expanded(
              child: BlocConsumer<TaskBloc, TaskState>(
                listener: (context, state) {
                  if (state is TaskFailure) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(state.error)));
                  }
                  if (state is TaskSuccess) {
                    _fetchAllTasks();
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
                    // FILTRADO: Solo mostramos las tareas que coincidan con la fecha seleccionada
                    final tasksForDate = state.tasks.where((task) {
                      return AppDateUtils.isSameDate(
                        task.dueDate,
                        selectedDate,
                      );
                    }).toList();

                    // ORDENADO: De más temprano a más tarde
                    tasksForDate.sort((a, b) => a.dueDate.compareTo(b.dueDate));

                    if (tasksForDate.isEmpty) {
                      return const Center(
                        child: Text('There are not tasks for today 🌴'),
                      );
                    }

                    return ListView.builder(
                      itemCount: tasksForDate.length,
                      itemBuilder: (context, index) {
                        final task = tasksForDate[index];
                        return Dismissible(
                          key: Key(task.id),
                          direction: DismissDirection.endToStart,
                          // 1. EL FONDO ROJO (Lo que se ve al deslizar) 🗑️
                          background: Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.redAccent,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),

                          onDismissed: (direction) {
                            final authState = context.read<AuthBloc>().state;
                            if (authState is AuthSuccess) {
                              // Disparamos el evento de borrar
                              context.read<TaskBloc>().add(
                                TaskDelete(
                                  taskId: task.id,
                                  token: authState.user.token,
                                ),
                              );

                              //  Mensaje abajo
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Task deleted')),
                              );
                            }
                          },

                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(context, EditTaskPage.route(task));
                            },
                            child: TaskCard(
                              title: task.title,
                              description: task.description,
                              color: AppDateUtils.hexToColor(task.hexColor),
                              dueAt: task.dueDate,
                              isCompleted: task.isCompleted,
                              onCheckboxTap: () {
                                final authState = context
                                    .read<AuthBloc>()
                                    .state;
                                if (authState is AuthSuccess) {
                                  context.read<TaskBloc>().add(
                                    TaskUpdateStatus(
                                      taskId: task.id,
                                      isCompleted: !task.isCompleted,
                                      token: authState.user.token,
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        );
                      },
                    );
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
