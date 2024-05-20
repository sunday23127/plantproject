import 'package:plant_project/login.dart';
import 'package:plant_project/otherfunction.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';


/*課堂回饋頁面*/
class OutcomePage extends StatefulWidget {
  const OutcomePage({super.key});

  @override
  _OutcomePageState createState() => _OutcomePageState();
}

class _OutcomePageState extends State<OutcomePage> {
  TextEditingController _textFieldController = TextEditingController();
  List<String> _dropDownItems = ['請選擇植物'];
  String _selectedItem = '請選擇植物';
  String _selectedPage = '請選擇頁數';
  String? _selectedTemplate = '請選擇模板';
  String studentId = studentClass + studentNum;
  bool _processing = false; //是否在生成簡報
  bool _generatebtn = true; //是否顯示生成簡報按鈕
  String _presentationUrl = ''; //簡報網址
  late TemplateDropdown _templateDropdown;


  @override
  void initState() {
    super.initState();
    _fetchDropdownOptions();
    // Initialize the TemplateDropdown instance
    _templateDropdown = TemplateDropdown(
      onChanged: (selectedTemplate) {
        // Handle onChanged event if needed
      },
      selectedTemplateName: _selectedTemplate,
    );
  }

  //取得植物的下拉選項
  void _fetchDropdownOptions() async {
    // 從 Firebase 獲取下拉選單選項
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('學生')
        .doc(studentSchool)
        .collection(studentID)
        .doc('掃描資料')
        .get();

    if (snapshot.exists) {
      Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?; // 進行類型轉換
      if (data != null && data.containsKey('植物名稱')) {
        List<dynamic> categories = data['植物名稱'];
        List<String> options = categories.map((category) => category.toString()).toList();
        setState(() {
          _dropDownItems.addAll(options);
          print(_dropDownItems);
        });
      } else {
        // 如果文檔不存在或者 "categories" 字段不存在，則將下拉選單選項置為空列表
        setState(() {
          _dropDownItems = ['請選擇植物'];
        });
      }
    } else {
      // 如果文檔不存在，則將下拉選單選項置為空列表
      setState(() {
        _dropDownItems = ['請選擇植物'];
      });
    }
  }

  @override
  void dispose() {
    _textFieldController.dispose();
    super.dispose();
  }

