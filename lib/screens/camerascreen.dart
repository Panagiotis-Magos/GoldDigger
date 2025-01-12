import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class CameraScreen extends StatefulWidget {
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
      // Get available cameras
      cameras = await availableCameras();

      // Initialize the first available camera
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
        setState(() {});
      } catch (e) {
        print('Error capturing photo: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isCameraReady || controller == null) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Camera Screen'),
        backgroundColor: Colors.amber,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: CameraPreview(controller!),
          ),
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
                ],
              ),
            ),
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: capturePhoto,
                  child: Text('Capture Photo'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                ),
                if (capturedImage != null)
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        capturedImage = null; // Clear the captured image
                      });
                    },
                    child: Text('Clear Photo'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
