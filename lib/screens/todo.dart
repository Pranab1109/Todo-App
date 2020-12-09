import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:todo/cooloors.dart';
import 'package:todo/models/database_helper.dart';
import 'package:todo/models/task_model.dart';
import 'package:todo/models/todo_model.dart';
import 'package:velocity_x/velocity_x.dart';

class TodoPage extends StatefulWidget {
  final Task task;
  TodoPage({Key key, this.task}) : super(key: key);

  @override
  _TodoPageState createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  TextEditingController todoEditingController;
  DatabaseHelper dbHelper = DatabaseHelper();

  int totalTodo;
  int totalTodoDone;
  int _taskId = 0;
  int rem;
  //bool check;

  int totalTodoRem;
  @override
  void initState() {
    super.initState();
    todoEditingController = TextEditingController();
    _taskId = widget.task.id;
    totalTodos();
    totalTodosDone();
    totalTodosRem();
  }

  void totalTodos() async {
    totalTodo = await dbHelper.totalTodo(widget.task.id);
    setState(() {});
  }

  void totalTodosDone() async {
    totalTodoDone = await dbHelper.totalTodoDone(widget.task.id);
    setState(() {});
  }

  void totalTodosRem() async {
    totalTodoRem = await dbHelper.totalTodoRem(widget.task.id);
    setState(() {});
  }

  var _formKey = GlobalKey<FormState>();
  DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Scaffold(
        backgroundColor: Cooloors.primaryColor1,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 50.0),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        size: 24,
                        color: Cooloors.accentColor2,
                      ),
                      onPressed: () {
                        Navigator.pop(context, totalTodo.toString());
                      }),
                  Text(widget.task.title,
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ))
                ],
              ),
              Theme(
                data: ThemeData(
                  primaryColor: Cooloors.accentColor2,
                ),
                child: TextFormField(
                  cursorColor: Cooloors.accentColor1,
                  style: TextStyle(color: Colors.white),

                  // ignore: missing_return
                  validator: (String value) {
                    if (value.isEmpty) {
                      return 'Enter a text !';
                    }
                  },
                  textCapitalization: TextCapitalization.sentences,
                  onFieldSubmitted: (value) async {
                    if (_formKey.currentState.validate()) {
                      Todo _newTodo = Todo(
                        title: todoEditingController.text,
                        isDone: 0,
                        taskId: widget.task.id,
                      );
                      await _dbHelper.insertTodo(_newTodo);
                      setState(() {
                        todoEditingController.clear();
                      });
                    }
                  },
                  controller: todoEditingController,
                  decoration: InputDecoration(
                    hintStyle: TextStyle(
                        color: Colors.white,
                        fontFamily: 'NerkoOne',
                        fontSize: 20),
                    errorStyle: TextStyle(
                        fontSize: 18,
                        color: Vx.red100,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'NerkoOne'),
                    fillColor: Vx.gray100.withOpacity(0.3),
                    filled: true,
                    border: InputBorder.none,
                    hintText: "What to do?",
                    prefixIcon: Icon(Icons.text_fields_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.done),
                      onPressed: () async {
                        if (_formKey.currentState.validate()) {
                          Todo _newTodo = Todo(
                            title: todoEditingController.text,
                            isDone: 0,
                            taskId: widget.task.id,
                          );
                          await _dbHelper.insertTodo(_newTodo);
                          setState(() {
                            todoEditingController.clear();
                          });
                        }
                      },
                    ),
                  ),
                ).cornerRadius(16.0),
              ),
              /*TodoCard(
                todo: todo == null ? "" : "$todo",
              ),*/
              20.heightBox,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Your Tasks : ',
                    style: TextStyle(
                        fontSize: 32.0,
                        // fontWeight: FontWeight.w700,
                        color: Colors.white),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      RichText(
                        text: TextSpan(children: [
                          TextSpan(
                              text: 'Total todo: ',
                              style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontFamily: 'NerkoOne')),
                          TextSpan(
                              text: '$totalTodo',
                              style: TextStyle(
                                color: Cooloors.accentColor1,
                                // fontWeight: FontWeight.bold,
                                fontFamily: 'NerkoOne',
                                fontSize: 16,
                              )),
                        ]),
                      ),
                      RichText(
                        text: TextSpan(children: [
                          TextSpan(
                              text: 'Done: ',
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Colors.white,
                                fontFamily: 'NerkoOne',
                                fontSize: 16,
                              )),
                          TextSpan(
                              text: '$totalTodoDone',
                              style: TextStyle(
                                color: Cooloors.accentColor1,
                                // fontWeight: FontWeight.bold,
                                fontFamily: 'NerkoOne',
                                fontSize: 16,
                              )),
                        ]),
                      ),
                      RichText(
                        text: TextSpan(children: [
                          TextSpan(
                              text: 'Remaining: ',
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Colors.white,
                                fontFamily: 'NerkoOne',
                                fontSize: 16,
                              )),
                          TextSpan(
                              text: '$totalTodoRem',
                              style: TextStyle(
                                color: Cooloors.accentColor1,
                                // fontWeight: FontWeight.bold,
                                fontFamily: 'NerkoOne',
                                fontSize: 16,
                              )),
                        ]),
                      ),
                    ],
                  )
                ],
              ),
              Expanded(
                child: FutureBuilder(
                    initialData: [],
                    future: _dbHelper.getTodo(_taskId),
                    builder: (context, snapshot) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        setState(() {
                          totalTodo = snapshot.data.length;
                        });
                      });
                      return ListView.builder(
                          itemCount: snapshot.data.length,
                          itemBuilder: (context, index) {
                            totalTodo = snapshot.data.length;
                            return GestureDetector(
                                onTap: () async {
                                  if (snapshot.data[index].isDone == 0) {
                                    await _dbHelper.updateTodoDone(
                                        snapshot.data[index].id, 1);
                                  } else {
                                    await _dbHelper.updateTodoDone(
                                        snapshot.data[index].id, 0);
                                  }
                                  setState(() {});
                                },
                                child: Container(
                                  child: Row(
                                    children: [
                                      Theme(
                                        data: ThemeData(
                                            unselectedWidgetColor:
                                                index % 2 == 0
                                                    ? Cooloors.accentColor1
                                                    : Cooloors.accentColor2),
                                        child: Checkbox(
                                            checkColor: Cooloors.primaryColor1,
                                            activeColor: index % 2 == 0
                                                ? Cooloors.accentColor1
                                                : Cooloors.accentColor2,
                                            value:
                                                snapshot.data[index].isDone == 0
                                                    ? false
                                                    : true,
                                            onChanged: (bool value) {
                                              _dbHelper.updateTodoDone(
                                                  snapshot.data[index].id,
                                                  value == true ? 1 : 0);
                                              totalTodosDone();
                                              totalTodosRem();
                                              setState(() {});
                                            }),
                                      ),
                                      Flexible(
                                        child:
                                            snapshot.data[index].title != null
                                                ? Text(
                                                    "${snapshot.data[index].title}",
                                                    style: TextStyle(
                                                      fontSize: 25,
                                                      color: snapshot
                                                                  .data[index]
                                                                  .isDone ==
                                                              1
                                                          ? Vx.gray600
                                                          : Colors.white,
                                                      decoration: snapshot
                                                                  .data[index]
                                                                  .isDone ==
                                                              1
                                                          ? TextDecoration
                                                              .lineThrough
                                                          : TextDecoration.none,
                                                    ),
                                                  )
                                                : "Unnamed task".text.make(),
                                      ),
                                    ],
                                  ),
                                ));
                          });
                    }),
              )
            ],
          ),
        ),
      ),
    );
  }
}
