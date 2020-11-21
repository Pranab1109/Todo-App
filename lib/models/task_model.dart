class Task {
  final int id;
  final String title;
  final String description;
  final int isDone;

  Task({this.id, this.title, this.description, this.isDone});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isDone': isDone
    };
  }
}
