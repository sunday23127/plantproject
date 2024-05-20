import 'package:plant_project/login.dart';
import 'package:plant_project/other_dictionary.dart';
import 'package:plant_project/plant_structure.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'dart:ui';

/*植物介紹頁面*/
class PlantIntroducePage extends StatefulWidget {
  final String plantName; // 植物名稱
  final bool isMy; // 有沒有掃描過

  //接收傳遞的參數
  PlantIntroducePage({required this.plantName, required this.isMy});
  @override
  _PlantIntroducePageState createState() => _PlantIntroducePageState();
}

class _PlantIntroducePageState extends State<PlantIntroducePage> {
  int _current = 0;
  final CarouselController _controller = CarouselController();
  List<String> _imageUrls = [];

  @override
  void initState() {
    super.initState();
    _fetchPlantImages(widget.plantName);
    _fetchMyPlantImages(widget.plantName);
  }

  //讀取植物圖片
  Future<void> _fetchPlantImages(String plantName) async {
    print(widget.isMy);
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('植物資料')
          .doc(plantName)
          .get();

      if (snapshot.exists) {
        final imageUrl = snapshot.data()?['圖片'] as String? ?? "";
        setState(() {
          _imageUrls.add(imageUrl);
        });
      } else {
        print('No documents found for plant $plantName');
      }
    } catch (error) {
      print('Error fetching plant images: $error');
    }
  }

  //讀取使用者拍的植物圖片
  Future<void> _fetchMyPlantImages(String plantName) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('學生')
          .doc(studentSchool)
          .collection(studentID)
          .doc('掃描資料')
          .collection(plantName)
          .orderBy('掃描時間', descending: true)
          .limit(5)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final List<String> urls = snapshot.docs.map((doc) => doc.data()['掃描圖片'] as String).toList();

        setState(() {
          _imageUrls.addAll(urls);
        });
      } else {
        print('No documents found for plant $plantName');
      }
    } catch (error) {
      print('Error fetching plant images: $error');
    }
  }

  //頁面呈現
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/plant.introduce.png"),
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),
          Positioned(
            top: ScreenUtil().setHeight(90),
            left: ScreenUtil().setWidth(80),
            child: GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => DictionaryPage()),
                );
              },
              child: Image.asset(
                "assets/images/back_btn.png",
                width: ScreenUtil().setWidth(200),
                height: ScreenUtil().setHeight(150),
              ),
            ),
          ),
          Positioned(
            top: ScreenUtil().setHeight(790),
            left: ScreenUtil().setWidth(100),
            child: Container(
              width: ScreenUtil().setWidth(600),
              height: ScreenUtil().setHeight(160),
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromRGBO(216, 214, 183, 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: Text(
                    '植物介紹',
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(70),
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: ScreenUtil().setHeight(790),
            left: ScreenUtil().setWidth(900),
            child: Container(
              width: ScreenUtil().setWidth(600),
              height: ScreenUtil().setHeight(160),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PlantStructurePage(plantName: widget.plantName,isMy: widget.isMy)),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromRGBO(237, 235, 207, 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: Text(
                    '植物構造',
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(70),
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: ScreenUtil().setHeight(190),
            left: ScreenUtil().setWidth(265),
            child: Container(
              width: ScreenUtil().setWidth(1100),
              height: ScreenUtil().setHeight(450),
              child: _imageUrls.isNotEmpty
                  ? widget.isMy
                  ? CarouselSlider(
                items: _imageUrls.map((url) {
                  return Container(
                    width: ScreenUtil().setWidth(700),
                    height: ScreenUtil().setHeight(450),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: Image.network(
                        url,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                }).toList(),
                carouselController: _controller,
                options: CarouselOptions(
                  //autoPlay: true,
                  enlargeCenterPage: true,
                  aspectRatio: 2.0,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _current = index;
                    });
                  },
                ),
              )
                  : CarouselSlider(
                items: _imageUrls.map((url) {
                  return Container(
                    width: ScreenUtil().setWidth(700),
                    height: ScreenUtil().setHeight(450),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: ImageFiltered(
                        imageFilter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                        child: Image.network(
                          url,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                }).toList(),
                carouselController: _controller,
                options: CarouselOptions(
                  //autoPlay: true,
                  enlargeCenterPage: true,
                  aspectRatio: 2.0,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _current = index;
                    });
                  },
                ),
              )
                  : SizedBox.shrink(),
            ),
          ),
          Positioned(
            top: ScreenUtil().setHeight(650),
            right: ScreenUtil().setWidth(100),
            left: ScreenUtil().setWidth(100),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _imageUrls.asMap().entries.map((entry) {
                return GestureDetector(
                  onTap: () => _controller.animateToPage(entry.key),
                  child: Container(
                    width: ScreenUtil().setWidth(50),
                    height: ScreenUtil().setHeight(50),
                    margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: (_current == entry.key ? Color.fromRGBO(80, 78, 57, 1) : Color.fromRGBO(195, 203, 169, 1)),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Positioned(
            top: ScreenUtil().setHeight(1050),//350,
            left: ScreenUtil().setWidth(50),//10,
            child: Container(
              width: ScreenUtil().setWidth(1600),//200,
              height: ScreenUtil().setHeight(1100),//300,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance.collection('植物資料').doc(widget.plantName).snapshots(),
                      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        }

                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Color.fromRGBO(167, 173, 147, 1)),);
                        }

                        if (!snapshot.hasData) {
                          return Text('No data available');
                        }

                        // 從快照中獲取植物資料
                        final Map<String, dynamic>? data = snapshot.data!.data() as Map<String, dynamic>?;

                        if (data == null) {
                          return Text('No data available');
                        }

                        // 在這裡使用植物資料来構建界面
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              '中文名稱：${data['中文名稱']}\n\n學名：${data['學名']}\n\n地理分布：${data['地理分布']}\n\n植株特徵：${data['植株特徵']}\n\n葉片特徵：${data['葉片特徵']}\n\n花朵特徵：${data['花朵特徵']}\n\n果實特徵：${data['果實特徵']}',
                              style: TextStyle(fontSize: ScreenUtil().setSp(70)),
                              softWrap: true,
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


