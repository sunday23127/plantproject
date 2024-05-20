import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:plant_project/login.dart';
import 'package:plant_project/other_test_write.dart';
import 'package:plant_project/other_test_write_inside.dart';

/*顯示測驗分數頁面*/
class TestScorePage extends StatelessWidget {
  final String testName;
  final int correctAnswers;
  final int totalQuestions;
  final List<TestQuestion> questions;

  //接收傳遞的參數
  TestScorePage({
    required this.testName,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.questions,
  });

  @override
  Widget build(BuildContext context) {
    // 計算分數
    double score = (correctAnswers / totalQuestions) * 100;
    
    TestService testService = TestService();
    
    testService.saveTestResult(
      testName: testName,
      correctAnswers: correctAnswers,
      totalQuestions: totalQuestions,
      score: score,
      questions: questions,
    );

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
                        builder: (context) => WriteTestPage()),//跳轉至作答測驗頁面
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
              left: ScreenUtil().setWidth(500),
              child: Text(
                testName,
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
                '答對題數',
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
              ),
            ),
            Positioned(
              top: ScreenUtil().setHeight(434),
              left: ScreenUtil().setWidth(550),
              child: Center(
                child: Text(
                  '$correctAnswers/$totalQuestions',
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(60),
                    color: Colors.black,
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
                '得分',
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
              ),
            ),
            Positioned(
              top: ScreenUtil().setHeight(434),
              left: ScreenUtil().setWidth(1300),
              child: Center(
                child: Text(
                  '${score.truncateToDouble() == score ? score.toInt().toString() : score.toStringAsFixed(1)}',
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(60),
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            Positioned(
              top: ScreenUtil().setHeight(620),
              left: ScreenUtil().setWidth(1250),
              child: Text(
                '作答結果',
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(65),
                  color: Colors.black,
                ),
              ),
            ),
            Positioned(
              top: ScreenUtil().setHeight(700),
              left: ScreenUtil().setWidth(80),
              right: ScreenUtil().setWidth(80),
              child: Container(
                height: ScreenUtil().setHeight(900), 
                child: ListView.builder(
                  itemCount: questions.length,
                  itemBuilder: (context, index) {
                    bool isCorrect = questions[index].selectedOption == questions[index].answer;
                    
                    return Container(
                      decoration: BoxDecoration(
                        color: (index + 1)%2!=0 ? Color.fromRGBO(211, 216, 190, 1) : Color.fromRGBO(239, 237, 215, 1),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: ListTile(
                        title: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              '${index + 1}',
                              style: TextStyle(
                                fontSize: ScreenUtil().setSp(80),
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: ScreenUtil().setWidth(10)),
                            Expanded( // Wrap the text part in Expanded
                              child: Text(
                                questions[index].question,
                                style: TextStyle(
                                  fontSize: ScreenUtil().setSp(60),
                                  color: Colors.black,
                                ),
                                maxLines: null, // Allow multiple lines
                                overflow: TextOverflow.visible, // Allow text overflow
                                softWrap: true, // Enable soft wrapping
                              ),
                            ),
                          ],
                        ),
                        trailing: Icon(
                          isCorrect ? Icons.check : Icons.close,
                          color: isCorrect ? Color.fromRGBO(108, 118, 72, 1) : Color.fromRGBO(148, 13, 13, 1),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TestService {
  final CollectionReference studentCollection =
  FirebaseFirestore.instance.collection('學生');

  Future<void> saveTestResult({
    //required String studentId,
    required String testName,
    required int correctAnswers,
    required int totalQuestions,
    required double score,
    required List<TestQuestion> questions,
  }) async {
    // 將問題資料轉換為適合儲存在Firestore中的格式
    List<Map<String, dynamic>> questionsData = questions
        .map((question) => {
      '題目內容': question.question,
      '選項1': question.option1,
      '選項2': question.option2,
      '選項3': question.option3,
      '選擇的答案': question.selectedOption,
      '正確答案': question.answer,
    })
        .toList();

    // 儲存測試结果到Firestore中的學生文檔的"測驗歷史"子集合中
    await studentCollection
        .doc(studentSchool)
        .collection(studentID)
        .doc('測驗歷史')
        .collection(testName.substring(0, 4))
        .doc(testName)
        .set({
          '評量名稱': testName,
          '答對題數': correctAnswers,
          '題數': totalQuestions,
          '成績': score,
          '題目': questionsData,
    });
  }
}
