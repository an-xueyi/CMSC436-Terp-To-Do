import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:terp_to_do/completed_task_page.dart';
import 'package:terp_to_do/task_history_page.dart';
import 'todo.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:terp_to_do/timer_page.dart';

TextEditingController newTodo_title = TextEditingController();
TextEditingController description = TextEditingController();
TextEditingController dateCtl = TextEditingController();

var size;
void main() {
  runApp(ChangeNotifierProvider(
      create: (context) {
        var terp = TerpState();
        terp.initState();
        return terp;
      },
      child: const MyApp()));
}

/* This is a state helping changing the status of todo, (check or uncheck)*/
class TerpState extends ChangeNotifier {
   List<Todo> list = [];
  List<Todo> unfinished= [];
  List<Todo> finished=[];
  SharedPreferences? sharedPreferences;
  /*addToDo: Call when the user click submit */

  /*Complete: Call when the user click the check box of a task */

  void initState() {
    loadSharedPreferencesAndData();
  }

  void loadSharedPreferencesAndData() async {
    sharedPreferences = await SharedPreferences.getInstance();
    loadData();
    /* print("loaded");*/
    /* print(list);*/
    notifyListeners();
  }

  void loadData() {
    List<String>? listString = sharedPreferences?.getStringList('list');
    if (listString != null) {
      list = listString.map((item) => Todo.fromMap(json.decode(item))).toList();
      for (var item in list) {
        if(item.completed){
          finished.insert(0,item);
        }else{
          unfinished.insert(0,item);
        }
}
    }
  }

  void removeTodo(Todo item) {
    list.remove(item);
    if(item.completed){
      finished.remove(item);
    }else{
      unfinished.remove(item);
    }
    saveData();
    notifyListeners();
  }

  void addTodo(Todo item) {
    item.timeCompleted = 0;
    // Insert an item into the top of our list, on index zero
    list.insert(0, item);
    unfinished.insert(0, item);
    saveData();
    notifyListeners();
  }

  void editTodo(Todo item, String title, String description, String due_date) {
    item.description = description;
    item.dueDate = due_date;
    item.title = title;
    saveData();
    notifyListeners();
  }

  void changeTodoCompleteness(Todo todo) {
    if(todo.completed){
      finished.remove(todo);
      unfinished.insert(0,todo);
    }else{
      unfinished.remove(todo);
      finished.insert(0,todo);
    }
    todo.completed = !todo.completed;

    saveData();
    notifyListeners();
  }
   void updateCompletedTime(Todo todo){
    saveData();
    notifyListeners();
  }
  // Save comment for a specific task
  void saveCommentForTask(Todo task, String comment) {
    final int index = list.indexWhere((element) => element == task);
    if (index != -1) {
      list[index].comment = comment;
      saveData();
    }
  }

  // Get comment for a specific task
  String? getCommentForTask(Todo task) {
    final int index = list.indexWhere((element) => element == task);
    if (index != -1) {
      return list[index].comment;
    }
    return null;
  }

  void saveImagePathForTask(Todo task, String path) {
    final int index = list.indexWhere((element) => element == task);
    if (index != -1) {
      list[index].picturePath = path;
      list[index].addComment =
          true; // Set addComment to true when saving image path
      saveData();
    }
  }

  // Get image path for a specific task
  String? getImagePathForTask(Todo task) {
    final int index = list.indexWhere((element) => element == task);
    if (index != -1) {
      return list[index].picturePath;
    }
    return null;
  }

  
  void saveData() {
    List<String> stringList =
        list.map((item) => json.encode(item.toMap())).toList();
    sharedPreferences?.setStringList('list', stringList);
    notifyListeners();
  }
}

/*Main App */
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Terp To Do',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
      ),
      home: TerpHomepage(),
    );
  }
}

