class Todo {
  String title;
  bool completed = false;

  Todo({
    this.title,
    this.completed = false,
  });

  Todo.fromMap(Map map)
      : this.title = map['title'],
        this.completed = map['completed'];

  Map toMap() {
    return {
      'title': this.title,
      'completed': this.completed,
    };
  }
}
