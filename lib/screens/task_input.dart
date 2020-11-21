import 'package:flutter/material.dart';
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
          backgroundColor: Color(0xff222831),
          body: Padding(
            padding: const EdgeInsets.fromLTRB(16, 40, 16, 40),
            child: Column(
              children: [
                Row(
                  //mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                        icon: Icon(Icons.backspace),
                        onPressed: () {
                          Navigator.pop(context);
                        }),
                    Spacer(),
                    Center(
                      child: "What's up next?".text.bold.size(26.0).make(),
                    ),
                    Spacer(),
                  ],
                ),
                20.heightBox,
                Theme(
                  data: ThemeData(primaryColor: Color(0xfff2a365)),
                  child: TextFormField(
                    controller: titleEditor,

                    // ignore: missing_return
                    validator: (String value) {
                      if (value.isEmpty) {
                        return '   Please enter a title';
                      }
                    },
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(

                        // labelText: 'Title',
                        //alignLabelWithHint: false,
                        contentPadding: EdgeInsets.only(top: 14.0),
                        //helperText: ' ',
                        prefixIcon: Icon(Icons.text_fields_rounded),
                        hintText: 'Title',
                        border: InputBorder.none,
                        filled: true,
                        fillColor: Vx.purple100.withOpacity(0.3),
                        errorStyle: TextStyle(
                            color: Vx.purple900,
                            fontWeight: FontWeight.bold,
                            fontSize: 14)),
                  ).cornerRadius(16.0).cornerRadius(0.0),
                ),
                20.heightBox,
                Theme(
                  data: ThemeData(primaryColor: Color(0xfff2a365)),
                  child: VxTextField(
                    borderType: VxTextFieldBorderType.none,
                    controller: descriptionEditor,
                    autofocus: false,
                    clear: false,
                    hint: "Task details",
                    fillColor: Vx.purple100.withOpacity(0.3),
                    borderRadius: 18,
                    contentPaddingTop: 15.0,
                    prefixIcon: Icon(Icons.notes),
                  ).cornerRadius(16.0),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
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
            child: Icon(Icons.thumb_up_alt_outlined),
            elevation: 3.0,
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
        ),
      ),
    );
  }
}