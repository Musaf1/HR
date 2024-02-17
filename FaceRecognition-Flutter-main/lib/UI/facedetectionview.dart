import 'dart:async';
import 'package:facerecognition_flutter/UI/Employed.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:facesdk_plugin/facedetection_interface.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:facesdk_plugin/facesdk_plugin.dart';
import 'package:sqflite/sqflite.dart';
import '../Processes/Process.dart';

class FaceRecognitionView extends StatefulWidget {
  // final List<Person> personList;
  final EmployedPageState employedPageState;

  const FaceRecognitionView(
      {super.key,
      // required this.personList,
      required this.employedPageState});

  @override
  State<StatefulWidget> createState() => FaceRecognitionViewState();
}

class FaceRecognitionViewState extends State<FaceRecognitionView> {
  dynamic _faces;
  // dynamic _identifiedFace;
  dynamic _enrolledFace;
  double _livenesThreshold = 0;
  double _identifyThreshold = 0;
  bool _recognized = false;

  // int _identifiedId = 0;
  String _identifiedName = "";

  // String _identifiedJob = "";
  final _facesdkPlugin = FacesdkPlugin();
  late bool _cameraLens;
  late int index;
  late String textStatus = 'You have been attended';
  late String imageStatus = 'assets/correct.png';
  FaceDetectionViewController? faceDetectionViewController;

  @override
  void initState() {
    super.initState();
    loadSettings();
    updateCameraLens(true);
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    String? livensThreshold = prefs.getString("liveness_threshold");
    String? identifyThreshold = prefs.getString("identify_threshold");
    setState(() {
      _livenesThreshold = double.parse(livensThreshold ?? "0.7");
      _identifyThreshold = double.parse(identifyThreshold ?? "0.7");
    });
  }

  Future<void> faceRecognitionStart() async {
    final prefs = await SharedPreferences.getInstance();
    var cameraLens = prefs.getInt("camera_lens");

    setState(() {
      _faces = null;
      _recognized = false;
    });

    await faceDetectionViewController?.startCamera(cameraLens ?? 1);
  }

  Future<void> updateCameraLens(value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("camera_lens", value ? 1 : 0);

    setState(() {
      _cameraLens = value;
      faceRecognitionStart();
    });
  }

