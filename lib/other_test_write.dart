import 'package:plant_project/login.dart';
import 'package:plant_project/other_test_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:plant_project/other_test_write_inside.dart';

/*作答測驗頁面*/
class WriteTestPage extends StatelessWidget {
  const WriteTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/write_test.png"),
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
                    MaterialPageRoute(
                        builder: (context) => TestMenuPage()),
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
              top: ScreenUtil().setHeight(120),
              left: ScreenUtil().setWidth(600),
                child: Text(
                  '作答測驗',
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(110),
                    color: Colors.black,
                  ),
                ),
              ),
            Positioned(
              top: ScreenUtil().setHeight(350),
              left: ScreenUtil().setWidth(150),
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
              left: ScreenUtil().setWidth(530),
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
              left: ScreenUtil().setWidth(1030),
              child: Text(
                '題數',
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
                '總分',
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
                child: TestList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TestList extends StatefulWidget {
  const TestList({super.key});
  @override
  _TestListState createState() => _TestListState();
}

class _TestListState extends State<TestList> {
  late List<bool> isTestCompletedList;
  String teacherName="周老師";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    isTestCompletedList = [];
    main();
  }

  void main() async{
    teacherName = await _fetchTeacher();
    print(teacherName);
    await _checkTestCompletion();
    setState(() {
      isLoading = false;
    });
  }

  Future<String> _fetchTeacher() async {
    final querySnapshot = await FirebaseFirestore.instance.collection('學校').doc(studentSchool).collection('班級').doc(studentClass).get();
    final data = querySnapshot.data();
    if (data != null) { // 對 data 進行 null 檢查
      final teacher = data['教師'];
      return teacher;
    } else {
      return ''; // 或者返回其他預設值
    }
  }

  Future<void> _checkTestCompletion() async {
    final querySnapshot = await FirebaseFirestore.instance.collection('學校').doc(studentSchool).collection('教師').doc(teacherName).collection('評量').get();
    for (final doc in querySnapshot.docs) {
      final name = doc['評量名稱'];
      final isTestCompleted = await _isTestCompleted(name);
      setState(() {
        isTestCompletedList.add(isTestCompleted);
      });
    }
  }

  Future<bool> _isTestCompleted(String testName) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('學生')
        .doc(studentSchool)
        .collection(studentID)
        .doc('測驗歷史')
        .collection(testName.substring(0, 4))
        .doc(testName)
        .get();
    return snapshot.exists;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: new AlwaysStoppedAnimation<Color>(
              Color.fromRGBO(167, 173, 147, 1)),
        ),
      );
    } else {
      return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('學校')
            .doc(studentSchool)
            .collection('教師')
            .doc(teacherName)
            .collection('評量')
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting ||
              !snapshot.hasData) {
            return CircularProgressIndicator(
              valueColor: new AlwaysStoppedAnimation<Color>(
                  Color.fromRGBO(167, 173, 147, 1)),
            );
          }

          final querySnapshot = snapshot.requireData;
          final documents = querySnapshot.docs;

          return ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: documents.length,
            itemBuilder: (context, index) {
              final name = documents[index]['評量名稱'];
              final questionNum = documents[index]['題目'].length;
              final serialNum = index + 1;
              final isTestCompleted = isTestCompletedList.isNotEmpty &&
                  index < isTestCompletedList.length &&
                  isTestCompletedList[index];

              return GestureDetector(
                onTap: () {
                  if (!isTestCompleted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) =>
                          WriteTestInsidePage(testName: name, testNum: questionNum,
                              num: serialNum, teacherName: teacherName,
                              )), //跳轉作答題目頁面
                    );
                  }
                },
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                  padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 0.0),
                  decoration: BoxDecoration(
                    color: isTestCompleted ? Color.fromRGBO(154, 161, 127, 1) :
                    Color.fromRGBO(211, 216, 190, 1), // 根據測試完成情況設置顏色
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          SizedBox(width: ScreenUtil().setWidth(120)),
                          Text(
                            '$serialNum',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: ScreenUtil().setSp(70),
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(width: ScreenUtil().setWidth(200)),
                          Text(
                            '$name',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: ScreenUtil().setSp(70),
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(width: ScreenUtil().setWidth(200)),
                          Text(
                            '$questionNum',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: ScreenUtil().setSp(70),
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(width: ScreenUtil().setWidth(200)),
                          Text(
                            '100',
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
            },
          );
        },
      );
    }
  }
}



