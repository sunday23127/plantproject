import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:plant_project/login.dart';


/*獲取植物資料(校園地圖)*/
class PlantInfo {
  String plantName;
  String docname;
  List<LatLng> locations;
  String plantphoto;
  String id;
  String STime;

  PlantInfo({
    required this.plantName,
    required this.docname,
    required this.locations,
    required this.plantphoto,
    required this.id,
    required this.STime,
  });
}


class PlantImage {
  String plantName;
  String imageUrl;
  String STime;

  PlantImage({
    required this.plantName,
    required this.imageUrl,
    required this.STime,

  });
}

DateTime now = DateTime.now();
String todayDate = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

List<String> plantNames = [];

Future<List<dynamic>> fetchAllPlantData() async {
  List<PlantInfo> plantInfoList = [];
  List<PlantImage> plantImages = [];
  int Pcount=0;

  try {
    final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
    await FirebaseFirestore.instance
        .collection('學生')
        .doc(studentSchool)
        .collection(studentID)
        .doc('掃描資料')
        .get();

    if (!documentSnapshot.exists || !documentSnapshot.data()!.containsKey('植物名稱')) {
      print('植物名稱字段不存在');

      return [[], []];
    }

    List<dynamic>? plantNameArray = documentSnapshot.get('植物名稱');

    plantNames = plantNameArray!.map((e) => e.toString()).toList();

    for (String plantName in plantNames) {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('學生')
          .doc(studentSchool)
          .collection(studentID)
          .doc('掃描資料')
          .collection(plantName)
          .get();

      final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
      await FirebaseFirestore.instance
          .collection('植物資料')
          .doc(plantName)
          .get();

      String plantphoto=documentSnapshot.get('圖片');

      for (var doc in snapshot.docs) {
        String date = doc.id.substring(6, 16);
        String name = doc.id;
        List<LatLng> locations = [];

        // 取得座標
        GeoPoint? geoPoint = doc['座標'];
        if (geoPoint != null) {
          double latitude = geoPoint.latitude;
          double longitude = geoPoint.longitude;
          locations.add(LatLng(latitude, longitude));
          print('Added location: $latitude, $longitude');
        }

        Pcount+=1;

        if (date == todayDate) {
          String imageUrl = doc['掃描圖片'].toString(); // 获取掃描圖片的 image URL
          String STime=doc['掃描時間'];
          PlantImage plantImage = PlantImage(imageUrl: imageUrl, plantName: plantName,STime:STime);
          plantImages.add(plantImage);
        }
        Timestamp SCTime= doc['掃描時間'];
        int millisecondsSinceEpoch = SCTime.seconds * 1000 + SCTime.nanoseconds ~/ 1000000;
        DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch);
        String formattedDateTime = DateFormat('yyyy-MM-dd HH:mm').format(dateTime);

        // 創建 PlantInfo 對象並添加到列表中
        PlantInfo plantInfo = PlantInfo(
          plantName: plantName,
          docname: name,
          locations: locations,
          plantphoto: plantphoto,
          id:Pcount.toString(),
          STime: formattedDateTime,
        );
        plantInfoList.add(plantInfo);

      }
    }

    print('All data fetched successfully');

    if (plantInfoList.isEmpty) {
      List<LatLng> loc = [const LatLng(0, 0)];
      PlantInfo plantInfo = PlantInfo(
        plantName: '無植物',
        docname: '無日期',
        locations: loc,
        plantphoto: 'unknown',
        id:'unknown',
        STime:'unknown',
      );
      plantInfoList.add(plantInfo);
    }

    return [plantInfoList, plantImages];
  } catch (e) {
    print('Error fetching plant locations: $e');

    return [[], []];
  }
}