/*Header */
class TerpHomepage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return DefaultTabController(
        length: 2,
        child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              title: const Center(child: Text('Terp To Do')),
              bottom: const TabBar(
                tabs: [
                  Tab(
                      child: Column(children: [
                    Icon(Icons.check_box_outline_blank_outlined, color: Colors.white),
                    Text('To-Do List', style: TextStyle(color: Colors.white))
                  ])),
                  Tab(
                      child: Column(children: [
                    Icon(Icons.check_box, color: Colors.white),
                    Text('Finished List', style: TextStyle(color: Colors.white))
                  ])),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
               backgroundColor: Colors.red,
                child: Icon(Icons.add,color:Colors.white),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) {
                            return addTodoPage();
                          },
                          settings: RouteSettings()));
                  dateCtl.text = "";
                  description.text = "";
                  newTodo_title.text = "";
                }),
            body: TabBarView(children: [TodoList(),FinishedTodoList()])));
  }
}
class FinishedTodoList extends StatelessWidget {
  FinishedTodoList({super.key});
  @override
  Widget build(BuildContext context) => Consumer<TerpState>(
      builder: (context, value, child) => ListView.builder(
            itemCount: value.finished.length,
            itemBuilder: (context, index) {
              Todo cur_todo = value.finished[index];
              return Slidable(
                actionPane: const SlidableDrawerActionPane(),
                actionExtentRatio: 0.25,
                secondaryActions: <Widget>[
                  IconSlideAction(
                      caption: 'Timer',
                      color: cur_todo.completed ? Colors.grey : Colors.blue,
                      icon: Icons.timer,
                      onTap: () {
                        if (!cur_todo.completed) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TimerPage(todo: cur_todo,)),
                          );
                        }
                      })
                ],
                child: ListTile(
                  title: Text(cur_todo.title!),
                  onTap: () {
                    if (cur_todo.completed) {
                      if (cur_todo.addComment) {
                        // Navigate to the TaskHistory page if task is completed and has comments
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TaskHistory(task: cur_todo),
                          ),
                        );
                      } else {
                        // Navigate to the CompletedTaskPage if task is completed but has no comments
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CompletedTaskPage(task: cur_todo),
                          ),
                        );
                      }
                    }
                  },
                  onLongPress: () {
                    dateCtl.text = cur_todo.dueDate as String;
                    description.text = cur_todo.description as String;
                    newTodo_title.text = cur_todo.title as String;
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) {
                              return editTodoPage();
                            },
                            settings: RouteSettings(arguments: cur_todo)));
                  },
                  leading: GestureDetector(
                      onTap: () {
                        Provider.of<TerpState>(context, listen: false)
                            .changeTodoCompleteness(cur_todo);
                      },
                      child: cur_todo.completed
                          ? Icon(Icons.check_box_outlined)
                          : Icon(Icons.check_box_outline_blank_outlined)),
                ),
              );
            },
          ));
}


class TodoList extends StatelessWidget {
  TodoList({super.key});
  @override
  Widget build(BuildContext context) => Consumer<TerpState>(
      builder: (context, value, child) => ListView.builder(
            itemCount: value.unfinished.length,
            itemBuilder: (context, index) {
              Todo cur_todo = value.unfinished[index];
              return Slidable(
                actionPane: const SlidableDrawerActionPane(),
                actionExtentRatio: 0.25,
                secondaryActions: <Widget>[
                  IconSlideAction(
                      caption: 'Timer',
                      color: cur_todo.completed ? Colors.grey : Colors.blue,
                      icon: Icons.timer,
                      onTap: () {
                        if (!cur_todo.completed) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TimerPage(todo: cur_todo,)),
                          );
                        }
                      })
                ],
                child: ListTile(
                  title: Text(cur_todo.title!),
                  onTap: () {
                    if (cur_todo.completed) {
                      if (cur_todo.addComment) {
                        // Navigate to the TaskHistory page if task is completed and has comments
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TaskHistory(task: cur_todo),
                          ),
                        );
                      } else {
                        // Navigate to the CompletedTaskPage if task is completed but has no comments
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CompletedTaskPage(task: cur_todo),
                          ),
                        );
                      }
                    }
                  },
                  onLongPress: () {
                    dateCtl.text = cur_todo.dueDate as String;
                    description.text = cur_todo.description as String;
                    newTodo_title.text = cur_todo.title as String;
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) {
                              return editTodoPage();
                            },
                            settings: RouteSettings(arguments: cur_todo)));
                  },
                  leading: GestureDetector(
                      onTap: () {
                        Provider.of<TerpState>(context, listen: false)
                            .changeTodoCompleteness(cur_todo);
                      },
                      child: cur_todo.completed
                          ? Icon(Icons.check_box_outlined)
                          : Icon(Icons.check_box_outline_blank_outlined)),
                ),
              );
            },
          ));
}

