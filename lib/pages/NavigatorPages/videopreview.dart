import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:tagyourtaxi_driver/functions/functions.dart';
import 'package:tagyourtaxi_driver/pages/loadingPage/loading.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;

class videopreview extends StatefulWidget {
  String filePath;
  String tokens;
  videopreview(this.filePath, this.tokens);

  @override
  State<videopreview> createState() => _videopreviewState();
}

class _videopreviewState extends State<videopreview> {
  late VideoPlayerController _videoPlayerController;
  bool _isLoading = false;
  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

  Future _initVideoPlayer() async {
    _videoPlayerController = VideoPlayerController.file(File(widget.filePath));
    await _videoPlayerController.initialize();
    await _videoPlayerController.setLooping(true);
    await _videoPlayerController.play();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preview'),
        elevation: 0,
        backgroundColor: Colors.black26,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () async {
              if (!_isLoading) {
                await _videoPlayerController.pause();
                setState(() {
                  _isLoading = true;
                });
                savevideo();
              }
            },
          )
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          FutureBuilder(
            future: _initVideoPlayer(),
            builder: (context, state) {
              if (state.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else {
                return VideoPlayer(_videoPlayerController);
              }
            },
          ),
          _isLoading?Positioned(top: 0, child: Loading()):Container(),
        ],
      ),
    );

  }

  savevideo() async {
    final response =  http.MultipartRequest('POST', Uri.parse(url + 'api/v1/user/add-media'));
    response.headers.addAll({'Content-Type': 'application/json','Authorization': 'Bearer ${widget.tokens}'});
    response.files.add(
        await http.MultipartFile.fromPath('media', widget.filePath));
    response.fields['status'] = "2";
    response.fields['type'] = "2";
    var request = await response.send();
    var respon = await http.Response.fromStream(request);
    print(respon.body);
    if(respon.statusCode==200) {
      if(jsonDecode(respon.body)['success']==true) {
        setState(() {
          _isLoading = false;
        });
        _videoPlayerController.dispose();
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("${jsonDecode(respon.body)['message']}"),
              margin: EdgeInsets.all(10),
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)
              ),
            )
        );
      } else {
        setState(() {
          _isLoading = false;
        });
        Navigator.pop(context);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("${jsonDecode(respon.body)['message']}"),
              margin: EdgeInsets.all(10),
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)
              ),
            )
        );
      }
    }
  }
}
