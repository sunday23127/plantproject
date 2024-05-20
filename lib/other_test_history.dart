import 'package:plant_project/login.dart';
import 'package:plant_project/other_test_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:plant_project/other_test_history_inside.dart';

/*測驗歷史主頁面*/
class TestHistoryPage extends StatelessWidget {
  const TestHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/write_test.png"), //背景
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
                    MaterialPageRoute(
                        builder: (context) => TestMenuPage()), //返回課堂評量選單頁面
                  );
                },
                child: Image.asset(
                  "assets/images/back_btn.png", //返回按鈕
                  width: ScreenUtil().setWidth(200),
                  height: ScreenUtil().setHeight(150),
                ),
              ),
            ),
            Positioned(
              top: ScreenUtil().setHeight(120),
              left: ScreenUtil().setWidth(600),
              child: Text(
                '測驗歷史',
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(110),
                  color: Colors.black,
                ),
              ),
            ),
            Positioned(
              top: ScreenUtil().setHeight(350),
              left: ScreenUtil().setWidth(130),
              child: Text(
                '編號',
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(70),
                  color: Colors.black,
                ),
              ),
            ),
            Positioned(
              top: ScreenUtil().setHeight(350),
              left: ScreenUtil().setWidth(430),
              child: Text(
                '測驗名稱',
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(70),
                  color: Colors.black,
                ),
              ),
            ),
            Positioned(
              top: ScreenUtil().setHeight(350),
              left: ScreenUtil().setWidth(920),
              child: Text(
                '答對題數',
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(70),
                  color: Colors.black,
                ),
              ),
            ),
            Positioned(
              top: ScreenUtil().setHeight(350),
              left: ScreenUtil().setWidth(1310),
              child: Text(
                '得分',
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(70),
                  color: Colors.black,
                ),
              ),
            ),
            Positioned(
              top: ScreenUtil().setHeight(420),
              left: 0,
              right: 0,
              bottom: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 10),
                child: TestHistoryList(), //呼叫測驗歷史列表
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//顯示測驗歷史
class TestHistoryList extends StatelessWidget {
  const TestHistoryList({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<QuerySnapshot>>(
      future: _getCollections(),
      builder: (BuildContext context, AsyncSnapshot<List<QuerySnapshot>> snapshot) {
        var num = 0;
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Color.fromRGBO(167, 173, 147, 1)),),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        final List<QuerySnapshot>? collections = snapshot.data;

        if (collections == null || collections.isEmpty) {
          return Center(
            child: Text('目前沒有測驗歷史'),
          );

        }
        return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: collections.length,
          itemBuilder: (context, index) {
            final QuerySnapshot querySnapshot = collections[index];

            if (querySnapshot.docs.isEmpty) {
              return Container();
            }

            return Column(
              children: querySnapshot.docs.map((DocumentSnapshot document) {
                var name = document['評量名稱'];
                var questionNum = document['題數'];
                var answerNum = document['答對題數'];
                var score = document['成績'];
                var serialNum = ++num;
                var formattedScore = score == 0 ? '0' : score.truncateToDouble() == score ? score.toInt().toString() : score.toStringAsFixed(1);

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => TestHistoryInsidePage(testName: name)),
                    );
                  },
                  child: Container(
                    width: 1000,
                    margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                    padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 0.0),
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(211, 216, 190, 1),
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            SizedBox(width: ScreenUtil().setWidth(110)),
                            Text(
                              '$serialNum',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: ScreenUtil().setSp(70),
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(width: ScreenUtil().setWidth(150)),
                            Text(
                              '$name',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: ScreenUtil().setSp(70),
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(width: ScreenUtil().setWidth(180)),
                            Text(
                              '$answerNum/$questionNum',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: ScreenUtil().setSp(70),
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(width: ScreenUtil().setWidth(220)),
                            Text(
                              '$formattedScore',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: ScreenUtil().setSp(70),
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
        );
      },
    );
  }

  // 從firebase取得資料
  Future<List<QuerySnapshot>> _getCollections() async {
    List<QuerySnapshot> collections = [];
    DateTime now = DateTime.now();
    int currentYear = now.year - 1911;

    for (int i = currentYear-4; i <= currentYear+4; i++) {
      for (String suffix in ['上', '下']) {
        String collectionName = '$i$suffix';

        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('學生')
            .doc(studentSchool)
            .collection(studentID)
            .doc('測驗歷史')
            .collection(collectionName)
            .get();

        collections.add(snapshot);
      }
    }
    return collections;
  }
}