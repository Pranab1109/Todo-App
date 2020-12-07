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
  @override
  void initState() {
    super.initState();
    getTotalTodo();
  }

  getTotalTodo() async {
    totalTodo = await _dbHelper.totalTodo(taskId);
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
          // actions: [
          //   IconButton(
          //     icon: Icon(
          //       Icons.info,
          //       color: Colors.white,
          //     ),
          //     onPressed: () {},
          //   )
          // ],
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
                                animationEnabled: true,
                                customColors: CustomSliderColors(
                                    progressBarColors: [
                                      Colors.white,
                                      Colors.blue
                                    ]),
                                customWidths:
                                    CustomSliderWidths(progressBarWidth: 10)),
                            min: 0,
                            max: 100,
                            initialValue: 60,
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
                                            setState(() {});
                                          },
                                        ),
                                      ),
                                    );
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
                                        setState(() {});
                                      });
                                    },
                                    child: TaskCard(
                                      key: UniqueKey(),
                                      task: snapshot.data[index],
                                      totalTodo: totalTodo,
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
