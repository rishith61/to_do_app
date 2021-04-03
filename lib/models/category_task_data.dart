class CategoryTasks {
  String categoryTaskTitle;
  bool categoryTaskcompleted = false;

  CategoryTasks({
    this.categoryTaskTitle,
    this.categoryTaskcompleted = false,
  });

  CategoryTasks.fromMap(Map map)
      : this.categoryTaskTitle = map['categoryTaskTitle'],
        this.categoryTaskcompleted = map['categoryCompleted'];

  Map toMap() {
    return {
      'categoryTaskTitle': this.categoryTaskTitle,
      'categoryCompleted': this.categoryTaskcompleted,
    };
  }
}
