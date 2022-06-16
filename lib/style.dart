import 'package:flutter/material.dart'; //기본 위젯 쓰려면 필요

//var _var1; // 다른 파일에서 쓰기 싫은 변수는 언더바붙이기(_변수명/_함수명/_클래스명)


//저작권 정보표시: 저작물명,저작자명,출처,이용조건
//예시: 바리스타,최유나,공유마당,CC BY

TextStyle facltNm_style = TextStyle(fontFamily: 'jeju', fontSize : 30);

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

