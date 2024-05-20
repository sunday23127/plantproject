import 'package:plant_project/menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

late String studentSchool;
late String studentID;
late String studentClass;
late String studentNum;
late String teacherName;

/*登入頁面*/
class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController accountController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  List<String> _dropDownItems = ['請選擇學校'];
  String _selectedSchool = '請選擇學校';

  @override
  void initState() {
    super.initState();
    _fetchDropdownOptions();
  }

  //取得學校的下拉選項
  void _fetchDropdownOptions() async {
    List<String> options = [];
    // 從 Firebase 獲取下拉選單選項
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
        .collection('學校')
        .get();

    querySnapshot.docs.forEach((doc) {
      String school = doc.id; // 文件的名稱
      options.add(school);
    });
    setState(() {
      _dropDownItems.addAll(options);
    });
  }

  @override
  void dispose() {
    // 釋放控制器
    accountController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  //頁面顯示
  @override
  Widget build(BuildContext context) {
    Future<void> login(BuildContext context) async {
      if(_selectedSchool=='請選擇學校'){
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Color.fromRGBO(243, 243, 231, 1),
              title: Align(
                alignment: Alignment.center,
                child: Text(
                  '登 入 失 敗',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: ScreenUtil().setSp(100)),
                ),
              ),
              content: Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  '未 選 擇 學 校',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: ScreenUtil().setSp(70)),
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              actions: <Widget>[
                ButtonBar(
                  alignment: MainAxisAlignment.center, // 將按鈕置中
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
                        '確定',
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
      else if(accountController.text==''){
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Color.fromRGBO(243, 243, 231, 1),
              title: Align(
                alignment: Alignment.center,
                child: Text(
                  '登 入 失 敗',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: ScreenUtil().setSp(100)),
                ),
              ),
              content: Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  '帳 號 未 填 寫',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: ScreenUtil().setSp(70)),
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              actions: <Widget>[
                ButtonBar(
                  alignment: MainAxisAlignment.center, // 將按鈕置中
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
                        '確定',
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
      else if(passwordController.text==''){
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Color.fromRGBO(243, 243, 231, 1),
              title: Align(
                alignment: Alignment.center,
                child: Text(
                  '登 入 失 敗',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: ScreenUtil().setSp(100)),
                ),
              ),
              content: Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  '密 碼 未 填 寫',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: ScreenUtil().setSp(70)),
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              actions: <Widget>[
                ButtonBar(
                  alignment: MainAxisAlignment.center, // 將按鈕置中
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
      /*else if(usernameController.text.length != 5){
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Color.fromRGBO(243, 243, 231, 1),
              title: Align(
                alignment: Alignment.center,
                child: Text(
                  '登 入 失 敗',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: ScreenUtil().setSp(100)),
                ),
              ),
              content: Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  '帳 號 為 你 的 班 級 加 座 號',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: ScreenUtil().setSp(70)),
                ),
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
                        '確定',
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
      }*/
      else{
        final String enteredSchool = _selectedSchool;
        final String enteredAccount = accountController.text;
        final String enteredPassword = passwordController.text;

        // 使用 Firestore 來檢查帳號和密碼
        final DocumentSnapshot<Map<String, dynamic>> result = await FirebaseFirestore.instance
            .collection('學生')
            .doc(enteredSchool)
            .collection(enteredAccount)
            .doc('個人資料')
            .get();

        // 從 result 中獲取學號和密碼欄位的值
        final Map<String, dynamic>? data = result.data();

        // 檢查是否成功獲取到資料並且學號、密碼與使用者輸入相符
        if (data != null && data['學號'] == enteredAccount && data['密碼'] == enteredPassword) {
          // 設置全域變數的值
          studentSchool = enteredSchool;
          studentID = data['學號'];
          studentClass = data['班級'];
          studentNum = data['座號'];

          // 從文件中獲取教師欄位
          final DocumentSnapshot<Map<String, dynamic>> documentSnapshot = await FirebaseFirestore.instance
              .collection('學校')
              .doc(studentSchool)
              .collection('班級')
              .doc(studentClass)
              .get();

          if (documentSnapshot.exists) {
            teacherName = documentSnapshot['教師'];
          }
          // 登入成功，跳轉至首頁
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) =>  MenuPage()),
          );
        } else {
          // 登入失敗，顯示錯誤訊息
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                backgroundColor: Color.fromRGBO(243, 243, 231, 1),
                title: Align(
                  alignment: Alignment.center,
                  child: Text(
                    '登 入 失 敗',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: ScreenUtil().setSp(100)),
                  ),
                ),
                content: Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    '帳 號 或 密 碼 輸 入 錯 誤',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: ScreenUtil().setSp(70)),
                  ),
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
                          '確定',
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
      }
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/login.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: <Widget>[
            Positioned(
              top: ScreenUtil().setHeight(580),
              left: ScreenUtil().setWidth(130),
              child: Container(
                width: ScreenUtil().setWidth(1400),
                height: ScreenUtil().setHeight(580),
                decoration: BoxDecoration(
                  color: Color.fromRGBO(250, 249, 241, 1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.black,
                    width: 1.0,
                  ),
                ),
              ),
            ),
            Positioned(
              top: ScreenUtil().setHeight(710),//30,
              left: ScreenUtil().setWidth(260),//20,
              child: Text(
                '學 校',
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(100),//25,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            Positioned(
              top: ScreenUtil().setHeight(850),//30,
              left: ScreenUtil().setWidth(260),//20,
              child: Text(
                '帳 號',
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(100),//25,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            Positioned(
              top: ScreenUtil().setHeight(985),//30,
              left: ScreenUtil().setWidth(260),//20,
              child: Text(
                '密 碼',
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(100),//25,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            Positioned(
              top: ScreenUtil().setHeight(350),//30,
              left: ScreenUtil().setWidth(585),//20,
              child: Image.asset(
                "assets/images/login_icon.png",
                width: ScreenUtil().setWidth(450),//50,
                height: ScreenUtil().setHeight(400),//50,
              ),
            ),
            Positioned(
              top: ScreenUtil().setHeight(700), //100, // 調整起始位置
              left: ScreenUtil().setWidth(590),
              child: DropdownExample(
                onChanged: (value) {
                  setState(() {
                    if (value != '請選擇學校') {
                      _selectedSchool = value;
                    }
                    else if (value == '請選擇學校') {
                      _selectedSchool = value;
                    }
                  });
                },
                dropDownItems: _dropDownItems,
                selectedSchool: _selectedSchool,
              ),
            ),
            Positioned(
              top: ScreenUtil().setHeight(840),
              left: ScreenUtil().setWidth(500),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: ScreenUtil().setWidth(850),
                  height: ScreenUtil().setHeight(105),
                  child: TextField(
                    controller: accountController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Color.fromRGBO(230,234,220,1),
                      hintText: '請 輸 入 帳 號',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20,vertical: 5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: ScreenUtil().setHeight(980),
              left: ScreenUtil().setWidth(500),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  height: ScreenUtil().setHeight(105),
                  width: ScreenUtil().setWidth(850),
                  child: TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Color.fromRGBO(230,234,220,1),
                      hintText: '請 輸 入 密 碼',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20,vertical: 5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: ScreenUtil().setHeight(1200),
              left: ScreenUtil().setWidth(450),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  height: ScreenUtil().setHeight(120),
                  width: ScreenUtil().setWidth(550),
                  child: ElevatedButton(
                    onPressed: () => login(context),
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: Color.fromRGBO(250, 249, 241, 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                        side: BorderSide(color: Colors.black),
                      ),
                      foregroundColor: Color.fromRGBO(246, 247, 242, 1),
                    ),
                    child: Text("登 入",
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(100),
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
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
}

//下拉選單(學校)
class DropdownExample extends StatefulWidget {
  final Function(String)? onChanged;
  final List<String> dropDownItems;
  String selectedSchool;

  DropdownExample({Key? key, this.onChanged, required this.dropDownItems, required this.selectedSchool}) : super(key: key);

  @override
  _DropdownExampleState createState() => _DropdownExampleState(dropDownItems,selectedSchool);
}

class _DropdownExampleState extends State<DropdownExample> {

  @override
  void initState() {
    super.initState();
  }


  // 接收下拉選單選項列表
  _DropdownExampleState(List<String> dropDownItems,String selectedSchool) {
    dropDownItems = dropDownItems;
    selectedSchool = selectedSchool;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ScreenUtil().setWidth(850),
      height: ScreenUtil().setHeight(105),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: Color.fromRGBO(230,234,220,1),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: widget.selectedSchool,
          onChanged: (String? newValue) {
            setState(() {
              widget.selectedSchool = widget.dropDownItems.contains(newValue) ? newValue! : '請選擇學校';
            });
            // 通知父组件下拉選單的更改
            widget.onChanged?.call(widget.dropDownItems.contains(newValue) ? newValue! : '請選擇學校');
          },
          style: TextStyle(color: Colors.black, fontSize: ScreenUtil().setSp(80), fontFamily: 'FangSong'),
          dropdownColor: Color.fromRGBO(235, 236, 219, 1), // 設定下拉選單背景顏色
          icon: Transform.translate(
            offset: Offset(-15.0, 0.0),
            child: Icon(Icons.arrow_drop_down_rounded),
          ), // 設定箭頭圖示
          iconSize: ScreenUtil().setSp(105), // 設定箭頭圖示大小
          menuMaxHeight: ScreenUtil().setHeight(500),
          borderRadius: BorderRadius.circular(30),
          isExpanded: true, // 讓選單擴展至容器的寬度
          alignment: Alignment.centerRight, // 設定文字對齊方式
          items: widget.dropDownItems.map<DropdownMenuItem<String>>((String value) {
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
