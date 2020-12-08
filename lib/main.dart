import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:todo/models/database_helper.dart';
import 'package:todo/models/task_model.dart';
import 'package:todo/models/todo_model.dart';
import 'package:todo/screens/task_input.dart';
import 'package:todo/screens/todo.dart';
import 'package:todo/widgets/task_card.dart';
import 'package:velocity_x/velocity_x.dart';
import 'dart:ui';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  DatabaseHelper _dbHelper = DatabaseHelper();
  int totalTodo;
  int totalTask;
  int totalTaskDone;
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
        backgroundColor: Color(0xff222831),
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
                                    bottomLabelStyle: TextStyle(
                                        color: Colors.cyan,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500),
                                    topLabelStyle: TextStyle(
                                        color: Colors.orange,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500),
                                    topLabelText: "Completed :",
                                    mainLabelStyle: TextStyle(
                                        color: Colors.white,
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold),
                                    bottomLabelText:
                                        totalTaskDone / totalTask * 100 != 100
                                            ? "Keep Going!"
                                            : "Well Done"),
                                animationEnabled: true,
                                customColors: CustomSliderColors(
                                    dynamicGradient: true,
                                    progressBarColors: [
                                      Colors.pink,
                                      Colors.white,
                                      Colors.blue,
                                    ],
                                    shadowColor: Colors.blue,
                                    shadowMaxOpacity: 0.5),
                                customWidths: CustomSliderWidths(
                                  progressBarWidth: 12,
                                  shadowWidth: 5.0,
                                )),
                            min: 0,
                            max: 100,
                            initialValue: totalTaskDone != null
                                ? totalTaskDone / totalTask * 100
                                : 0,
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
                                        setState(() {});
                                      });
                                    },
                                    child: Container(
                                      key: UniqueKey(),
                                      child: HStack([
                                        Theme(
                                          child: Checkbox(
                                              activeColor: Color(0xff222831),
                                              value:
                                                  snapshot.data[index].isDone ==
                                                          1
                                                      ? true
                                                      : false,
                                              onChanged: (bool value) {
                                                _dbHelper.updateTaskDone(
                                                    snapshot.data[index].id,
                                                    value == true ? 1 : 0);
                                                getTotalTask();
                                                getTotalTaskDone();
                                                setState(() {});
                                              }),
                                          data: ThemeData(
                                              unselectedWidgetColor:
                                                  Colors.white),
                                        ),
                                        VStack(
                                          [
                                            Flexible(
                                                child: Text(
                                              snapshot.data[index].title,
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w700,
                                                  color: snapshot.data[index]
                                                              .isDone ==
                                                          1
                                                      ? Vx.gray400
                                                      : Color(0xffbbe1fa),
                                                  decoration: snapshot
                                                              .data[index]
                                                              .isDone ==
                                                          1
                                                      ? TextDecoration
                                                          .lineThrough
                                                      : TextDecoration.none),
                                            )),
                                            10.heightBox,
                                            Flexible(
                                                child: Text(
                                              snapshot.data[index].description,
                                              style: TextStyle(
                                                  color: snapshot.data[index]
                                                              .isDone ==
                                                          1
                                                      ? Vx.gray600
                                                      : Color(0xfff2a365)),
                                            )),
                                          ],
                                          crossAlignment:
                                              CrossAxisAlignment.start,
                                        ).p12().expand(),
                                        Icon(Icons.chevron_right_rounded)
                                      ])
                                          .backgroundColor(Color(0xff30475e))
                                          .px12()
                                          .py4(),
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
                setState(() {});
              });
            },
            backgroundColor: Color(0xffbbe1fa),
            child: Icon(
              Icons.add,
              color: Color(0xff222831),
            ),
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

class TaskCard extends StatefulWidget {
  final Task task;
  int totalTodo;
  TaskCard({Key key, this.task, this.totalTodo}) : super(key: key);

  @override
  _TaskCardState createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  int taskId;
  DatabaseHelper dbHelper = DatabaseHelper();
  bool isdone;
  @override
  void initState() {
    super.initState();
    if (widget.task.isDone == 0) {
      isdone = false;
    } else {
      isdone = true;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: UniqueKey(),
      child: HStack([
        Theme(
          child: Checkbox(
              activeColor: Color(0xff222831),
              value: isdone,
              onChanged: (bool value) {
                dbHelper.updateTaskDone(widget.task.id, value == true ? 1 : 0);
                setState(() {
                  isdone = value;
                });
              }),
          data: ThemeData(unselectedWidgetColor: Colors.white),
        ),
        VStack(
          [
            Flexible(
              child: widget.task.title.text != null
                  ? widget.task.title.text.bold
                      .textStyle(
                        TextStyle(
                            color: isdone ? Vx.gray400 : Color(0xffbbe1fa),
                            decoration: isdone
                                ? TextDecoration.lineThrough
                                : TextDecoration.none),
                      )
                      .size(20)
                      .make()
                  : "Unnamed task".text.make(),
            ),
            10.heightBox,
            Flexible(
              child: widget.task.description.text != null
                  ? widget.task.description.text
                      .textStyle(TextStyle(
                          color: isdone ? Vx.gray600 : Color(0xfff2a365)))
                      .size(16)
                      .make()
                  : SizedBox(
                      height: 0.0,
                    ),
            ),
          ],
          crossAlignment: CrossAxisAlignment.start,
        ).p12().expand(),
        Icon(Icons.chevron_right_rounded)
      ]).backgroundColor(Color(0xff30475e)).px12().py4(),
    );
  }
}
