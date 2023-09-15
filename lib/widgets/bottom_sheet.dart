import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../helpers/task.dart';
import '../helpers/task_provider.dart';
import '../helpers/constants.dart';
import '../helpers/notification_helper.dart';

class ModelBottomSheet extends StatefulWidget {
  BuildContext context;
  Task? task;

  ModelBottomSheet({
    super.key,
    required this.context,
    this.task,
  });

  @override
  State<ModelBottomSheet> createState() => _ModelBottomSheetState();
}

class _ModelBottomSheetState extends State<ModelBottomSheet> {
  bool isdateSelected = false;
  bool isTimeSelected = false;

  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  TextEditingController subjectController = TextEditingController();
  var notifierHelper = NotifyHelper();

  @override
  void initState() {
    super.initState();
    subjectController = TextEditingController(text: widget.task?.subject);
    notifierHelper.initializeNotification();
    notifierHelper;
  }

  @override
  void dispose() {
    subjectController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    final taskProvider = Provider.of<TaskProvider>(context);

    String timeString = widget.task?.time ?? '';

    return Container(
      height: 300 + keyboardHeight,
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: ListView(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Add task',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
              Container(
                alignment: Alignment.bottomRight,
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: TextButton.icon(
                  style: TextButton.styleFrom(
                    backgroundColor: color1,
                    foregroundColor: Colors.white,
                    elevation: 5,
                  ),
                  icon: const Icon(Icons.save),
                  label: const Text('Save'),
                  onPressed: () async {
                    final pickedDate =
                        DateFormat.yMd().format(selectedDate).toString();
                    final pickedTime = DateFormat.jm()
                        .format(DateTime(
                            2021, 1, 1, selectedTime.hour, selectedTime.minute))
                        .toString();
                    final newTask = Task(
                        subject: subjectController.text,
                        date: widget.task != null
                            ? isdateSelected
                                ? pickedDate
                                : widget.task!.date
                            : pickedDate,
                        time: widget.task != null
                            ? isTimeSelected
                                ? pickedTime
                                : widget.task!.time
                            : pickedTime);
                    if (widget.task != null) {
                      // Update existing task
                      // Set the ID of the existing task
                      await taskProvider.updateTask(widget.task!.id!, newTask);
                      snackBar(
                        context: context,
                        content: 'Task updated Successfully',
                        color: color1,
                      );
                    } else {
                      // Add new task
                      await taskProvider.addTask(newTask);
                      snackBar(
                        context: context,
                        content: 'Task Added Successfully',
                        color: Colors.green,
                      );
                    }
                    notifierHelper.scheduledNotification(selectedTime, newTask);
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
          SizedBox(
            height: 5,
          ),
          TextField(
            controller: subjectController,
            maxLines: 4,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              alignLabelWithHint: true,
              border: OutlineInputBorder(borderSide: BorderSide(color: color1)),
              labelText: 'Subject',
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8), color: color3),
                child: TextButton.icon(
                  onPressed: () {
                    _selectDate(context);
                  },
                  icon: Icon(Icons.calendar_today),
                  label: Text(
                    isdateSelected
                        ? DateFormat.yMd().format(selectedDate)
                        : widget.task != null
                            ? widget.task!.date
                            : 'Choose Date',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8), color: color3),
                child: TextButton.icon(
                  onPressed: () {
                    _selectTime(context, timeString);
                  },
                  icon: Icon(Icons.timer),
                  label: Text(
                    isTimeSelected
                        ? DateFormat.jm().format(DateTime(
                            2021, 1, 1, selectedTime.hour, selectedTime.minute))
                        : widget.task != null
                            ? widget.task!.time
                            : 'Choose Time',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final datePicked = await showDatePicker(
      context: context,
      initialDate: widget.task != null
          ? DateFormat('MM/dd/yyyy').parse(widget.task!.date)
          : selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (datePicked != null && datePicked != selectedDate) {
      // Update the selectedDate date variable
      selectedDate = datePicked;
      setState(() {
        isdateSelected = true;
      });
    }
  }

  Future<void> _selectTime(BuildContext context, String timeString) async {
    final timePicked = await showTimePicker(
        context: context,
        initialTime: widget.task != null
            ? parseTimeStringToTimeOfDay(timeString)
            : selectedTime);
    if (timePicked != null && timePicked != selectedDate) {
      // Update the selectedDate date variable
      selectedTime = timePicked;
      setState(() {
        isTimeSelected = true;
      });
    }
  }

  TimeOfDay parseTimeStringToTimeOfDay(String timeString) {
    final DateFormat timeFormat = DateFormat.jm();
    final DateTime parsedTime = timeFormat.parse(timeString);

    return TimeOfDay(hour: parsedTime.hour, minute: parsedTime.minute);
  }
}
