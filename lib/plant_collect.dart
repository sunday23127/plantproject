import 'package:plant_project/login.dart';
import 'package:plant_project/personal_information.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/*植物蒐藏家*/
class PlantCollectPage extends StatefulWidget {
  const PlantCollectPage({super.key});

  @override
  _PlantCollectPageState createState() => _PlantCollectPageState();
}

class _PlantCollectPageState extends State<PlantCollectPage> {
  int collectedPictures = 1; // 已收集的頭貼數量
  int allScore = 0; //總積分
  int usePictures = 0; // 使用中的頭貼
  Map<int, bool> badgeExchangeStatus = {};

  @override
  void initState() {
    super.initState();
    // 從Firebase獲取已收集的植物數量
    _fetchCollectedPictures();
    // 從Firebase獲取總共需要收集的植物數量
    _fetchAllScore();
    _fetchUsePictures();
    for (int i = 0; i < 20; i++) {
      badgeExchangeStatus[i] = false; // 初始狀態設為未兌換
    }
  }

  // 從Firebase獲取已收集的頭貼數量
  void _fetchCollectedPictures() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('學生')
          .doc(studentSchool)
          .collection(studentID)
          .doc('頭貼')
          .get();
      setState(() {
        collectedPictures = snapshot['頭貼數量'] ?? 0; // 如果字段不存在，則默認為0
        print(collectedPictures);
      });
    } catch (e) {
      print("Error fetching collected pictures: $e");
    }
  }

  // 從Firebase獲取使用中的頭貼
  void _fetchUsePictures() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('學生')
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

  // 從Firebase獲取總積分
  void _fetchAllScore() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('學生')
          .doc(studentSchool)
          .collection(studentID)
          .doc('任務')
          .get();

      final Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

      setState(() {
        allScore = data['總積分'];
        print(allScore);
      });
    } catch (e) {
      print("Error fetching student name: $e");
    }
  }

  // 從Firebase獲取已收集的頭貼
  void _fetchExchangeStatus(int index) async {
    try {
      // 查詢頭貼兌換狀態
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('學生')
          .doc(studentSchool)
          .collection(studentID)
          .doc('頭貼')
          .get();

      // 检查頭貼是否已兌換
      List<dynamic> headshotList = snapshot.exists ? snapshot['頭貼列表'] : [];

      if (index < headshotList.length) {
        setState(() {
          // 更新頭貼的兌換狀態
          badgeExchangeStatus[index] = headshotList[index];
        });
      } else {
        print("Error: Badge index out of range");
      }
    } catch (e) {
      print("Error fetching exchange status for badge $index: $e");
    }
  }

  //變更頭貼
  void _changeBadge(int index) async {
    _showchangeDialog(index);
  }

  //兌換頭貼
  void _exchangeBadge(int index) {
    _showexchangeDialog(index);
  }

  // 更新總積分
  void _upadateScore() async {
    try {
      await FirebaseFirestore.instance
          .collection('學生')
          .doc(studentSchool)
          .collection(studentID)
          .doc('任務')
          .update({
        '積分': allScore,
      });
    } catch (e) {
      print("Error changing badge: $e");
    }
  }

  //變更頭貼確認
  void _showchangeDialog(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: Color.fromRGBO(210, 215, 185, 1),
            ),
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  '是否將頭貼變更為所選照片？',
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(70),
                  ),
                ),
                SizedBox(height: ScreenUtil().setHeight(60)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: Color.fromRGBO(229, 232, 216, 1),
                        foregroundColor: Color.fromRGBO(246, 247, 242, 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        '取消',
                        style: TextStyle(
                            color: Colors.black
                        ),
                      ),
                    ),
                    SizedBox(width: ScreenUtil().setWidth(200)),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: Color.fromRGBO(229, 232, 216, 1),
                        foregroundColor: Color.fromRGBO(246, 247, 242, 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () async {
                        usePictures = index;
                        // 更新Firebase中的相應數據，將該頭貼設置為當前使用的頭貼
                        try {
                          await FirebaseFirestore.instance
                              .collection('學生')
                              .doc(studentSchool)
                              .collection(studentID)
                              .doc('頭貼')
                              .update({
                            '使用頭貼': index, // 更新當前使用的頭貼索引
                          });
                        } catch (e) {
                          print("Error changing badge: $e");
                        }
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        '確認',
                        style: TextStyle(
                            color: Colors.black
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  //兌換頭貼確認
  void _showexchangeDialog(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Color.fromRGBO(210, 215, 185, 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Container(
            height: ScreenUtil().setHeight(380),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
            ),
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  '是否扣除30積分兌換該頭貼？',
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(70),
                  ),
                ),
                SizedBox(height: ScreenUtil().setHeight(60)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: Color.fromRGBO(230, 233, 218, 1),
                        foregroundColor: Color.fromRGBO(230, 233, 218, 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        '取消',
                        style: TextStyle(
                            color: Colors.black
                        ),
                      ),
                    ),
                    SizedBox(width: ScreenUtil().setWidth(200)),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: Color.fromRGBO(230, 233, 218, 1),
                        foregroundColor: Color.fromRGBO(230, 233, 218, 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () async {
                          if(allScore >= 30){
                            allScore = allScore - 30;
                            collectedPictures = collectedPictures + 1;
                            _upadateScore();
                            // 先讀取當前的頭貼列表
                            final docSnapshot = await FirebaseFirestore.instance
                                .collection('學生')
                                .doc(studentSchool)
                                .collection(studentID)
                                .doc('頭貼')
                                .get();

                            if (docSnapshot.exists) {
                              // 取得當前的頭貼列表
                              List<dynamic>? PictureList = docSnapshot.data()?['頭貼列表'];

                              if (PictureList != null) {
                                // 更新指定 index 的值
                                PictureList[index] = true;

                                // 將更新後的列表寫回 Firebase
                                await FirebaseFirestore.instance
                                    .collection('學生')
                                    .doc(studentSchool)
                                    .collection(studentID)
                                    .doc('頭貼')
                                    .update({'頭貼列表': PictureList});

                                await FirebaseFirestore.instance
                                    .collection('學生')
                                    .doc(studentSchool)
                                    .collection(studentID)
                                    .doc('頭貼')
                                    .update({'頭貼數量': collectedPictures});
                              }
                            }
                            Navigator.of(context).pop();
                          }
                          else{
                            Navigator.of(context).pop();
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  backgroundColor: Color.fromRGBO(210, 215, 185, 1),
                                  content: Text(
                                    '積 分 不 足',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: ScreenUtil().setSp(70)),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  actions: <Widget>[
                                    ButtonBar(
                                      alignment: MainAxisAlignment.center,
                                      children: [
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            elevation: 0,
                                            backgroundColor: Color.fromRGBO(229, 232, 216, 1),
                                            foregroundColor: Color.fromRGBO(229, 232, 216, 1),
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
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                      },
                      child: Text(
                        '確認',
                        style: TextStyle(
                            color: Colors.black
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  //頁面呈現
  @override
  Widget build(BuildContext context) {
    // 計算進度條的進度
    double progress = collectedPictures / 20;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/other_background.png"),
            fit: BoxFit.fill,
          ),
        ),
        child: Stack(
          children: <Widget>[
            Positioned(
              top: ScreenUtil().setHeight(100),
              left: ScreenUtil().setWidth(80),
              child: GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) =>
                        PersonalPage()),//跳轉至個人資訊頁面
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
              top: ScreenUtil().setHeight(160),
              left: ScreenUtil().setWidth(1000),
              child: Text(
                '目前積分',
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(60),
                  color: Colors.black,
                ),
              ),
            ),
            Positioned(
              top: ScreenUtil().setHeight(145),
              left: ScreenUtil().setWidth(1300),
              child: Container(
                width: ScreenUtil().setWidth(250),
                height: ScreenUtil().setHeight(80),
                decoration: BoxDecoration(
                  color: Color.fromRGBO(244, 245, 241, 1),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Center(
                  child: Text(
                    '$allScore',
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(60),
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: ScreenUtil().setHeight(360),
              left: ScreenUtil().setWidth(100),
              child: Text(
                '蒐集頭貼數',
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(60),
                  color: Colors.black,
                ),
              ),
            ),
            // 添加線性進度條
            Positioned(
              top: ScreenUtil().setHeight(380),
              left: ScreenUtil().setWidth(450),
              child: Container(
                width: ScreenUtil().setWidth(950), // 控制進度條的寬度
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Color.fromRGBO(178, 175, 173, 1),
                    valueColor: AlwaysStoppedAnimation<Color>(
                        Color.fromRGBO(108, 118, 73, 1)),
                  ),
                ),
              ),
            ),
            Positioned(
              top: ScreenUtil().setHeight(360),
              left: ScreenUtil().setWidth(1450),
              child: Text(
                '$collectedPictures/20',
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(60),
                  color: Colors.black,
                ),
              ),
            ),
            // 添加GridView
            Positioned(
              top: ScreenUtil().setHeight(400),
              left: ScreenUtil().setWidth(20),
              right: ScreenUtil().setWidth(20),
              bottom: 0,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  GridView.count(
                    crossAxisCount: 3,
                    children: List.generate(
                      20,
                          (index) {
                        _fetchExchangeStatus(index);
                        String buttonText = index == usePictures ? '使用中' : (badgeExchangeStatus[index] ?? false) ? '變更' : '兌換';

                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              margin: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Color.fromRGBO(239, 237, 215, 1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  (badgeExchangeStatus[index] == false) ?
                                   Image.asset(
                                      _getBadgeGrayImagePath(index),
                                      width: ScreenUtil().setWidth(450),
                                      height: ScreenUtil().setHeight(250),
                                    )
                                  :
                                  Image.asset(
                                    _getBadgeImagePath(index),
                                    fit: BoxFit.contain,
                                    width: ScreenUtil().setWidth(450),
                                    height: ScreenUtil().setHeight(250),
                                  ),
                                  SizedBox(height: 0),
                                ],
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              child: Container(
                                width: ScreenUtil().setWidth(450), // 調整按鈕寬度
                                height: ScreenUtil().setHeight(80), // 調整按鈕高度
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: index == usePictures ? Color.fromRGBO(188, 187, 179, 1) : buttonText == '變更'?Color.fromRGBO(190, 142, 116, 1):Color.fromRGBO(153, 160, 123, 1),
                                    shadowColor: index == usePictures ? Color.fromRGBO(188, 187, 179, 1) : buttonText == '變更'?Color.fromRGBO(190, 142, 116, 1):Color.fromRGBO(153, 160, 123, 1),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  onPressed: () {
                                    if (buttonText == '變更') {
                                      _changeBadge(index);
                                    } else if (buttonText == '兌換') {
                                      _exchangeBadge(index);
                                    }
                                  },
                                  child: Text(
                                    buttonText,
                                    style: TextStyle(
                                      fontSize: ScreenUtil().setSp(60),
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
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

// 根據 index 獲取相應的圖片(未兌換)路徑
String _getBadgeGrayImagePath(int index) {
  switch (index) {
    case 0:
      return 'assets/images/picture1_gray.png';
    case 1:
      return 'assets/images/picture2_gray.png';
    case 2:
      return 'assets/images/picture3_gray.png';
    case 3:
      return 'assets/images/picture4_gray.png';
    case 4:
      return 'assets/images/picture5_gray.png';
    case 5:
      return 'assets/images/picture6_gray.png';
    case 6:
      return 'assets/images/picture7_gray.png';
    case 7:
      return 'assets/images/picture8_gray.png';
    case 8:
      return 'assets/images/picture9_gray.png';
    case 9:
      return 'assets/images/picture10_gray.png';
    case 10:
      return 'assets/images/picture11_gray.png';
    case 11:
      return 'assets/images/picture12_gray.png';
    case 12:
      return 'assets/images/picture13_gray.png';
    case 13:
      return 'assets/images/picture14_gray.png';
    case 14:
      return 'assets/images/picture15_gray.png';
    case 15:
      return 'assets/images/picture16_gray.png';
    case 16:
      return 'assets/images/picture17_gray.png';
    case 17:
      return 'assets/images/picture18_gray.png';
    case 18:
      return 'assets/images/picture19_gray.png';
    case 19:
      return 'assets/images/picture20_gray.png';
    default:
      return '';
  }
}