import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class NearbyCampingSites extends StatefulWidget {
  const NearbyCampingSites({Key? key}) : super(key: key);

  @override
  State<NearbyCampingSites> createState() => _NearbyCampingSitesState();
}

class _NearbyCampingSitesState extends State<NearbyCampingSites> {

  var data; // 주변 캠핑장 정보
  bool loading = true;
  final String authkey = 'q6tw/AWLdEFNCHf6qcCrXFWErhIdK4fr9cHdlIX/2KRVOvi90Jr3f8u3/SvhBH4mTcgzOu5I6nRlKvWwem2WKw=='; // 나영 인증키
  late double mapX; //128.6142847;// 126.8395857;//  // (현재 GPS좌표)(샘플데이터 기준)
  late double mapY; // = 36.0345423;  // 33.3259761;// (현재 GPS좌표)(샘플데이터 기준)

  getPosition() async { // 현재 GPS좌표 저장 함수
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState((){
      mapX = position.longitude; // 경도
      mapY = position.latitude;
    });
    print(mapX);
    print(mapY);// 위도
  }

  getData() async {
    // 고캠핑 api 요청 함수

    final http.Response response
    = await http.get(Uri.parse
      (
        'http://api.visitkorea.or.kr/openapi/service/rest/GoCamping/locationBasedList?'
            'ServiceKey=${authkey}'
            '&MobileOS=ETC&MobileApp=AppTest&mapX=${mapX}&mapY=${mapY}&radius=20000&_type=json'));
// 요청 변수 수정완료(&radius=2000 -> 200000)

    if (response.statusCode == 200) { //응답이 성공하면

      var body = utf8.decode(response.bodyBytes);
      //print("body \n $body"); // 확인용

      var json = jsonDecode(body);
      //print("json \n $json"); // 확인용

      setState(() {
        data = json['response']['body']['items']['item'];
      });

      print("data \n $data"); // 확인용
      //print(data.runtimeType); // 확인용

    } else {
      // 만약 응답이 OK가 아니면, 에러를 던집니다.
      throw Exception('Failed to load post');
    }
  }

start() async {
    await getPosition();
    await getData();
}

@override
  void initState() { // 화면 로드시 1번 호출
    super.initState();
    loading = true;
    start();
    /*  아래처럼 쓰면 에러남, start 함수로 한 번 더 정의해서 묶어야됨.(다트 언어 특징때문, 알 필요X)
    getPosition();
    getData();
    */
  }

// 스타일 저장 변수들
 static TextStyle _style1 = TextStyle(fontFamily: 'Suseong',
     fontSize : 30, color: Colors.teal);  // 야영장 이름 스타일
 static TextStyle _style2 = TextStyle(fontFamily: 'jeju',
     fontSize : 15, color: Colors.black38);    //지역명(도 시/군/구) 스타일
 static TextStyle _style3 = TextStyle(fontFamily: 'jeju', fontSize : 18); // 한줄소개 스타일
 static TextStyle _style4 = TextStyle(fontFamily: 'Suseong', fontSize: 20);

 static BoxDecoration _boxDeco = BoxDecoration( // 컨테이너 박스 스타일
     borderRadius: BorderRadius.circular(10),
     border: Border.all(color: Colors.black12, width: 2 ));
var noImgUrl = 'https://www.freeiconspng.com/thumbs/no-image-icon/no-image-icon-6.png';
// 이미지 정보 없을 때 출력할 이미지 url

