import 'dart:async';
import 'package:plant_project/camera.dart';
import 'package:plant_project/login.dart';
import 'package:plant_project/otherfunction.dart';
import 'package:plant_project/send_location.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:plant_project/personal_information.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:plant_project/plant_data.dart';
import 'package:plant_project/plant_introduce.dart';
import 'package:plant_project/task.dart';
import 'package:plant_project/plant_marker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/*首頁*/
class MenuPage extends StatefulWidget {
  const MenuPage({Key? key}) : super(key: key);

  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  late GoogleMapController _mapController;
  LatLng? _currentLocation; // 初始位置為 (0, 0);
  late StreamSubscription<Position> _positionStreamSubscription;
  List<PlantInfo> _plantLocations = [];
  List<PlantImage> _plantImages=[];
  final Set<Marker> _markers = {};
  late MQTTManager _mqttManager;

  @override
  void initState() {
    super.initState();
    _initializePage();
    _mqttManager = MQTTManager(studentID); //傳定位
  }

  Future<void> _initializePage() async {
    await _determinePosition();
    await _loadPlantLocations();
    await _loadMarkers();

    _positionStreamSubscription = Geolocator.getPositionStream().listen((position) {
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });
    });
  }

  @override
  void dispose() {
    _positionStreamSubscription.cancel();
    _mqttManager.dispose();
    super.dispose();
  }

  //讀取植物位置
  Future<void> _loadPlantLocations() async {
    List<dynamic> plantData = await fetchAllPlantData();
    print(plantData);
    if (plantData.isNotEmpty && plantData[0].isNotEmpty || plantData[1].isNotEmpty){
      setState(() {
        _plantLocations = plantData[0];
        if (_plantLocations.isEmpty) {
          print('no data');
        }
        if(plantData[1].isNotEmpty){
          _plantImages = plantData[1];
          if (_plantImages.isEmpty) {
            print('no data');
          }
        }
      });
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return Geolocator.getCurrentPosition();
  }

  //載入植物圖片
  Future<void> _loadMarkers() async {
    List<Marker?> markerList = await Future.wait(
      _plantLocations.map(
            (location) async {
          return CustomMarker.buildMarkerFromUrl(
            id: location.id,
            url: location.plantphoto,
            position: LatLng(location.locations[0].latitude, location.locations[0].longitude),
            width: ScreenUtil().setWidth(400),
            height:ScreenUtil().setHeight(250),
            onTap: () {
              _showPlantInfo(location);
            },
          );
        },
      ),
    );

    List<Marker> customMarkers = markerList.whereType<Marker>().toList();

    setState(() {
      _markers.addAll(customMarkers);
    });
  }

  //顯示植物掃描資訊
  void _showPlantInfo(PlantInfo plantInfo) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: Align(
            alignment: Alignment.center,
            child: Text('植 物 資 訊', textAlign: TextAlign.center,),
          ),
          content: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: ScreenUtil().setHeight(150)), // 設定最大高度
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('植　　物： ${plantInfo.plantName}'),
                    Text('拍攝時間： ${plantInfo.STime}'),
                  ],
                ),
              ),
            ),
          ),
          actions: <Widget>[
            Row(
            mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PlantIntroducePage(plantName: plantInfo.plantName,isMy: true)), //跳轉圖鑑(植物介紹)頁面
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(167, 173, 147, 1),
                    shadowColor: const Color.fromRGBO(167, 173, 147, 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    '查看更多',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
                SizedBox(width: ScreenUtil().setWidth(100)),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(167, 173, 147, 1),
                    shadowColor: const Color.fromRGBO(167, 173, 147, 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    '確定',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
                ],
            ),
          ],
          backgroundColor: const Color.fromRGBO(238, 241, 230, 1),
        );
      },
    );
  }


  //選擇要上傳的任務照片
  void _showPhotoUploadDialog(BuildContext context, Task task) {
    final now = DateTime.now().add(Duration(hours: 0));
    List<String> selectedImage = [];
    List<String> selectedImageUrls = [];


    DateTime startTime = DateTime.parse(task.stime);
    DateTime endTime = DateTime.parse(task.otime);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10), 
              ),
              title: Column(
                children: [
                  const Text(
                    '選擇要上傳的照片',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '已選擇 ${selectedImage.length} 張照片',
                    style: TextStyle(fontSize: ScreenUtil().setSp(70)),
                  ),
                ],
              ),
              content: Container(
                width: ScreenUtil().setWidth(500),
                height: ScreenUtil().setHeight(800),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                  ),
                  itemCount: _plantImages.length,
                  itemBuilder: (BuildContext context, int index) {
                    final image = _plantImages[index].STime;
                    final imageUrl = _plantImages[index].imageUrl;
                    final isSelected = selectedImage.contains(image);

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            selectedImage.remove(image);
                            selectedImageUrls.remove(imageUrl);
                          } else {
                            selectedImage.add(image);
                            selectedImageUrls.add(imageUrl);
                          }
                        });
                      },
                      child: Stack(
                        children: [
                          ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child:Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                width: ScreenUtil().setWidth(400),
                                height: ScreenUtil().setHeight(500),
                              ),
                          ),
                          if (isSelected)
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.black.withOpacity(0.4), // 50% 的黑色半透明背景
                                ),
                                child: Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: ScreenUtil().setWidth(200),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              backgroundColor: const Color.fromRGBO(238, 241, 230, 1),
              actions: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                       ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: Color.fromARGB(255, 185, 181, 181), // 灰色背景
                          foregroundColor: Color.fromARGB(255, 185, 181, 181),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          '返回',
                          style: TextStyle(fontSize: ScreenUtil().setSp(70), color: Colors.white),
                        ),
                      ),
                    SizedBox(width: ScreenUtil().setWidth(80)),
                    Builder(
                      builder: (BuildContext context) {
                        // 檢查任務是否處於開放狀態
                        if (now.isBefore(startTime) || now.isAfter(endTime)) {
                          return ElevatedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10), // 調整AlertDialog的borderRadius
                                    ),
                                    content: Text(
                                      '任務尚未開放！',
                                      style: TextStyle(
                                        fontSize: ScreenUtil().setSp(90),
                                      ),
                                      textAlign: TextAlign.center, // 將文字置中
                                    ),
                                    actions: <Widget>[
                                      ButtonBar(
                                        alignment: MainAxisAlignment.center, // 將按鈕置中
                                        children: [
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              elevation: 0,
                                              backgroundColor: Color.fromRGBO(167, 173, 147, 1),
                                              foregroundColor: Color.fromRGBO(167, 173, 147, 1),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                            ),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text(
                                              '確 定',
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                    backgroundColor: Color.fromRGBO(238, 241, 230, 1),// 灰色背景
                                  );
                                },
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: Color.fromARGB(255, 185, 181, 181), // 灰色背景
                              foregroundColor: Color.fromARGB(255, 185, 181, 181),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              '確認上傳',
                              style: TextStyle(fontSize: ScreenUtil().setSp(70), color: Colors.white),
                            ),
                          );
                        } else {
                          return ElevatedButton(
                            onPressed: () {
                              _uploadSelectedImagesToFirebase(selectedImageUrls, task);
                              Navigator.of(context).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: Color.fromRGBO(167, 173, 147, 1),
                              foregroundColor: Color.fromRGBO(167, 173, 147, 1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              '確認上傳',
                              style: TextStyle(fontSize: ScreenUtil().setSp(70), color: Colors.white),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  //上傳任務照片到firebase
  Future<void> _uploadSelectedImagesToFirebase(List<String> selectedImageUrls, Task task) async {
    String currentDate = DateTime.now().toString().substring(0, 4)+task.Name.substring(3, 7);

    String collectionPath = '學生/${studentSchool}/${studentID}/任務/$currentDate';
    String documentPath = '${task.Name}';
    bool finish = false;

    FirebaseFirestore.instance.collection(collectionPath).doc(documentPath).set({
      '掃描圖片': selectedImageUrls,
      '內容': task.content,
      '積分': task.score,
      '完成': finish,
    }).then((_) {
      print('Images uploaded successfully!');
    }).catchError((error) {
      print('Error uploading images: $error');
    });

    try {
      // 檢查文檔中是否存在任務列表陣列
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('學生')
          .doc(studentSchool)
          .collection(studentID)
          .doc('任務')
          .get();
      if (docSnapshot.exists) {
        Map<String, dynamic>? data = docSnapshot.data() as Map<String, dynamic>?;
        if (data != null) {
          List<String>? taskList = data['任務列表']?.cast<String>();
          if (taskList == null || !taskList.contains(currentDate)) {
            // 如果任務列表陣列不存在或不包含當前任務名稱，則添加當前任務名稱
            taskList ??= [];
            taskList.add(currentDate);
            await FirebaseFirestore.instance
                .collection('學生')
                .doc(studentSchool)
                .collection(studentID)
                .doc('任務')
                .update({'任務列表': taskList});
          }
        }
      } else {
        await FirebaseFirestore.instance
            .collection('學生')
            .doc(studentSchool)
            .collection(studentID)
            .doc('任務')
            .set({'任務列表': [currentDate]});
      }
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            content: Text(
              '上傳成功！',
              style: TextStyle(
                fontSize: ScreenUtil().setSp(90),
              ),
              textAlign: TextAlign.center,
            ),
            actions: <Widget>[
              ButtonBar(
                alignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: Color.fromRGBO(167, 173, 147, 1),
                      foregroundColor: Color.fromRGBO(167, 173, 147, 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      '確 定',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            backgroundColor: Color.fromRGBO(238, 241, 230, 1),// 灰色背景
          );
        },
      );
    } catch (e) {
      print('Error updating scan count: $e');
    }
  }

  //顯示今日任務
  void _showMenuTaskOptions() async {
    try {
      final tasks = await fetchTasks();

      showDialog(
        context: context,
        builder: (BuildContext context) {
          if (tasks.isEmpty) {
            // 如果 tasks 為空，顯示 '今日沒有任務' 的提示
            return AlertDialog(
              title: const Text(
                '今日沒有任務',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              backgroundColor: const Color.fromRGBO(238, 241, 230, 1),
            );
          } else {
            // 如果 tasks 不為空，則顯示任務列表
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                    10),
              ),
              title: const Text(
                '今日任務',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: ListBody(
                  children: tasks.map((task) {
                    return Column(
                      children: [
                        Row( // 在這裡包裹 ListTile 和按鈕
                          children: [
                            Expanded(
                              child: ListTile(
                                title: Text(
                                  task.title,
                                  style: TextStyle(fontSize: ScreenUtil().setSp(90)),
                                ),
                                subtitle: Text(
                                  task.content,
                                  style: TextStyle(fontSize: ScreenUtil().setSp(80)),
                                ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                _showPhotoUploadDialog(context, task);
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Color.fromRGBO(
                                      167, 173, 147, 1)
                              ),
                              child: const Text(
                                '上傳照片',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        const Divider(),
                      ],
                    );
                  }).toList(),
                ),
              ),
              backgroundColor: const Color.fromRGBO(238, 241, 230, 1),
            );
          }
        },
      );
    } catch (e) {
      print('Error fetching tasks: $e');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: const Text(
              '獲取任務失敗',
              style: TextStyle(fontFamily: 'FangSong'),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('確定', style: TextStyle(fontFamily: 'FangSong')),
              ),
            ],
            backgroundColor: const Color.fromARGB(255, 237, 189, 186),
          );
        },
      );
    }
  }

  // 要求定位
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

  @override
  Widget build(BuildContext context) {
    _requestLocationPermission();
    return Scaffold(
      backgroundColor: Color(0xFFFAF9F3),
      body: _currentLocation == null
          ? Center(
        child: CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Color.fromRGBO(167, 173, 147, 1)),),
      )
          :  Container(
            decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/images/menu.png"), // 背景
            fit: BoxFit.fill,
      ),
    ),child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: ScreenUtil().setHeight(1865),
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _currentLocation ?? const LatLng(0, 0),
                zoom: 18,
              ),
              onMapCreated: (controller) {
                _mapController = controller;
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              markers: _markers,
              minMaxZoomPreference: MinMaxZoomPreference(18, null),
              mapType: MapType.normal, // 或者是其他地圖類型，比如satellite
              /*cameraTargetBounds: CameraTargetBounds(
                LatLngBounds(
                  southwest: const LatLng(23.4851074, 120.4557846), // 西南角
                  northeast: const LatLng(23.4860749, 120.4565896), // 東北角
                ),
              ),*/
            ),
          ),
          Positioned(
            top: ScreenUtil().setHeight(110),
            left: ScreenUtil().setWidth(60),
            child: FloatingActionButton(
              backgroundColor: const Color.fromRGBO(238, 241, 230, 1),
              child: const Icon(Icons.my_location),
              onPressed: () async {
                final position = await _determinePosition();
                _mapController.animateCamera(CameraUpdate.newLatLng(
                  LatLng(position.latitude, position.longitude),
                ));
              },
            ),
          ),
          Positioned(
            top: ScreenUtil().setHeight(110),
            left: ScreenUtil().setWidth(1300),
            child: ElevatedButton(
              onPressed: _showMenuTaskOptions,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                elevation: 0,
                backgroundColor: Color.fromRGBO(238, 241, 230, 1),
                foregroundColor: Color.fromRGBO(238, 241, 230, 1),
                shape: CircleBorder(), //任務按鈕
              ),
              child: Ink(
                height: ScreenUtil().setHeight(150),
                width: ScreenUtil().setWidth(100),
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/menu_task.png"),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: ScreenUtil().setHeight(1900),
            left: ScreenUtil().setWidth(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                height: ScreenUtil().setHeight(220),
                width: ScreenUtil().setWidth(280),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PersonalPage()), //跳轉個人設定頁面
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: CircleBorder(),
                    padding: EdgeInsets.zero,
                  ),
                  child: Ink(
                    height: ScreenUtil().setHeight(220),
                    width: ScreenUtil().setWidth(280),
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/images/menu_btn1.png"),//個人設定按鈕
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: ScreenUtil().setHeight(1895),
            left: ScreenUtil().setWidth(565),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                height: ScreenUtil().setHeight(220),
                width: ScreenUtil().setWidth(320),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => CameraPage()),//跳轉掃描頁面
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: CircleBorder(),
                    padding: EdgeInsets.zero,
                  ),
                  child: Ink(
                    height: ScreenUtil().setHeight(220),
                    width: ScreenUtil().setWidth(320),
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/images/menu_btn2.png"), //掃描按鈕
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: ScreenUtil().setHeight(1910),
            left: ScreenUtil().setWidth(1150),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                height: ScreenUtil().setHeight(205),
                width: ScreenUtil().setWidth(280),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => OtherFunctionPage()), //跳轉功能選單頁面
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: CircleBorder(),
                    padding: EdgeInsets.zero,
                  ),
                  child: Ink(
                    height: ScreenUtil().setHeight(205),
                    width: ScreenUtil().setWidth(280),
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/images/menu_btn3.png"), //功能選單按鈕
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}