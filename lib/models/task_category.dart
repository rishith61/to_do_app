class CategoryTodo {
  String categorytitle;

  CategoryTodo({
    this.categorytitle,
  });

  CategoryTodo.fromMap(Map map) : this.categorytitle = map['categorytitle'];

  Map toMap() {
    return {
      'categorytitle': this.categorytitle,
    };
  }
}
