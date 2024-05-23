import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:terp_to_do/main.dart';
import 'package:terp_to_do/todo.dart';
import 'dart:io';

class TaskHistory extends StatelessWidget {
  final Todo task;

  const TaskHistory({Key? key, required this.task}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Task History',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
      ),
      body: MediaQuery.of(context).orientation == Orientation.landscape
          ? _buildLandscapeView(context)
          : _buildPortraitView(context),
    );
  }

  Widget _buildLandscapeView(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 110.0, right: 30, top: 10, bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: _buildTaskInfoWidgets(),
          ),
          const SizedBox(width: 20),
          _buildPicture(context),
        ],
      ),
    );
  }

  Widget _buildPortraitView(BuildContext context) {
    return Padding(
       padding: const EdgeInsets.only(left: 50.0, bottom: 100.0, right: 30),
      
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTaskInfoWidgets(),
          const SizedBox(height: 20),
          _buildPicture(context),
        ],
      ),
    );
  }

  Widget _buildTaskInfoWidgets() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildText('Task Title:', task.title ?? 'No title'),
          _buildText('Description:', task.description ?? 'No description'),
          _buildText('Due Date:', task.dueDate ?? 'No due date'),
          _buildText('Completed:', task.completed ? 'Yes' : 'No'),
          _buildText('Comment:', task.comment ?? 'No comment'),
        ],
      ),
    );
  }

  Widget _buildText(String title, String content) {
  String displayContent = content.isNotEmpty ? content : 'No content'; // Display 'No content' if content is empty
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18.0,
        ),
      ),
      Text(
        displayContent,
        style: const TextStyle(fontSize: 16.0),
      ),
    ],
  );
}



  Widget _buildPicture(BuildContext context) {
    return FutureBuilder<String?>(
      future: _getPicturePath(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          final String? picturePath = snapshot.data;
          return picturePath != null
              ? SizedBox(
                  width: 300,
                  height: 300,
                  child: Image.file(
                    File(picturePath),
                    fit: BoxFit.contain,
                  ),
                )
              : const Text('No picture');
        }
      },
    );
  }

  Future<String?> _getPicturePath(BuildContext context) async {
    try {
      final String? picturePath =
          Provider.of<TerpState>(context, listen: false).getImagePathForTask(task!);
      return picturePath;
    } catch (e) {
      print('Error retrieving picture path: $e');
      return null;
    }
  }
}
