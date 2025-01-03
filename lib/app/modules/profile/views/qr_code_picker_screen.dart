import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart'; // For camera permissions

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  bool _isCameraInitialized = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeCamera(); // Initialize camera
  }

  // Request camera permission and initialize the camera
  Future<void> _initializeCamera() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        _controller = CameraController(
          cameras[0], 
          ResolutionPreset.high, 
        );
        _initializeControllerFuture = _controller.initialize();
        _initializeControllerFuture.then((_) {
          if (mounted) {
            setState(() {
              _isCameraInitialized = true;
            });
          }
        }).catchError((e) {
          if (mounted) {
            setState(() {
              _errorMessage = "Error initializing camera: $e";
            });
          }
        });
      } else {
        setState(() {
          _errorMessage = "No cameras available.";
        });
      }
    } else {
      setState(() {
        _errorMessage = "Camera permission denied.";
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose the camera when the screen is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white), // White back arrow
          onPressed: () {
            Navigator.pop(context); // Pop the screen when back arrow is pressed
          },
        ),
        title: const Text(
          'Live Camera Feed',
          style: TextStyle(color: Colors.white), // White text for the title
        ),
        backgroundColor: Colors.blue, // AppBar color
        elevation: 0, // No shadow under the AppBar
      ),
      body: _errorMessage.isNotEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, color: Colors.red, size: 50),
                    const SizedBox(height: 20),
                    Text(
                      _errorMessage,
                      style: TextStyle(color: Colors.red, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : _isCameraInitialized
              ? Stack(
                  children: [
                    CameraPreview(_controller), // Show camera preview once initialized
                    Center(
                      child: Container(
                        color: Colors.black.withOpacity(0.5), // Semi-transparent overlay for better readability
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: Text(
                          'Scan QR Code',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : Center(child: CircularProgressIndicator()), // Loading while initializing
    );
  }
}
