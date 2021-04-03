import 'dart:convert';
import 'package:circular_check_box/circular_check_box.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:theme_provider/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:to_do_6/screens/category_tasks.dart';
import 'models/task_data.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';
import 'package:to_do_6/models/task_category.dart';
import 'package:floating_action_bubble/floating_action_bubble.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(Main());
}

class Main extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ThemeProvider(
      saveThemesOnChange: true,
      loadThemeOnInit: true,
      themes: <AppTheme>[customLightTheme(), customDarkTheme()],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: ThemeConsumer(
          child: Home(),
        ),
      ),
    );
  }
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
            fontSize: scaler.getTextSize(9),
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
            fontSize: scaler.getTextSize(9),
          )),
      primaryColor: Colors.white,
      brightness: Brightness.light,
    ),
  );
}

class Home extends StatefulWidget {
  final Todo item;
  final CategoryTodo category;
  Home({this.item, this.category});

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> with SingleTickerProviderStateMixin {
  Animation<double> _animation;
  AnimationController _animationController;
  List<Todo> todos = [];
  List<CategoryTodo> categoryTodos = [];
  SharedPreferences sharedPreferences;
  TextEditingController _quickTaskTextController;
  TextEditingController _categoriesTextController;
  int id;
  ThemeData currTheme = ThemeData.light();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  int index;

  @override
  void initState() {
    loadPrefsWithCategories();
    loadPrefsWithQuickTasks();
    _quickTaskTextController = new TextEditingController();
    _categoriesTextController = new TextEditingController();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 260),
    );

