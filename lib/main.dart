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
          actions: [
            IconButton(
              icon: Icon(
                Icons.info,
                color: Colors.white,
              ),
              onPressed: () {},
            )
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: FutureBuilder(
                  initialData: [],
                  future: _dbHelper.getTask(),
                  builder: (context, snapshot) {
                    return ListView.builder(
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
                          onDismissed: (DismissDirection direction) async {
                            Task newTask = snapshot.data[index];
                            List<Todo> newTodo =
                                await _dbHelper.getTodo(newTask.id);
                            await _dbHelper.deleteTask(snapshot.data[index].id);

                            Scaffold.of(context).showSnackBar(
                              SnackBar(
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
                                      await _dbHelper.insertTodo(element);
                                    });
                                    setState(() {});
                                  },
                                ),
                              ),
                            );
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
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Icon(
                                      Icons.delete_forever,
                                      size: 30.0,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
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
              content: Text("Are you sure you want to Delete?"),
              actions: <Widget>[
                FlatButton(
                  child: Text("Delete"),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
                FlatButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    return Navigator.of(context).pop(false);
                  },
                )
              ],
            );
          }) ??
      false; // In case the user dismisses the dialog by clicking away from it
}
