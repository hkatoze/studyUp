import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:math' as math;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:pdf_text/pdf_text.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:study_up/constants.dart';

class AudioRead extends StatefulWidget {
  final String bookPicture;
  final String bookTitle;
  final String bookAuthor;
  final String book;

  const AudioRead(
      {Key? key,
      required this.bookPicture,
      required this.bookAuthor,
      required this.bookTitle,
      required this.book})
      : super(key: key);
  @override
  _AudioReadState createState() => _AudioReadState();
}

class _AudioReadState extends State<AudioRead>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: Duration(seconds: 10))
        ..repeat();
  bool isSpeaking = false;
  bool isReading = true;
  String _text = "";
  PDFDoc? _pdfDoc;
  bool _isOk = false;
  var end = "";
  final _flutterr_tts = FlutterTts();
  void initializeTts() {
    _flutterr_tts.setStartHandler(() {
      setState(() {
        isSpeaking = true;
      });
    });
    _flutterr_tts.setCompletionHandler(() {
      setState(() {
        isSpeaking = false;
      });
    });
    _flutterr_tts.awaitSpeakCompletion(true);
    _flutterr_tts.setErrorHandler((message) {
      setState(() {
        isSpeaking = false;
      });
    });

    _flutterr_tts.setLanguage("fr-FR");
    _flutterr_tts.setSpeechRate(0.5);
    _flutterr_tts.setPitch(1);
  }

  @override
  void initState() {
    super.initState();
    initializeTts();
    extracText();
  }

  void speak(String text) async {
    var count = text.length;
    var max = 4000;
    var loopCount = count ~/ max;

    for (var i = 0; i <= loopCount; i++) {
      if (i != loopCount) {
        await _flutterr_tts.speak(text.substring(i * max, (i + 1) * max));
      } else {
        var end = (count - ((i * max)) + (i * max));
        await _flutterr_tts.speak(text.substring(i * max, end));
      }
    }
  }

  void stop() async {
    await _flutterr_tts.stop();
  }

  void pause() async {
    await _flutterr_tts.pause();
  }

  void continued() async {
    speak(_text);
  }

  String removeAllHtmlTags(String htmlText) {
    RegExp exp = RegExp(
      r"/\r?\n|\r/g",
    );

    return htmlText.replaceAll(exp, '');
  }

  void extracText() async {
    _pdfDoc = await PDFDoc.fromURL(
        "https://bookstudy.smt-group.net/docs/${widget.book}");

    String text = await _pdfDoc!.text;

    setState(() {
      _text = removeAllHtmlTags(text);
      _isOk = true;
    });

    speak(_text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColor,
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        centerTitle: true,
        title: Text(widget.bookTitle),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            size: 25.0,
            color: KSecondaryColor,
          ),
          onPressed: () {
            _controller.stop();
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.more_vert,
              size: 25.0,
              color: KSecondaryColor,
            ),
            onPressed: () => {},
          ),
        ],
      ),
      body: !_isOk
          ? Center(
              child: SpinKitRotatingCircle(
              color: Colors.white,
            ))
          : SingleChildScrollView(
              physics: BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics()),
              child: Container(
                height: heightP(context, 1),
                color: kPrimaryColor,
                child: Column(children: [
                  SizedBox(
                    height: heightP(context, 0.01),
                  ),
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (_, child) {
                      return Transform.rotate(
                        angle: _controller.value * 2 * math.pi,
                        child: child,
                      );
                    },
                    child: Container(
                      width: widthP(context, 0.5),
                      height: heightP(context, 0.5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: CachedNetworkImageProvider(
                              "https://bookstudy.smt-group.net/image/${widget.bookPicture}"),
                        ),
                      ),
                    ),
                  ),
                  Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        IconButton(
                          onPressed: () {},
                          icon: Icon(
                            Icons.list,
                            size: 25.0,
                            color: Colors.grey,
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: Icon(
                            Icons.shuffle,
                            size: 25.0,
                            color: Colors.grey,
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: Icon(
                            Icons.favorite_border,
                            size: 25.0,
                            color: Colors.grey,
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: Icon(
                            Icons.cloud_download,
                            size: 25.0,
                            color: Colors.grey,
                          ),
                        ),
                      ]),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  Text(
                    widget.bookAuthor,
                    style: TextStyle(color: Colors.grey, fontSize: 15.0),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  Text(
                    widget.bookTitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        isReading = !isReading;
                        if (isReading == false) {
                          _controller.stop();
                          stop();
                        } else {
                          _controller.repeat();
                          continued();
                        }
                      });
                    },
                    child: Container(
                      height: heightP(context, 0.06),
                      width: heightP(context, 0.06),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Color(0XFFdfe6fc)),
                      child: Icon(
                        isReading ? Icons.pause_circle : Icons.play_arrow,
                        color: Colors.blue,
                      ),
                    ),
                  )
                ]),
              )),
    );
  }
}