    final curvedAnimation =
        CurvedAnimation(curve: Curves.easeInOut, parent: _animationController);
    _animation = Tween<double>(begin: 0, end: 1).animate(curvedAnimation);
    super.initState();
  }

  void loadPrefsWithQuickTasks() async {
    sharedPreferences = await SharedPreferences.getInstance();
    loadQuickTasks();
  }

  void loadPrefsWithCategories() async {
    sharedPreferences = await SharedPreferences.getInstance();
    loadCategories();
  }

  void submitCategories() async {
    Navigator.of(context).pop(_categoriesTextController.text);
    setState(() {});
  }

  void submitQuickTask() async {
    Navigator.of(context).pop(_quickTaskTextController.text);
    setState(() {});
  }

  void addItem(Todo item) {
    todos.add(item);
    saveQuickTasks();
    loadQuickTasks();
  }

  void addCategory(CategoryTodo category) {
    categoryTodos.add(category);
    saveCategories();
    loadCategories();
  }

  void removeCategory(CategoryTodo category) {
    categoryTodos.remove(category);
    saveCategories();
    loadCategories();
  }

  void taskIsdone(Todo item) {
    setState(() {
      item.completed = !item.completed;
    });
    saveQuickTasks();
    loadQuickTasks();
  }

  void editTaskItem(item) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          ScreenScaler scaler = new ScreenScaler()..init(context);
          return AlertDialog(
            elevation: 9,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
            content: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: scaler.getPaddingLTRB(0, 2, 0, 1),
                    child: Text(
                      "Edit task",
                      style: TextStyle(
                          fontSize: 30,
                          fontFamily: "KumbhSans",
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: scaler.getPaddingLTRB(1, 0, 1, 2),
                    child: Theme(
                      data: ThemeProvider.themeOf(context).data,
                      child: TextFormField(
                        expands: false,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              new RegExp("^[a-zA-Z , 0-9 -]*"))
                        ],
                        maxLength: 16,
                        maxLines: 1,
                        autofocus: false,
                        controller: _quickTaskTextController,
                        onFieldSubmitted: (value) {
                          submitQuickTask();
                        },
                        validator: (value) {
                          if (value.isEmpty) {
                            return "Required";
                          } else if (value.length > 16) {
                            return "It's too long  😅";
                          } else {
                            return null;
                          }
                        },
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(18),
                          labelText: 'Edit task',
                          labelStyle: TextStyle(color: Colors.grey),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                width: 2,
                                color: Colors.grey,
                              ),
                              borderRadius: BorderRadius.circular(40)),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                width: 2,
                                color: Colors.grey,
                              ),
                              borderRadius: BorderRadius.circular(40)),
                          errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                width: 2,
                                color: Colors.red,
                              ),
                              borderRadius: BorderRadius.circular(40)),
                          focusedErrorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                width: 2,
                                color: Colors.red,
                              ),
                              borderRadius: BorderRadius.circular(40)),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 55,
                    width: MediaQuery.of(context).size.width / 1.1,
                    // ignore: deprecated_member_use
                    child: FlatButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40)),
                      color: Colors.blue,
                      onPressed: () async {
                        if (_formKey.currentState.validate()) {
                          submitQuickTask();
                        }
                      },
                      child: Text(
                        'Finish edit',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontFamily: "KumbhSans",
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  SizedBox(height: 30)
                ],
              ),
            ),
          );
        }).then((title) {
      if (title != null) {
        editItem(item, title);
      }
    });
  }

  void editCategories(category) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          ScreenScaler scaler = new ScreenScaler()..init(context);
          return AlertDialog(
            elevation: 9,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
            content: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: scaler.getPaddingLTRB(0, 2, 0, 1),
                    child: Text(
                      "Edit task",
                      style: TextStyle(
                          fontSize: 30,
                          fontFamily: "KumbhSans",
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: scaler.getPaddingLTRB(1, 0, 1, 2),
                    child: Theme(
                      data: ThemeProvider.themeOf(context).data,
                      child: TextFormField(
                        expands: false,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              new RegExp("^[a-zA-Z , 0-9 -]*"))
                        ],
                        maxLength: 16,
                        maxLines: 1,
                        autofocus: false,
                        controller: _categoriesTextController,
                        onFieldSubmitted: (value) {
                          submitCategories();
                        },
                        validator: (value) {
                          if (value.isEmpty) {
                            return "Required";
                          } else if (value.length > 16) {
                            return "It's too long  😅";
                          } else {
                            return null;
                          }
                        },
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(18),
                          labelText: 'Edit task',
                          labelStyle: TextStyle(color: Colors.grey),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                width: 2,
                                color: Colors.grey,
                              ),
                              borderRadius: BorderRadius.circular(40)),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                width: 2,
                                color: Colors.grey,
                              ),
                              borderRadius: BorderRadius.circular(40)),
                          errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                width: 2,
                                color: Colors.red,
                              ),
                              borderRadius: BorderRadius.circular(40)),
                          focusedErrorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                width: 2,
                                color: Colors.red,
                              ),
                              borderRadius: BorderRadius.circular(40)),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 55,
                    width: MediaQuery.of(context).size.width / 1.1,
                    // ignore: deprecated_member_use
                    child: FlatButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40)),
                      color: Colors.blue,
                      onPressed: () async {
                        if (_formKey.currentState.validate()) {
                          submitCategories();
                        }
                      },
                      child: Text(
                        'Finish edit',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontFamily: "KumbhSans",
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  SizedBox(height: 30)
                ],
              ),
            ),
          );
        }).then((categoryTodos) {
      if (categoryTodos != null) {
        editCategory(category, categoryTodos);
      }
    });
  }

  void taskItemInfo(title, item) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          ScreenScaler scaler = new ScreenScaler()..init(context);
          return AlertDialog(
            elevation: 9,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: scaler.getPaddingLTRB(0, 2, 0, 1),
                  child: Text(
                    "Task info",
                    style: TextStyle(
                        fontSize: 30,
                        fontFamily: "KumbhSans",
                        fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: scaler.getPaddingLTRB(1, 0, 1, 2),
                  child: Theme(
                    data: ThemeProvider.themeOf(context).data,
                    child: Text("Task: " + title,
                        style: TextStyle(
                            fontFamily: "KumbhSans",
                            fontSize: scaler.getTextSize(15))),
                  ),
                ),
                Container(
                  height: 55,
                  width: MediaQuery.of(context).size.width / 1.1,
                  // ignore: deprecated_member_use
                  child: FlatButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40)),
                    color: Colors.blue,
                    onPressed: () => editTaskItem(item),
                    child: Text(
                      'Edit task',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontFamily: "KumbhSans",
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                SizedBox(height: 30)
              ],
            ),
          );
        });
  }

  void editItem(Todo item, String title) {
    item.title = title;
    saveQuickTasks();
    loadQuickTasks();
  }

  void editCategory(CategoryTodo category, String catTitle) {
    category.categorytitle = catTitle;
    saveCategories();
    loadCategories();
  }

  void removeItem(Todo item) {
    todos.remove(item);
    saveQuickTasks();
    loadQuickTasks();
  }

  void loadQuickTasks() {
    List<String> listString = sharedPreferences.getStringList('list');
    if (listString != null) {
      todos =
          listString.map((item) => Todo.fromMap(json.decode(item))).toList();
      setState(() {});
    }
  }

  void loadCategories() {
    List<String> listCategory =
        sharedPreferences.getStringList('categories') ?? [];
    if (listCategory != null) {
      categoryTodos = listCategory
          .map((category) => CategoryTodo.fromMap(json.decode(category)))
          .toList();
      setState(() {});
    }
  }

  void saveQuickTasks() {
    List<String> stringList =
        todos.map((item) => json.encode(item.toMap())).toList();
    sharedPreferences.setStringList('list', stringList);
  }

  void saveCategories() {
    List<String> catogeryList =
        categoryTodos.map((category) => json.encode(category.toMap())).toList();
    sharedPreferences.setStringList('categories', catogeryList);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    ScreenScaler scaler = new ScreenScaler()..init(context);
    return ThemeConsumer(
      child: Builder(
        builder: (themeContext) => MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeProvider.themeOf(context).data,
          home: Scaffold(
              appBar: PreferredSize(
                preferredSize: Size.fromHeight(55),
                child: AppBar(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  title: SafeArea(
                    minimum: EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Text(
                          'TO DO',
                          style: TextStyle(
                            fontFamily: 'KumbhSans',
                            fontWeight: FontWeight.bold,
                            fontSize: scaler.getTextSize(16),
                            color: Colors.blue,
                          ),
                        ),
                        Spacer(),
                        IconButton(
                          icon: FaIcon(
                            FontAwesomeIcons.moon,
                            size: scaler.getHeight(2),
                          ),
                          onPressed:
                              ThemeProvider.controllerOf(context).nextTheme,
                        )
                      ],
                    ),
                  ),
                ),
              ),
              floatingActionButton: FloatingActionBubble(
                items: [
                  Bubble(
                    title: "Add category",
                    iconColor: Colors.white,
                    bubbleColor: Colors.blue,
                    icon: FontAwesomeIcons.tasks,
                    titleStyle: TextStyle(fontSize: 16, color: Colors.white),
                    onPress: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              elevation: 9,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(40)),
                              content: Form(
                                key: _formKey,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Padding(
                                      padding:
                                          scaler.getPaddingLTRB(0, 2, 0, 1),
                                      child: Center(
                                        child: Text(
                                          "Add category",
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
                                      padding:
                                          scaler.getPaddingLTRB(1, 0, 1, 2),
                                      child: Theme(
                                        data:
                                            ThemeProvider.themeOf(context).data,
                                        child: TextFormField(
                                          expands: false,
                                          inputFormatters: [
                                            FilteringTextInputFormatter.allow(
                                                new RegExp(
                                                    "^[a-zA-Z , 0-9 -]*"))
                                          ],
                                          maxLength: 16,
                                          maxLines: 1,
                                          autofocus: false,
                                          controller: _categoriesTextController,
                                          onFieldSubmitted: (value) {
                                            submitCategories();
                                            _categoriesTextController.clear();
                                          },
                                          validator: (value) {
                                            if (value.isEmpty) {
                                              return "Required";
                                            } else if (value.length > 16) {
                                              return "It's too long  😅";
                                            } else {
                                              return null;
                                            }
                                          },
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18),
                                          decoration: InputDecoration(
                                            contentPadding: EdgeInsets.all(18),
                                            labelText: 'New category',
                                            labelStyle:
                                                TextStyle(color: Colors.grey),
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
                                            focusedErrorBorder:
                                                OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      width: 2,
                                                      color: Colors.red,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            40)),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      height: 55,
                                      width: MediaQuery.of(context).size.width /
                                          1.1,
                                      // ignore: deprecated_member_use
                                      child: FlatButton(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(40)),
                                        color: Colors.blue,
                                        onPressed: () async {
                                          if (_formKey.currentState
                                              .validate()) {
                                            submitCategories();
                                            _categoriesTextController.clear();
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
                            );
                          }).then((category) {
                        if (category != null) {
                          addCategory(CategoryTodo(
                            categorytitle: category,
                          ));
                        }
                      });

                      _animationController.reverse();
                    },
                  ),
                  //Floating action menu item
                  Bubble(
                    title: "Quick task",
                    iconColor: Colors.white,
                    bubbleColor: Colors.blue,
                    icon: Icons.add_box_rounded,
                    titleStyle: TextStyle(fontSize: 16, color: Colors.white),
                    onPress: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              elevation: 9,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(40)),
                              content: Form(
                                key: _formKey,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Padding(
                                      padding:
                                          scaler.getPaddingLTRB(0, 2, 0, 1),
                                      child: Text(
                                        "Add new task",
                                        style: TextStyle(
                                            fontSize: 30,
                                            fontFamily: "KumbhSans",
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Padding(
                                      padding:
                                          scaler.getPaddingLTRB(1, 0, 1, 2),
                                      child: Theme(
                                        data:
                                            ThemeProvider.themeOf(context).data,
                                        child: TextFormField(
                                          expands: false,
                                          inputFormatters: [
                                            FilteringTextInputFormatter.allow(
                                                new RegExp(
                                                    "^[a-zA-Z , 0-9 -]*"))
                                          ],
                                          autofocus: false,
                                          controller: _quickTaskTextController,
                                          onFieldSubmitted: (value) {
                                            submitQuickTask();
                                            _quickTaskTextController.clear();
                                          },
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18),
                                          decoration: InputDecoration(
                                            contentPadding: EdgeInsets.all(18),
                                            labelText: 'New task',
                                            labelStyle:
                                                TextStyle(color: Colors.grey),
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
                                            focusedErrorBorder:
                                                OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      width: 2,
                                                      color: Colors.red,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            40)),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      height: 55,
                                      width: MediaQuery.of(context).size.width /
                                          1.1,
                                      // ignore: deprecated_member_use
                                      child: FlatButton(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(40)),
                                        color: Colors.blue,
                                        onPressed: () async {
                                          if (_formKey.currentState
                                              .validate()) {
                                            submitQuickTask();
                                            _quickTaskTextController.clear();
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
                            );
                          }).then((title) {
                        if (title != null) {
                          addItem(Todo(
                            title: title,
                          ));
                        }
                      });

                      _animationController.reverse();
                    },
                  ),
                ],
                animation: _animation,

                // On pressed change animation state
                onPress: () {
                  _animationController.isCompleted
                      ? _animationController.reverse()
                      : _animationController.forward();
                },
                // Floating Action button Icon color
                iconColor: Colors.white,

                // Flaoting Action button Icon
                iconData: Icons.add,
                backGroundColor: Colors.blue,
              ),
              body: todos.isEmpty && categoryTodos.isEmpty
                  ? Column(
                      children: [
                        Padding(
                          padding: scaler.getPadding(0, 3),
                          child: Row(
                            children: [
                              Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                      DateFormat.MMMd().format(DateTime.now()),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText2)),
                              SizedBox(width: scaler.getWidth(1)),
                              Text("·",
                                  style: TextStyle(
                                      color: Colors.blue,
                                      fontSize: scaler.getTextSize(18))),
                              SizedBox(width: scaler.getWidth(1)),
                              Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                      DateFormat.EEEE().format(DateTime.now()),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText2)),
                            ],
                          ),
                        ),
                        Expanded(child: emptyList()),
                      ],
                    )
                  : Column(
                      children: [
                        Padding(
                          padding: scaler.getPadding(0, 3),
                          child: Row(
                            children: [
                              Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                      DateFormat.MMMd().format(DateTime.now()),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText2)),
                              SizedBox(width: scaler.getWidth(1)),
                              Text("·",
                                  style: TextStyle(
                                      color: Colors.blue,
                                      fontSize: scaler.getTextSize(18))),
                              SizedBox(width: scaler.getWidth(1)),
                              Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                      DateFormat.EEEE().format(DateTime.now()),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText2)),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              if (categoryTodos.isEmpty)
                                Container(width: 0, height: 0)
                              else
                                SizedBox(
                                  height: 150,
                                  width: scaler.getWidth(100),
                                  child: MediaQuery.removeViewInsets(
                                    context: context,
                                    removeTop: true,
                                    child: buildCategoryView(),
                                  ),
                                ),
                              Expanded(child: buildListView()),
                            ],
                          ),
                        ),
                      ],
                    )),
        ),
      ),
    );
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

  Widget buildListView() {
    return ListView.builder(
      physics: BouncingScrollPhysics(),
      itemCount: todos.length,
      itemBuilder: (BuildContext context, int index) {
        return buildItem(todos[index], index);
      },
    );
  }

  Widget buildCategoryView() {
    final _controller = PageController(viewportFraction: 0.9);
    return MediaQuery.removeViewPadding(
      context: context,
      removeTop: true,
      removeBottom: true,
      child: PageView.builder(
          controller: _controller,
          physics: BouncingScrollPhysics(),
          itemCount: categoryTodos.length,
          itemBuilder: (BuildContext context, int index) {
            return buildCategoryListTile(categoryTodos[index], index);
          }),
    );
  }

  Widget buildCategoryListTile(CategoryTodo category, int index) {
    ScreenScaler scaler = new ScreenScaler()..init(context);
    return Padding(
      padding: scaler.getPaddingLTRB(1, 0, 1, 1),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: GestureDetector(
          onDoubleTap: () {
            editCategories(category);
            setState(() {});
          },
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => NewCategoryTask(
                        taskName: categoryTodos[index].categorytitle)));
          },
          child: Container(
            color: Colors.blue,
            height: 300,
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Row(
                children: [
                  Padding(
                      padding: scaler.getPaddingLTRB(2, 0, 0, 0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          categoryTodos[index].categorytitle == null
                              ? ''
                              : categoryTodos[index].categorytitle,
                          style: Theme.of(context).textTheme.bodyText2,
                        ),
                      )),
                  Spacer(),
                  IconButton(
                      icon: Icon(Icons.delete_outline_rounded),
                      onPressed: () {
                        setState(() {
                          removeCategory(category);
                        });
                      }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildItem(Todo item, index) {
    return Dismissible(
      key: Key('${todos[index].hashCode}'),
      background: Padding(
        padding: const EdgeInsets.only(top: 5, bottom: 5),
        child: Container(height: 90, color: Colors.transparent),
      ),
      onDismissed: (direction) => removeItem(item),
      direction: DismissDirection.startToEnd,
      child: buildListTile(item, index),
    );
  }

  Widget buildCategory(CategoryTodo category, index) {
    return Dismissible(
      key: Key('${categoryTodos[index].hashCode}'),
      onDismissed: (direction) => removeCategory(category),
      direction: DismissDirection.vertical,
      child: buildCategoryListTile(category, index),
    );
  }

  Widget buildListTile(Todo item, int index) {
    ScreenScaler scaler = new ScreenScaler()..init(context);
    return GestureDetector(
        onDoubleTap: () => editTaskItem(item),
        onLongPress: () => taskItemInfo(todos[index].title, item),
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
                        taskIsdone(item);
                      });
                    },
                    leading: CircularCheckBox(
                        activeColor: Colors.blue,
                        disabledColor: Colors.grey,
                        value: todos[index].completed,
                        onChanged: (bool val) => setState(() {
                              todos[index].completed = !todos[index].completed;
                            })),
                    title: SafeArea(
                        child: Align(
                      alignment: Alignment.centerLeft,
                      child: SafeArea(
                          minimum: scaler.getPadding(1, 0),
                          child: RichText(
                            text: TextSpan(
                                style: TextStyle(
                                    fontSize: 24,
                                    fontFamily: "Kumbh",
                                    fontWeight: FontWeight.bold,
                                    decoration: item.completed
                                        ? TextDecoration.lineThrough
                                        : null),
                                children: [
                                  TextSpan(
                                      text: todos[index].title,
                                      style:
                                          Theme.of(context).textTheme.bodyText1)
                                ]),
                          )),
                    )),
                    trailing: SafeArea(
                      child: IconButton(
                        onPressed: () {
                          setState(() {
                            removeItem(item);
                          });
                        },
                        icon: Icon(Icons.delete_outline_rounded),
                      ),
                    ),
                  )),
            )));
  }
}
