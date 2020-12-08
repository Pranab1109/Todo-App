import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:todo/models/database_helper.dart';
import 'package:todo/models/task_model.dart';
import 'package:todo/models/todo_model.dart';
import 'package:todo/screens/task_input.dart';
import 'package:todo/screens/todo.dart';
import 'package:velocity_x/velocity_x.dart';
import 'dart:ui';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'cooloors.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  DatabaseHelper _dbHelper = DatabaseHelper();
  int totalTodo = 0;
  int totalTask = 0;
  int totalTaskDone = 0;
  @override
  void initState() {
    super.initState();
    getTotalTodo();
    getTotalTask();
    getTotalTaskDone();
  }

  getTotalTodo() async {
    totalTodo = await _dbHelper.totalTodo(taskId);
    setState(() {});
  }

  getTotalTask() async {
    totalTask = await _dbHelper.totalTask();
    setState(() {});
  }

  getTotalTaskDone() async {
    totalTaskDone = await _dbHelper.totalTaskDone();
    setState(() {});
  }

  int taskId;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        textTheme: GoogleFonts.ralewayTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: Scaffold(
        backgroundColor: Cooloors.primaryColor1,
        appBar: AppBar(
          title: "Todo App".text.make().centered(),
          backgroundColor: Colors.transparent,
          elevation: 0.0,
        ),
        body: Column(
          children: [
            Expanded(
              child: FutureBuilder(
                  initialData: [],
                  future: _dbHelper.getTask(),
                  builder: (context, snapshot) {
                    if (snapshot.data.length != 0) {
                      return Column(
                        children: [
                          SleekCircularSlider(
                            appearance: CircularSliderAppearance(
                                infoProperties: InfoProperties(
                                    modifier: (value) {
                                      return ' $totalTaskDone / $totalTask';
                                    },
                                    bottomLabelStyle: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500),
                                    topLabelStyle: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500),
                                    topLabelText: "Completed :",
                                    mainLabelStyle: TextStyle(
                                        color: Cooloors.accentColor1,
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold),
                                    bottomLabelText: totalTaskDone != totalTask
                                        ? "Keep Going!"
                                        : "All Done"),
                                animationEnabled: true,
                                customColors: CustomSliderColors(
                                    dynamicGradient: true,
                                    trackColor: Color(0xff373C40),
                                    progressBarColor: Colors.white,
                                    shadowColor: Colors.blue,
                                    shadowMaxOpacity: 0.5),
                                customWidths: CustomSliderWidths(
                                  trackWidth: 12.0,
                                  progressBarWidth: 12,
                                  shadowWidth: 5.0,
                                )),
                            min: 0,
                            max: totalTask + 0.0,
                            initialValue:
                                totalTaskDone != null ? totalTaskDone + 0.0 : 0,
                          ),
                          Expanded(
                            child: ListView.builder(
                              physics: BouncingScrollPhysics(
                                  parent: AlwaysScrollableScrollPhysics()),
                              itemCount: snapshot.data.length,
                              itemBuilder: (context, index) {
                                taskId = snapshot.data[index].id;

                                return Dismissible(
                                  confirmDismiss: (direction) {
                                    return promptUser(context);
                                  },
                                  key: UniqueKey(),
                                  onDismissed:
                                      (DismissDirection direction) async {
                                    Scaffold.of(context).hideCurrentSnackBar();
                                    Task newTask = snapshot.data[index];
                                    List<Todo> newTodo =
                                        await _dbHelper.getTodo(newTask.id);
                                    await _dbHelper
                                        .deleteTask(snapshot.data[index].id);

                                    Scaffold.of(context).showSnackBar(
                                      SnackBar(
                                        behavior: SnackBarBehavior.floating,
                                        backgroundColor: Vx.purple500,
                                        content: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Task deleted!',
                                              style: TextStyle(
                                                  color: Vx.white,
                                                  fontSize: 20.0,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                        action: SnackBarAction(
                                          label: 'Undo',
                                          textColor: Vx.white,
                                          onPressed: () async {
                                            await _dbHelper.insertTask(newTask);
                                            newTodo.forEach((element) async {
                                              await _dbHelper
                                                  .insertTodo(element);
                                            });
                                            getTotalTask();
                                            getTotalTaskDone();
                                            setState(() {});
                                          },
                                        ),
                                      ),
                                    );
                                    getTotalTask();
                                    getTotalTaskDone();
                                    setState(() {});
                                  },
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => TodoPage(
                                            task: snapshot.data[index],
                                          ),
                                        ),
                                      ).then((value) {
                                        getTotalTask();
                                        getTotalTaskDone();
                                        setState(() {});
                                      });
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(0.0),
                                      key: UniqueKey(),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Color(0xff2A2E32),
                                            // border: Border.all(
                                            //     color: Color(0xff373C40),
                                            //     width: 1.0),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            // gradient: LinearGradient(
                                            //     colors: [
                                            //       Color(0xff414141),
                                            //       Color(0xff2E343B)
                                            //     ],
                                            //     begin: Alignment.topLeft,
                                            //     end: Alignment.bottomRight),
                                          ),
                                          child: Row(
                                            children: [
                                              Theme(
                                                child: Checkbox(
                                                    activeColor: index % 2 == 0
                                                        ? Cooloors.accentColor1
                                                        : Cooloors.accentColor2,
                                                    value: snapshot.data[index]
                                                                .isDone ==
                                                            1
                                                        ? true
                                                        : false,
                                                    onChanged: (bool value) {
                                                      _dbHelper.updateTaskDone(
                                                          snapshot
                                                              .data[index].id,
                                                          value == true
                                                              ? 1
                                                              : 0);
                                                      getTotalTask();
                                                      getTotalTaskDone();
                                                      setState(() {});
                                                    }),
                                                data: ThemeData(
                                                    unselectedWidgetColor:
                                                        index % 2 == 0
                                                            ? Cooloors
                                                                .accentColor1
                                                            : Cooloors
                                                                .accentColor2),
                                              ),
                                              VStack(
                                                [
                                                  Flexible(
                                                      child: Text(
                                                    snapshot.data[index].title,
                                                    style: TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: snapshot
                                                                    .data[index]
                                                                    .isDone ==
                                                                1
                                                            ? Vx.gray400
                                                            : Colors.white,
                                                        decoration: snapshot
                                                                    .data[index]
                                                                    .isDone ==
                                                                1
                                                            ? TextDecoration
                                                                .lineThrough
                                                            : TextDecoration
                                                                .none),
                                                  )),
                                                  10.heightBox,
                                                  Flexible(
                                                      child: Text(
                                                    snapshot.data[index]
                                                        .description,
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w900,
                                                        color: snapshot
                                                                    .data[index]
                                                                    .isDone ==
                                                                1
                                                            ? Vx.gray600
                                                            : Colors.white),
                                                  )),
                                                ],
                                                crossAlignment:
                                                    CrossAxisAlignment.start,
                                              ).p12().expand(),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 8.0),
                                                child: Icon(Icons
                                                    .chevron_right_rounded),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  background: Padding(
                                    padding: const EdgeInsets.all(4.50),
                                    child: Container(
                                      color: Vx.red500,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 8.0),
                                            child: Icon(
                                              Icons.delete_forever,
                                              size: 30.0,
                                              color: Colors.white,
                                            ),
                                          ),
                                          SizedBox(),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 8.0),
                                            child: Icon(
                                              Icons.delete_forever,
                                              size: 30.0,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    } else
                      return Padding(
                        padding: const EdgeInsets.all(26.0),
                        child: Center(
                          child: Column(
                            children: [
                              Image.asset(
                                'assets/td.png',
                                scale: 3.0,
                                color: Colors.white,
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Text(
                                'Add your tasks',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 26),
                              ),
                              Divider(
                                color: Colors.white,
                                thickness: 2.0,
                              ),
                              Row(
                                children: [
                                  Icon(Icons.control_point),
                                  SizedBox(
                                    width: 15,
                                  ),
                                  Expanded(
                                    child: RichText(
                                      text: TextSpan(children: [
                                        TextSpan(
                                          text: 'Press on the  ',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w300,
                                              fontSize: 20),
                                        ),
                                        TextSpan(
                                            text: '+  ',
                                            style: TextStyle(
                                                fontSize: 26,
                                                fontWeight: FontWeight.bold)),
                                        TextSpan(
                                          text:
                                              'button on the bottom to add task!',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w300,
                                              fontSize: 20),
                                        ),
                                      ]),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Row(
                                children: [
                                  Icon(Icons.control_point),
                                  SizedBox(
                                    width: 15,
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Tap on your tasks to add more Sub-Tasks!',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 20),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Row(
                                children: [
                                  Icon(Icons.control_point),
                                  SizedBox(
                                    width: 15,
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Swipe to delete your task!',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 20),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                  }),
            ),
          ],
        ),
        floatingActionButton: Builder(
          builder: (context) => FloatingActionButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Taskinput()),
              ).then((value) {
                getTotalTask();
                getTotalTaskDone();
                setState(() {});
              });
            },
            backgroundColor: Cooloors.accentColor2,
            child: Icon(Icons.add, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

Future<bool> promptUser(BuildContext context) async {
  return showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              elevation: 2.0,
              backgroundColor: Colors.white70,
              content: Text(
                "Are you sure you want to Delete?",
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
              actions: <Widget>[
                ButtonBar(
                  mainAxisSize: MainAxisSize
                      .min, // this will take space as minimum as posible(to center)
                  children: <Widget>[
                    RaisedButton(
                      color: Colors.red,
                      child: Text(
                        "Delete",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      },
                    ),
                    new RaisedButton(
                      child: Text('Cancel'),
                      onPressed: () {
                        return Navigator.of(context).pop(false);
                      },
                    ),
                  ],
                ),
              ],
            );
          }) ??
      false; // In case the user dismisses the dialog by clicking away from it
}
