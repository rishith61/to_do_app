import 'dart:convert';
import 'package:circular_check_box/circular_check_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:theme_provider/theme_provider.dart';
import 'package:to_do_6/models/category_task_data.dart';
import 'package:to_do_6/models/task_category.dart';

class NewCategoryTask extends StatefulWidget {
  @override
  _NewCategoryTaskState createState() => _NewCategoryTaskState();
  final String taskName;
  final CategoryTodo category;
  final CategoryTasks categoryTaskItem;
  NewCategoryTask(
      {Key key, @required this.taskName, this.category, this.categoryTaskItem})
      : super(key: key);
}

AppTheme customDarkTheme() {
  ScreenScaler scaler = new ScreenScaler();
  return AppTheme(
    id: "dark_theme",
    description: "Custom Color Scheme",
    data: ThemeData(
      textTheme: TextTheme(
          bodyText1: TextStyle(
              fontFamily: 'KumbhSans',
              fontSize: scaler.getTextSize(8),
              fontWeight: FontWeight.bold),
          bodyText2: TextStyle(
            color: Colors.white,
            fontFamily: 'KumbhSans',
            fontWeight: FontWeight.bold,
            fontSize: scaler.getTextSize(10),
          )),
      brightness: Brightness.dark,
      hintColor: Colors.white,
    ),
  );
}

AppTheme customLightTheme() {
  ScreenScaler scaler = new ScreenScaler();
  return AppTheme(
    id: "light_theme",
    description: "Custom Color Scheme",
    data: ThemeData(
      textTheme: TextTheme(
          bodyText1: TextStyle(
              color: Colors.black,
              fontFamily: 'KumbhSans',
              fontSize: scaler.getTextSize(8),
              fontWeight: FontWeight.bold),
          bodyText2: TextStyle(
            color: Colors.black,
            fontFamily: 'KumbhSans',
            fontWeight: FontWeight.bold,
            fontSize: scaler.getTextSize(10),
          )),
      primaryColor: Colors.white,
      brightness: Brightness.light,
    ),
  );
}

