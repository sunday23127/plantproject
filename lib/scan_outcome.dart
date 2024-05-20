import 'dart:io';
import 'package:plant_project/camera.dart';
import 'package:flutter/material.dart';
import 'package:plant_project/login.dart';
import 'package:plant_project/plant_introduce.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

/*辨識結果頁面*/
class ScanOutcomePage extends StatelessWidget {
  final String imagePath;
  final String plant;
  final Position currentPosition;
  final String currentDateTime;

  const ScanOutcomePage({super.key, required this.imagePath, required this.plant, required this.currentPosition, required this.currentDateTime});

  Future<void> uploadImageToStorageAndFirestore(String imagePath, String plant) async {
    File file = File(imagePath);
    String fileName = file.path.split('/').last; // 獲取文件名
    print('圖片路徑:');
    print(imagePath);
    print('圖片名稱:');
    print(fileName);

    try {
      // 上傳圖片到 Firebase Storage
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
          .ref('/掃描資料/$studentSchool/$studentID/$plant/$fileName');
      await ref.putFile(file);

      // 獲取上傳後圖片的 URL
      String imageUrl = await ref.getDownloadURL();
      print('圖片url:');
      print(imageUrl);

      GeoPoint location = GeoPoint(currentPosition.latitude, currentPosition.longitude);
      Timestamp timestamp = Timestamp.fromDate(DateTime.now());
      // 將座標、日期、圖片的 URL 儲存到 Firestore 中
      await FirebaseFirestore.instance.collection('學生').doc(studentSchool).collection(studentID).doc('掃描資料').collection(plant).doc(studentID + ' ' + currentDateTime).set({
        '座標': location,
        '掃描時間': timestamp,
        '掃描圖片': imageUrl,
      });
    } catch (e) {
      print('Error uploading image to Storage and Firestore: $e');
    }
  }

  Future<int> getScanCount() async {
    try {
      // 獲取 Firestore 中儲存的掃描數量
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('學生')
          .doc(studentSchool)
          .collection(studentID)
          .doc('掃描資料')
          .get();
      if (docSnapshot.exists) {
        Map<String, dynamic>? data = docSnapshot.data() as Map<String, dynamic>?;
        return data?['掃描數量'] ?? 0;
      } else {
        return 0;
      }
    } catch (e) {
      print('Error getting scan count: $e');
      return 0;
    }
  }

  //更新掃描數量
  Future<void> updateScanCountIfNeeded(String plantName, int currentCount) async {
    try {
      // 檢查文檔中是否存在植物名稱陣列
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('學生')
          .doc(studentSchool)
          .collection(studentID)
          .doc('掃描資料')
          .get();
      if (docSnapshot.exists) {
        Map<String, dynamic>? data = docSnapshot.data() as Map<String, dynamic>?;
        if (data != null) {
          List<String>? plantNames = data['植物名稱']?.cast<String>();
          if (plantNames == null || !plantNames.contains(plantName)) {
            // 如果植物名稱陣列不存在或不包含當前植物名稱，則添加當前植物名稱並更新掃描數量
            plantNames ??= [];
            plantNames.add(plantName);
            await FirebaseFirestore.instance
                .collection('學生')
                .doc(studentSchool)
                .collection(studentID)
                .doc('掃描資料')
                .update({'植物名稱': plantNames, '掃描數量': currentCount + 1});
          }
        }
      } else {
        // 如果文檔不存在，則創建新文檔並設置掃描數量為 1，包含當前植物名稱的陣列
        await FirebaseFirestore.instance
            .collection('學生')
            .doc(studentSchool)
            .collection(studentID)
            .doc('掃描資料')
            .set({'植物名稱': [plantName], '掃描數量': 1});
      }
    } catch (e) {
      print('Error updating scan count: $e');
    }
  }

  //頁面呈現
  @override
  Widget build(BuildContext context) {
    if(plant != ''){
      uploadImageToStorageAndFirestore(imagePath, plant);
      // 在成功上傳圖片後，更新掃描數量
      getScanCount().then((count) {
        updateScanCountIfNeeded(plant, count);
      });
    }
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/scan_background.png"),
            fit: BoxFit.fill,
          ),
        ),
        child: Stack(
          children: <Widget>[
            Positioned(
              top: ScreenUtil().setHeight(90),
              left: ScreenUtil().setWidth(80),
              child: GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => CameraPage()),//跳轉至掃描頁面
                  );
                },
                child: Image.asset(
                  "assets/images/back_btn.png",
                  width: ScreenUtil().setWidth(200),
                  height: ScreenUtil().setHeight(150),
                ),
              ),
            ),
            if(plant != '') Positioned(
              top: ScreenUtil().setHeight(550),
              left: ScreenUtil().setWidth(300),
              right: ScreenUtil().setWidth(300),
              child: Text(
                plant,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(90),
                  color: Colors.black,
                ),
              ),
            ),
            Positioned(
              top: plant != '' ?ScreenUtil().setHeight(750):ScreenUtil().setHeight(450),
              left: ScreenUtil().setWidth(300),
              right: ScreenUtil().setWidth(300),
              child: Container(
                width: ScreenUtil().setWidth(950),
                height: ScreenUtil().setHeight(650),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.0),
                  border: Border.all(
                    color: Colors.black,
                    width: 2.0,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15.0),
                  child: plant != '' ? Image.file(
                      File(imagePath),
                      fit: BoxFit.cover,
                    ): Image.asset(
                    "assets/images/scan_error.png",
                    fit: BoxFit.cover,
                ),
                ),
              ),
            ),
            if(plant != '') Positioned(
              top: ScreenUtil().setHeight(1500),
              left: ScreenUtil().setWidth(525),
              right: ScreenUtil().setWidth(525),
              child: ElevatedButton(
                onPressed:() {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PlantIntroducePage(plantName: plant,isMy: true)), //跳轉圖鑑(植物介紹)頁面
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(218, 222, 197, 1),
                  shadowColor: const Color.fromRGBO(218, 222, 197, 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  '查看更多',
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(80),
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            if(plant == '') Positioned(
              top: ScreenUtil().setHeight(1200),
              left: ScreenUtil().setWidth(500),
              right: ScreenUtil().setWidth(500),
              child: Container(
                width: ScreenUtil().setWidth(200),
                height: ScreenUtil().setHeight(120),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(238, 217, 202, 1),
                  borderRadius: BorderRadius.circular(20.0),
                ),
                alignment: Alignment.center,
                child: Text(
                  '請重新辨識！',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(70),
                    color: Colors.black,
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

