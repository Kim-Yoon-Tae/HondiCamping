
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeUI extends StatefulWidget {
  const HomeUI({Key? key}) : super(key: key);

  @override
  State<HomeUI> createState() => _HomeUIState();
}

class _HomeUIState extends State<HomeUI> {


  var authkey = 't8cep12p82p6rbc2c11c6ebee_2c1bpo'; // 나영 인증키

  var data = [];
  var result;

  getData() async {
    var response = await http.get(Uri.parse
      ('https://open.jejudatahub.net/api/proxy/a11801tD1bttatDttD1b0t1Dt80b011a/${authkey}?&limit=100'));

    if (response.statusCode == 200) {
      setState(() {
        result = jsonDecode(response.body);
        data = result['data']; // list형
      });
      // 만약 서버가 OK 응답을 반환하면, JSON을 파싱
      print(result); //확인용
      print(data.length); //확인용
      //  print(data is List<dynamic>); // true
    } else {
      // 만약 응답이 OK가 아니면, 에러를 던집니다.
      throw Exception('Failed to load post');
    }

    // print(data['data'][0]); //확인용
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
                  return Text(data[i]['placeName']);
                }),
          )
      );
    } else { // 로딩중 이미지 출력
      return  CircularProgressIndicator();
    }

  }
}
