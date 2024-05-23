class Todo {
  String? title;
  bool completed;
  String? description;
  String? dueDate;
  int timeCompleted;
  bool addComment;
  String? comment;
  String? picturePath;

  Todo({
    this.title,
    this.completed = false,
    this.description,
    this.dueDate,
    this.timeCompleted = 0,
    this.addComment = false,
    this.comment,
    this.picturePath,
  });

  Todo.fromMap(Map<String, dynamic> map)
      : title = map['title'],
        completed = map['completed'] ?? false,
        description = map['description'],
        dueDate = map['due_date'],
        timeCompleted = map['timeCompleted'] ?? 0,
        addComment = map['add_comment'] ?? false,
        comment = map['comment'],
        picturePath = map['picture'];

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'completed': completed,
      'description':description,
      'due_date':dueDate,
      'timeCompleted': timeCompleted,
      'add_comment': addComment,
      'comment': comment,
      'picture': picturePath,
    };
  }
}
