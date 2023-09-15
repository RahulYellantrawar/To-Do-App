import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'package:provider/provider.dart';

import 'package:to_do/helpers/constants.dart';
import 'package:to_do/helpers/notification_helper.dart';
import 'package:to_do/widgets/task_container.dart';

import '../widgets/bottom_sheet.dart';
import '../helpers/task.dart';
import '../helpers/task_provider.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  var notifierHelper = NotifyHelper();

  @override
  void initState() {
    super.initState();
    notifierHelper;
    notifierHelper.initializeNotification();
    tz.initializeTimeZones();
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    taskProvider.fetchTasks();
    taskProvider.fetchCompletedTasks();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    final taskProvider = Provider.of<TaskProvider>(context);

    Map<String, List<Task>> tasksByDate = {};

    for (var task in taskProvider.tasks) {
      final taskDateString = task.date;

      if (!tasksByDate.containsKey(taskDateString)) {
        tasksByDate[taskDateString] = [];
      }

      tasksByDate[taskDateString]!.add(task);
    }

    String getFormattedDateHeader(String taskDate) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final tomorrow = today.add(const Duration(days: 1));

      final taskDateTime = DateFormat('MM/dd/yyyy').parse(taskDate);

      if (taskDateTime.isAtSameMomentAs(today)) {
        return 'Today';
      } else if (taskDateTime.isAtSameMomentAs(tomorrow)) {
        return 'Tomorrow';
      } else {
        return DateFormat('MMMM dd, yyyy').format(taskDateTime);
      }
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          elevation: 8,
          title: const Text(
            'Tasks',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          bottom: const TabBar(
            indicatorColor: Colors.teal,
            tabs: [
              Text(
                'Active',
                style: TextStyle(fontSize: 18),
              ),
              Text(
                'Finished',
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
            backgroundColor: color1,
            foregroundColor: Colors.white,
            child: const Icon(Icons.add),
            onPressed: () => showModalBottomSheet(
                  isScrollControlled: true,
                  context: context,
                  builder: (context) => GestureDetector(
                      onTap: () {
                        FocusScope.of(context).unfocus();
                      },
                      onVerticalDragDown: (_) {
                        FocusScope.of(context).unfocus();
                      },
                      child: ModelBottomSheet(
                        context: context,
                      )),
                )),
        body: TabBarView(
          children: [
            Container(
              padding: EdgeInsets.all(width * 0.02),
              child: taskProvider.tasks.isEmpty
                  ? const Center(
                      child: Text('Create your first task...'),
                    )
                  : ListView.builder(
                      itemCount: tasksByDate.length,
                      itemBuilder: (context, index) {
                        final taskDate = tasksByDate.keys.elementAt(index);
                        final taskList = tasksByDate[taskDate];
                        // final task = taskProvider.tasks[index];
                        return Column(
                          children: [
                            SizedBox(
                              height: height * 0.005,
                            ),
                            Text(
                              getFormattedDateHeader(taskDate),
                            ),
                            SizedBox(
                              height: height * 0.005,
                            ),
                            Column(
                              children: taskList!.map(
                                (task) {
                                  return TaskContainer(
                                    taskId: task.id.toString(),
                                    index: index,
                                    task: task,
                                    taskProvider: taskProvider,
                                    isCompleted: true,
                                  );
                                },
                              ).toList(),
                            ),
                          ],
                        );
                      },
                    ),
            ),
            Container(
              padding: EdgeInsets.all(width * 0.02),
              child: taskProvider.completedTasks.isEmpty
                  ? const Center(
                      child: Text('You are not finished a task yet!.'),
                    )
                  : ListView.builder(
                      itemCount: taskProvider.completedTasks.length,
                      itemBuilder: (context, index) {
                        final finishedTasks =
                            taskProvider.completedTasks[index];
                        // final task = taskProvider.tasks[index];
                        return Column(
                          children: [
                            SizedBox(
                              height: height * 0.005,
                            ),
                            TaskContainer(
                              taskId: finishedTasks.id!.toString(),
                              index: index,
                              task: finishedTasks,
                              taskProvider: taskProvider,
                              isCompleted: false,
                            ),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
