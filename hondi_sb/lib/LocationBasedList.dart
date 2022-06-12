import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class NearbyCampingSites extends StatefulWidget {
  const NearbyCampingSites({Key? key}) : super(key: key);

  @override
  State<NearbyCampingSites> createState() => _NearbyCampingSitesState();
}

class _NearbyCampingSitesState extends State<NearbyCampingSites> {

  var data; // 주변 캠핑장 정보
  int len = 0; // 주변 캠핑장 정보 개수

  final String authkey = 'q6tw/AWLdEFNCHf6qcCrXFWErhIdK4fr9cHdlIX/2KRVOvi90Jr3f8u3/SvhBH4mTcgzOu5I6nRlKvWwem2WKw=='; // 나영 인증키
  double mapx = 128.6142847;// 126.8395857;//  // (현재 GPS좌표)(샘플데이터 기준)
  double mapy = 36.0345423;  // 33.3259761;// (현재 GPS좌표)(샘플데이터 기준)

  getData() async {   // 고캠핑 api 요청 함수
    final http.Response response
    = await http.get(Uri.parse
      ('http://api.visitkorea.or.kr/openapi/service/rest/GoCamping/locationBasedList?'
        'ServiceKey=${authkey}'
        '&MobileOS=ETC&MobileApp=AppTest&mapX=${mapx}&mapY=${mapy}&radius=2000&_type=json'));

    if (response.statusCode == 200) {  //응답이 성공하면

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
    // 현재 위치 좌표 mapx, mapy에 저장하는 코드 추가 예정
  }

// 스타일 저장 변수들
 static TextStyle _style1 = TextStyle(fontFamily: 'Suseong',
     fontSize : 30, color: Colors.teal);  // 야영장 이름 스타일
 static TextStyle _style2 = TextStyle(fontFamily: 'jeju',
     fontSize : 15, color: Colors.black38);    //지역명(도 시/군/구)
 static TextStyle _style3 = TextStyle(fontFamily: 'jeju', fontSize : 18);

 static BoxDecoration _boxDeco = BoxDecoration( // 컨테이너 박스 스타일
     borderRadius: BorderRadius.circular(10),
     border: Border.all(color: Colors.black12, width: 2 ));


  @override
  Widget build(BuildContext context) {
    if (data != null) {
      return Scaffold(
          body: Column(
            children: <Widget> [
              SizedBox(
                height: 50,
                child: Container(
                  width: double.infinity, // 가로 꽉차게
                  child: Text(" test"),
                ),
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(8.0),
                  child: ListView.builder(
                      itemCount: len,
                      itemBuilder: (c, i) {
                        if(data is List) { // 주변 캠핑장 정보가 2개 이상이라면
                          return Container(
                            padding: EdgeInsets.all(8.0),
                            height: 200,
                            decoration: _boxDeco,
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0), // 이미지 모서리 둥글게 하기
                                  child: Image.network(data[i]["firstImageUrl"], fit:BoxFit.fill,),
                                ),
                                SizedBox(width: 20,),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(data[i]["facltNm"] ?? 'default value',
                                      style: _style1,),// 캠핑장 이름
                                    SizedBox(height: 10),
                                    Text(
                                      '${data[i]["addr1"] ?? ' '} ${data[i]["addr2"] ?? ' '} ',
                                       style: _style2,
                                      ),
                                     // 지역명(도 시/군/구)
                                    SizedBox(height: 30,),
                                    Text(data[i]["lineIntro"],style: _style3,), // 한줄 소개
                                    TextButton(
                                      child: Text('상세 보기'),
                                      onPressed: (){ // 상세페이지 이동
                                        Navigator.push(context,
                                            MaterialPageRoute(builder:
                                               (context) => AlertDialog(
                                                 title: Text(data[i]["facltNm"] ?? ' ',
                                                   textAlign: TextAlign.center,
                                                    ),
                                                 titleTextStyle: _style1,

                                                 content: SingleChildScrollView(
                                                     child:  Container(
                                                       margin: EdgeInsets.all(30),
                                                       width: 800,
                                                       height:900,
                                                       child: ListView.builder(
                                                           itemCount: 1,
                                                           itemBuilder: (c,i){
                                                             return Container(
                                                                 child : Column(
                                                                   children: [
                                                                     Text('상세보기 페이지'),
                                                                     IconButton( // 창 닫기 버튼
                                                                         onPressed: (){
                                                                           Navigator.pop(context);},
                                                                         icon: Icon(Icons.exit_to_app_outlined)),

                                                                   ],)
                                                             );}
                                                       ),
                                                     )
                                                 )
                                                 ,)
                                            ),);
                                      },
                                    )
                                  ],
                                ),
                              ],
                            ),
                          );
                        }else{ // 주변 캠핑장 정보가 1개라면
                          return Container(); // 나영 역할: 위에 코드 복붙해서 인덱스([i])만 삭제예정
                        }
                      }
                  ),
                ),
              ),
            ],
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



