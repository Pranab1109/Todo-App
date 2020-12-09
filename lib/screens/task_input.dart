import 'package:flutter/material.dart';
import 'package:todo/cooloors.dart';
import 'package:todo/models/database_helper.dart';
import 'package:todo/models/task_model.dart';
import 'package:velocity_x/velocity_x.dart';

class Taskinput extends StatefulWidget {
  @override
  _TaskinputState createState() => _TaskinputState();
}

class _TaskinputState extends State<Taskinput> {
  TextEditingController titleEditor;
  TextEditingController descriptionEditor;
  String title;
  String details;
  @override
  void initState() {
    super.initState();
    titleEditor = TextEditingController();
    descriptionEditor = TextEditingController();
  }

  var _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Scaffold(
          backgroundColor: Cooloors.primaryColor1,
          body: Padding(
            padding: const EdgeInsets.fromLTRB(16, 40, 16, 40),
            child: Column(
              children: [
                Row(
                  //mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                        icon: Icon(
                          Icons.arrow_left_rounded,
                          size: 50,
                          color: Cooloors.accentColor1,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        }),
                    Spacer(),
                    Center(
                        child: Text(
                      "What's up next?",
                      style:
                          TextStyle(fontSize: 26, color: Cooloors.accentColor1),
                    )),
                    Spacer(),
                  ],
                ),
                20.heightBox,
                Theme(
                  data: ThemeData(
                    primaryColor: Cooloors.accentColor1,
                    cursorColor: Cooloors.accentColor1,
                  ),
                  child: TextFormField(
                    autofocus: true, cursorColor: Cooloors.accentColor1,
                    style: TextStyle(
                      color: Colors.white,
                    ),
                    controller: titleEditor,

                    // ignore: missing_return
                    validator: (String value) {
                      if (value.isEmpty) {
                        return '   Please enter a title';
                      }
                    },
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                        focusColor: Cooloors.accentColor1,

                        // labelText: 'Title',
                        //alignLabelWithHint: false,
                        contentPadding: EdgeInsets.only(top: 14.0),
                        //helperText: ' ',
                        prefixIcon: Icon(Icons.text_fields_rounded),
                        hintText: 'Title',
                        hintStyle: TextStyle(
                            color: Colors.white,
                            fontFamily: 'NerkoOne',
                            fontSize: 20),
                        border: InputBorder.none,
                        filled: true,
                        fillColor: Vx.purple100.withOpacity(0.3),
                        errorStyle: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14)),
                  ).cornerRadius(16.0),
                ),
                20.heightBox,
                Theme(
                  data: ThemeData(primaryColor: Cooloors.accentColor1),
                  child: TextFormField(
                    cursorColor: Cooloors.accentColor1,
                    style: TextStyle(color: Colors.white),
                    controller: descriptionEditor,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.only(top: 14.0),
                        prefixIcon: Icon(Icons.text_fields_rounded),
                        hintText: 'Task details',
                        hintStyle: TextStyle(
                            color: Colors.white,
                            fontFamily: 'NerkoOne',
                            fontSize: 20),
                        border: InputBorder.none,
                        filled: true,
                        fillColor: Vx.purple100.withOpacity(0.3),
                        errorStyle: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14)),
                  ).cornerRadius(16.0),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Cooloors.accentColor2,
            onPressed: () async {
              if (_formKey.currentState.validate()) {
                setState(() {
                  title = titleEditor.text;
                  details = descriptionEditor.text;
                });

                Navigator.pop(context);
                DatabaseHelper _dbHelper = DatabaseHelper();
                if (titleEditor.text != "" || titleEditor != null) {
                  Task newTask =
                      Task(title: title, description: details, isDone: 0);
                  await _dbHelper.insertTask(newTask);
                }
              }
            },
            child: Icon(
              Icons.thumb_up_alt_outlined,
              color: Cooloors.primaryColor1,
            ),
            elevation: 3.0,
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
        ),
      ),
    );
  }
}
