import 'package:flutter/material.dart'; //기본 위젯 쓰려면 필요

//var _var1; // 다른 파일에서 쓰기 싫은 변수는 언더바붙이기(_변수명/_함수명/_클래스명)

var theme = ThemeData(
  appBarTheme: AppBarTheme(
      color: Colors.white,
      elevation: 1, // 그림자 크기
      actionsIconTheme: IconThemeData(color: Colors.black)
  ),
);

var text1 = TextStyle(
    fontFamily: 'tway',
    fontSize: 20
);
var text2 = TextStyle(
    color: Colors.black,
    fontFamily: 'tway',
    fontSize: 40
);

