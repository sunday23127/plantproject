import 'package:plant_project/login.dart';
import 'package:plant_project/other_test_menu.dart';
import 'package:plant_project/otherfunction.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/*新增測驗頁面*/
class TestAddPage extends StatefulWidget {
  const TestAddPage({super.key});

  @override
  _TestAddPageState createState() => _TestAddPageState();
}


class _TestAddPageState extends State<TestAddPage> {
  TextEditingController _textFieldController1 = TextEditingController();
  TextEditingController _textFieldController2 = TextEditingController();
  TextEditingController _textFieldController3 = TextEditingController();
  TextEditingController _textFieldController4 = TextEditingController();
  String _selectedItem = '請選擇';


  Future<String> _fetchTeacher() async {
    final querySnapshot = await FirebaseFirestore.instance.collection('學生').doc(studentClass).get();
    final data = querySnapshot.data();
    if (data != null) { // 對 data 進行 null 檢查
      final teacher = data['教師'];
      return teacher;
    } else {
      return ''; // 或者返回其他預設值
    }
  }

  Future<String> getLatestDocumentId() async {
    String teacherName = await _fetchTeacher();
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('學校').doc(studentSchool).collection('教師').doc(teacherName).collection('題目').orderBy('題目編號', descending: true).limit(1).get();
    if (querySnapshot.docs.isNotEmpty) {
      print(querySnapshot.docs.last.id);
      return querySnapshot.docs.last.id.substring(1);
    }
    return '0'; // 如果集合為空，則返回 0
  }

  Future<void> addTest(Map<String, dynamic> data) async {
    String teacherName = await _fetchTeacher();
    String latestDocumentId = await getLatestDocumentId();
    print(latestDocumentId);
    int newDocumentId = int.parse(latestDocumentId) + 1;
    print(newDocumentId);
    String newDocumentName = "Q" + newDocumentId.toString().padLeft(2, '0');

    await FirebaseFirestore.instance.collection('教師').doc(teacherName).collection('題目').doc(newDocumentName).set({
      '題目編號': newDocumentName,
      '題目內容': data['question'],
      '選項A': data['optionA'],
      '選項B': data['optionB'],
      '選項C': data['optionC'],
      '題目答案': data['correctAnswer'],
    });
  }

