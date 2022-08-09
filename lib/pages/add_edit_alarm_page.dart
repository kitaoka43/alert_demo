import 'package:alert_demo/sqflite.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../alarm.dart';

class AddEditAlarmPage extends StatefulWidget {
  const AddEditAlarmPage({Key? key, required this.alarmList, this.index})
      : super(key: key);
  final List<Alarm> alarmList;
  final int? index;

  @override
  State<AddEditAlarmPage> createState() => _AddEditAlarmPageState();
}

class _AddEditAlarmPageState extends State<AddEditAlarmPage> {
  TextEditingController controller = TextEditingController();
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.index != null) {
      selectedDate = widget.alarmList[widget.index!].alarmTime;
      controller.text = DateFormat('H:mm').format(selectedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 100,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            alignment: Alignment.center,
            child: const Text(
              'キャンセル',
              style: TextStyle(color: Colors.orange),
            ),
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () async {
              DateTime now = DateTime.now();
              DateTime? alarmTime;
              if (now.compareTo(selectedDate) == -1) {
                alarmTime = DateTime(selectedDate.year, selectedDate.month,
                    selectedDate.day, selectedDate.hour, selectedDate.minute);
              } else {
                alarmTime = DateTime(
                    selectedDate.year,
                    selectedDate.month,
                    selectedDate.day + 1,
                    selectedDate.hour,
                    selectedDate.minute);
              }
              Alarm alarm = Alarm(alarmTime: alarmTime);
              if (widget.index != null) {
                alarm.id = widget.alarmList[widget.index!].id;
                await DBProvider.updateDate(alarm);
              } else {
                int id = await DBProvider.insertDate(alarm);
                alarm.id = id;
              }

              Navigator.pop(context, alarm);
            },
            child: Container(
              padding: const EdgeInsets.only(right: 20),
              alignment: Alignment.center,
              child: const Text(
                '保存',
                style: const TextStyle(color: Colors.orange),
              ),
            ),
          ),
        ],
        backgroundColor: Colors.black87,
        title: const Text(
          'アラームを追加',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Container(
        height: double.infinity,
        color: Colors.black,
        child: Column(
          children: [
            const SizedBox(
              height: 50,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '時間',
                    style: const TextStyle(color: Colors.white),
                  ),
                  Container(
                    width: 70,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.orange),
                        borderRadius: BorderRadius.circular(10)),
                    child: TextField(
                      controller: controller,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                      ),
                      readOnly: true,
                      onTap: () {
                        showModalBottomSheet(
                            context: context,
                            builder: (context) {
                              return CupertinoDatePicker(
                                  initialDateTime: selectedDate,
                                  mode: CupertinoDatePickerMode.time,
                                  onDateTimeChanged: (newDate) {
                                    String time =
                                        DateFormat('H:mm').format(newDate);
                                    selectedDate = newDate;
                                    controller.text = time;
                                  });
                            });
                      },
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
