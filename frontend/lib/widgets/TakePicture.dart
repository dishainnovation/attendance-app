import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/widgets/ScaffoldPage.dart';

import '../Models/ErrorObject.dart';

class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({super.key, required this.camera});

  final CameraDescription camera;

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  ErrorObject error = ErrorObject(title: '', message: '');
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  initializeCameraController() {
    _controller = CameraController(
      enableAudio: false,
      widget.camera,
      ResolutionPreset.medium,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void initState() {
    super.initState();
    initializeCameraController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return ScaffoldPage(
      error: error,
      title: 'Take a picture',
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            _controller.lockCaptureOrientation(DeviceOrientation.landscapeLeft);
            return Center(
              child: Container(
                  height: size.height * 0.8,
                  width: size.width,
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[600]!),
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white),
                  child: CameraPreview(
                    _controller,
                  )),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingButton: FloatingActionButton(
        onPressed: () async {
          try {
            await _initializeControllerFuture;

            final image = await _controller.takePicture();

            if (!context.mounted) return;

            Navigator.of(context).pop(image.path);
          } catch (e) {
            print(e);
          }
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}
