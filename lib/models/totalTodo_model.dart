import 'package:scoped_model/scoped_model.dart';

class TodoNumber extends Model {
  Map<int, int> map1 = {};
  Map<int, int> map2 = {};
  int remTodo;
  totalTodo(int id) {
    map1[id]++;
    notifyListeners();
  }

  doneTodo(int id) {
    map2[id]++;
    notifyListeners();
  }

  remTodos(int id) {
    remTodo = map1[id] - map2[id];
    notifyListeners();
  }
}
