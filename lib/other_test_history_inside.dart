import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:plant_project/login.dart';
import 'package:plant_project/other_test_history.dart';

/*測驗歷史內頁*/
class TestHistoryInsidePage extends StatefulWidget {
  final String testName; // 測驗名稱

  // 接收傳遞的參數
  TestHistoryInsidePage({required this.testName});
  @override
  _TestHistoryInsidePageState createState() => _TestHistoryInsidePageState();
}

class TestQuestion {
  final String question;
  final String option1;
  final String option2;
  final String option3;
  final String answer;
  String selectedOption;

  TestQuestion({
    required this.question,
    required this.option1,
    required this.option2,
    required this.option3,
    required this.answer,
    this.selectedOption = "",
  });
}

Future<List<TestQuestion>> getQuestions(String testName) async {
  List<TestQuestion> questions = [];

  try {
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot = await FirebaseFirestore.instance
          .collection('學生')
          .doc(studentSchool)
          .collection(studentID)
          .doc('測驗歷史')
          .collection(testName.substring(0, 4))
          .doc(testName)
          .get();
      if (documentSnapshot.exists) {
        Map<String, dynamic>? data = documentSnapshot.data();
        if (data != null && data['題目'] != null) {
          List<dynamic> questionsData = data['題目'];
          questionsData.forEach((questionData) {
            questions.add(TestQuestion(
              question: questionData['題目內容'] ?? "",
              option1: questionData['選項1'] ?? "",
              option2: questionData['選項2'] ?? "",
              option3: questionData['選項3'] ?? "",
              answer: questionData['正確答案'] ?? "",
              selectedOption: questionData['選擇的答案'] ?? "",
            ));
          });
        }
      }
  } catch (e) {
    print('Error retrieving questions: $e');
  }
  return questions;
}

class _TestHistoryInsidePageState extends State<TestHistoryInsidePage> {
  late Future<List<TestQuestion>> _questionsFuture;
  int _currentQuestionIndex = 0;

  @override
  void initState() {
    super.initState();
    _questionsFuture = getQuestions(widget.testName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _questionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(
              valueColor: new AlwaysStoppedAnimation<Color>(
                  Color.fromRGBO(167, 173, 147, 1)),
            ));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<TestQuestion>? questions = snapshot.data as List<TestQuestion>?;
            if (questions == null || questions.isEmpty) {
              return Center(child: Text('No questions available.'));
            }

            TestQuestion currentQuestion = questions[_currentQuestionIndex];

            return GestureDetector(
                onHorizontalDragEnd: (details) {
                  if (details.primaryVelocity != 0) {
                    if (details.primaryVelocity! < 0) {
                      _changeQuestion(1,questions);
                    } else {
                      _changeQuestion(-1,questions);
                    }
                  }
                },
            child: Container(
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
                                builder: (context) => TestHistoryPage()),
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
                        widget.testName,
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(100),
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Positioned(
                      top: ScreenUtil().setHeight(400),
                      left: ScreenUtil().setWidth(210),
                      child: Container(
                        width: ScreenUtil().setWidth(1200),
                        padding: EdgeInsets.all(20.0),
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(228, 230, 212, 1),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Q：' + currentQuestion.question,
                              style: TextStyle(
                                fontSize: ScreenUtil().setSp(80),//18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: ScreenUtil().setHeight(50)),
                            buildOption("(A)", currentQuestion.option1, currentQuestion.selectedOption, currentQuestion.answer),
                            buildOption("(B)", currentQuestion.option2, currentQuestion.selectedOption, currentQuestion.answer),
                            buildOption("(C)", currentQuestion.option3, currentQuestion.selectedOption, currentQuestion.answer),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: ScreenUtil().setHeight(800),
                      left: ScreenUtil().setWidth(5),
                      child: Visibility(
                        visible: _currentQuestionIndex > 0, // 控制按鈕消失
                        child: MaterialButton(
                          onPressed: () => _changeQuestion(-1,questions),
                          highlightColor: Colors.transparent, 
                          splashColor: Colors.transparent, 
                          padding: EdgeInsets.zero, 
                          minWidth: ScreenUtil().setWidth(100), 
                          height: ScreenUtil().setHeight(50), 
                          child: Image.asset(
                            "assets/images/arrowleft.png",
                            width: ScreenUtil().setWidth(150),
                            height: ScreenUtil().setHeight(200),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: ScreenUtil().setHeight(800),
                      right: ScreenUtil().setWidth(5),
                      child: Visibility(
                        visible: _currentQuestionIndex < questions.length - 1, // 控制按鈕消失
                        child: MaterialButton(
                          onPressed: () => _changeQuestion(1,questions),
                          highlightColor: Colors.transparent, 
                          splashColor: Colors.transparent, 
                          padding: EdgeInsets.zero, 
                          minWidth: ScreenUtil().setWidth(100), 
                          height: ScreenUtil().setHeight(50), 
                          child: Image.asset(
                            "assets/images/arrowright.png",
                            width: ScreenUtil().setWidth(150),
                            height: ScreenUtil().setHeight(200),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: ScreenUtil().setHeight(1380),
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          questions.length,
                              (index) => Container(
                            margin: EdgeInsets.symmetric(horizontal: 5.0),
                            width: ScreenUtil().setWidth(50),
                            height: ScreenUtil().setHeight(50),
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: index == _currentQuestionIndex
                                    ? Color.fromRGBO(80, 78, 57, 1) 
                                    : Color.fromRGBO(195, 203, 169, 1) 
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
        },
      ),
    );
  }

  //切換題目
  void _changeQuestion(int increment,List<TestQuestion> questions) {
    setState(() {
      _currentQuestionIndex += increment;
      if (_currentQuestionIndex < 0) {
        _currentQuestionIndex = 0;
      } else if (_currentQuestionIndex >= questions.length) {
        _currentQuestionIndex = questions.length - 1;
      }
    });
  }

  Widget buildOption(String option, String text, String selectedOption, String correctAnswer) {
    String optionNew = option.replaceAll(RegExp(r'[()]'), '');
    bool isSelected = selectedOption == '選項' + optionNew;
    bool isCorrect = '選項' + optionNew == correctAnswer;
    bool userCorrect = selectedOption == correctAnswer;
    print(userCorrect);

    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.0),
      padding: EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: isSelected ? Color.fromRGBO(151, 173, 133, 1) : Color.fromRGBO(206, 212, 183, 1),
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: Row(
        children: [
          Text(
            option,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(80),
              fontWeight: FontWeight.bold,
              color: isSelected ? (!userCorrect ? Color.fromRGBO(148, 13, 13, 1) : Colors.black) : Colors.black ,
            ),
          ),
          SizedBox(width: ScreenUtil().setWidth(10)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(80),
                color: isSelected ? (!userCorrect ? Color.fromRGBO(148, 13, 13, 1) : Colors.black) : Colors.black ,
              ),
            ),
          ),
          if (isCorrect)
            Icon(
              Icons.check, // 正確時顯示綠色的勾號圖標
              color: Color.fromRGBO(108, 118, 72, 1),
            ),
        ],
      ),
    );
  }
}



