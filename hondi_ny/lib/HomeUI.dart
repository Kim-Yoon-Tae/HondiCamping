
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class HomeUI extends StatefulWidget {
  const HomeUI({Key? key}) : super(key: key);

  @override
  State<HomeUI> createState() => _HomeUIState();
}

class _HomeUIState extends State<HomeUI> {

  var data;

  int len = 0;

  final String authkey = 'q6tw/AWLdEFNCHf6qcCrXFWErhIdK4fr9cHdlIX/2KRVOvi90Jr3f8u3/SvhBH4mTcgzOu5I6nRlKvWwem2WKw=='; // 나영 인증키
  double mapx = 128.6142847;// 126.8395857;//  // (현재 GPS좌표)(샘플데이터 기준)
  double mapy = 36.0345423;  // 33.3259761;// (현재 GPS좌표)(샘플데이터 기준)

  getData() async {
    final http.Response response
    = await http.get(Uri.parse
      ('http://api.visitkorea.or.kr/openapi/service/rest/GoCamping/locationBasedList?'
        'ServiceKey=${authkey}'
        '&MobileOS=ETC&MobileApp=AppTest&mapX=${mapx}&mapY=${mapy}&radius=2000&_type=json'));

    if (response.statusCode == 200) {

      var body = utf8.decode(response.bodyBytes);
      //print("body \n $body"); // 확인용

      var json = jsonDecode(body);
      //print("json \n $json"); // 확인용
      setState((){
        data = json['response']['body']['items']['item'];
        if(data is List){ // totalCount가 2개 이상일 때는 list로 받게 됨.
          len = data.length;
        }else if(data is Map){ // totalCount가 하나일 때는 map으로 받게 됨.
          len = 1;
        }
      });

      print("data \n $data"); // 확인용
      //print(data.runtimeType); // 확인용

    } else {
      // 만약 응답이 OK가 아니면, 에러를 던집니다.
      throw Exception('Failed to load post');
    }
  }


  @override
  void initState() { // 위젯 초기화시 1번 호출
    super.initState();
    getData();
  }


  @override
  Widget build(BuildContext context) {
    if (data != null) {
      return Scaffold(
          body: Container(
            child: ListView.builder(
                itemCount: len,
                itemBuilder: (c, i) {
                  if(data is List) {
                    return Text(
                        data[i]["facltNm"] ?? 'default value');
                  }else{
                    return Text(
                        data["facltNm"].toString());// 야영장명 출력
                  }
                }
            ),
          )
      );
    } else { // 로딩중 이미지 출력
      return Container(
        child : Center(
          child: LoadingAnimationWidget.inkDrop(
              color: Colors.teal,
              size: 200),
        )
      );
    }
  }
}
