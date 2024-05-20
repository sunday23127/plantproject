import 'package:plant_project/login.dart';
import 'package:plant_project/otherfunction.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:plant_project/plant_introduce.dart';
import 'dart:ui';

/*圖鑑頁面*/
class DictionaryPage extends StatefulWidget {
  const DictionaryPage({super.key});

  @override
  _DictionaryPageState createState() => _DictionaryPageState();
}

class _DictionaryPageState extends State<DictionaryPage> {
  bool showAllPlants = true;
  String category = '';
  String _searchKeyword = '';
  late TextEditingController _searchController;
  String _selectedItem = '分類';
  List<String> _dropDownItems = ['分類'];
  late TextEditingController _addItemController;
  List<String> selectedPlants = [];
  List<String> MyPlants = [];
  bool isMy = false;


  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchKeyword = '';

    // 初始化 _addItemController
    _addItemController = TextEditingController();

    _fetchDropdownOptions();
    _searchMyPlant();
  }

  //取得分類的下拉選項
  void _fetchDropdownOptions() async {
    // 從 Firebase 獲取下拉選單選項
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('學生')
        .doc(studentSchool)
        .collection(studentID)
        .doc('植物分類')
        .get();

    if (snapshot.exists) {
      Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?; // 進行類型轉換
      if (data != null && data.containsKey('植物分類')) {
        List<dynamic> categories = data['植物分類'];
        List<String> options = categories.map((category) => category.toString()).toList();
        setState(() {
          _dropDownItems.addAll(options);
          print(_dropDownItems);
        });
      } else {
        // 如果文檔不存在或者 "categories" 字段不存在，則將下拉選單選項置為空列表
        setState(() {
          _dropDownItems = ['分類'];
        });
      }
    } else {
      // 如果文檔不存在，則將下拉選單選項置為空列表
      setState(() {
        _dropDownItems = ['分類'];
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _addItemController.dispose();
    super.dispose();
  }

  //畫面呈現
  @override
  Widget build(BuildContext context) {
    //getData();
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/dictionary_background.png"), //背景
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
              left: ScreenUtil().setWidth(250),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  height: ScreenUtil().setHeight(120),
                  width: ScreenUtil().setWidth(1000),
                  child: TextField(
                    onChanged: (value) {
                      if(value == "") {
                        setState(() {
                          _searchKeyword = value;
                        });
                      }
                    },
                    controller: _searchController,
                    decoration: InputDecoration( //搜尋框
                      filled: true,
                      fillColor: Color.fromRGBO(246, 247, 242, 1),
                      hintText: '請輸入想搜尋的植物',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
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
              top: ScreenUtil().setHeight(115),
              left: ScreenUtil().setWidth(1300),
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _searchKeyword = _searchController.text;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: Color.fromRGBO(246, 247, 242, 1),
                    foregroundColor: Color.fromRGBO(246, 247, 242, 1),
                    shape: CircleBorder(), //搜尋按鈕
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    child: Icon(Icons.search, size: ScreenUtil().setSp(120), color: Colors.black),
                  ),
                ),
            ),
            Positioned(
              top: ScreenUtil().setHeight(280),//30,
              left: ScreenUtil().setWidth(60),//18,
              child: ElevatedButton(
                onPressed: () {
                  if(_selectedItem == '分類'){
                    _showPlantSelectionDialog();
                  }else{
                    _showPlantSelectionDialogforCategory();
                  }
                },
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: Color.fromRGBO(246, 247, 242, 1),
                  foregroundColor: Color.fromRGBO(246, 247, 242, 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  fixedSize: Size(ScreenUtil().setWidth(400),ScreenUtil().setHeight(100)),
                ),
                child: Text("選取",
                  style: TextStyle(color: Colors.black, fontSize: ScreenUtil().setSp(80)),
                ),
              ),
            ),
            Positioned(
              top: ScreenUtil().setHeight(290), 
              left: ScreenUtil().setWidth(480),
              child: DropdownExample(
                onChanged: (value) {
                  setState(() {
                    if (value == '全部') {
                      showAllPlants = true;
                    } else if (value == '我的') {
                      showAllPlants = false;
                    }
                  });
                },
              ),
            ),
            Positioned(
              top: ScreenUtil().setHeight(290), 
              left: ScreenUtil().setWidth(960),
              child: DropdownExample2(
                onChanged: (value) {
                  setState(() {
                    if (value != '分類') {
                      _selectedItem = value;
                      category = value;
                    }
                    else if (value == '分類') {
                      _selectedItem = value;
                      category = "";
                    }
                  });
                },
                dropDownItems: _dropDownItems,
                studentId: studentClass + studentNum,
                selectedItem: _selectedItem,
              ),
            ),
            Positioned(
              top: ScreenUtil().setHeight(280),
              left: ScreenUtil().setWidth(1370),
              child: ElevatedButton(
                onPressed: _showAddCategoryDialog,
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: Color.fromRGBO(246, 247, 242, 1),
                  foregroundColor: Color.fromRGBO(246, 247, 242, 1),
                  shape: CircleBorder(), //新增分類按鈕
                ),
                child: Align(
                  alignment: Alignment.center,
                  child: Icon(Icons.add, size: ScreenUtil().setSp(100), color: Colors.black),
                ),
              ),
            ),
            Positioned(
              top: ScreenUtil().setHeight(450), 
              left: 0,
              right: 0,
              bottom: ScreenUtil().setHeight(220),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: plantList(context, showAllPlants, category)
              ),
            ),
            Positioned(
              top: ScreenUtil().setHeight(2000),
              left: ScreenUtil().setWidth(550),
              right: ScreenUtil().setWidth(550),
              child: category != '' ? ElevatedButton( // 根據 DropdownExample2 的值来决定是否顯示按鈕
                onPressed: () {
                  _showDeleteCategoryDialog();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromRGBO(255, 255, 247, 1.0),
                  foregroundColor: Color.fromRGBO(246, 247, 242, 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  fixedSize: Size(ScreenUtil().setWidth(400),ScreenUtil().setHeight(100)),
                ),
                child: Text("刪除分類",
                  style: TextStyle(color: Colors.black),
                ),
              ) : SizedBox(),
            ),
          ],
        ),
      ),
    );
  }
  //顯示植物列表(全部或掃描過的或是分類)
  Widget plantList(BuildContext context, bool showAllPlants, String category) {
    print('showAllPlants: $showAllPlants');
    if (showAllPlants && category == "") {
      print('all');
      return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('學校')
            .doc(studentSchool)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Color.fromRGBO(167, 173, 147, 1),));
          }

          final DocumentSnapshot? querySnapshot = snapshot.data;
          if (querySnapshot == null || !querySnapshot.exists) {
            return Container(
              margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(220),vertical: ScreenUtil().setHeight(100)), // 添加 margin
              child: Text(
                '沒有植物',
                style: TextStyle(fontSize: ScreenUtil().setSp(100)),
              ),
            );
          }

          final Map<String, dynamic>? data = querySnapshot.data() as Map<String, dynamic>?;

          if (data == null || !data.containsKey('植物列表')) {
            return Container(
              margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(220),vertical: ScreenUtil().setHeight(100)), // 添加 margin
              child: Text(
                '沒有植物',
                style: TextStyle(fontSize: ScreenUtil().setSp(100)),
              ),
            );
          }

          final List<dynamic>? plantNames = data['植物列表'] as List<dynamic>?;

          if (plantNames == null || plantNames.isEmpty) {
            return Container(
              margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(220),vertical: ScreenUtil().setHeight(100)), // 添加 margin
              child: Text(
                '沒有植物',
                style: TextStyle(fontSize: ScreenUtil().setSp(100)),
              ),
            );
          }

          // 過濾植物列表
          final filteredPlants = plantNames.where((plantName) {
            final name = (plantName as String).toLowerCase();
            return name.contains(_searchKeyword.toLowerCase());
          }).toList();


          return GridView.builder(
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 20.0,
              crossAxisSpacing: 10.0,
              childAspectRatio: 1.0,
            ),
            itemCount: filteredPlants.length,
            itemBuilder: (context, index) {
              final collection = filteredPlants[index];
              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('植物資料').where(FieldPath.documentId, isEqualTo: collection).snapshots(),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Color.fromRGBO(167, 173, 147, 1)),);
                  }

                  final QuerySnapshot? querySnapshot = snapshot.data;
                  if (querySnapshot == null || querySnapshot.docs.isEmpty) {
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(220),vertical: ScreenUtil().setHeight(100)), // 添加 margin
                      child: Text(
                        '沒有植物',
                        style: TextStyle(fontSize: ScreenUtil().setSp(100)),
                      ),
                    );
                  }

                  final List<DocumentSnapshot> documents = querySnapshot.docs;

                  final Map<String, dynamic> data = documents.first.data() as Map<String, dynamic>;
                  var allimg = data['圖片'];
                  var name = data['中文名稱'];
                  return GestureDetector(
                    onTap: () {
                      MyPlants.contains(name) ? isMy = true : isMy = false;
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PlantIntroducePage(plantName: name,isMy: isMy)),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(246, 247, 242, 1),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          MyPlants.contains(name) ?
                          ClipOval( child:Image.network(allimg, width: ScreenUtil().setWidth(340), height: ScreenUtil().setHeight(210),fit: BoxFit.cover,))
                              :
                          ClipOval(
                            child:ImageFiltered(
                              imageFilter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                              child: Image.network(allimg, width: ScreenUtil().setWidth(340), height: ScreenUtil().setHeight(210),fit: BoxFit.cover,),
                            ),
                          ),
                          SizedBox(height: ScreenUtil().setHeight(10)),
                          Text(name),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      );
    } else if(showAllPlants == false && category == "") {
      return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('學生')
            .doc(studentSchool)
            .collection(studentID)
            .doc('掃描資料')
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Color.fromRGBO(167, 173, 147, 1),));
          }

          final DocumentSnapshot? querySnapshot = snapshot.data;
          if (querySnapshot == null || !querySnapshot.exists) {
            return Container(
              margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(220),vertical: ScreenUtil().setHeight(100)), // 添加 margin
              child: Text(
                '快去蒐集自己的植物吧!',
                style: TextStyle(fontSize: ScreenUtil().setSp(100)),
              ),
            );
          }

          final Map<String, dynamic>? data = querySnapshot.data() as Map<String, dynamic>?;

          if (data == null || !data.containsKey('植物名稱')) {
            return Container(
              margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(220),vertical: ScreenUtil().setHeight(100)), // 添加 margin
              child: Text(
                '快去蒐集自己的植物吧!',
                style: TextStyle(fontSize: ScreenUtil().setSp(100)),
              ),
            );
          }

          final List<dynamic>? plantNames = data['植物名稱'] as List<dynamic>?;

          if (plantNames == null || plantNames.isEmpty) {
            return Container(
              margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(220),vertical: ScreenUtil().setHeight(100)), // 添加 margin
              child: Text(
                '快去蒐集自己的植物吧!',
                style: TextStyle(fontSize: ScreenUtil().setSp(100)),
              ),
            );
          }

          // 過濾植物列表
          final filteredPlants = plantNames.where((plantName) {
            final name = (plantName as String).toLowerCase();
            return name.contains(_searchKeyword.toLowerCase());
          }).toList();


          return GridView.builder(
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 20.0,
              crossAxisSpacing: 10.0,
              childAspectRatio: 1.0,
            ),
            itemCount: filteredPlants.length,
            itemBuilder: (context, index) {
              final collection = filteredPlants[index];
              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('植物資料').where(FieldPath.documentId, isEqualTo: collection).snapshots(),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Color.fromRGBO(167, 173, 147, 1)),);
                  }

                  final QuerySnapshot? querySnapshot = snapshot.data;
                  if (querySnapshot == null || querySnapshot.docs.isEmpty) {
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(220),vertical: ScreenUtil().setHeight(100)), // 添加 margin
                      child: Text(
                        '快去蒐集自己的植物吧!',
                        style: TextStyle(fontSize: ScreenUtil().setSp(100)),
                      ),
                    );
                  }

                  final List<DocumentSnapshot> documents = querySnapshot.docs;

                  final Map<String, dynamic> data = documents.first.data() as Map<String, dynamic>;
                  var allimg = data['圖片'];
                  var name = data['中文名稱'];
                  return GestureDetector(
                    onTap: () {
                      MyPlants.contains(name) ? isMy = true : isMy = false;
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PlantIntroducePage(plantName: name,isMy: isMy)),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(246, 247, 242, 1),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          ClipOval(child:Image.network(allimg, width: ScreenUtil().setWidth(340), height: ScreenUtil().setHeight(210),fit: BoxFit.cover,)),
                          SizedBox(height: ScreenUtil().setHeight(10)),
                          Text(name),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      );
    }else{
      return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('學生')
            .doc(studentSchool)
            .collection(studentID)
            .doc('植物分類')
            .collection(category)
            .doc(category+'植物')
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Color.fromRGBO(167, 173, 147, 1)),);
          }

          final DocumentSnapshot? querySnapshot = snapshot.data;
          if (querySnapshot == null || !querySnapshot.exists) {
            return Container(
              margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(350),vertical: ScreenUtil().setHeight(100)), // 添加 margin
              child: Text(
                '此分類還沒有植物\n   快點新增吧!',
                style: TextStyle(fontSize: ScreenUtil().setSp(100)),
              ),
            );
          }

          final Map<String, dynamic>? data = querySnapshot.data() as Map<String, dynamic>?;

          if (data == null || !data.containsKey('植物名稱')) {
            return Text('No "植物名稱" array available');
          }

          final List<dynamic>? plantNames = data['植物名稱'] as List<dynamic>?;

          if (plantNames == null || plantNames.isEmpty) {
            return Container(
              margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(350),vertical: ScreenUtil().setHeight(100)), // 添加 margin
              child: Text(
                '此分類還沒有植物\n   快點新增吧!',
                style: TextStyle(fontSize: ScreenUtil().setSp(100)),
              ),
            );
          }

          // 過濾植物列表
          final filteredPlants = plantNames.where((plantName) {
            final name = (plantName as String).toLowerCase();
            return name.contains(_searchKeyword.toLowerCase());
          }).toList();


          return GridView.builder(
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 20.0,
              crossAxisSpacing: 10.0,
              childAspectRatio: 1.0,
            ),
            itemCount: filteredPlants.length,
            itemBuilder: (context, index) {
              final collection = filteredPlants[index];
              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('植物資料').where(FieldPath.documentId, isEqualTo: collection).snapshots(),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Color.fromRGBO(167, 173, 147, 1),));
                  }

                  final QuerySnapshot? querySnapshot = snapshot.data;
                  if (querySnapshot == null || querySnapshot.docs.isEmpty) {
                    return Text('No data available');
                  }

                  final List<DocumentSnapshot> documents = querySnapshot.docs;

                  final Map<String, dynamic> data = documents.first.data() as Map<String, dynamic>;
                  var allimg = data['圖片'];
                  var name = data['中文名稱'];
                  return GestureDetector(
                    onTap: () {
                      MyPlants.contains(name) ? isMy = true : isMy = false;
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PlantIntroducePage(plantName: name,isMy: isMy)),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(246, 247, 242, 1),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          ClipOval(child:Image.network(allimg, width: ScreenUtil().setWidth(340), height: ScreenUtil().setHeight(210),fit: BoxFit.cover,)),
                          SizedBox(height: ScreenUtil().setHeight(10)),
                          Text(name),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      );
    }
  }

  //新增分類
  void _showAddCategoryDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Color.fromRGBO(210, 215, 185, 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0), 
            ),
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  '新 增 植 物 分 類',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: ScreenUtil().setSp(80),
                  ),
                ),
                SizedBox(height: ScreenUtil().setHeight(60)),
                Row(
                  children: [
                    Text(
                      '名 稱',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: ScreenUtil().setSp(80),
                      ),
                    ),
                    SizedBox(width: ScreenUtil().setWidth(50)),
                    Expanded(
                      child: TextField(
                        controller: _addItemController,
                        decoration: InputDecoration(
                          hintText: '請輸入要新增的分類',
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color.fromRGBO(229, 232, 216, 1)), 
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color.fromRGBO(229, 232, 216, 1)), 
                          ),
                          fillColor: Color.fromRGBO(229, 232, 216, 1), 
                          filled: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
                        ),
                      ),
                    ),
                  ],
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
                        String newItem = _addItemController.text.trim();
                        if (newItem.isNotEmpty &&
                            !_dropDownItems.contains(newItem)) {
                          // 將新選項儲存到 Firebase 中
                          await FirebaseFirestore.instance
                              .collection('學生')
                              .doc(studentSchool)
                              .collection(studentID)
                              .doc('植物分類')
                              .set({
                            '植物分類': FieldValue.arrayUnion([newItem])
                          }, SetOptions(merge: true));
                          _addItemController.text = "";
                          setState(() {
                            _dropDownItems.add(newItem);
                            _selectedItem = newItem;
                            category = newItem;
                          });
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

  //選取植物加入分類-選植物(顯示掃描過的)
  void _showPlantSelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Color.fromRGBO(243, 243, 231, 1), 
              title: Align(
                alignment: Alignment.center,
                child: Text('選 擇 植 物', textAlign: TextAlign.center,),
              ),
              content: Container(
                width: double.maxFinite,
                height: ScreenUtil().setHeight(800),
                child: StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                          .collection('學生')
                          .doc(studentSchool)
                          .collection(studentID)
                          .doc('掃描資料')
                          .snapshots(),
                  builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      //return CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Color.fromRGBO(167, 173, 147, 1)),);
                    }

                    final DocumentSnapshot? querySnapshot = snapshot.data;
                    if (querySnapshot == null || !querySnapshot.exists) {
                      return Container(
                        margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30),vertical: ScreenUtil().setHeight(100)), // 添加 margin
                        child: Text(
                          '要蒐集自己的植物後\n才能加入分類喔!',
                          style: TextStyle(fontSize: ScreenUtil().setSp(70)),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }

                    final Map<String, dynamic>? data = querySnapshot.data() as Map<String, dynamic>?;
                    if (data == null || !data.containsKey('植物名稱')) {
                      return Container(
                        margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30),vertical: ScreenUtil().setHeight(100)), // 添加 margin
                        child: Text(
                          '要蒐集自己的植物後\n才能加入分類喔!',
                          style: TextStyle(fontSize: ScreenUtil().setSp(70)),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }

                    final List<dynamic>? plantCategories = data['植物名稱'];

                    return ListView.separated(
                      padding: EdgeInsets.symmetric(vertical: ScreenUtil().setHeight(10)),
                      separatorBuilder: (BuildContext context, int index) => SizedBox(height: ScreenUtil().setHeight(10)),
                      itemCount: plantCategories?.length ?? 0, // 更新itemCount以反映陣列的長度
                      itemBuilder: (context, index) {
                          final collection = plantCategories?[index];
                          return StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance.collection('植物資料').where(FieldPath.documentId, isEqualTo: collection).snapshots(),
                          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            }

                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Color.fromRGBO(167, 173, 147, 1)),);
                            }

                            final QuerySnapshot? querySnapshot = snapshot.data;
                            if (querySnapshot == null || querySnapshot.docs.isEmpty) {
                              return Container(
                                margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30),vertical: ScreenUtil().setHeight(100)), // 添加 margin
                                child: Text(
                                  '要蒐集自己的植物後\n才能加入分類喔!',
                                  style: TextStyle(fontSize: ScreenUtil().setSp(80)),
                                ),
                              );
                            }

                            final List<DocumentSnapshot> documents = querySnapshot.docs;

                            final Map<String, dynamic> data = documents.first.data() as Map<
                                String,
                                dynamic>;
                            var allimg = data['圖片'];
                            var plantName = data['中文名稱'];

                            var isSelected = selectedPlants.contains(plantName);

                            return Container(
                              //color: Color.fromRGBO(211, 216, 190, 1),
                              child: ListTile(
                                contentPadding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(10)),
                                title: Text(plantName),
                                leading: ClipOval(
                                  child: Image.network(
                                    allimg, // 使用你從植物資料中獲取的圖片URL
                                    width: ScreenUtil().setWidth(210), // 調整圖片寬度
                                    height: ScreenUtil().setHeight(130), // 調整圖片高度
                                    fit: BoxFit.cover, // 調整圖片顯示方式
                                  ),
                                ),
                                trailing: Checkbox(
                                  value: isSelected,
                                  activeColor: Color.fromRGBO(80, 78, 57, 1),
                                  onChanged: (newValue) {
                                    setState(() {
                                      if (newValue!) {
                                        selectedPlants.add(plantName);
                                      } else {
                                        selectedPlants.remove(plantName);
                                      }
                                    });
                                  },
                                ),
                              ),
                            );
                          }
                        );
                      },
                    );
                  },
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10), 
              ),
              actions: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: Color.fromRGBO(246, 247, 242, 1),
                        foregroundColor: Color.fromRGBO(246, 247, 242, 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        selectedPlants = [];
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        '取 消',
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(width: ScreenUtil().setWidth(100)), 
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: Color.fromRGBO(246, 247, 242, 1),
                        foregroundColor: Color.fromRGBO(246, 247, 242, 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        print('Selected Plants: $selectedPlants');
                        if(selectedPlants.isEmpty){
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                backgroundColor: Color.fromRGBO(243, 243, 231, 1),
                                content: Text(
                                    '尚 未 選 擇 任 何 植 物',
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
                                          backgroundColor: Color.fromRGBO(246, 247, 242, 1),
                                          foregroundColor: Color.fromRGBO(246, 247, 242, 1),
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
                        }else{
                          Navigator.of(context).pop();
                          _showAddPlantCategoryDialog();
                        }
                      },
                      child: Text(
                        '新 增 分 類',
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
      },
    );
  }

  //選取植物從分類中移除
  void _showPlantSelectionDialogforCategory() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Color.fromRGBO(243, 243, 231, 1), 
              title: Align(
                alignment: Alignment.center,
                child: Text('選 擇 植 物', textAlign: TextAlign.center,),
              ),
              content: Container(
                width: double.maxFinite,
                height: ScreenUtil().setHeight(800),
                child: StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('學生')
                      .doc(studentSchool)
                      .collection(studentID)
                      .doc('植物分類')
                      .collection(_selectedItem)
                      .doc(_selectedItem+'植物')
                      .snapshots(),
                  builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      //return CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Color.fromRGBO(167, 173, 147, 1)),);
                    }

                    final DocumentSnapshot? querySnapshot = snapshot.data;
                    if (querySnapshot == null || !querySnapshot.exists) {
                      return Container(
                        margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30),vertical: ScreenUtil().setHeight(100)), // 添加 margin
                        child: Text(
                          '這個分類裡面還沒有植物喔!',
                          style: TextStyle(fontSize: ScreenUtil().setSp(70)),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }

                    final Map<String, dynamic>? data = querySnapshot.data() as Map<String, dynamic>?;
                    if (data == null || !data.containsKey('植物名稱')) {
                      return Text('Field "植物分類" does not exist');
                    }

                    final List<dynamic>? plantCategories = data['植物名稱'];

                    if (plantCategories != null && plantCategories.isEmpty) {
                      return Container(
                        margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30),vertical: ScreenUtil().setHeight(100)), // 添加 margin
                        child: Text(
                          '這個分類裡面還沒有植物喔!',
                          style: TextStyle(fontSize: ScreenUtil().setSp(70)),
                        ),
                      );
                    }
                    
                    return ListView.separated(
                      padding: EdgeInsets.symmetric(vertical: ScreenUtil().setHeight(10)),
                      separatorBuilder: (BuildContext context, int index) => SizedBox(height: ScreenUtil().setHeight(10)),
                      itemCount: plantCategories?.length ?? 0, // 更新itemCount以反映陣列的長度
                      itemBuilder: (context, index) {
                        final collection = plantCategories?[index];
                        return StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance.collection('植物資料').where(FieldPath.documentId, isEqualTo: collection).snapshots(),
                            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                              if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              }

                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Color.fromRGBO(167, 173, 147, 1)),);
                              }

                              final QuerySnapshot? querySnapshot = snapshot.data;
                              if (querySnapshot == null || querySnapshot.docs.isEmpty) {
                                return Container(
                                  margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30),vertical: ScreenUtil().setHeight(100)), // 添加 margin
                                  child: Text(
                                    '這個分類裡面還沒有植物喔!',
                                    style: TextStyle(fontSize: ScreenUtil().setSp(70)),
                                  ),
                                );
                              }

                              final List<DocumentSnapshot> documents = querySnapshot.docs;

                              final Map<String, dynamic> data = documents.first.data() as Map<
                                  String,
                                  dynamic>;
                              var allimg = data['圖片'];
                              var plantName = data['中文名稱'];

                              var isSelected = selectedPlants.contains(plantName);

                              return Container(
                                //color: Color.fromRGBO(211, 216, 190, 1),
                                child: ListTile(
                                  contentPadding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(10)),
                                  title: Text(plantName),
                                  leading: ClipOval(
                                    child: Image.network(
                                      allimg, // 使用你從植物資料中獲取的圖片URL
                                      width: ScreenUtil().setWidth(210), // 調整圖片寬度
                                      height: ScreenUtil().setHeight(130), // 調整圖片高度
                                      fit: BoxFit.cover, // 調整圖片顯示方式
                                    ),
                                  ),
                                  trailing: Checkbox(
                                    value: isSelected,
                                    activeColor: Color.fromRGBO(80, 78, 57, 1),
                                    onChanged: (newValue) {
                                      setState(() {
                                        if (newValue!) {
                                          selectedPlants.add(plantName);
                                        } else {
                                          selectedPlants.remove(plantName);
                                        }
                                      });
                                    },
                                  ),
                                ),
                              );
                            }
                        );
                      },
                    );
                  },
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10), 
              ),
              actions: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: Color.fromRGBO(246, 247, 242, 1),
                        foregroundColor: Color.fromRGBO(246, 247, 242, 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        selectedPlants = [];
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        '取 消',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: ScreenUtil().setSp(50),
                        ),
                      ),
                    ),
                    SizedBox(width: ScreenUtil().setWidth(50)), 
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: Color.fromRGBO(246, 247, 242, 1),
                        foregroundColor: Color.fromRGBO(246, 247, 242, 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        print('Selected Plants: $selectedPlants');
                        if(selectedPlants.isEmpty){
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                backgroundColor: Color.fromRGBO(243, 243, 231, 1),
                                content: Text('尚 未 選 擇 任 何 植 物'),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                actions: <Widget>[
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      elevation: 0,
                                      backgroundColor: Color.fromRGBO(246, 247, 242, 1),
                                      foregroundColor: Color.fromRGBO(246, 247, 242, 1),
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
                              );
                            },
                          );
                        }else{
                          Navigator.of(context).pop();
                          _deletePlantInCategory(category,selectedPlants);
                        }
                      },
                      child: Text(
                        '從 分 類 中 移 除',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: ScreenUtil().setSp(50),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  //選取植物加入分類-選分類(顯示掃描過的)
  void _showAddPlantCategoryDialog() {
    String? selectedCategory;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Color.fromRGBO(243, 243, 231, 1),
              title: Align(
                alignment: Alignment.center,
                child: Text('選 擇 分 類', textAlign: TextAlign.center,),
              ),
              content: Container(
                width: double.maxFinite,
                height: ScreenUtil().setHeight(800),
                child: StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('學生')
                      .doc(studentSchool)
                      .collection(studentID)
                      .doc('植物分類')
                      .snapshots(), 
                  builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Color.fromRGBO(167, 173, 147, 1)),),
                      );
                    }

                    final DocumentSnapshot? querySnapshot = snapshot.data;
                    if (!querySnapshot!.exists) {
                      return Text('No data available');
                    }

                    final List<dynamic> documents = querySnapshot['植物分類'];

                    return ListView.separated(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      separatorBuilder: (BuildContext context, int index) => SizedBox(height: ScreenUtil().setHeight(10)),
                      itemCount: documents.length,
                      itemBuilder: (BuildContext context, int index) {
                        final String plantCategory = documents[index] as String;

                        return RadioListTile(
                          title: Text(plantCategory),
                          value: plantCategory,
                          activeColor: Color.fromRGBO(80, 78, 57, 1),
                          groupValue: selectedCategory,
                          onChanged: (newValue) {
                            setState(() {
                              selectedCategory = newValue as String?;
                            });
                          },
                        );
                      },
                    );
                  },
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              actions: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: Color.fromRGBO(246, 247, 242, 1),
                        foregroundColor: Color.fromRGBO(246, 247, 242, 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        selectedCategory = null;
                        Navigator.of(context).pop();
                        _showPlantSelectionDialog();
                      },
                      child: Text(
                        '取 消',
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(width: ScreenUtil().setWidth(200)),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: Color.fromRGBO(246, 247, 242, 1),
                        foregroundColor: Color.fromRGBO(246, 247, 242, 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        if (selectedCategory != null) {
                          String category = selectedCategory ?? '';
                          // 將 selectedPlants 中的資料儲存到 Firebase 中
                          FirebaseFirestore.instance
                              .collection('學生')
                              .doc(studentSchool)
                              .collection(studentID)
                              .doc('植物分類')
                              .collection(category)
                              .doc(category+'植物')
                              .set({
                            '植物名稱': FieldValue.arrayUnion(selectedPlants)
                          },SetOptions(merge: true)).then((_) {
                            print('Selected plants added to Firebase successfully');
                          }).catchError((error) {
                            print('Error adding selected plants to Firebase: $error');
                          });
                          selectedPlants=[];
                          Navigator.of(context).pop();
                        }else if(selectedCategory == null){
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                backgroundColor: Color.fromRGBO(243, 243, 231, 1),
                                content: Text(
                                  '尚 未 選 擇 任 何 分 類',
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
                                          backgroundColor: Color.fromRGBO(246, 247, 242, 1),
                                          foregroundColor: Color.fromRGBO(246, 247, 242, 1),
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
                        }else{
                          Navigator.of(context).pop();
                        }
                      },
                      child: Text(
                        '確 認',
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
      },
    );
  }

  //刪除分類的確認視窗
  void _showDeleteCategoryDialog() {
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
              color: Color.fromRGBO(209, 214, 182, 1),
            ),
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  '確 定 要 刪 除 此 分 類 ？',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
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
                        backgroundColor: Color.fromRGBO(246, 247, 242, 1),
                        foregroundColor: Color.fromRGBO(246, 247, 242, 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        '取 消',
                        style: TextStyle(
                            color: Colors.black
                        ),
                      ),
                    ),
                    SizedBox(width: ScreenUtil().setWidth(200)),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: Color.fromRGBO(246, 247, 242, 1),
                        foregroundColor: Color.fromRGBO(246, 247, 242, 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        _deleteCategory(category);
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        '確 定',
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

  //刪除分類的firebase函式(整個分類刪除)
  void _deleteCategory(String categoryId) async{
    // 獲取到Firebase Firestore的instance
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // 在'categories'集合中根據分類的ID刪除文檔
    firestore
        .collection('學生')
        .doc(studentSchool)
        .collection(studentID)
        .doc('植物分類')
        .collection(category)
        .doc(category+'植物')
        .delete()
        .then((_) {
      print('分類刪除成功！');
    }).catchError((error) {
      print('分類刪除失败：$error');
    });

    // 獲取學生文檔的引用
    DocumentReference studentRef = firestore
        .collection('學生')
        .doc(studentSchool)
        .collection(studentID)
        .doc('植物分類');

    // 讀取學生文檔
    DocumentSnapshot studentSnapshot = await studentRef.get();

    if (studentSnapshot.exists && studentSnapshot.data() != null) {
      // 將資料類型明確轉換為 Map<String, dynamic>
      Map<String, dynamic> data = studentSnapshot.data() as Map<String, dynamic>;

      // 檢查植物分類字段是否存在且不為 null
      if (data.containsKey('植物分類') && data['植物分類'] != null) {
        // 獲取文檔中的植物分類陣列
        List<dynamic> categories = List.from(data['植物分類']);

        // 删除陣列中符合 category 的值
        categories.removeWhere((item) => item == category);

        // 更新文檔
        await studentRef.update({'植物分類': categories});

        print('已從文檔中刪除分類 $category 並更新植物分類陣列！');
        setState(() {
          int indexToRemove = _dropDownItems.indexWhere((item) => item == category);
          if (indexToRemove != -1) {
            // 如果被刪除的項目是當前選擇的項目，則將選擇重置為 '分類'
            if (_selectedItem == category) {
              _selectedItem = '分類';
              category = "";
            }
            print("Before removal: $_dropDownItems");
            _dropDownItems.removeAt(indexToRemove);
            print("After removal: $_dropDownItems");
            print(_selectedItem);
            print(_dropDownItems);
          }
        });
      } else {
        print('找不到植物分類字段或字段值為 null！');
      }
    } else {
      print('找不到學生文檔或文檔不存在！');
    }
  }

  //刪除分類的firebase函式(只刪除分類中的植物)
  void _deletePlantInCategory(String categoryId, List<String> selectedItems) async {
    // 獲取到Firebase Firestore的instance
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    firestore
        .collection('學生')
        .doc(studentSchool)
        .collection(studentID)
        .doc('植物分類')
        .collection(categoryId)
        .doc(categoryId + '植物')
        .get()
        .then((docSnapshot) {
      if (docSnapshot.exists) {
        Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
        List<dynamic> plantNames = data['植物名稱'];

        // 根據_selectedItem中的值，刪除植物名稱中符合的項目
        selectedItems.forEach((item) {
          plantNames.remove(item);
        });

        // 更新 '植物名稱' 欄位
        docSnapshot.reference.update({'植物名稱': plantNames}).then((_) {
          print('植物刪除成功！');
        }).catchError((error) {
          print('植物刪除失败：$error');
        });
      } else {
        print('文件不存在！');
      }
    }).catchError((error) {
      print('發生錯誤：$error');
    });
  }

  //把掃描過的植物存到MyPlants List
  void _searchMyPlant() async {
    // 获取到Firebase Firestore的instance
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      // 通過監聽文檔的快照来獲取資料
      firestore
          .collection('學生')
          .doc(studentSchool)
          .collection(studentID)
          .doc('掃描資料')
          .snapshots()
          .listen((DocumentSnapshot snapshot) {
        // 檢查文檔是否存在且包含資料
        if (snapshot.exists && snapshot.data() != null) {
          // 獲取植物名稱字段的值，假設它是一个陣列
          Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;

          // 檢查是否成功轉換
          if (data != null) {
            // 獲取植物名稱字段的值，假設它是一個陣列
            List<dynamic>? plantNames = data['植物名稱'];

            // 如果植物名稱有資料，則儲存到陣列中
            if (plantNames != null) {
              MyPlants = List<String>.from(plantNames);
              print('植物名稱陣列：$MyPlants');
            } else {
              // 如果植物名稱字段為空，則輸出錯誤訊息
              print('未找到植物名稱資料');
            }
          } else {
            // 輸出錯誤訊息，資料轉換失敗
            print('無法獲取文檔資料');
          }
        } else {
          // 如果文檔不存在或者不包含資料，則輸出錯誤訊息
          print('文檔不存在或者不包含資料');
        }
      });
    } catch (e) {
      // 捕獲任何異常並輸出錯誤訊息
      print('發生錯誤：$e');
    }
  }

}

