import 'package:plant_project/other_dictionary.dart';
import 'package:plant_project/menu.dart';
import 'package:plant_project/other_outcome.dart';
import 'package:plant_project/other_test_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/*功能選單頁面*/
class OtherFunctionPage extends StatelessWidget {
  const OtherFunctionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/other_background.png"),
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
                    MaterialPageRoute(builder: (context) => MenuPage()),//跳轉至首頁
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
              top: ScreenUtil().setHeight(380),
              left: ScreenUtil().setWidth(130),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DictionaryPage()),//跳轉至圖鑑頁面
                  );
                },
                child: Container(
                  width: ScreenUtil().setWidth(1400),
                  height: ScreenUtil().setHeight(320),
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(211, 216, 190, 1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Center(
                    child: Text(
                      '植 物 圖 鑑',
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(90),
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: ScreenUtil().setHeight(780),
              left: ScreenUtil().setWidth(130),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TestMenuPage()),//跳轉至課堂評量選單頁面
                  );
                },
                child: Container(
                  width: ScreenUtil().setWidth(1400),
                  height: ScreenUtil().setHeight(320),
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(211, 216, 190, 1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Center(
                    child: Text(
                      '課 堂 評 量',
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(90),
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: ScreenUtil().setHeight(1180),
              left: ScreenUtil().setWidth(130),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => OutcomePage()),//跳轉至課堂回饋頁面
                  );
                },
                child: Container(
                  width: ScreenUtil().setWidth(1400),
                  height: ScreenUtil().setHeight(320),
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(211, 216, 190, 1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Center(
                    child: Text(
                      '課 堂 回 饋',
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(90),
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: ScreenUtil().setWidth(600),
              left: ScreenUtil().setHeight(150),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DictionaryPage()),//跳轉至圖鑑頁面
                  );
                },
                child: Container(
                  width: ScreenUtil().setWidth(300),
                  height: ScreenUtil().setHeight(300),
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(241, 243, 235, 1),
                    shape: BoxShape.circle
                  ),
                  child: Image.asset(
                    "assets/images/dictionary_icon.png",
                    width: ScreenUtil().setWidth(200),
                    height: ScreenUtil().setHeight(150),
                  ),
                ),
              ),
            ),
            Positioned(
              top: ScreenUtil().setWidth(1230),
              left: ScreenUtil().setHeight(150),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TestMenuPage()),//跳轉至課堂評量選單頁面
                  );
                },
                child: Container(
                  width: ScreenUtil().setWidth(300),
                  height: ScreenUtil().setHeight(300),
                  decoration: BoxDecoration(
                      color: Color.fromRGBO(241, 243, 235, 1),
                      shape: BoxShape.circle
                  ),
                  child: Image.asset(
                    "assets/images/test_icon.png",
                    width: ScreenUtil().setWidth(200),
                    height: ScreenUtil().setHeight(150),
                  ),
                ),
              ),
            ),
            Positioned(
              top: ScreenUtil().setWidth(1860),
              left: ScreenUtil().setHeight(150),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => OutcomePage()),//跳轉至課堂回饋頁面
                  );
                },
                child: Container(
                  width: ScreenUtil().setWidth(300),
                  height: ScreenUtil().setHeight(300),
                  decoration: BoxDecoration(
                      color: Color.fromRGBO(241, 243, 235, 1),
                      shape: BoxShape.circle
                  ),
                  child: Image.asset(
                    "assets/images/outcome_icon.png",
                    width: ScreenUtil().setWidth(200),
                    height: ScreenUtil().setHeight(150),
                  ),
                ),
              ),
            ),
            Positioned(
              top: ScreenUtil().setWidth(730),
              right: ScreenUtil().setWidth(60),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DictionaryPage()),//跳轉至圖鑑頁面
                  );
                },
                child: Image.asset(
                  "assets/images/arrow1.png",
                  width: ScreenUtil().setWidth(400),
                  height: ScreenUtil().setHeight(150),
                ),
              ),
            ),
            Positioned(
              top: ScreenUtil().setWidth(1370),
              right: ScreenUtil().setWidth(60),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TestMenuPage()),//跳轉至課堂評量選單頁面
                  );
                },
                child: Image.asset(
                  "assets/images/arrow1.png",
                  width: ScreenUtil().setWidth(400),
                  height: 50,
                ),
              ),
            ),
            Positioned(
              top: ScreenUtil().setWidth(1990),
              right: ScreenUtil().setWidth(60),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => OutcomePage()),//跳轉至課堂回饋
                  );
                },
                child: Image.asset(
                  "assets/images/arrow1.png",
                  width: ScreenUtil().setWidth(400),
                  height: ScreenUtil().setHeight(150),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

