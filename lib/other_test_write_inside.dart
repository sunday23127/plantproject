import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:plant_project/other_test_inside_score.dart';
import 'package:plant_project/other_test_write.dart';
import 'login.dart';

/*作答測驗內頁*/
class WriteTestInsidePage extends StatefulWidget {
  final String testName; // 測驗名稱
  final int testNum; // 測驗題數
  final int num; //編號
  final String teacherName ; //教師名字

  //接收傳遞的參數
  WriteTestInsidePage({required this.testName,required this.testNum,required this.num,required this.teacherName});
  @override
  _WriteTestInsidePageState createState() => _WriteTestInsidePageState();
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

Future<List<TestQuestion>> getQuestions(String testName, int testNum, int num, String teacherName) async {
  List<TestQuestion> questions = [];
  var serialNum = "T" + num.toString().padLeft(2, '0');
  print(serialNum);
  try {
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot = await FirebaseFirestore.instance
          .collection('學校')
          .doc(studentSchool)
          .collection('教師')
          .doc(teacherName)
          .collection('評量')
          .doc(serialNum)
          .get();
      if (documentSnapshot.exists) {
        Map<String, dynamic> data = documentSnapshot.data() ?? {};
        List<dynamic> questionsData = data['題目'];
        questionsData.shuffle();
        print(questionsData);
        for (int i = 0; i <= questionsData.length; i++) {
          DocumentSnapshot<
              Map<String, dynamic>> documentSnapshot2 = await FirebaseFirestore
              .instance
              .collection('學校')
              .doc(studentSchool)
              .collection('教師')
              .doc(teacherName)
              .collection('題目')
              .doc(questionsData[i])
              .get();

          if (documentSnapshot2.exists) {
            Map<String, dynamic>? data2 = documentSnapshot2.data();
            if (data2 != null) {
              questions.add(TestQuestion(
                question: data2['題目內容'] ?? "",
                option1: data2['選項A'] ?? "",
                option2: data2['選項B'] ?? "",
                option3: data2['選項C'] ?? "",
                answer: data2['題目答案'] ?? "",
                selectedOption: "",
              ));
              print("Added question: ${data2['題目內容']}");
              print("Selected option: ${questions.last.selectedOption}");
            }
          }
        }
      }
  } catch (e) {
    print('Error retrieving questions: $e');
  }
  return questions;
}

//頁面呈現
class _WriteTestInsidePageState extends State<WriteTestInsidePage> {
  late Future<List<TestQuestion>> _questionsFuture;
  int _currentQuestionIndex = 0;

  @override
  void initState(){
    super.initState();
    _questionsFuture = getQuestions(widget.testName, widget.testNum, widget.num, widget.teacherName);
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
                                  builder: (context) => WriteTestPage()),//跳轉作答測驗頁面
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
                                  fontSize: ScreenUtil().setSp(80),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 20.0),
                              buildOption("(A)", currentQuestion.option1, currentQuestion.selectedOption, questions),
                              buildOption("(B)", currentQuestion.option2, currentQuestion.selectedOption, questions),
                              buildOption("(C)", currentQuestion.option3, currentQuestion.selectedOption, questions),
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
                        top: ScreenUtil().setHeight(1380), // Adjust position as needed
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
                                    ? Color.fromRGBO(80, 78, 57, 1) // Color of the current question dots
                                    : Color.fromRGBO(195, 203, 169, 1) // Color of the other question dots
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (_currentQuestionIndex == questions.length - 1) // Show finish button if it's the last question
                        Positioned(
                          bottom: ScreenUtil().setHeight(580), // Adjust position as needed
                          left: 0,
                          right: 0,
                          child: Center(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color.fromRGBO(228, 230, 212, 1),
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                padding: EdgeInsets.zero,
                                minimumSize: Size(
                                  ScreenUtil().setWidth(300),
                                  ScreenUtil().setHeight(100),
                                ),
                              ),
                              onPressed: () {
                                int unansweredQuestions = _countUnansweredQuestions(questions);
                                if (unansweredQuestions > 0) {
                                  // 還有未作答的題目，顯示提示訊息
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return Theme(
                                        data: ThemeData(
                                          dialogTheme: DialogTheme(
                                            backgroundColor: Color.fromRGBO(209, 214, 182, 1),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10.0),
                                            ),
                                          ),
                                        ),
                                        child: AlertDialog(
                                          content: Text(
                                            '還有 $unansweredQuestions 題未作答，確定要完成嗎？',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: ScreenUtil().setSp(65), // 設置字體大小
                                              color: Colors.black, // 設置字體顏色
                                              fontFamily: 'FangSong', // 設置字體
                                            ),
                                          ),
                                          actions: <Widget>[
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
                                                        color: Colors.black,
                                                        fontFamily: 'FangSong',
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
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                    // 繼續跳轉到下一個頁面
                                                    _navigateToTestScorePage(questions);
                                                  },
                                                  child: Text(
                                                    '確定',
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontFamily: 'FangSong',
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                } else {
                                  // 所有题目都已經作答了，直接跳轉到下一個頁面
                                  _navigateToTestScorePage(questions);
                                }
                              },
                              child: Text(
                                '完成',
                                style: TextStyle(
                                  color: Colors.black,
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

  //計算未作答的題目數量
  int _countUnansweredQuestions(List<TestQuestion> questions) {
    int unansweredCount = 0;
    for (var question in questions) {
      if (question.selectedOption.isEmpty) {
        unansweredCount++;
      }
    }
    return unansweredCount;
  }

  //跳轉至分數頁面
  void _navigateToTestScorePage(List<TestQuestion> questions) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TestScorePage(
          testName: widget.testName,
          correctAnswers: _calculateCorrectAnswers(questions),
          totalQuestions: questions.length,
          questions: questions,
        ),
      ),
    );
  }

  int _calculateCorrectAnswers(List<TestQuestion> questions) {
    int correct = 0;
    for (var question in questions) {
      if (question.selectedOption == question.answer) {
        correct++;
      }
    }
    return correct;
  }

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

  Widget buildOption(String option, String text, String selectedOption, List questions) {
    String optionNew = option.replaceAll(RegExp(r'[()]'), '');
    bool isSelected = selectedOption == '選項' + optionNew;
    print("Option: $option, Selected option: $selectedOption");

    return GestureDetector(
      onTap: () {
        setState(() {
          questions[_currentQuestionIndex].selectedOption = '選項' + optionNew;
        });
      },
      child: Container(
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
                fontSize: ScreenUtil().setSp(80),//16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 10.0),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(80),//16.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



