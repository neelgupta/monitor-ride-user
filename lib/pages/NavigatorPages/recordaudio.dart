import 'dart:convert';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tagyourtaxi_driver/functions/functions.dart';
import 'package:tagyourtaxi_driver/pages/loadingPage/loading.dart';
import 'package:tagyourtaxi_driver/styles/styles.dart';
import 'package:tagyourtaxi_driver/translations/translation.dart';
import 'package:http/http.dart' as http;

class recordaudio extends StatefulWidget {
  const recordaudio({Key? key}) : super(key: key);

  @override
  State<recordaudio> createState() => _recordaudioState();
}

class _recordaudioState extends State<recordaudio> {
  bool Recording = false;
  bool pause = false;
  final record = Record();
  String FilePath = "";
  var tokens;
  bool play = false;
  bool isLoading = false;
  Duration duration = Duration(seconds: 0);
  Duration position = Duration(seconds: 0);
  AudioPlayer audioPlayer = AudioPlayer();

  pauseaudio() {
    audioPlayer.pause();
  }
  stopaudio() {
    audioPlayer.stop();
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tokens = pref.getString('Bearer');
    print(tokens);
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    record.dispose();
    stopaudio();
  }
  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              padding: EdgeInsets.all(media.width * 0.025),
              child: Column(
                children: [
                  Container(
                    height: media.height * 0.85,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            InkWell(onTap: () {
                              Navigator.pop(context);
                            },child: Icon(Icons.arrow_back_outlined)),
                            Spacer(),
                            Text(languages[choosenLanguage]['text_recordaudio'],style: GoogleFonts.roboto(
                                fontSize: media.width * 0.055,
                                fontWeight: FontWeight.w600,
                                color: textColor),),
                            Spacer(),
                            Container(
                              width: media.width *0.08,
                            )
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.all(media.width * 0.1),
                          child: Text(languages[choosenLanguage]['text_audio'],textAlign: TextAlign.center,style: GoogleFonts.roboto(
                              fontSize: media.width * 0.04,
                              fontWeight: FontWeight.w500,
                              color: textColor),),
                        ),
                        Container(
                          height: media.height *0.6,
                          alignment: Alignment.center,
                          child: Recording?Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              InkWell(
                                onTap: () async {
                                  Directory tempDir = await getTemporaryDirectory();
                                  setState(() {
                                    File filePath = File('${tempDir.path}/audio.mp3');
                                    FilePath = filePath.path;
                                    Recording = false;
                                  });
                                  await record.stop();
                                },
                                child: Container(
                                  height: media.height * 0.3,
                                  width: media.height * 0.3,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.black12
                                  ),
                                  child: Icon(Icons.stop,size: media.width * 0.1,),
                                ),
                              ),
                              InkWell(
                                onTap: () async {
                                  if(pause)  {
                                    setState(() {
                                      pause = false;
                                    });
                                    await record.resume();
                                  } else {
                                    setState(() {
                                      pause = true;
                                    });
                                    await record.pause();
                                  }
                                },
                                child: Container(
                                  height: media.height * 0.3,
                                  width: media.height * 0.3,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.black12
                                  ),
                                  child: Icon(pause?Icons.play_arrow:Icons.pause,size: media.width * 0.1,),
                                ),
                              ),
                            ],
                          ):Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              InkWell(
                                onTap: () async {
                                  bool result = await Record().hasPermission();
                                  if (result) {
                                    Directory tempDir = await getTemporaryDirectory();
                                    File filePath = File('${tempDir.path}/audio.mp3');
                                    FilePath = filePath.path;
                                    setState(() {
                                      Recording = true;
                                      duration = Duration(seconds: 0);
                                      position = Duration(seconds: 0);
                                    });
                                    await record.start(
                                      path: filePath.path, // required
                                      encoder: AudioEncoder.aacLc, // by default
                                      bitRate: 128000, // by default
                                      samplingRate: 44100, // by default
                                    ).then((value) {
                                      setState(() {
                                        FilePath = filePath.path;
                                      });
                                    });
                                  } else {
                                    Permission.microphone.request();
                                  }
                                },
                                child: Container(
                                  height: media.height * 0.3,
                                  width: media.height * 0.3,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.black12
                                  ),
                                  child: Icon(Recording?Icons.pause:Icons.mic,size: media.width * 0.1,),
                                ),
                              ),
                              SizedBox(
                                height: media.height * 0.01,
                              ),
                              FilePath!=""?Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  play?
                                  InkWell(
                                    onTap: () async {
                                      setState(() {
                                        play = !play;
                                      });
                                      pauseaudio();
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(media.width * 0.02),
                                      decoration: BoxDecoration(
                                          color: Colors.black12,
                                          shape: BoxShape.circle
                                      ),
                                      child: Icon(Icons.pause,color: Colors.black,),
                                    ),
                                  ):
                                  InkWell(
                                    onTap: () async {
                                      setState(() {
                                        play = !play;
                                      });
                                      await audioPlayer.play("$FilePath");
                                      audioPlayer.onDurationChanged.listen((updatedduration) {
                                        setState(() {
                                          duration = updatedduration;
                                        });
                                      });
                                      audioPlayer.onPlayerCompletion.listen((event) {
                                        setState(() {
                                          play = false;
                                          position = Duration(seconds: 0);
                                        });
                                      });
                                      audioPlayer.onAudioPositionChanged.listen((event) {
                                        setState(() {
                                          position = event;
                                        });
                                      });
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(media.width * 0.02),
                                      decoration: BoxDecoration(
                                          color: Colors.black12,
                                          shape: BoxShape.circle
                                      ),
                                      child: Icon(Icons.play_arrow,color: Colors.black,),
                                    ),
                                  ),
                                  SizedBox(width: media.width*0.638,child: Slider(value: position.inSeconds.toDouble(), onChanged: (value) {},max: duration.inSeconds.toDouble(),min: 0,inactiveColor: Colors.black12,activeColor: Colors.yellow,)),
                                  InkWell(
                                      onTap: () {
                                        stopaudio();
                                        setState(() {
                                          FilePath = "";
                                        });
                                      },
                                      child: Icon(Icons.delete))
                                ],
                              ):Text(languages[choosenLanguage]['text_taptorecord'],textAlign: TextAlign.center,style: GoogleFonts.roboto(
                                  fontSize: media.width * 0.04,
                                  fontWeight: FontWeight.w500,
                                  color: textColor),)
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      if(FilePath!="" && !Recording){
                        setState(() {
                          isLoading = true;
                        });
                        saveaudio();
                      }
                      print(FilePath);
                    },
                    child: Container(
                      height: media.width * 0.12,
                      width: media.width * 1 - media.width * 0.08,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: FilePath!="" && !Recording?Colors.black:Colors.black12
                      ),
                      child : Text(languages[choosenLanguage]
                          ['text_save'],
                        style: GoogleFonts.roboto(
                            fontSize: media.width * sixteen,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1),
                      ),
                    ),
                  )
                ],
              ),
            ),
            isLoading?Positioned(top: 0, child: Loading()):Container(),
          ],
        ),
      ),
    );
  }

  saveaudio() async {
      final response =  http.MultipartRequest('POST', Uri.parse(url + 'api/v1/user/add-media'));
      response.headers.addAll({'Content-Type': 'application/json','Authorization': 'Bearer $tokens'});
      response.files.add(
          await http.MultipartFile.fromPath('media', FilePath));
      response.fields['status'] = "1";
      response.fields['type'] = "2";
      var request = await response.send();
      var respon = await http.Response.fromStream(request);
      print(respon.body);
      if(respon.statusCode==200) {
        if(jsonDecode(respon.body)['success']==true) {
          setState(() {
            FilePath="";
            isLoading = false;
          });
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
            isLoading = false;
          });
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