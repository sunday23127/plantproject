import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:plant_project/menu.dart';
import 'package:plant_project/scan_outcome.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

/*掃描頁面*/
class CameraPage extends StatelessWidget {
  const CameraPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FutureBuilder<List<CameraDescription>>(
        future: availableCameras(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return CameraScreen(cameras: snapshot.data!);
          } else {
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Color.fromRGBO(167, 173, 147, 1)),),
              ),
            );
          }
        },
      ),
      theme: ThemeData(
        primaryColor: Color.fromRGBO(167, 173, 147, 1),  // 主要顏色
        fontFamily: 'FangSong',  // 字體設置
        textSelectionTheme: TextSelectionThemeData(
            cursorColor: Color.fromRGBO(167, 173, 147, 1)
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  CameraScreen({required this.cameras});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late String plant;
  late CameraController controller;
  late Position currentPosition;
  late String currentDateTime;
  bool _isGettingLocation = false;
  XFile? imageFile;
  bool isFlashOn = false;
  double zoomLevel = 1;

  //拍的圖片傳到python模型辨識
  Future<void> _uploadImage(XFile xfile) async {
    File image = File(xfile.path);

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('https://us-central1-hybrid-snowfall-419307.cloudfunctions.net/onnx_model-1'),
    );
    request.files.add(
      await http.MultipartFile.fromPath(
        'image',
        image.path,
      ),
    );

    final response = await request.send();
    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final result = jsonDecode(responseData);
      String detectedClass = "";
      print('Prediction: $result');
      if(result.isNotEmpty){
        detectedClass = result[0]['class_name'];
      }
      plant = detectedClass;
    } else {
      print('Failed to upload image');
    }
  }

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();

    if (widget.cameras.isNotEmpty) {
      controller = CameraController(
        widget.cameras[0],
        ResolutionPreset.medium,
      );

      controller.initialize().then((_) {
        if (!mounted) {
          return;
        }
        controller.setZoomLevel(zoomLevel); // 設置初始缩放级别
        controller.startImageStream((image) => _processCameraImage(image)); // 开始相機圖像流
        setState(() {});
      });
    }
  }

  @override
  void dispose() {
    controller.stopImageStream(); // 停止相機圖像流
    controller.dispose();
    super.dispose();
  }

  // 要求定位權限
  void _requestLocationPermission() async {
    // Request location permission
    PermissionStatus status = await Permission.location.request();

    // Check the permission status
    if (status.isGranted) {
      // Permission granted, perform your operation
      print('Location permission granted');
    } else if (status.isDenied) {
      // Permission denied, show a message to the user
      print('Location permission denied');
    } else if (status.isPermanentlyDenied) {
      // Permission permanently denied, take the user to app settings
      print('Location permission permanently denied');
      openAppSettings();
    }
  }

  //取得目前所在位置
  Future<void> getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      currentPosition = position;
      print('位置');
      print(currentPosition);
    });
  }

  //取得目前日期時間
  void getCurrentDateTime() {
    DateTime now = DateTime.now();
    String formattedDateTime = DateFormat('yyyy-MM-dd HH:mm').format(now);
    setState(() {
      currentDateTime = formattedDateTime;
      print('時間');
      print(currentDateTime);
    });
  }


  void _processCameraImage(CameraImage image) {
    // 處理相機圖片
  }

  //拍照
  Future<void> takePicture() async {
    setState(() {
      _isGettingLocation = true; // 開始獲取位置信息，顯示Loading
      controller.setFlashMode(isFlashOn ? FlashMode.torch : FlashMode.off);
    });
    if (!controller.value.isInitialized) {
      return;
    }

    try {
      final XFile file = await controller.takePicture();
      setState(() {
        imageFile = file;
      });

      await _uploadImage(file);// 上傳照片去辨識

      await getCurrentLocation();// 獲取當前位置

      getCurrentDateTime();// 獲取當前日期

      setState(() {
        _isGettingLocation = false; // 結束獲取位置訊息，停止Loading
      });

      //跳轉至辨識結果頁面
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ScanOutcomePage(imagePath: file.path,plant: plant,currentPosition: currentPosition,currentDateTime: currentDateTime,)),
      );
    } catch (e) {
      print(e);
    }
  }

  //閃光燈
  void toggleFlash() {
    setState(() {
      isFlashOn = !isFlashOn;
      controller.setFlashMode(isFlashOn ? FlashMode.torch : FlashMode.off);
    });
  }

  //縮放鏡頭
  void zoomIn() {
    setState(() {
      zoomLevel += 1.0;
      zoomLevel = zoomLevel.clamp(1, 10); // 限制缩放級別在1x到10x之間
      controller.setZoomLevel(zoomLevel);
    });
  }

  void zoomOut() {
    setState(() {
      zoomLevel -= 1.0;
      zoomLevel = zoomLevel.clamp(1.0, 10.0); // 限制缩放級別在1x到10x之間
      controller.setZoomLevel(zoomLevel);
    });
  }

  //對焦
  void focusOnPoint(Offset offset) {
    controller.setFocusPoint(
      Offset(offset.dx / MediaQuery.of(context).size.width,
          offset.dy / MediaQuery.of(context).size.height),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.cameras.isEmpty) {
      return Scaffold(
        body: Center(
          child: Text('未檢測到相機'),
        ),
      );
    }

    if (!controller.value.isInitialized) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Color.fromRGBO(167, 173, 147, 1)),),
        ),
      );
    }
    if(_isGettingLocation){
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Color.fromRGBO(167, 173, 147, 1)),),
        ),
      );
    }
    return Scaffold(
      body: Stack(
        children: [
          GestureDetector(
            onTapDown: (TapDownDetails details) {
              focusOnPoint(details.localPosition);
            },
            onScaleUpdate: (ScaleUpdateDetails details) {
              if (details.scale != 1.0) {
                // 只有在缩放比例不是1.0時才進行放大或缩小
                double newZoomLevel = zoomLevel * details.scale;
                // 限制缩放級别在1到10之間
                newZoomLevel = newZoomLevel.clamp(1.0, 10.0);
                if (newZoomLevel != zoomLevel) {
                  setState(() {
                    zoomLevel = newZoomLevel;
                    controller.setZoomLevel(zoomLevel);
                  });
                }
              }
            },
            child: AspectRatio(
              aspectRatio: 0.55,
              child: CameraPreview(controller),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(right: 32.0, left: 32.0, bottom: 110.0),
              child: ElevatedButton(
                onPressed: () {
                  if (zoomLevel == 1.0) {
                    zoomIn();
                  }else if (zoomLevel == 2.0) {
                    setState(() {
                      zoomLevel = 5.0;
                      zoomLevel = zoomLevel.clamp(1, 10); // 限制缩放级别在1x到10x之間
                      controller.setZoomLevel(zoomLevel);
                    });
                  }else if (zoomLevel == 5.0) {
                    setState(() {
                      zoomLevel = 10.0;
                      zoomLevel = zoomLevel.clamp(1, 10); // 限制缩放级别在1x到10x之間
                      controller.setZoomLevel(zoomLevel);
                    });
                  }else if (zoomLevel == 10.0) {
                    setState(() {
                      zoomLevel = 1.0;
                      zoomLevel = zoomLevel.clamp(1, 10); // 限制缩放级别在1x到10x之間
                      controller.setZoomLevel(zoomLevel);
                    });
                  }else {
                    zoomOut();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromRGBO(0, 0, 0, 0.2),
                  shape: CircleBorder(),
                  side: BorderSide(
                    color: Color.fromRGBO(255, 255, 255, 0.4),
                    width: 1.5,
                  ),
                  padding: EdgeInsets.all(ScreenUtil().setSp(30)),
                ),
                child: Text(
                  '${zoomLevel.toStringAsFixed(1)}x',
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(50),
                    color: Color.fromRGBO(255, 255, 255, 0.9),
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 32.0, bottom: 16.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => MenuPage()),
                  );
                },
                child: Image.asset(
                  "assets/images/camera_back_btn.png",
                  width: ScreenUtil().setWidth(250),
                  height: ScreenUtil().setHeight(200),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: MaterialButton(
                onPressed: takePicture,
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
                child: Icon(
                  Icons.camera,
                  size: ScreenUtil().setSp(300),
                  color: Colors.black,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 28.0, bottom: 20.0),
              child: ElevatedButton(
                onPressed: toggleFlash,
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: CircleBorder(),
                  side: BorderSide(
                    color: Colors.black,
                    width: 2,
                  ),
                  padding: EdgeInsets.all(ScreenUtil().setSp(25)),
                ),
                child: Icon(
                  isFlashOn ? Icons.flash_on : Icons.flash_off,
                  size: ScreenUtil().setSp(125),
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