  Future<bool> onFaceDetected(faces) async {
    if (_recognized == true) {
      return false;
    }

    if (!mounted) return false;

    setState(() {
      _faces = faces;
    });

    bool recognized = false;
    double maxSimilarity = -1;
    //int maxSimilarityId = 0;
    String maxSimilarityName = "";
    // String maxSimilarityAttId = "";
    // String maxSimilarityJob = "";
    double maxLiveness = -1;
    dynamic enrolledFace; //, identifiedFace;
    if (faces.length > 0) {
      var face = faces[0];
      var databasesPath = await getDatabasesPath();
      String path = join(databasesPath, 'mydb.db');
      Database database = await openDatabase(
        path,
        version: 1,
      );
      List<Map> list = await database.rawQuery('SELECT * FROM Face');
      //var person = widget.personList[0];
        double similarity = await _facesdkPlugin.similarityCalculation(
                face['templates'], list[0]['templates']) ??
            -1;
        if (maxSimilarity < similarity) {
          final prefs = await SharedPreferences.getInstance();
          // maxSimilarityAttId = (await prefs.getInt('id').toString());
          maxSimilarityName = (await prefs.getString('name'))!;
          maxSimilarity = similarity;
          //maxSimilarityId = person.id;
          //maxSimilarityName = person.name;
          //maxSimilarityAttId = person.id_att;
          // maxSimilarityJob = person.job;
          maxLiveness = face['liveness'];
          // identifiedFace = face['faceJpg'];
          enrolledFace = list[0]['faceJpg'];
        }

        if (maxSimilarity > _identifyThreshold &&
            maxLiveness > _livenesThreshold) {
          faceDetectionViewController?.stopCamera();
          index = await Process().timeRecord();
          if (index == 1) {
            textStatus = 'You have been attended';
            imageStatus = 'assets/correct.png';
          } else if (index == 2) {
            textStatus = 'You have attended before';
            imageStatus = 'assets/logistics.png';
          } else {
            textStatus = 'Outside working hours';
            imageStatus = 'assets/working.png';
          }
          recognized = true;
        }
    }

    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted) return false;
      setState(() {
        _recognized = recognized;
        // _identifiedId = maxSimilarityId;
        _identifiedName = maxSimilarityName;
        // _identifiedJob = maxSimilarityJob;
        _enrolledFace = enrolledFace;
        // _identifiedFace = identifiedFace;
      });
      if (recognized) {
        faceDetectionViewController?.stopCamera();
        setState(() {
          _faces = null;
        });
        widget.employedPageState.setState(() {

        });
      }
    });

    return recognized;
  }

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(
      color: Color.fromRGBO(0, 150, 150, 1),
      fontWeight: FontWeight.w600,
      fontSize: 26,
    );
    // const textStyle2 = TextStyle(
    //   color: Color.fromRGBO(0, 150, 150, 1),
    //   fontWeight: FontWeight.w600,
    //   fontSize: 20,
    // );
    // const textStyle3 = TextStyle(
    //   color: Color.fromARGB(0xFF, 0x0, 150, 15),
    //   fontWeight: FontWeight.w600,
    //   fontSize: 26,
    // );
    return WillPopScope(
      onWillPop: () async {
        faceDetectionViewController?.stopCamera();
        return true;
      },
      child: SafeArea(
        child: Scaffold(
          body: Stack(
            children: <Widget>[
              FaceDetectionView(faceRecognitionViewState: this),
              SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: CustomPaint(
                  painter: FacePainter(
                      faces: _faces, livenessThreshold: _livenesThreshold),
                ),
              ),
              // Row(
              //   children: [
              //     Expanded(
              //       child: ElevatedButton.icon(
              //           label: const Text(
              //             'Add CV',
              //             // style: textStyle
              //           ),
              //           icon: const Icon(
              //             //  color: textColor,
              //             Icons.person_add_outlined,
              //             // color: Colors.white70,
              //           ),
              //           style: ElevatedButton.styleFrom(
              //               padding: const EdgeInsets.only(top: 10, bottom: 10),
              //               // foregroundColor: Colors.white70,
              //               //  backgroundColor: color,
              //               shape: const RoundedRectangleBorder(
              //                 borderRadius:
              //                     BorderRadius.all(Radius.circular(12.0)),
              //               )),
              //           onPressed: () {
              //             MyHomePageState().initShowDialog();
              //             MyHomePageState().enrollPerson(context);
              //           }),
              //     ),
              //   ],
              // ),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Icon(
                        Icons.camera_alt_outlined,
                        size: 36,
                      ),
                      const SizedBox(width: 8),
                      Switch(
                          //activeColor: const Color.fromRGBO(0, 96, 100, 1),
                          inactiveTrackColor:
                              const Color.fromRGBO(0, 172, 193, 1),
                          inactiveThumbColor:
                              const Color.fromRGBO(197, 225, 165, 1),
                          value: _cameraLens,
                          onChanged: (bool value) {
                            updateCameraLens(value);
                          }),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.camera_front_outlined,
                        size: 36,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  )
                ],
              ),
              Visibility(
                  visible: _recognized,
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Theme.of(context).colorScheme.background,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                _enrolledFace != null
                                    ? Column(
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            child: Image.memory(
                                              _enrolledFace,
                                              width: 200,
                                              height: 200,
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 5,
                                          ),
                                          Text(_identifiedName,
                                              style: textStyle),
                                          const SizedBox(
                                            height: 16,
                                          ),
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            child: Image(
                                              width: 200,
                                              height: 200,
                                              image: AssetImage(imageStatus),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 16,
                                          ),
                                          Text(textStatus, style: textStyle),
                                          // const SizedBox(
                                          //   height: 16,
                                          // ),
                                          // ElevatedButton.icon(
                                          //   icon: const Icon(
                                          //     //  color: textColor,
                                          //     Icons.check_circle_outline,
                                          //     color: Colors.green,
                                          //   ),
                                          //   style: ElevatedButton.styleFrom(
                                          //     // padding: const EdgeInsets.only(top: 10, bottom: 10),
                                          //     // foregroundColor: Colors.white70,
                                          //     //  backgroundColor: color,
                                          //       shape: const RoundedRectangleBorder(
                                          //         borderRadius: BorderRadius.all(Radius.circular(12.0)),
                                          //       )),
                                          //   onPressed: () {
                                          //     GoRouter.of(context).go('/');
                                          //   },
                                          //   label: const Text('OK'),
                                          // ),
                                        ],
                                      )
                                    : const SizedBox(
                                        height: 1,
                                      ),
                                // _identifiedFace != null
                                //     ? Column(
                                //         children: [
                                //           ClipRRect(
                                //             borderRadius:
                                //                 BorderRadius.circular(8.0),
                                //             child: Image.memory(
                                //               _identifiedFace,
                                //               width: 160,
                                //               height: 160,
                                //             ),
                                //           ),
                                //           const SizedBox(
                                //             height: 5,
                                //           ),
                                //           const Text('Identified',
                                //               style: textStyle2)
                                //         ],
                                //       )
                                //     : const SizedBox(
                                //         height: 1,
                                //       )
                              ],
                            ),
                          ),
                          // const SizedBox(
                          //   height: 10,
                          // ),
                          // Row(
                          //   children: [
                          //     const SizedBox(
                          //       width: 16,
                          //     ),
                          //     const Text('Id: ', style: textStyle),
                          //     Text('$_identifiedId', style: textStyle3)
                          //   ],
                          // ),
                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.center,
                          //   children: [
                          //     const SizedBox(
                          //       width: 16,
                          //     ),
                          //    // const Text('Name: ', style: textStyle),
                          //     Text(_identifiedName, style: textStyle3)
                          //   ],
                          // ),
                          // const SizedBox(
                          //   height: 16,
                          // ),
                          // Row(
                          //   children: [
                          //     const SizedBox(
                          //       width: 16,
                          //     ),
                          //     const Text('Job: ', style: textStyle),
                          //     Text(_identifiedJob, style: textStyle3)
                          //   ],
                          // ),
                        ]),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class FaceDetectionView extends StatelessWidget
    implements FaceDetectionInterface {
  FaceRecognitionViewState faceRecognitionViewState;

  FaceDetectionView({super.key, required this.faceRecognitionViewState});

  @override
  Future<void> onFaceDetected(faces) async {
    await faceRecognitionViewState.onFaceDetected(faces);
  }

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidView(
        viewType: 'facedetectionview',
        onPlatformViewCreated: _onPlatformViewCreated,
      );
    } else {
      return UiKitView(
        viewType: 'facedetectionview',
        onPlatformViewCreated: _onPlatformViewCreated,
      );
    }
  }

  void _onPlatformViewCreated(int id) async {
    final prefs = await SharedPreferences.getInstance();
    var cameraLens = prefs.getInt("camera_lens");

    faceRecognitionViewState.faceDetectionViewController =
        FaceDetectionViewController(id, this);

    await faceRecognitionViewState.faceDetectionViewController?.initHandler();

    int? livenessLevel = prefs.getInt("liveness_level");
    await faceRecognitionViewState._facesdkPlugin
        .setParam({'check_liveness_level': livenessLevel ?? 0});

    await faceRecognitionViewState.faceDetectionViewController
        ?.startCamera(cameraLens ?? 1);
  }
}

