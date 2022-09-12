import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:tagyourtaxi_driver/functions/functions.dart';
import 'package:tagyourtaxi_driver/pages/NavigatorPages/videopreview.dart';

class videoscreen extends StatefulWidget {
  const videoscreen({Key? key}) : super(key: key);

  @override
  State<videoscreen> createState() => _videoscreenState();
}

class _videoscreenState extends State<videoscreen> {
  bool _isLoading = true;
  bool _isRecording = false;
  var tokens;
  late CameraController _cameraController;
  _initCamera() async {
    final cameras = await availableCameras();
    final front = cameras.firstWhere((camera) => camera.lensDirection == CameraLensDirection.front);
    _cameraController = CameraController(front, ResolutionPreset.max);
    await _cameraController.initialize();
    setState(() => _isLoading = false);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initCamera();
    tokens = pref.getString('Bearer');
  }
  @override
  Widget build(BuildContext context) {
    return _isLoading?Container(
      color: Colors.white,
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    ):Center(
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          CameraPreview(_cameraController),
          Padding(
            padding: const EdgeInsets.all(25),
            child: FloatingActionButton(
              backgroundColor: Colors.black,
              child: Icon(_isRecording ? Icons.stop : Icons.circle),
              onPressed: () => _recordVideo(),
            ),
          ),
        ],
      ),
    );
  }

  _recordVideo() async {
    if (_isRecording) {
      final file = await _cameraController.stopVideoRecording();
      setState(() => _isRecording = false);
      final route = MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => videopreview(file.path,tokens),
      );
      Navigator.push(context, route);
    } else {
      await _cameraController.prepareForVideoRecording();
      await _cameraController.startVideoRecording();
      setState(() => _isRecording = true);
    }
  }
}
