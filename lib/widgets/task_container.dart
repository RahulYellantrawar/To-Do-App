import 'dart:math';

import 'package:flutter/material.dart';

import 'bottom_sheet.dart';
import '../helpers/constants.dart';
import '../helpers/task.dart';

class TaskContainer extends StatefulWidget {
  String taskId;
  int index;
  Task task;
  dynamic taskProvider;
  bool isCompleted;
  TaskContainer({
    super.key,
    required this.taskId,
    required this.index,
    required this.task,
    required this.taskProvider,
    required this.isCompleted,
  });

  @override
  State<TaskContainer> createState() => _TaskContainerState();
}

class _TaskContainerState extends State<TaskContainer> {
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    Color getRandomColor() {
      final Random random = Random();
      final int red = random.nextInt(256);
      final int green = random.nextInt(256);
      final int blue = random.nextInt(256);

      return Color.fromARGB(255, red, green, blue);
    }

    return Dismissible(
      key: UniqueKey(), // Use a unique key for each task

      secondaryBackground: Container(
        color: Colors.red, // Background color when swiping
        alignment: Alignment.centerRight,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.06),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
      ),

      background: Container(
        color: Colors.green, // Background color when swiping
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.06),
          child: widget.isCompleted
              ? const Icon(Icons.task_alt_outlined, color: Colors.white)
              : const Icon(Icons.cancel, color: Colors.white),
        ),
      ),

      onDismissed: (direction) {
        if (direction == DismissDirection.startToEnd) {
          try {
            setState(() {
              widget.isCompleted
                  ? widget.taskProvider.markTaskAsCompleted(
                      widget.index, widget.task, widget.task.completed!)
                  : widget.taskProvider.markTaskAsNotCompleted(
                      widget.index, widget.task, widget.task.completed!);
            });
            snackBar(
              context: context,
              content:
                  widget.isCompleted ? 'Task completed' : 'Task not completed',
              color: Colors.green,
            );
          } catch (error) {
            print(error);
          }
        } else if (direction == DismissDirection.endToStart) {
          try {
            widget.taskProvider.deleteTask(widget.task.id);
            snackBar(
              context: context,
              content: 'Task Successfully deleted',
              color: Colors.red,
              snackbarAction: SnackBarAction(
                disabledTextColor: Colors.white,
                backgroundColor: Colors.white,
                textColor: Colors.black,
                label: 'Undo',
                onPressed: () {
                  widget.taskProvider.addTask(widget.task);
                },
              ),
            );
          } catch (error) {
            print(error);
          }
        }
      },

      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              showModalBottomSheet(
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
                    task: widget.task,
                  ),
                ),
              );
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: width * 0.04),
              decoration: BoxDecoration(
                color: getRandomColor().withAlpha(20),
                borderRadius: BorderRadius.circular(width * 0.04),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Container(
                      width: width * 0.02,
                      height: height * 0.08,
                      color: getRandomColor(),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: width * 0.7,
                        child: Text(
                          widget.task.subject,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Text(
                        'Date: ${widget.task.date}, Time ${widget.task.time}',
                        style: TextStyle(color: Colors.grey.shade700),
                      )
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') {
                            showModalBottomSheet(
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
                                  task: widget.task,
                                ),
                              ),
                            );
                          } else if (value == 'delete') {
                            try {
                              widget.taskProvider.deleteTask(widget.task
                                  .id); // Assuming id is the task ID in the database
                              snackBar(
                                context: context,
                                content: 'Task Successfully deleted',
                                color: Colors.red,
                                snackbarAction: SnackBarAction(
                                  disabledTextColor: Colors.white,
                                  backgroundColor: Colors.white,
                                  textColor: Colors.black,
                                  label: 'Undo',
                                  onPressed: () {
                                    widget.taskProvider.addTask(widget.task);
                                  },
                                ),
                              );

                            } catch (error) {
                              print(error);
                            }
                          } else if (value == 'mark as completed' ||
                              value == 'not completed') {
                            try {
                              setState(() {
                                widget.isCompleted
                                    ? widget.taskProvider.markTaskAsCompleted(
                                        widget.index,
                                        widget.task,
                                        widget.task.completed!)
                                    : widget.taskProvider
                                        .markTaskAsNotCompleted(
                                            widget.index,
                                            widget.task,
                                            widget.task.completed!);
                              });
                              snackBar(
                                context: context,
                                content: widget.isCompleted
                                    ? 'Task completed'
                                    : 'Task not completed',
                                color: Colors.green,
                              );
                            } catch (error) {
                              print(error);
                            }
                          }
                        },
                        itemBuilder: (BuildContext context) => [
                          const PopupMenuItem<String>(
                            value: 'edit',
                            child: Text('Edit'),
                          ),
                          const PopupMenuItem<String>(
                            value: 'delete',
                            child: Text('Delete'),
                          ),
                          PopupMenuItem<String>(
                            value: widget.isCompleted
                                ? 'not completed'
                                : 'mark as completed',
                            child: Text(widget.isCompleted
                                ? 'Completed'
                                : 'Not Completed'),
                          ),
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
          SizedBox(
            height: height * 0.005,
          )
        ],
      ),
    );
  }
}
