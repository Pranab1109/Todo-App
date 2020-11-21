import 'package:flutter/material.dart';
import 'package:todo/models/database_helper.dart';
import 'package:velocity_x/velocity_x.dart';

class TodoCard extends StatefulWidget {
  final String todoTitle;
  final int isDone;
  final int id;

  const TodoCard({Key key, @required this.todoTitle, this.isDone, this.id})
      : super(key: key);
  @override
  _TodoCardState createState() => _TodoCardState();
}

class _TodoCardState extends State<TodoCard> {
  DatabaseHelper _dbHelper = DatabaseHelper();
  int isdone;
  bool check;
  @override
  void initState() {
    super.initState();
    isdone = widget.isDone;
    if (isdone == 0) {
      check = false;
    } else {
      check = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          Theme(
            data: ThemeData(unselectedWidgetColor: Colors.white),
            child: Checkbox(
                activeColor: Color(0xff222831),
                value: check,
                onChanged: (bool value) {
                  _dbHelper.updateTodoDone(widget.id, value == true ? 1 : 0);
                  setState(() {
                    check = value;
                  });
                }),
          ),
          Flexible(
            child: widget.todoTitle.text != null
                ? widget.todoTitle.text
                    .textStyle(
                      TextStyle(
                          color: check ? Vx.gray600 : Color(0xfff2a365),
                          decoration: check
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          fontWeight:
                              check ? FontWeight.normal : FontWeight.w600),
                    )
                    .size(18)
                    .make()
                : "Unnamed task".text.make(),
          ),
        ],
      ),
    );
  }
}
