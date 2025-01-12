import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../services/database_service.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class CameraScreen extends StatefulWidget {
  final int userId;
  final int taskId;

  const CameraScreen({Key? key, required this.userId, required this.taskId})
      : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late List<CameraDescription> cameras;
  CameraController? controller;
  bool isCameraReady = false;
  XFile? capturedImage;

  @override
  void initState() {
    super.initState();
    initializeCamera();
  }

  Future<void> initializeCamera() async {
    try {
      cameras = await availableCameras();
      controller = CameraController(cameras[0], ResolutionPreset.high);
      await controller!.initialize();
      setState(() {
        isCameraReady = true;
      });
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  Future<void> capturePhoto() async {
    if (controller != null && controller!.value.isInitialized) {
      try {
        capturedImage = await controller!.takePicture();
        setState(() {}); // Refresh UI to show captured image
      } catch (e) {
        print('Error capturing photo: $e');
      }
    }
  }

  Future<void> _acceptPhoto() async {
    if (capturedImage == null) return;

    try {
      // Save the captured photo in internal storage
      final directory = await getApplicationDocumentsDirectory();
      final savedPath = '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      await File(capturedImage!.path).copy(savedPath);

      // Insert into the database
      final db = await DatabaseService().database;
      print(savedPath);
      await db.insert(
        'photos',
        {
          'user_id': widget.userId,
          'task_id': widget.taskId,
          'url': savedPath,
          'uploaded_at': DateTime.now().toIso8601String(),
        },
      );

      print('Photo saved to database: $savedPath');
      Navigator.pop(context, savedPath); // Return to the previous screen with the photo path
    } catch (e) {
      print('Error saving photo to database: $e');
    }
  }

  void _declinePhoto() {
    setState(() {
      capturedImage = null; // Clear the captured image
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!isCameraReady || controller == null) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Capture Task Image'),
        backgroundColor: Colors.amber,
      ),
      body: Column(
        children: [
          Expanded(flex: 4, child: CameraPreview(controller!)),
          if (capturedImage != null)
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  Text(
                    'Captured Image:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Image.file(
                    File(capturedImage!.path),
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: _acceptPhoto,
                        child: Text('Accept'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      ),
                      ElevatedButton(
                        onPressed: _declinePhoto,
                        child: Text('Retake'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      ),
                    ],
                  ),
                ],
              ),
            )
          else
            Expanded(
              flex: 1,
              child: Center(
                child: ElevatedButton(
                  onPressed: capturePhoto,
                  child: Text('Capture Photo'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                ),
              ),
            ),
        ],
      ),
    );
  }
}