//下拉選單(全部&我的)
class DropdownExample extends StatefulWidget {
  final Function(String)? onChanged;

  DropdownExample({Key? key, this.onChanged}) : super(key: key);

  @override
  _DropdownExampleState createState() => _DropdownExampleState();
}

class _DropdownExampleState extends State<DropdownExample> {
  String _selectedItem = '全部';

  @override
  Widget build(BuildContext context) {
    return Container(
        width: ScreenUtil().setWidth(450),
        height: ScreenUtil().setHeight(115),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Color.fromRGBO(246, 247, 242, 1),
        ),
    child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
        value: _selectedItem,
          onChanged: (String? newValue) {
            setState(() {
              _selectedItem = newValue!;
            });
            // 通知父组件下拉選單的更改
            widget.onChanged?.call(newValue!);
          },
          style: TextStyle(color: Colors.black, fontSize: ScreenUtil().setSp(80), fontFamily: 'FangSong'),
          dropdownColor: Color.fromRGBO(246, 247, 242, 1),
          icon: Icon(Icons.arrow_drop_down_rounded),
          iconSize: ScreenUtil().setSp(105),
          menuMaxHeight: ScreenUtil().setHeight(500),
          borderRadius: BorderRadius.circular(20),
          isExpanded: true, // 讓選單擴展至容器的寬度
          alignment: Alignment.centerRight,
          items: <String>['全部', '我的']
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

//下拉選單(分類)
class DropdownExample2 extends StatefulWidget {
  final Function(String)? onChanged;
  final List<String> dropDownItems;
  final String studentId;
  String selectedItem;

  DropdownExample2({Key? key, this.onChanged, required this.dropDownItems, required this.studentId, required this.selectedItem}) : super(key: key);

  @override
  _DropdownExample2State createState() => _DropdownExample2State(dropDownItems,studentId,selectedItem);
}

class _DropdownExample2State extends State<DropdownExample2> {

  @override
  void initState() {
    super.initState();
  }


  // 構造函數接收下拉選單選項列表
  _DropdownExample2State(List<String> dropDownItems,String studentId,String selectedItem) {
    dropDownItems = dropDownItems;
    studentId = studentId;
    selectedItem = selectedItem;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ScreenUtil().setWidth(450),
      height: ScreenUtil().setHeight(115),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Color.fromRGBO(246, 247, 242, 1),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: widget.selectedItem,
          onChanged: (String? newValue) {
            setState(() {
              widget.selectedItem = widget.dropDownItems.contains(newValue) ? newValue! : '分類';
            });
            // 通知父组件下拉選單的更改
            widget.onChanged?.call(widget.dropDownItems.contains(newValue) ? newValue! : '分類');
          },
          style: TextStyle(color: Colors.black, fontSize: ScreenUtil().setSp(80), fontFamily: 'FangSong'),
          dropdownColor: Color.fromRGBO(246, 247, 242, 1),
          icon: Icon(Icons.arrow_drop_down_rounded),
          iconSize: ScreenUtil().setSp(105),
          menuMaxHeight: ScreenUtil().setHeight(500),
          borderRadius: BorderRadius.circular(20),
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