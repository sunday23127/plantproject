import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:plant_project/login.dart';
import 'package:plant_project/personal_information.dart';

/*任務紀錄頁面*/
class TaskRecordPage extends StatefulWidget {
  const TaskRecordPage({super.key});

  @override
  _TaskRecordPageState createState() => _TaskRecordPageState();
}

class _TaskRecordPageState extends State<TaskRecordPage> {
  int completeTask = 0;
  int allTask = 0;
  int ListIndex = 0;

  @override
  void initState() {
    super.initState();
    _updateTaskCounts();
  }
  @override
  void dispose() {
    super.dispose();
  }

  //頁面呈現
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('學生')
            .doc(studentSchool)
            .collection(studentID)
            .doc('任務')
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Color.fromRGBO(167, 173, 147, 1)),));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // 獲取 '任務' 文檔的資料
          final taskData = snapshot.data!.data() as Map<String, dynamic>?;

          if (taskData == null || taskData.isEmpty) {
            // '任務' 文檔不存在或者没有資料
            return Container(
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
                              builder: (context) =>
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
                    top: ScreenUtil().setHeight(140),
                    left: ScreenUtil().setWidth(750),
                    child: Text(
                      '任務',
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(100),
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Positioned(
                    top: ScreenUtil().setHeight(400),
                    left: ScreenUtil().setWidth(150),
                    child: Container(
                      width: ScreenUtil().setWidth(600),
                      height: ScreenUtil().setHeight(120),
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(232, 233, 220, 1),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                  Positioned(
                    top: ScreenUtil().setHeight(434),
                    left: ScreenUtil().setWidth(180),
                    child: Text(
                      '完成任務',
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(60),
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Positioned(
                    top: ScreenUtil().setHeight(420),
                    left: ScreenUtil().setWidth(470),
                    child: Container(
                      width: ScreenUtil().setWidth(250),
                      height: ScreenUtil().setHeight(80),
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(244, 245, 241, 1),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Center(
                        child: Text(
                          '$completeTask/$allTask',
                          style: TextStyle(
                            fontSize: ScreenUtil().setSp(60),
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: ScreenUtil().setHeight(400),
                    left: ScreenUtil().setWidth(900),
                    child: Container(
                      width: ScreenUtil().setWidth(600),
                      height: ScreenUtil().setHeight(120),
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(232, 233, 220, 1),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                  Positioned(
                    top: ScreenUtil().setHeight(434),
                    left: ScreenUtil().setWidth(980),
                    child: Text(
                      '總積分',
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(60),
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Positioned(
                    top: ScreenUtil().setHeight(420),
                    left: ScreenUtil().setWidth(1200),
                    child: Container(
                      width: ScreenUtil().setWidth(250),
                      height: ScreenUtil().setHeight(80),
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(244, 245, 241, 1),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Center(
                        child: Text(
                          '0',
                          style: TextStyle(
                            fontSize: ScreenUtil().setSp(60),
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );

          }
          // 從 '任務' 文檔中獲取集合的 ID 列表
          final taskList = taskData['任務列表'];
          print(taskList);



          return FutureBuilder<int>(
            future: _getAllScore(),
            builder: (context, scoreSnapshot) {
              if (scoreSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Color.fromRGBO(167, 173, 147, 1)),));
              }
              if (scoreSnapshot.hasError) {
                return Center(child: Text('Error: ${scoreSnapshot.error}'));
              }

              final allScore = scoreSnapshot.data ?? 0;

              return Container(
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
                                builder: (context) =>
                                    PersonalPage()),
                          );
                        },
                        child: Image.asset(
                          "assets/images/back_btn.png",
                          width: ScreenUtil().setWidth(200), //50,
                          height: ScreenUtil().setHeight(150), //50,
                        ),
                      ),
                    ),
                    Positioned(
                      top: ScreenUtil().setHeight(140),
                      left: ScreenUtil().setWidth(750),
                      child: Text(
                        '任務',
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(100),
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Positioned(
                      top: ScreenUtil().setHeight(400), //130,
                      left: ScreenUtil().setWidth(150), //30,
                      child: Container(
                        width: ScreenUtil().setWidth(600), //350,
                        height: ScreenUtil().setHeight(120), //110,
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(232, 233, 220, 1),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                    Positioned(
                      top: ScreenUtil().setHeight(434), //130,
                      left: ScreenUtil().setWidth(180), //30,
                      child: Text(
                        '完成任務',
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(60),
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Positioned(
                      top: ScreenUtil().setHeight(420),
                      left: ScreenUtil().setWidth(470),
                      child: Container(
                        width: ScreenUtil().setWidth(250),
                        height: ScreenUtil().setHeight(80),
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(244, 245, 241, 1),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Center(
                          child: Text(
                            '$completeTask/$allTask',
                            style: TextStyle(
                              fontSize: ScreenUtil().setSp(60),
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: ScreenUtil().setHeight(400),
                      left: ScreenUtil().setWidth(900),
                      child: Container(
                        width: ScreenUtil().setWidth(600),
                        height: ScreenUtil().setHeight(120),
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(232, 233, 220, 1),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                    Positioned(
                      top: ScreenUtil().setHeight(434),
                      left: ScreenUtil().setWidth(980),
                      child: Text(
                        '總積分',
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(60),
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Positioned(
                      top: ScreenUtil().setHeight(420),
                      left: ScreenUtil().setWidth(1200),
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
                      top: ScreenUtil().setHeight(620),
                      left: ScreenUtil().setWidth(450),
                      child: Text(
                        '任務',
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(65),
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Positioned(
                      top: ScreenUtil().setHeight(620),
                      left: ScreenUtil().setWidth(950),
                      child: Text(
                        '積分',
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(65),
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Positioned(
                      top: ScreenUtil().setHeight(620),
                      left: ScreenUtil().setWidth(1250),
                      child: Text(
                        '完成狀況',
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(65),
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Positioned(
                      top: ScreenUtil().setHeight(680),
                      left: ScreenUtil().setWidth(80),
                      right: ScreenUtil().setWidth(80),
                      child: Container(
                        height: ScreenUtil().setHeight(1000),
                        child: ListView.builder(
                            itemCount: taskList.length,
                            itemBuilder: (context, index) {

                              return FutureBuilder<QuerySnapshot>(
                                future: FirebaseFirestore.instance
                                    .collection('學生')
                                    .doc(studentSchool)
                                    .collection(studentID)
                                    .doc('任務')
                                    .collection(taskList[index]) // 獲取特定集合
                                    .get(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Center(
                                        child: CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Color.fromRGBO(167, 173, 147, 1)),));
                                  }
                                  if (snapshot.hasError) {
                                    return Center(
                                        child:
                                            Text('Error: ${snapshot.error}'));
                                  }

                                  final documents = snapshot.data!.docs; // 獲取文檔列表
                                  return ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: documents.length,
                                    itemBuilder: (context, docIndex) {
                                      final docData = documents[docIndex].data()
                                          as Map<String, dynamic>;
                                      // 根據你的需求，顯示文檔的内容
                                      // 例如：顯示文檔中的某些字段
                                      final String title = docData['內容'];
                                      final String score = docData['積分'];
                                      final bool completed = docData['完成'];


                                      return Container(
                                        decoration: BoxDecoration(
                                          color: (ListIndex) % 2 != 0
                                              ? Color.fromRGBO(211, 216, 190, 1)
                                              : Color.fromRGBO(
                                                  239, 237, 215, 1),
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        child: ListTile(
                                        title:  Row(
                                          children: <Widget>[
                                            SizedBox(width: ScreenUtil().setWidth(40)),
                                            Text(
                                              '${++ListIndex}',
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                fontSize: ScreenUtil().setSp(70),
                                                color: Colors.black,
                                              ),
                                            ),
                                            SizedBox(width: ScreenUtil().setWidth(100)),
                                            Flexible(
                                              flex: 1,
                                              child: Text(
                                                title,
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                  fontSize: ScreenUtil().setSp(70),
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: ScreenUtil().setWidth(160)),
                                            Text(
                                              score.toString(),
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                fontSize: ScreenUtil().setSp(70),
                                                color: Colors.black,
                                              ),
                                            ),
                                            SizedBox(width: ScreenUtil().setWidth(200)),
                                          ],
                                        ),
                                        trailing: Icon(
                                        completed
                                        ? Icons.check
                                            : Icons.close,
                                        color: completed
                                        ? Color.fromRGBO(
                                        108, 118, 72, 1)
                                            : Color.fromRGBO(
                                        148, 13, 13, 1),
                                        ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              );
                            }),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // 從firebase取得總積分
  Future<int> _getAllScore() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('學生')
        .doc(studentSchool)
        .collection(studentID)
        .doc('任務')
        .get();

    final Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    final int allScore = data['總積分'] as int;

    return allScore;
  }


  //更新任務完成數量
  void _updateTaskCounts() async {
    // Retrieve the task data from Firestore
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('學生')
        .doc(studentSchool)
        .collection(studentID)
        .doc('任務')
        .get();

    final taskData = snapshot.data() as Map<String, dynamic>?;

    if (taskData != null && taskData.isNotEmpty) {
      final taskList = taskData['任務列表'];
        for (String task in taskList) {
          QuerySnapshot taskSnapshot = await FirebaseFirestore.instance
              .collection('學生')
              .doc(studentSchool)
              .collection(studentID)
              .doc('任務')
              .collection(task)
              .get();
          allTask += taskSnapshot.docs.length;
          taskSnapshot.docs.forEach((doc) {
            if (doc['完成']) {
              setState(() {
                completeTask++;
              });
            }
          });
          setState(() {
            allTask;
          });
        }
    }
  }
}
