import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tagyourtaxi_driver/functions/functions.dart';
import 'package:tagyourtaxi_driver/pages/NavigatorPages/videoscreen.dart';
import 'package:tagyourtaxi_driver/styles/styles.dart';
import 'package:tagyourtaxi_driver/translations/translation.dart';

class recordvideo extends StatefulWidget {
  const recordvideo({Key? key}) : super(key: key);

  @override
  State<recordvideo> createState() => _recordvideoState();
}

class _recordvideoState extends State<recordvideo> {

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Container(
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
                      child: Text(languages[choosenLanguage]['text_video'],textAlign: TextAlign.center,style: GoogleFonts.roboto(
                          fontSize: media.width * 0.04,
                          fontWeight: FontWeight.w500,
                          color: textColor),),
                    ),
                    Container(
                      height: media.height *0.6,
                      alignment: Alignment.center,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () async {
                              Navigator.push(context, MaterialPageRoute(builder: (context) {
                                return videoscreen();
                              },));
                            },
                            child: Container(
                              height: media.height * 0.3,
                              width: media.height * 0.3,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black12
                              ),
                              child: Icon(Icons.video_call_outlined,size: media.width * 0.3,),
                            ),
                          ),
                          SizedBox(
                            height: media.height * 0.01,
                          ),
                          Text(languages[choosenLanguage]['text_taptorecord'],textAlign: TextAlign.center,style: GoogleFonts.roboto(
                              fontSize: media.width * 0.04,
                              fontWeight: FontWeight.w500,
                              color: textColor),)
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: media.width * 0.12,
                width: media.width * 1 - media.width * 0.08,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.black
                ),
                child : Text(languages[choosenLanguage]
                ['text_submit'],
                  style: GoogleFonts.roboto(
                      fontSize: media.width * sixteen,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