 //頁面呈現
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
                        builder: (context) => TestMenuPage()), //返回課堂評量選單頁面
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
                '新增題目',
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(110),
                  color: Colors.black,
                ),
              ),
            ),
            Positioned(
              top: ScreenUtil().setHeight(470),
              left: ScreenUtil().setWidth(200),
              child: Text(
                '題 目',
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(80),
                  color: Colors.black,
                ),
              ),
            ),
            Positioned(
              top: ScreenUtil().setHeight(450),
              left: ScreenUtil().setWidth(600),
              child: Container(
                height: ScreenUtil().setHeight(200),
                width: ScreenUtil().setWidth(950),
                child: TextField(
                  controller: _textFieldController1,
                  maxLines: null,
                  expands: true,
                  keyboardType: TextInputType.multiline,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: InputDecoration( //題目輸入框
                    filled: true,
                    fillColor: Color.fromRGBO(235, 236, 219, 1),
                    hintText: '請 輸 入 題 目 敘 述',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: ScreenUtil().setHeight(740),
              left: ScreenUtil().setWidth(210),
              child: Text(
                '選項A',
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(80),
                  color: Colors.black,
                ),
              ),
            ),
            Positioned(
              top: ScreenUtil().setHeight(700),
              left: ScreenUtil().setWidth(600),
              child: Container(
                height: ScreenUtil().setHeight(150),
                width: ScreenUtil().setWidth(950),
                child: TextField(
                  controller: _textFieldController2,
                  maxLines: null,
                  expands: true,
                  keyboardType: TextInputType.multiline,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: InputDecoration( //選項A輸入框
                    filled: true,
                    fillColor: Color.fromRGBO(235, 236, 219, 1),
                    hintText: '請 輸 入 選 項 A',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: ScreenUtil().setHeight(940),
              left: ScreenUtil().setWidth(210),
              child: Text(
                '選項B',
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(80),
                  color: Colors.black,
                ),
              ),
            ),
            Positioned(
              top: ScreenUtil().setHeight(900),
              left: ScreenUtil().setWidth(600),
              child: Container(
                height: ScreenUtil().setHeight(150),
                width: ScreenUtil().setWidth(950),
                child: TextField(
                  controller: _textFieldController3,
                  maxLines: null,
                  expands: true,
                  keyboardType: TextInputType.multiline,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: InputDecoration( //選項B輸入框
                    filled: true,
                    fillColor: Color.fromRGBO(235, 236, 219, 1),
                    hintText: '請 輸 入 選 項 B',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: ScreenUtil().setHeight(1140),
              left: ScreenUtil().setWidth(210),
              child: Text(
                '選項C',
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(80),
                  color: Colors.black,
                ),
              ),
            ),
            Positioned(
              top: ScreenUtil().setHeight(1100),
              left: ScreenUtil().setWidth(600),
              child: Container(
                height: ScreenUtil().setHeight(150),
                width: ScreenUtil().setWidth(950),
                child: TextField(
                  controller: _textFieldController4,
                  maxLines: null,
                  expands: true,
                  keyboardType: TextInputType.multiline,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: InputDecoration( //選項C輸入框
                    filled: true,
                    fillColor: Color.fromRGBO(235, 236, 219, 1),
                    hintText: '請 輸 入 選 項 C',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: ScreenUtil().setHeight(1340),
              left: ScreenUtil().setWidth(200),
              child: Text(
                '答 案',
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(80),
                  color: Colors.black,
                ),
              ),
            ),
            Positioned(
              top: ScreenUtil().setHeight(1300),
              left: ScreenUtil().setWidth(600),
              child: DropdownExample(
                onChanged: (value) {
                  setState(() {
                    if (value != '請選擇') {
                      _selectedItem = value;
                    }
                    else if (value == '請選擇') {
                      _selectedItem = value;
                    }
                  });
                },
                selectedItem: _selectedItem,
              ),
            ),
            Positioned(
              top: ScreenUtil().setHeight(1700),
              left: ScreenUtil().setWidth(500),
              right: ScreenUtil().setWidth(500),
              child: ElevatedButton(
                onPressed: () {
                  // 獲取使用者輸入的資料
                  String question = _textFieldController1.text;
                  String optionA = _textFieldController2.text;
                  String optionB = _textFieldController3.text;
                  String optionC = _textFieldController4.text;
                  String correctAnswer = _selectedItem;

                  Map<String, dynamic> testData = {
                    'question': question,
                    'optionA': optionA,
                    'optionB': optionB,
                    'optionC': optionC,
                    'correctAnswer': correctAnswer,
                  };

                  if(_textFieldController1.text != "" && _textFieldController2.text != "" && _textFieldController3.text != "" && _textFieldController4.text != "" && _selectedItem != "請選擇答案"){
                    // 將資料儲存到 Firestore
                    addTest(testData);
                    setState(() {
                      _selectedItem = "請選擇";
                    });
                    _textFieldController1.text = "";
                    _textFieldController2.text = "";
                    _textFieldController3.text = "";
                    _textFieldController4.text = "";
                  }else if(_textFieldController1.text == ""){
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor: Color.fromRGBO(243, 243, 231, 1),
                          content: Text(
                            '尚 未 輸 入 題 目',
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
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                        Color.fromRGBO(246, 247, 242, 1)),
                                    shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
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
                  }else if(_textFieldController2.text == ""){
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor: Color.fromRGBO(243, 243, 231, 1),
                          content: Text(
                            '尚 未 輸 入 選 項 A',
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
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                        Color.fromRGBO(246, 247, 242, 1)),
                                    shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
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
                  }else if(_textFieldController3.text == ""){
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor: Color.fromRGBO(243, 243, 231, 1),
                          content: Text(
                            '尚 未 輸 入 選 項 B',
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
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                        Color.fromRGBO(246, 247, 242, 1)),
                                    shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
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
                  }else if(_textFieldController4.text == ""){
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor: Color.fromRGBO(243, 243, 231, 1),
                          content: Text(
                            '尚 未 輸 入 選 項 C',
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
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                        Color.fromRGBO(246, 247, 242, 1)),
                                    shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
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
                  }else if(_selectedItem == "請選擇"){
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor: Color.fromRGBO(243, 243, 231, 1),
                          content: Text(
                            '尚 未 選 擇 正 確 答 案',
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
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                        Color.fromRGBO(246, 247, 242, 1)),
                                    shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromRGBO(167, 173, 147, 1),
                  shadowColor: Color.fromRGBO(167, 173, 147, 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  '新 增 題 目',
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(70),
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//下拉選單(答案)
class DropdownExample extends StatefulWidget {
  final Function(String)? onChanged;
  String selectedItem;

  DropdownExample({Key? key, this.onChanged, required this.selectedItem}) : super(key: key);

  @override
  _DropdownExampleState createState() => _DropdownExampleState();
}

class _DropdownExampleState extends State<DropdownExample> {

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ScreenUtil().setWidth(550),
      height: ScreenUtil().setHeight(150),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Color.fromRGBO(249, 248, 244, 1),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: widget.selectedItem,
          onChanged: (String? newValue) {
            setState(() {
              widget.selectedItem = newValue!;
            });
            // 通知父组件下拉選單的更改
            widget.onChanged?.call(newValue!);
          },
          style: TextStyle(color: Colors.black, fontSize: ScreenUtil().setSp(80), fontFamily: 'FangSong'),
          dropdownColor: Color.fromRGBO(249, 248, 244, 1),
          icon: Icon(Icons.arrow_drop_down_rounded),
          iconSize: ScreenUtil().setSp(105),
          borderRadius: BorderRadius.circular(10),
          isExpanded: true, // 讓選單擴展至容器的寬度
          alignment: Alignment.centerRight,
          items: <String>['請選擇', '選項A', '選項B', '選項C']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  value,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