class _NewCategoryTaskState extends State<NewCategoryTask>
    with SingleTickerProviderStateMixin {
  SharedPreferences sharedPreferences;
  List<CategoryTodo> categoryTodos = [];
  List<CategoryTasks> categoryTasks = [];
  TextEditingController _categoryTaskTextEditingContoller;
  TextEditingController _categoriesTextController;
  GlobalKey<FormState> _categoryFormKey = GlobalKey<FormState>();
  int index;

  @override
  void initState() {
    loadCategoryTasksWithData();
    _categoryTaskTextEditingContoller = new TextEditingController();
    _categoriesTextController = new TextEditingController();
    super.initState();
  }

  void loadCategoryTasksWithData() async {
    sharedPreferences = await SharedPreferences.getInstance();
    loadCategoryTasks();
  }

  void removeCategoryTasks(CategoryTasks categoryTaskItem) {
    categoryTasks.remove(categoryTaskItem);
    saveCategoryTasks();
    loadCategoryTasks();
  }

  void addCategoryTasks(CategoryTasks categoryTaskItem) {
    categoryTasks.add(categoryTaskItem);
    saveCategoryTasks();
    loadCategoryTasks();
  }

  void submitcategoryTasks() async {
    Navigator.of(context).pop(_categoryTaskTextEditingContoller.text);
    setState(() {});
  }

  void categorytaskIsdone(CategoryTasks categoryTaskItem) {
    setState(() {
      categoryTaskItem.categoryTaskcompleted =
          !categoryTaskItem.categoryTaskcompleted;
    });
    saveCategoryTasks();
    loadCategoryTasks();
  }

  void submitCategories() async {
    Navigator.of(context).pop(_categoriesTextController.text);
    setState(() {});
  }

  void editCategoryTask(CategoryTasks categoryTasks, String catTitle) {
    categoryTasks.categoryTaskTitle = catTitle;
    saveCategoryTasks();
    loadCategoryTasks();
  }

  void editCategory(CategoryTodo category, String catTitle) {
    category.categorytitle = catTitle;
    saveCategoryTasks();
    loadCategoryTasks();
  }

  void saveCategoryTasks() {
    List<String> stringListCategoryTasks = categoryTasks
        .map((categoryTasksItem) => json.encode(categoryTasksItem.toMap()))
        .toList();
    sharedPreferences.setStringList('categoryTasks', stringListCategoryTasks);

    setState(() {});
  }

  void loadCategoryTasks() {
    List<String> listCategoryTasks =
        sharedPreferences.getStringList('categoryTasks') ?? [];
    if (listCategoryTasks != null) {
      categoryTasks = listCategoryTasks
          .map((categoryTasksItem) =>
              CategoryTasks.fromMap(json.decode(categoryTasksItem)))
          .toList();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenScaler scaler = new ScreenScaler()..init(context);
    return ThemeConsumer(
        child: Builder(
      builder: (themeContext) => MaterialApp(
        theme: ThemeProvider.themeOf(context).data,
        home: Scaffold(
            resizeToAvoidBottomInset: false,
            floatingActionButton: FloatingActionButton(
              backgroundColor: Colors.blue,
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return Theme(
                        data: ThemeProvider.themeOf(context).data,
                        child: AlertDialog(
                          elevation: 9,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40)),
                          content: Form(
                            key: _categoryFormKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Padding(
                                  padding: scaler.getPaddingLTRB(0, 2, 0, 1),
                                  child: Center(
                                    child: Text(
                                      "Add new task",
                                      style: TextStyle(
                                          fontSize: 30,
                                          fontFamily: "KumbhSans",
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Padding(
                                  padding: scaler.getPaddingLTRB(1, 0, 1, 2),
                                  child: TextFormField(
                                    expands: false,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                          new RegExp("^[a-zA-Z , 0-9 -]*"))
                                    ],
                                    autofocus: false,
                                    controller:
                                        _categoryTaskTextEditingContoller,
                                    onFieldSubmitted: (value) {
                                      submitcategoryTasks();
                                      _categoryTaskTextEditingContoller.clear();
                                    },
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18),
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.all(18),
                                      labelText: 'New task',
                                      labelStyle: TextStyle(color: Colors.grey),
                                      focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            width: 2,
                                            color: Colors.grey,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(40)),
                                      enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            width: 2,
                                            color: Colors.grey,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(40)),
                                      errorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            width: 2,
                                            color: Colors.red,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(40)),
                                      focusedErrorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            width: 2,
                                            color: Colors.red,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(40)),
                                    ),
                                  ),
                                ),
                                Container(
                                  height: 55,
                                  width:
                                      MediaQuery.of(context).size.width / 1.1,
                                  // ignore: deprecated_member_use
                                  child: FlatButton(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(40)),
                                    color: Colors.blue,
                                    onPressed: () async {
                                      if (_categoryFormKey.currentState
                                          .validate()) {
                                        submitcategoryTasks();
                                        _categoryTaskTextEditingContoller
                                            .clear();
                                      }
                                    },
                                    child: Text(
                                      'Add',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontFamily: "KumbhSans",
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 30)
                              ],
                            ),
                          ),
                        ),
                      );
                    }).then((categoryTaskItem) {
                  if (categoryTaskItem != null) {
                    addCategoryTasks(CategoryTasks(
                      categoryTaskTitle: categoryTaskItem,
                    ));
                  }
                });
              },
              child: Icon(Icons.add, color: Colors.white),
            ),
            body: Column(
              children: [
                Row(
                  children: [
                    SafeArea(
                      minimum: scaler.getPaddingLTRB(0, 4, 0, 0),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: IconButton(
                            iconSize: scaler.getHeight(3),
                            icon: Icon(Icons.arrow_back_rounded),
                            onPressed: () {
                              Navigator.pop(context);
                            }),
                      ),
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: scaler.getPadding(1, 5),
                    child: Text(widget.taskName,
                        style: TextStyle(
                          fontSize: scaler.getTextSize(18),
                          fontFamily: "KumbhSans",
                          fontWeight: FontWeight.bold,
                        )),
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: scaler.getPadding(0, 5),
                    child: Text(
                      categoryTasks.isEmpty
                          ? "No tasks 😁"
                          : '${categoryTasks.length}' + " task(s)",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: scaler.getTextSize(14),
                        fontFamily: "KumbhSans",
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Expanded(child: buildCategoryTasksListView()),
              ],
            )),
      ),
    ));
  }

  Widget emptyList() {
    ScreenScaler scaler = new ScreenScaler()..init(context);
    return Center(
        child: Text('No tasks,hooray!!',
            style: TextStyle(
                fontSize: scaler.getTextSize(15),
                color: Colors.grey,
                fontFamily: "KumbhSans",
                fontWeight: FontWeight.bold)));
  }

  Widget buildCategoryTasksListView() {
    return ListView.builder(
      physics: BouncingScrollPhysics(),
      itemCount: categoryTasks.length,
      itemBuilder: (BuildContext context, int index) {
        return buildCategoryItem(categoryTasks[index], index);
      },
    );
  }

  Widget buildCategoryItem(CategoryTasks categoryTaskItem, int index) {
    return Dismissible(
      key: Key('${categoryTasks[index].hashCode}'),
      background: Padding(
        padding: const EdgeInsets.only(top: 5, bottom: 5),
        child: Container(height: 90, color: Colors.transparent),
      ),
      onDismissed: (direction) => removeCategoryTasks(categoryTaskItem),
      direction: DismissDirection.startToEnd,
      child: buildCategoryListTile(categoryTaskItem, index),
    );
  }

  Widget buildCategoryListTile(CategoryTasks categoryTaskItem, int index) {
    ScreenScaler scaler = new ScreenScaler()..init(context);
    return GestureDetector(
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Container(
              child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    onTap: () {
                      setState(() {
                        this.categorytaskIsdone(categoryTaskItem);
                      });
                    },
                    leading: CircularCheckBox(
                        activeColor: Colors.blue,
                        disabledColor: Colors.grey,
                        value: categoryTasks[index].categoryTaskcompleted,
                        onChanged: (bool val) {
                          setState(() {
                            this.categoryTasks[index].categoryTaskcompleted =
                                !this
                                    .categoryTasks[index]
                                    .categoryTaskcompleted;
                          });
                        }),
                    title: SafeArea(
                        child: Align(
                      alignment: Alignment.centerLeft,
                      child: SafeArea(
                          minimum: scaler.getPadding(1, 0),
                          child: RichText(
                            text: TextSpan(
                                style: TextStyle(
                                    fontSize: 24,
                                    fontFamily: "KumbhSans",
                                    fontWeight: FontWeight.bold,
                                    decoration:
                                        categoryTaskItem.categoryTaskcompleted
                                            ? TextDecoration.lineThrough
                                            : null),
                                children: [
                                  TextSpan(
                                      text: categoryTasks[index]
                                          .categoryTaskTitle,
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontFamily: "KumbhSans",
                                        fontWeight: FontWeight.bold,
                                      ))
                                ]),
                          )),
                    )),
                    trailing: SafeArea(
                      child: IconButton(
                        onPressed: () {
                          removeCategoryTasks(categoryTaskItem);
                          setState(() {});
                        },
                        icon: Icon(Icons.delete_outline_rounded),
                      ),
                    ),
                  )),
            )));
  }
}
