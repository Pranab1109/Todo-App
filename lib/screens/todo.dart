import 'dart:ui';

import 'package:flutter/material.dart';
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
        backgroundColor: Color(0xff222831),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 50.0),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios,
                        size: 24,
                        color: Color(0xffbbe1fa),
                      ),
                      onPressed: () {
                        Navigator.pop(context, totalTodo.toString());
                      }),
                  "${widget.task.title}"
                      .text
                      .bold
                      .size(28)
                      .textStyle(TextStyle(
                        color: Color(0xffbbe1fa),
                      ))
                      .make(),
                ],
              ),
              Theme(
                data: ThemeData(primaryColor: Color(0xfff2a365)),
                child: TextFormField(
                  style: TextStyle(color: Color(0xffbbe1fa)),
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
                    hintStyle: TextStyle(color: Colors.white),
                    errorStyle: TextStyle(
                      fontSize: 14,
                      color: Vx.red100,
                      fontWeight: FontWeight.w700,
                    ),
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
                        fontSize: 24.0,
                        fontWeight: FontWeight.w700,
                        color: Color(0xffbbe1fa)),
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
                                  color: Color(0xffbbe1fa))),
                          TextSpan(
                              text: '$totalTodo',
                              style: TextStyle(
                                  color: Color(0xfff2a365),
                                  fontWeight: FontWeight.bold)),
                        ]),
                      ),
                      RichText(
                        text: TextSpan(children: [
                          TextSpan(
                              text: 'Done: ',
                              style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: Color(0xffbbe1fa))),
                          TextSpan(
                              text: '$totalTodoDone',
                              style: TextStyle(
                                  color: Color(0xfff2a365),
                                  fontWeight: FontWeight.bold)),
                        ]),
                      ),
                      RichText(
                        text: TextSpan(children: [
                          TextSpan(
                              text: 'Remaining: ',
                              style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: Color(0xffbbe1fa))),
                          TextSpan(
                              text: '$totalTodoRem',
                              style: TextStyle(
                                  color: Color(0xfff2a365),
                                  fontWeight: FontWeight.bold)),
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
                                                Colors.white),
                                        child: Checkbox(
                                            activeColor: Color(0xff222831),
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
                                        child: snapshot.data[index].title !=
                                                null
                                            ? Text(
                                                "${snapshot.data[index].title}",
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    color: snapshot.data[index]
                                                                .isDone ==
                                                            1
                                                        ? Vx.gray600
                                                        : Color(0xfff2a365),
                                                    decoration: snapshot
                                                                .data[index]
                                                                .isDone ==
                                                            1
                                                        ? TextDecoration
                                                            .lineThrough
                                                        : TextDecoration.none,
                                                    fontWeight: snapshot
                                                                .data[index]
                                                                .isDone ==
                                                            1
                                                        ? FontWeight.normal
                                                        : FontWeight.bold),
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