/*UI for Adding new ToDo */
class addTodoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("New Task")),
        body: LayoutBuilder(
            builder: (context, constraints) => Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(children: [
                  Row(children: [
                    Text('Task Title:    ', style: TextStyle(fontSize: 20)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      width: 200,
                      height: 52,
                      child: TextField(
                        decoration: InputDecoration(labelText: 'New To Do'),
                        controller: newTodo_title,
                      ),
                    ),
                  ]),
                  Row(children: [
                    Text('Description:    ', style: TextStyle(fontSize: 20)),
                    Container(
                      width: 200,
                      height: 80,
                      child: TextField(
                        decoration: InputDecoration(labelText: 'Description'),
                        controller: description,
                      ),
                    ),
                  ]),
                  TextFormField(
                    controller: dateCtl,
                    decoration: InputDecoration(
                      labelText: "Due Date",
                      hintText: "Ex. Enter Due Date for the task",
                    ),
                    onTap: () async {
                      DateTime date = DateTime(1900);
                      FocusScope.of(context).requestFocus(new FocusNode());

                      DateTime? due_date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2024),
                          lastDate: DateTime(2025));

                      dateCtl.text =
                          due_date == null ? "" : due_date.toIso8601String();
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(children: [
                    SizedBox(
                        height: 30,
                        child: ElevatedButton(
                          onPressed: () {
                            Provider.of<TerpState>(context, listen: false)
                                .addTodo(Todo(
                                    title: newTodo_title.text,
                                    description: description.text,
                                    dueDate: dateCtl.text));
                            Navigator.of(context)
                                .popUntil((route) => route.isFirst);
                          },
                          child: const Text('Submit'),
                        )),
                  ])
                ]))));
  }
}

/*UI for Adding new ToDo */
class editTodoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Consumer<TerpState>(
      builder: (context, value, child) => Scaffold(
          appBar: AppBar(title: Text("Edit Task")),
          body: LayoutBuilder(
              builder: (context, constraints) => Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Column(children: [
                    Row(children: [
                      Text('Task Title:    ', style: TextStyle(fontSize: 20)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        width: 200,
                        height: 52,
                        child: TextFormField(
                          decoration: InputDecoration(labelText: "Edit Title"),
                          controller: newTodo_title,
                        ),
                      ),
                     
                    ]),
                    Row(children: [
                      Text('Description:    ', style: TextStyle(fontSize: 20)),
                      Container(
                        width: 200,
                        height: 80,
                        child: TextFormField(
                          decoration:
                              InputDecoration(labelText: 'Edit Description:'),
                          controller: description,
                        ),
                      ),
                    ]),
                    TextFormField(
                      controller: dateCtl,
                      decoration: InputDecoration(
                        labelText: "Due Date",
                        hintText: "Ex. Enter Due Date for the task",
                      ),
                      onTap: () async {
                        DateTime date = DateTime(1900);
                        FocusScope.of(context).requestFocus(new FocusNode());

                        DateTime? due_date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2024),
                            lastDate: DateTime(2025));

                        dateCtl.text =
                            due_date == null ? "" : due_date.toIso8601String();
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(children: [
                      SizedBox(
                          height: 30,
                          child: ElevatedButton(
                            onPressed: () {
                              Provider.of<TerpState>(context, listen: false)
                                  .editTodo(
                                      ModalRoute.of(context)!.settings.arguments
                                          as Todo,
                                      newTodo_title.text,
                                      description.text,
                                      dateCtl.text);
                              Navigator.of(context)
                                  .popUntil((route) => route.isFirst);
                            },
                            child: const Text('Submit'),
                          )),
                      SizedBox(
                          height: 30,
                          child: ElevatedButton(
                            onPressed: () {
                              Provider.of<TerpState>(context, listen: false)
                                  .removeTodo(ModalRoute.of(context)!
                                      .settings
                                      .arguments as Todo);

                              Navigator.of(context)
                                  .popUntil((route) => route.isFirst);
                            },
                            child: const Text('Delete'),

                          )), Text(' Total Focus Time: '+ (ModalRoute.of(context)!.settings.arguments
                                          as Todo).timeCompleted.toString()+' mins', )
                    ])
                  ])))));
}
