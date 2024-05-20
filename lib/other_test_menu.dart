import 'package:plant_project/other_test_history.dart';
import 'package:plant_project/other_test_write.dart';
import 'package:plant_project/other_test_add.dart';
import 'package:plant_project/otherfunction.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/*課堂評量選單頁面*/
class TestMenuPage extends StatelessWidget {
  const TestMenuPage({super.key});

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
              top: ScreenUtil().setHeight(100),
              left: ScreenUtil().setWidth(80),
              child: GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => OtherFunctionPage()),
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
                '課堂評量',
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(110),
                  color: Colors.black,
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
                    MaterialPageRoute(builder: (context) => TestAddPage()),//跳轉至新增測驗頁面
                  );
                },
                child: Container(
                  width: ScreenUtil().setWidth(1400),
                  height: ScreenUtil().setHeight(320),
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(211, 216, 190, 1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 40.0),
                      child: Text(
                        '新 增 題 目',
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(90),
                          color: Colors.black,
                        ),
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
                    MaterialPageRoute(builder: (context) => WriteTestPage()),//跳轉至作答測驗頁面
                  );
                },
                child: Container(
                  width: ScreenUtil().setWidth(1400),
                  height: ScreenUtil().setHeight(320),
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(211, 216, 190, 1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 40.0),
                      child: Text(
                        '作 答 測 驗',
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(90),
                          color: Colors.black,
                        ),
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
                    MaterialPageRoute(builder: (context) => TestHistoryPage()),//跳轉至測驗歷史頁面
                  );
                },
                child: Container(
                  width: ScreenUtil().setWidth(1400),
                  height: ScreenUtil().setHeight(320),
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(211, 216, 190, 1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 40.0),
                      child: Text(
                        '測 驗 歷 史',
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(90),
                          color: Colors.black,
                        ),
                      ),
                    ),
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
                    MaterialPageRoute(builder: (context) => TestAddPage()),//跳轉至新增測驗頁面
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
                    MaterialPageRoute(builder: (context) => WriteTestPage()),//跳轉至作答測驗頁面
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
              top: ScreenUtil().setWidth(1990),
              right: ScreenUtil().setWidth(60),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TestHistoryPage()),//跳轉至測驗歷史頁面
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
