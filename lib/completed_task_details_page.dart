import 'dart:io';

import 'package:flutter/material.dart';

class CompletedTaskDetailsPage extends StatelessWidget {
  final String taskComment;
  final String imagePath;

  const CompletedTaskDetailsPage({super.key, 
    required this.taskComment,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Completed Task Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Task Comment:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
              ),
            ),
            taskComment.isNotEmpty
                ? Text(taskComment)
                : const Text('No comment'),
            const SizedBox(height: 20),
            Expanded(
              child: Image.file(
                File(imagePath),
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); 
                Navigator.pop(context); 
              },
              child: const Text('Back to Main Page'),
            ),
          ],
        ),
      ),
    );
  }
}
