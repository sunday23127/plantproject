import 'package:plant_project/menu.dart';
import 'package:plant_project/login.dart';
import 'package:plant_project/plant_collect.dart';
import 'package:plant_project/task_record.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/*個人資訊頁面*/
class PersonalPage extends StatefulWidget {
  const PersonalPage({super.key});

  @override
  _PersonalPageState createState() => _PersonalPageState();
}

class _PersonalPageState extends State<PersonalPage> {
  String studentName=""; //學生名字
  int usePictures = 0; // 使用中的頭貼

  @override
  void initState() {
    super.initState();
    // 在頁面加載時從Firebase獲取學生姓名
    fetchStudentName();
    _fetchUsePictures();
  }

  //取得學生姓名
  void fetchStudentName() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('學生')
          .doc(studentSchool)
          .collection(studentID)
          .doc('個人資料')
          .get();
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      setState(() {
        studentName = data['姓名'];
      });
    } catch (e) {
      print("Error fetching student name: $e");
    }
  }

  // 從Firebase獲取使用中的頭貼
  void _fetchUsePictures() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance.collection('學生')
          .doc(studentSchool)
          .collection(studentID)
          .doc('頭貼')
          .get();
      setState(() {
        usePictures = snapshot['使用頭貼'] ?? 0; // 如果字段不存在，則默認為0
        print(usePictures);
      });
    } catch (e) {
      print("Error fetching use pictures: $e");
    }
  }

  //頁面呈現
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/personal_background.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: <Widget>[
            Positioned(
              top: ScreenUtil().setHeight(380),
              left: ScreenUtil().setWidth(130),
              child: Container(
                width: ScreenUtil().setWidth(1400),
                height: ScreenUtil().setHeight(900),
                decoration: BoxDecoration(
                  color: Color.fromRGBO(211, 216, 190, 1),
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            Positioned(
              top: ScreenUtil().setWidth(680),
              left: ScreenUtil().setHeight(170),
                child: Container(
                  width: ScreenUtil().setWidth(300),
                  height: ScreenUtil().setHeight(200),
                  decoration: BoxDecoration(
                      color: Color.fromRGBO(241, 243, 235, 1),
                      shape: BoxShape.circle
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      _getBadgeImagePath(usePictures),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
            ),
            Positioned(
              top: ScreenUtil().setHeight(650),
              left: ScreenUtil().setWidth(250),
              child: Text(
                studentClass + studentNum + " " + studentName,
              ),
            ),
            Positioned(
              top: ScreenUtil().setHeight(400),
              left: ScreenUtil().setWidth(1250),
              child: GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => MenuPage()),//跳轉至首頁
                  );
                },
                child: Image.asset(
                  "assets/images/personal_back.png",
                  width: ScreenUtil().setWidth(200),
                  height: ScreenUtil().setHeight(150),
                ),
              ),
            ),
            Positioned(
              top: ScreenUtil().setHeight(800),
              left: ScreenUtil().setWidth(235),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PlantCollectPage()),//跳轉植物蒐藏家頁面
                  );
                },
                child: Container(
                  width: ScreenUtil().setWidth(1200),
                  height: ScreenUtil().setHeight(150),
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(229, 231, 212, 1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                    child: Center(
                      child: Text(
                        '植 物 蒐 藏 家',
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(80),
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: ScreenUtil().setHeight(820),
              left: ScreenUtil().setWidth(300),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PlantCollectPage()),//跳轉植物蒐藏家頁面
                  );
                },
                child: Image.asset(
                  "assets/images/collect.png",
                  width: ScreenUtil().setWidth(150),
                  height: ScreenUtil().setHeight(100),
                ),
              ),
            ),
            Positioned(
              top: ScreenUtil().setHeight(835),
              left: ScreenUtil().setWidth(1250),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PlantCollectPage()),//跳轉植物蒐藏家頁面
                  );
                },
                child: Image.asset(
                  "assets/images/arrowright.png",
                  width: ScreenUtil().setWidth(130),
                  height: ScreenUtil().setHeight(80),
                ),
              ),
            ),
            Positioned(
              top: ScreenUtil().setHeight(1050),
              left: ScreenUtil().setWidth(235),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TaskRecordPage()),//跳轉任務紀錄頁面
                  );
                },
                child: Container(
                  width: ScreenUtil().setWidth(1200),
                  height: ScreenUtil().setHeight(150),
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(229, 231, 212, 1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 30, 0),
                    child: Center(
                      child: Text(
                        '任 務 紀 錄',
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(80),
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            Positioned(
              top: ScreenUtil().setHeight(1070),
              left: ScreenUtil().setWidth(300),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TaskRecordPage()),//跳轉任務紀錄頁面
                  );
                },
                child: Image.asset(
                  "assets/images/setting.png",
                  width: ScreenUtil().setWidth(150),
                  height: ScreenUtil().setHeight(100),
                ),
              ),
            ),
            Positioned(
              top: ScreenUtil().setHeight(1085),
              left: ScreenUtil().setWidth(1250),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TaskRecordPage()),//跳轉任務紀錄頁面
                  );
                },
                child: Image.asset(
                  "assets/images/arrowright.png",
                  width: ScreenUtil().setWidth(130),
                  height: ScreenUtil().setHeight(80),
                ),
              ),
            ),
            Positioned(
              top: ScreenUtil().setHeight(1350),
              left: ScreenUtil().setWidth(570),
              right: ScreenUtil().setWidth(570),
              child: ElevatedButton(
                onPressed: () {
                  studentClass = "";
                  studentNum = "";
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),//跳轉登入頁面
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromRGBO(167, 173, 147, 1),
                  shadowColor: Color.fromRGBO(167, 173, 147, 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '登 出',
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(70),
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: ScreenUtil().setHeight(1380),
              left: ScreenUtil().setWidth(600),
              child: GestureDetector(
                onTap: () {

                },
                child: Image.asset(
                  "assets/images/logout.png",
                  width: ScreenUtil().setWidth(130),
                  height: ScreenUtil().setHeight(80),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// 根據 index 獲取相應的圖片路徑
String _getBadgeImagePath(int index) {
  switch (index) {
    case 0:
      return 'assets/images/picture1.png';
    case 1:
      return 'assets/images/picture2.png';
    case 2:
      return 'assets/images/picture3.png';
    case 3:
      return 'assets/images/picture4.png';
    case 4:
      return 'assets/images/picture5.png';
    case 5:
      return 'assets/images/picture6.png';
    case 6:
      return 'assets/images/picture7.png';
    case 7:
      return 'assets/images/picture8.png';
    case 8:
      return 'assets/images/picture9.png';
    case 9:
      return 'assets/images/picture10.png';
    case 10:
      return 'assets/images/picture11.png';
    case 11:
      return 'assets/images/picture12.png';
    case 12:
      return 'assets/images/picture13.png';
    case 13:
      return 'assets/images/picture14.png';
    case 14:
      return 'assets/images/picture15.png';
    case 15:
      return 'assets/images/picture16.png';
    case 16:
      return 'assets/images/picture17.png';
    case 17:
      return 'assets/images/picture18.png';
    case 18:
      return 'assets/images/picture19.png';
    case 19:
      return 'assets/images/picture20.png';
    default:
      return '';
  }
}
