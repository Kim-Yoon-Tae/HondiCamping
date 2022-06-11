
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeUI extends StatefulWidget {
  const HomeUI({Key? key}) : super(key: key);

  @override
  State<HomeUI> createState() => _HomeUIState();
}

class _HomeUIState extends State<HomeUI> {


  final authkey = 'q6tw/AWLdEFNCHf6qcCrXFWErhIdK4fr9cHdlIX/2KRVOvi90Jr3f8u3/SvhBH4mTcgzOu5I6nRlKvWwem2WKw=='; // 나영 인증키
  var json;
  var data = {};
  var mapx = 126.8395857; // (현재 GPS좌표)(임시로 표선으로 저장)
  var mapy = 33.3259761; // (현재 GPS좌표)(임시로 표선으로 저장)

  getData() async { // ${mapX}&mapY=${mapY}
    var response
    = await http.get(Uri.parse
      ('http://api.visitkorea.or.kr/openapi/service/rest/GoCamping/locationBasedList?'
        'ServiceKey=${authkey}'
        '&MobileOS=ETC&MobileApp=AppTest&mapX=${mapx}&mapY=${mapy}&radius=2000&_type=json'));
    var body = utf8.decode(response.bodyBytes);

    if (response.statusCode == 200) {
      print(body); // 확인용
      json = jsonDecode(body);

      if (json['response']['header']['resultCode'] == "0000") {
        if (json['response']['body']['items'] == '') {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  content: Text("마지막 데이터 입니다."),
                );
              });
        } else {
          print(json); //확인용
        }
      } else {
        // 만약 응답이 OK가 아니면, 에러를 던집니다.
        throw Exception('Failed to load post');
      }
    }

     data = json['response']['body']['items'];
      print(data);
     print(data.length); //확인용
  }


    @override
  void initState() { // 위젯 초기화시 1번 호출
    super.initState();
    getData();
  }
  @override
  Widget build(BuildContext context) {

    if (data.isNotEmpty){
      return Scaffold(
          body: Container(
           child: ListView.builder(
                itemCount: data.length,
                itemBuilder: (c,i){
                  return Text(data["item"]["facltNm"]?? 'default value'); // 야영장명 출력
                }),
          )
      );
    } else { // 로딩중 이미지 출력
      return  CircularProgressIndicator();
    }

  }
}
