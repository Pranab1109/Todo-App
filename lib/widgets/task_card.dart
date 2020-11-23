import 'package:flutter/material.dart';
import 'package:todo/models/database_helper.dart';
import 'package:todo/models/task_model.dart';
import 'package:velocity_x/velocity_x.dart';

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
    return HStack([
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
    ]).backgroundColor(Color(0xff30475e)).px12().py4();
  }
}