class FacePainter extends CustomPainter {
  dynamic faces;
  double livenessThreshold;

  FacePainter({required this.faces, required this.livenessThreshold});

  @override
  void paint(Canvas canvas, Size size) {
    if (faces != null) {
      var paint = Paint();
      paint.color = const Color.fromARGB(0xFF, 0xfd, 83, 83);
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 3;

      for (var face in faces) {
        double xScale = face['frameWidth'] / size.width;
        double yScale = face['frameHeight'] / size.height;

        String title = "";
        Color color = const Color.fromARGB(0xFF, 0xfd, 83, 83);
        if (face['liveness'] < livenessThreshold) {
          color = const Color.fromARGB(0xFF, 0xfd, 83, 83);
          title = "Spoof";
        } else {
          color = const Color.fromARGB(0xFF, 0x0, 150, 15);
          title = "Real";
        }

        TextSpan span =
            TextSpan(style: TextStyle(color: color, fontSize: 20), text: title);
        TextPainter tp =
            TextPainter(text: span, textDirection: TextDirection.rtl);
        tp.layout();
        tp.paint(canvas, Offset(face['x1'] / xScale, face['y1'] / yScale - 30));

        paint.color = color;
        canvas.drawRect(
            Offset(face['x1'] / xScale, face['y1'] / yScale) &
                Size((face['x2'] - face['x1']) / xScale,
                    (face['y2'] - face['y1']) / yScale),
            paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
