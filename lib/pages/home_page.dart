import 'dart:async';

import 'package:alert_demo/pages/add_edit_alarm_page.dart';
import 'package:alert_demo/sqflite.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

import '../alarm.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Alarm> alarmList = [];
  Timer? timer;
  final FlutterLocalNotificationsPlugin plugin =
      FlutterLocalNotificationsPlugin();
  DateTime time = DateTime.now();

  Future<void> initDb() async {
    await DBProvider.setDb();
    alarmList = await DBProvider.getDate();
    alarmList.sort((a, b) => a.alarmTime.compareTo(b.alarmTime));
    setState(() {});
  }

  Future<void> reBuild() async {
    alarmList = await DBProvider.getDate();
    alarmList.sort((a, b) => a.alarmTime.compareTo(b.alarmTime));
    setState(() {});
  }

  void initializeNotification() {
    plugin.initialize(const InitializationSettings(
      android: AndroidInitializationSettings('ic_launcher'),
      iOS: IOSInitializationSettings(),
    ));
    plugin.show(
        1,
        'アラート',
        '時間になりました',
        const NotificationDetails(
            android: AndroidNotificationDetails('id', 'name',
                importance: Importance.max, priority: Priority.max),
            iOS: IOSNotificationDetails()));
  }

  void setNotification(int id, DateTime alarmTime) {
    plugin.zonedSchedule(
        id,
        'アラート',
        '時間になりました',
        tz.TZDateTime.from(alarmTime, tz.local),
        const NotificationDetails(
            android: AndroidNotificationDetails('id', 'name',
                importance: Importance.max, priority: Priority.max),
            iOS: IOSNotificationDetails()),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidAllowWhileIdle: true);
  }

  void notification() {
    plugin.initialize(const InitializationSettings(
      android: AndroidInitializationSettings('ic_launcher'),
      iOS: IOSInitializationSettings(),
    ));
    plugin.show(
        1,
        'アラート',
        '時間になりました',
        const NotificationDetails(
            android: AndroidNotificationDetails('id', 'name',
                importance: Importance.max, priority: Priority.max),
            iOS: IOSNotificationDetails()));
  }

  @override
  void initState() {
    super.initState();
    initDb();
    initializeNotification();
    timer = Timer.periodic(const Duration(milliseconds: 1), (timer) {
      time = time.add(const Duration(seconds: 1));
      alarmList.forEach((alarm) {
        if (alarm.isActive == true &&
            alarm.alarmTime.hour == time.hour &&
            alarm.alarmTime.minute == time.minute &&
            time.second == 0) {
          // notification();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: CustomScrollView(
          slivers: [
            CupertinoSliverNavigationBar(
              backgroundColor: Colors.black,
              largeTitle: const Text(
                'アラーム',
                style: TextStyle(color: Colors.white),
              ),
              trailing: GestureDetector(
                  onTap: () async {
                    Alarm result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                AddEditAlarmPage(alarmList: alarmList)));
                    if (result != null) {
                      setNotification(result.id, result.alarmTime);
                      reBuild();
                    }
                  },
                  child: const Icon(
                    Icons.add,
                    color: Colors.orange,
                  )),
            ),
            SlidableAutoCloseBehavior(
              child: SliverList(
                delegate: SliverChildBuilderDelegate(
                  childCount: alarmList.length,
                  (context, index) {
                    Alarm alarm = alarmList[index];
                    return Column(
                      children: [
                        if (index == 0)
                          const Divider(
                            color: Colors.grey,
                            height: 1,
                          ),
                        Slidable(
                          endActionPane: ActionPane(
                            extentRatio: 0.3,
                            motion: const ScrollMotion(),
                            children: [
                              SlidableAction(
                                onPressed: (value) async {
                                  await DBProvider.deleteDate(alarm);
                                  reBuild();
                                },
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                icon: Icons.delete,
                                label: '削除',
                              ),
                            ],
                          ),
                          child: ListTile(
                            title: Text(
                              DateFormat('H:mm').format(alarm.alarmTime),
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 50),
                            ),
                            trailing: CupertinoSwitch(
                              value: alarm.isActive,
                              onChanged: (newValue) async {
                                alarm.isActive = newValue;
                                await DBProvider.updateDate(alarm);
                                reBuild();
                              },
                            ),
                            onTap: () async {
                              await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => AddEditAlarmPage(
                                            alarmList: alarmList,
                                            index: index,
                                          )));
                              reBuild();
                            },
                          ),
                        ),
                        const Divider(
                          color: Colors.grey,
                          height: 0,
                        )
                      ],
                    );
                  },
                ),
              ),
            )
          ],
        ));
  }
}
