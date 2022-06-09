import 'package:flutter/material.dart';
import 'HomeUI.dart';
import './style.dart' as style; // 변수 중복문제 피하기 1

void main() {
  runApp(MaterialApp(
      home: MyApp(),
      theme: style.theme
  ));
}

class MyApp extends StatefulWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {


  final title=  TextStyle(color: Colors.teal,
      fontSize: 25, );

  int _selectedIndex = 0; // 현재 선택된 탭
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('HONDI CAMPING', style: title,),
        actions: [
          IconButton(
            icon: Icon(Icons.add_box_outlined), //임시 아이콘 -> 변경 및 삭제 가능
            onPressed: (){},
            iconSize: 30,
          )
        ],
      ),
      body: [HomeUI(), TourUI, MyPage][_selectedIndex], // 탭 3개
      bottomNavigationBar: BottomNavigationBar(
        //type: BottomNavigationBarType.shifting,
        selectedFontSize: 20,
        selectedIconTheme: IconThemeData(color: Colors.teal, size: 40),
        selectedItemColor: Colors.teal,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
        currentIndex: _selectedIndex, //New
        onTap: _onItemTapped,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined,),
              label: '홈'),
          BottomNavigationBarItem(
              icon: Icon(Icons.map, ),
              label: '주변 관광지 정보'),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_circle,),
              label: '마이페이지')
        ],

      ),
    );
  }
}


var TourUI = Container( // 임시로 만듬 -> 코드 길어지면 Tour.dart파일로 생성해도 좋음
  child: Text('주변관광지 정보 ui'),
);
var MyPage = Container( // 임시로 만듬 -> 코드 길어지면 MyPage.dart파일로 생성해도 좋음
  child: Text('마이페이지'),
);

