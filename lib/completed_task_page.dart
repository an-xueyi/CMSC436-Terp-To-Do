import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import 'dart:io';

import 'package:terp_to_do/completed_task_details_page.dart';
import 'package:terp_to_do/main.dart';
import 'package:terp_to_do/todo.dart';

class CompletedTaskPage extends StatefulWidget {
  final Todo task;
  const CompletedTaskPage({Key? key, required this.task}) : super(key: key); 
  @override
  _CompletedTaskPageState createState() => _CompletedTaskPageState();
}

class _CompletedTaskPageState extends State<CompletedTaskPage> {
  final TextEditingController _commentController = TextEditingController();
  CameraController? _cameraController;
  late Future<void> _initializeControllerFuture;
  XFile? _capturedImage;
  bool _showImage = false;
  


  @override
  void initState() {
    super.initState();
    _initializeControllerFuture = _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final firstCamera = cameras.first;
      _cameraController = CameraController(
        firstCamera,
        ResolutionPreset.high,
      );
      await _cameraController!.initialize();
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    try {
      await _initializeControllerFuture;
      final XFile picture = await _cameraController!.takePicture();
      setState(() {
        _capturedImage = picture;
        _showImage = true;
      });
    } catch (e) {
      print('Error taking picture: $e');
    }
  }

  void _done(Todo task) {
  Provider.of<TerpState>(context, listen: false)
    .saveCommentForTask(task, _commentController.text);
  Provider.of<TerpState>(context, listen: false)
    .saveImagePathForTask(task, _capturedImage!.path); // Store the picture path
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => CompletedTaskDetailsPage(
        taskComment: _commentController.text,
        imagePath: _capturedImage!.path,
      ),
    ),
  );
}



  void _tryAgain() {
    setState(() {
      _showImage = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Completed Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _commentController,
              decoration: const InputDecoration(labelText: 'Task Comment'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _showImage
                  ? Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.file(
                          File(_capturedImage!.path),
                          fit: BoxFit.contain,
                        ),
                        Positioned(
                          bottom: 50,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: () => _done(widget.task),
                                child: const Text('Done'),
                              ),
                              const SizedBox(width: 20),
                              ElevatedButton(
                                onPressed: _tryAgain,
                                child: const Text('Take Picture Again'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : _cameraPreviewWidget(),
            ),
          ],
        ),
      ),
      floatingActionButton: !_showImage
          ? FloatingActionButton(
              onPressed: _takePicture,
              child: const Icon(Icons.camera_alt),
            )
          : null,
    );
  }

  Widget _cameraPreviewWidget() {
    return FutureBuilder<void>(
      future: _initializeControllerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return CameraPreview(_cameraController!);
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