  @override
  Widget build(BuildContext context) {
    if (data != null) {
      return Scaffold(
          body: Column(
            children: <Widget>[
              Container(
                color: Colors.teal,
                width: double.infinity,
                height: 80,
                child: Center(
                  child: Text("현재 위치 주변 캠핑장 목록",
                    style: TextStyle(fontFamily: 'Suseong',
                        fontSize: 40,
                        color: Colors.white),),
                ),
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(8.0),
                  child: ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (c, i) {
                       // if (data is List) { // 주변 캠핑장 정보가 2개 이상이라면
                          return Container(
                            padding: EdgeInsets.all(8.0),
                            height: 200,
                            decoration: _boxDeco,
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  // 이미지 모서리 둥글게 하기
                                  child: Image.network(data[i]["firstImageUrl"] ?? noImgUrl,
                                    fit: BoxFit.fill,
                                    width: 200,
                                  ),
                                ),
                                SizedBox(width: 20,),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(data[i]["facltNm"] ?? 'default value',
                                      style: _style1,),
                                    // 캠핑장 이름
                                    SizedBox(height: 10),
                                    Text(
                                      '${data[i]["addr1"] ??' '} ${data[i]["addr2"] ?? ' '} ',
                                      style: _style2,
                                    ),
                                    // 지역명(도 시/군/구)
                                    SizedBox(height: 30,),
                                    Text(data[i]["lineIntro"]?? ' ', style: _style3,),
                                    SizedBox(height:10),
                                    TextButton(
                                      style: TextButton.styleFrom(primary: Colors.white, backgroundColor: Colors.teal),
                                      child:  Text('상세 보기', style: TextStyle(fontFamily: 'jeju'),),
                                      onPressed: () { // 상세페이지 이동
                                        Navigator.push(context,
                                          MaterialPageRoute(builder:
                                              (context) => ShowDetail(i) // 233 line부터 정의됨
                                          ),);
                                      },
                                    )
                                  ],
                                ),
                              ],
                            ),
                          );
                      }
                  ),
                ),
              ),
            ],
          )
      );
    } //else if(mapX != null){

  //}
     else { // 로딩중 이미지 출력
      return Container(
        child : Center(
          child: LoadingAnimationWidget.inkDrop(
              color: Colors.teal,
              size: 200),
        )
      );
    }
  }

  Widget ShowDetail(i) { // 윤태역할
    return  Scaffold(
      body: Dialog( // 굳이 Dialog로 안해도 됨! 마음대로!
        backgroundColor: Colors.white,
        child: Container(
          margin: EdgeInsets.all(30),
          width: 1000,
          child: ListView(
            children: [
              SizedBox(
                child: Align(
                  alignment: Alignment.topRight,
                  child: IconButton( // 창 닫기 버튼
                      onPressed: () {Navigator.pop(context);},
                      icon: Icon(Icons.exit_to_app_outlined), color: Colors.teal),
                ),
              ),
              Text(data[i]["facltNm"] ?? 'default value',
                style: _style1, textAlign: TextAlign.center,),
              Divider( indent: 100, endIndent: 100,thickness:2 , color: Colors.teal,), // 구분선
              SizedBox( // 여백
                height: 20,
              ),
              ClipRRect(// 이미지 모서리 둥글게 하기
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(data[i]["firstImageUrl"] ?? noImgUrl,
                  fit: BoxFit.fill,
                ),),
              SizedBox( // 여백
                height: 20,
              ),
              Text("이 페이지에서 제공하는 정보는 실제 캠핑장의 정보와 상이할 수 있습니다.",
                style: TextStyle(fontFamily: 'jeju', fontSize : 15, color: Colors.red), textAlign: TextAlign.left,),
              SizedBox( // 여백
                height: 20,
              ),
              Text("캠핑장 소개", style: _style4, textAlign: TextAlign.left,),
              SizedBox( // 여백
                height: 10,
              ),
              Text(data[i]["intro"]?? '제공하는 캠핑장 소개가 없습니다.', style: _style2, textAlign: TextAlign.left,),
              SizedBox( // 여백
                height: 20,
              ),
              Text("상세 주소", style: _style4, textAlign: TextAlign.left,),
              SizedBox( // 여백
                height: 10,
              ),
              Text('${data[i]["addr1"] ??'제공하는 상세 주소가 없습니다.'} ${data[i]["addr2"] ?? ' '} ', style: _style2, textAlign: TextAlign.left,),
              SizedBox( // 여백
                height: 20,
              ),
              Text("전화번호", style: _style4, textAlign: TextAlign.left,),
              SizedBox( // 여백
                height: 10,
              ),
              Text(data[i]["tel"]?? '제공하는 전화번호가 없습니다.', style: _style2, textAlign: TextAlign.left,),
              SizedBox( // 여백
                height: 20,
              ),
              Text("홈페이지 링크", style: _style4, textAlign: TextAlign.left,),
              SizedBox( // 여백
                height: 10,
              ),
              Text(data[i]["homepage"]?? '제공하는 홈페이지 링크가 없습니다.', style: _style2, textAlign: TextAlign.left,),
              SizedBox( // 여백
                height: 20,
              ),
              Text("야영시설", style: _style4, textAlign: TextAlign.left,),
              SizedBox( // 여백
                height: 10,
              ),
              Text(" - 일반야영장 : " + (data[i]["gnrlSiteCo"]).toString(), style: _style2, textAlign: TextAlign.left,),
              Text(" - 자동차야영장 : " + (data[i]["autoSiteCo"]).toString(), style: _style2, textAlign: TextAlign.left,),
              Text(" - 글램핑야영장 : " + (data[i]["glampSiteCo"]).toString(), style: _style2, textAlign: TextAlign.left,),
              SizedBox( // 여백
                height: 20,
              ),
              Text("부대시설", style: _style4, textAlign: TextAlign.left,),
              SizedBox( // 여백
                height: 10,
              ),
              Text(data[i]["sbrsCl"]?? '제공하는 부대시설 정보가 없습니다.', style: _style2, textAlign: TextAlign.left,)
              SizedBox( // 여백
                height: 20,
              ),
              Text("캠핑장 주변 관광지", style: _style4, textAlign: TextAlign.left,),
              SizedBox( // 여백
                height: 10,
              ),
            ],),),),
    );
  }
}