  //畫面呈現
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/other_background.png"), //背景
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
                        builder: (context) => OtherFunctionPage()), //返回功能選單頁面
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
                '課堂回饋',
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(110),
                  color: Colors.black,
                ),
              ),
            ),
            Positioned(
              top: ScreenUtil().setHeight(470),
              left: ScreenUtil().setWidth(150),
              child: Text(
                '簡 報 主 題',
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(80),
                  color: Colors.black,
                ),
              ),
            ),
            Positioned(
              top: ScreenUtil().setHeight(450),
              left: ScreenUtil().setWidth(650),
              child: DropdownExample(
                onChanged: (value) {
                  setState(() {
                    if (value != '請選擇植物') {
                      _selectedItem = value;
                    }
                    else if (value == '請選擇植物') {
                      _selectedItem = value;
                    }
                  });
                },
                dropDownItems: _dropDownItems,
                studentId: studentId,
                selectedItem: _selectedItem,
              ),
            ),
            Positioned(
              top: ScreenUtil().setHeight(670),
              left: ScreenUtil().setWidth(150),
              child: Text(
                '簡 報 頁 數',
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(80),
                  color: Colors.black,
                ),
              ),
            ),
            Positioned(
              top: ScreenUtil().setHeight(650),
              left: ScreenUtil().setWidth(650),
              child: DropdownExample2(
                onChanged: (value) {
                  setState(() {
                    if (value != '請選擇頁數') {
                      _selectedPage = value;
                    }
                    else if (value == '請選擇頁數') {
                      _selectedPage = value;
                    }
                  });
                },
                selectedItem: _selectedPage,
              ),
            ),
            Positioned(
              top: ScreenUtil().setHeight(870),
              left: ScreenUtil().setWidth(150),
              child: Text(
                '簡 報 模 版',
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(80),
                  color: Colors.black,
                ),
              ),
            ),
            Positioned(
              top: ScreenUtil().setHeight(840),
              left: ScreenUtil().setWidth(650),
              child: Container(
                width: ScreenUtil().setWidth(700),
                height: ScreenUtil().setHeight(500),
                child: TemplateDropdown(
                  onChanged: (template) {
                    // 接收子組件的通知，更新父組件狀態
                    setState(() {
                      if (template != '請選擇模板') {
                        print('not');
                        _selectedTemplate = template;
                      }
                      else if (template == '請選擇模板') {
                        print('模板');
                        _selectedTemplate = template;
                      }
                    });
                  },
                  selectedTemplateName: _selectedTemplate == '請選擇模板' ? _selectedTemplate : '模板' + _selectedTemplate!.substring(8),
                ),
              ),
            ),
            Positioned(
              top: ScreenUtil().setHeight(1040),
              left: ScreenUtil().setWidth(150),
              child: Text(
                '　心 得',
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(80),
                  color: Colors.black,
                ),
              ),
            ),
            Positioned(
              top: ScreenUtil().setHeight(1040),
              left: ScreenUtil().setWidth(650),
              child: Container(
                height: ScreenUtil().setHeight(550),
                width: ScreenUtil().setWidth(900),
                child: TextField(
                  controller: _textFieldController,
                  maxLines: null,
                  expands: true,
                  keyboardType: TextInputType.multiline,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: InputDecoration( //輸入心得框
                    filled: true,
                    fillColor: Color.fromRGBO(235, 236, 219, 1),
                    hintText: '請 輸 入 你 的 心 得',
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
              top: ScreenUtil().setHeight(1730),
              left: ScreenUtil().setWidth(500),
              right: ScreenUtil().setWidth(500),
              child: ElevatedButton(
                onPressed:_generatebtn ? () {
                  if(_selectedItem != "請選擇植物" && _selectedPage != "請選擇頁數" && _selectedTemplate != "請選擇模板" && _textFieldController.text != "" && _generatebtn){
                    setState(() {
                      _processing = true; // 開始生成簡報
                      _generatebtn = false;
                    });
                    // 傳遞參數並呼叫python
                    _executePythonScript(_selectedItem,_selectedPage,_selectedTemplate,_textFieldController.text,studentId);
                    setState(() {
                      _selectedItem = "請選擇植物";
                      _selectedPage = "請選擇頁數";
                      _selectedTemplate = "請選擇模板";
                      _templateDropdown.handleTemplateChange("請選擇模板");
                    });
                    _textFieldController.text = "";
                  }
                  else if(_selectedItem == "請選擇植物" && _generatebtn){
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor: Color.fromRGBO(243, 243, 231, 1),
                          content: Text(
                            '尚 未 選 擇 簡 報 主 題',
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
                  else if(_selectedPage == "請選擇頁數" && _generatebtn){
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor: Color.fromRGBO(243, 243, 231, 1),
                          content: Text(
                            '尚 未 選 擇 簡 報 頁 數',
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
                  else if(_selectedTemplate == "請選擇模板" && _generatebtn){
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor: Color.fromRGBO(243, 243, 231, 1),
                          content: Text(
                            '尚 未 選 擇 簡 報 模 板',
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
                  else if(_textFieldController.text == "" && _generatebtn){
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor: Color.fromRGBO(243, 243, 231, 1),
                          content: Text(
                            '尚 未 輸 入 你 的 心 得',
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
                }:null,
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: _generatebtn?Color.fromRGBO(167, 173, 147, 1):Colors.transparent,
                  disabledBackgroundColor: Colors.transparent,
                  foregroundColor: _generatebtn?Color.fromRGBO(167, 173, 147, 1):Colors.transparent,
                  shadowColor: _generatebtn?Color.fromRGBO(167, 173, 147, 1):Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                    _generatebtn?'生 成 簡 報':'',
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(70),
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            Positioned(
              top: ScreenUtil().setHeight(1680),
              left: ScreenUtil().setWidth(280),
              right: ScreenUtil().setWidth(280),
                child: Text(
                  _processing ?'生 成 簡 報 中 ， 請 稍 後':'' ,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(80),
                    color: Colors.black,
                  ),
                ),
              ),
            // 根據 _presentationUrl 顯示連接文字
            if (_presentationUrl.isNotEmpty)
                Positioned(
                  top: ScreenUtil().setHeight(1700),
                  left: ScreenUtil().setWidth(480),
                  right: ScreenUtil().setWidth(480),
                  child: GestureDetector(
                    onTap: () {
                      launch(_presentationUrl); // 點擊連結時調用 _launchURL 打開連結
                    },
                    child: RichText(
                      text: TextSpan(
                        text: '點 擊 下 載 簡 報',
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(80),
                          color: Color.fromRGBO(154, 161, 127, 1),
                          decoration: TextDecoration.underline,
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

  Future<void> _executePythonScript(String topic,String page,String? template,String inputText,String studentId) async {
    var url = 'https://us-central1-hybrid-snowfall-419307.cloudfunctions.net/function-ppttest2';
    var response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'topic': topic,
        'pages': page,
        'inputText': inputText,
        'school': studentSchool,
        'studentId': studentID,
        'template' : template,
      }),
    );

    if (response.statusCode == 200) {
      print('Python執行成功');
      print('Python返回的資料：${response.body}');
      setState(() {
        _processing = false; //生成簡報完畢
        _presentationUrl = response.body;
      });
    } else {
      print('Python執行失敗：${response.statusCode}');
      setState(() {
        _processing = false; //生成簡報完畢
      });
    }
  }
}

//下拉選單(植物)
class DropdownExample extends StatefulWidget {
  final Function(String)? onChanged;
  final List<String> dropDownItems;
  final String studentId;
  String selectedItem;

  DropdownExample({Key? key, this.onChanged, required this.dropDownItems, required this.studentId, required this.selectedItem}) : super(key: key);

  @override
  _DropdownExampleState createState() => _DropdownExampleState(dropDownItems,studentId,selectedItem);
}

class _DropdownExampleState extends State<DropdownExample> {

  @override
  void initState() {
    super.initState();
  }


  // 構造函數接收下拉選單選項列表
  _DropdownExampleState(List<String> dropDownItems,String studentId,String selectedItem) {
    dropDownItems = dropDownItems;
    studentId = studentId;
    selectedItem = selectedItem;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ScreenUtil().setWidth(700),
      height: ScreenUtil().setHeight(120),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Color.fromRGBO(235, 236, 219, 1),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: widget.selectedItem,
          onChanged: (String? newValue) {
            setState(() {
              widget.selectedItem = widget.dropDownItems.contains(newValue) ? newValue! : '請選擇植物';
            });
            // 通知父组件下拉選單的更改
            widget.onChanged?.call(widget.dropDownItems.contains(newValue) ? newValue! : '請選擇植物');
          },
          style: TextStyle(color: Colors.black, fontSize: ScreenUtil().setSp(80), fontFamily: 'FangSong'),
          dropdownColor: Color.fromRGBO(235, 236, 219, 1),
          icon: Transform.translate(
            offset: Offset(-15.0, 0.0),
            child: Icon(Icons.arrow_drop_down_rounded),
          ),
          iconSize: ScreenUtil().setSp(105),
          menuMaxHeight: ScreenUtil().setHeight(500),
          borderRadius: BorderRadius.circular(10),
          isExpanded: true, // 讓選單擴展至容器的寬度
          alignment: Alignment.centerRight,
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

//下拉選單(簡報頁數)
class DropdownExample2 extends StatefulWidget {
  final Function(String)? onChanged;
  String selectedItem;

  DropdownExample2({Key? key, this.onChanged, required this.selectedItem}) : super(key: key);

  @override
  _DropdownExample2State createState() => _DropdownExample2State();
}

class _DropdownExample2State extends State<DropdownExample2> {

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ScreenUtil().setWidth(700),
      height: ScreenUtil().setHeight(120),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Color.fromRGBO(235, 236, 219, 1),
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
          dropdownColor: Color.fromRGBO(235, 236, 219, 1),
          icon: Transform.translate(
            offset: Offset(-15.0, 0.0),
            child: Icon(Icons.arrow_drop_down_rounded),
          ),
          iconSize: ScreenUtil().setSp(105),
          menuMaxHeight: ScreenUtil().setHeight(500),
          borderRadius: BorderRadius.circular(10),
          isExpanded: true, // 讓選單擴展至容器的寬度
          alignment: Alignment.centerRight,
          items: <String>['請選擇頁數', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10']
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

//簡報模板選單
class TemplateDropdown extends StatefulWidget {
  final ValueChanged<String?>? onChanged;
  String? selectedTemplateName;

  TemplateDropdown({Key? key, this.onChanged, required this.selectedTemplateName}) : super(key: key);

  @override
  _TemplateDropdownState createState() => _TemplateDropdownState();

  void handleTemplateChange(String? selectedTemplate) {
    onChanged?.call(selectedTemplate);
  }
}

class _TemplateDropdownState extends State<TemplateDropdown> {
  bool _showOptions = false;
  //String? _selectedTemplateName;
  String? _selectedTemplate;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  title: Text('選擇模板'),
                  backgroundColor: Color.fromRGBO(235, 236, 219, 1),
                  content: StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                      return SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            customRadioListTile(context, '模板1', 'template1', _selectedTemplate, (value) {
                              setState(() {
                                _selectedTemplate = value as String?;
                                widget.selectedTemplateName = "模板1";
                              });
                              print(_selectedTemplate);
                              widget.onChanged?.call(_selectedTemplate);
                            }, 'assets/images/template_1.jpg'),

                            customRadioListTile(context, '模板2', 'template2', _selectedTemplate, (value) {
                              setState(() {
                                _selectedTemplate = value as String?;
                                widget.selectedTemplateName = "模板2";
                              });
                              widget.onChanged?.call(_selectedTemplate);
                            }, 'assets/images/template_blue.jpg'),
                            customRadioListTile(context, '模板3', 'template3', _selectedTemplate, (value) {
                              setState(() {
                                _selectedTemplate = value as String?;
                                widget.selectedTemplateName = "模板3";
                              });
                              widget.onChanged?.call(_selectedTemplate);
                            }, 'assets/images/template_color.jpg'),
                            customRadioListTile(context, '模板4', 'template4', _selectedTemplate, (value) {
                              setState(() {
                                _selectedTemplate = value as String?;
                                widget.selectedTemplateName = "模板4";
                              });
                              widget.onChanged?.call(_selectedTemplate);
                            }, 'assets/images/template_pink.jpg'),
                            customRadioListTile(context, '模板5', 'template5', _selectedTemplate, (value) {
                              setState(() {
                                _selectedTemplate = value as String?;
                                widget.selectedTemplateName = "模板5";
                              });
                              widget.onChanged?.call(_selectedTemplate);
                            }, 'assets/images/template_white.jpg'),
                            customRadioListTile(context, '模板6', 'template6', _selectedTemplate, (value) {
                              setState(() {
                                _selectedTemplate = value as String?;
                                widget.selectedTemplateName = "模板6";
                              });
                              widget.onChanged?.call(_selectedTemplate);
                            }, 'assets/images/template_yellow.jpg'),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Color.fromRGBO(235, 236, 219, 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.selectedTemplateName ?? '請選擇模板',
                  style: TextStyle(color: Colors.black, fontSize: ScreenUtil().setSp(80),),
                ),
                SizedBox(width: ScreenUtil().setWidth(8)),
                Icon(_showOptions ? null : Icons.arrow_drop_down_rounded, color:Color.fromRGBO(93, 88, 88, 1)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

Widget customRadioListTile(BuildContext context, String title, String value, String? selectedTemplate, Function(String)? onChanged, String imagePath) {
  return Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: () {
        if (onChanged != null) {
          onChanged(value); // 更新選中值
          _TemplateDropdownState? dropdownState = context.findAncestorStateOfType<_TemplateDropdownState>();
          dropdownState?.setState(() {
            dropdownState?._selectedTemplate = value as String?; // 設置選中的模板
            dropdownState?.widget.selectedTemplateName = title; // 更新選中模板的名稱
          });
        }
        Navigator.of(context).pop();
      },
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Radio(
                value: value,
                groupValue: selectedTemplate,
                onChanged: onChanged != null ? (newValue) => onChanged(newValue as String) : null,
                activeColor: Color.fromRGBO(80, 78, 57, 1),
              ),
              Text(title),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  alignment: Alignment.center,
                  child: Image.asset(
                    imagePath,
                    width: ScreenUtil().setWidth(500),
                    height: ScreenUtil().setHeight(200),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
