import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:geolocator/geolocator.dart';

import 'LocationBasedList.dart';
import 'package:flutter/material.dart';
import 'package:naver_map_plugin/naver_map_plugin.dart';
import 'package:http/http.dart' as http;

class MarkerMapPage extends StatefulWidget {
  @override
  _MarkerMapPageState createState() => _MarkerMapPageState();
}

class _MarkerMapPageState extends State<MarkerMapPage> {
  static const MODE_ADD = 0xF1;
  static const MODE_REMOVE = 0xF2;
  static const MODE_NONE = 0xF3;
  int _currentMode = MODE_NONE;

  Completer<NaverMapController> _controller = Completer();
  List<Marker> _markers = [];
  //List<LatLng> _latLang = [];
  var long;
  var lat;

  var data;
  bool loading = true;
  final String authkey = 'q6tw/AWLdEFNCHf6qcCrXFWErhIdK4fr9cHdlIX/2KRVOvi90Jr3f8u3/SvhBH4mTcgzOu5I6nRlKvWwem2WKw==';
  late double mapX;
  late double mapY;

  getPosition() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState((){
      mapX = position.longitude;
      mapY = position.latitude;
    });
    print(mapX);
    print(mapY);
  }

  getData() async {
    final http.Response response
    = await http.get(Uri.parse
      ('http://api.visitkorea.or.kr/openapi/service/rest/GoCamping/locationBasedList?'
        'ServiceKey=${authkey}'
        '&MobileOS=ETC&MobileApp=AppTest&mapX=${mapX}&mapY=${mapY}&radius=20000&_type=json'));

    if (response.statusCode == 200) {
      var body = utf8.decode(response.bodyBytes);
      //print("body \n $body");
      var json = jsonDecode(body);

      setState((){
        data = json['response']['body']['items']['item'];
      });
      //print("data \n $data");

    } else {
      throw Exception('Failed to load post');
    }
  }

  getLocation() {
    for (var i = 0; i < data.length; i++) {
      long = data[i]["mapX"];
      lat = data[i]["mapY"];
      //_latLang = [LatLng(data[i]["mapX"], data[i]["mapX"])];
    }
    //print(long);
    //print(lat);
  }

  getMarker() {
    for(var i = 0; i < data.length; i++) {
      _markers.add(Marker(
          markerId: 'id',
          position: LatLng(data[i]["mapX"], data[i]["mapX"]),
          captionText: data[i]["facltNm"] ?? 'default value',
          captionColor: Colors.indigo,
          captionTextSize: 20.0,
          alpha: 0.8,
          captionOffset: 30,
          anchor: AnchorPoint(0.5, 1),
          width: 45,
          height: 45,
          infoWindow: data[i]["lineIntro"]?? ' ',
          //onMarkerTab: _onMarkerTap
      ));
    }
  }

  start() async {
    await getPosition();
    await getData();
    await getLocation();
    await getMarker();
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      OverlayImage.fromAssetImage(
        assetName: 'icon/marker.png',
      ).then((image) {
        setState(() {
          _markers.add(Marker(
              markerId: 'id',
              position: LatLng(37.563600, 126.962370),
              captionText: "커스텀 아이콘",
              captionColor: Colors.indigo,
              captionTextSize: 20.0,
              alpha: 0.8,
              captionOffset: 30,
              icon: image,
              anchor: AnchorPoint(0.5, 1),
              width: 45,
              height: 45,
              infoWindow: '인포 윈도우',
              //onMarkerTab: _onMarkerTap
          ));
        });
      });
    });
    super.initState();
    loading = true;
    start();
    //addMarker(_latLang);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: <Widget>[
            ElevatedButton.icon(
              onPressed: (){
                Navigator.push(context,
                  MaterialPageRoute(builder: (context) => NearbyCampingSites()),
                );
              },
              icon: Icon(Icons.near_me,),
              label: Text('주변 캠핑장 목록 조회'),
            ),
            // _controlPanel(),
            _naverMap(),
          ],
        ),
      ),
    );
  }

  _naverMap() {
    return Expanded(
      child: Stack(
        children: <Widget>[
          NaverMap(
            onMapCreated: _onMapCreated,
            markers: _markers,
            initLocationTrackingMode: LocationTrackingMode.Follow,
            locationButtonEnable: true,
            onMapLongTap: _onMapLongTap,
          ),
        ],
      ),
    );
  }

  _onMapLongTap(LatLng position) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
          '[onLongTap] lat: ${position.latitude}, lon: ${position.longitude}'),
      duration: const Duration(milliseconds: 500),
      backgroundColor: Colors.black,
    ));
  }
  // ================== method ==========================

  void _onMapCreated(NaverMapController controller) {
    _controller.complete(controller);
  }

  // void _onMapTap(LatLng latLng) {
  //   if (_currentMode == MODE_ADD) {
  //     for(var i = 0; i < data.length; i++) {
  //       _markers.add(Marker(
  //           markerId: 'id',
  //           position: LatLng(data[i]["mapX"], data[i]["mapX"]),
  //           captionText: data[i]["facltNm"] ?? 'default value',
  //           captionColor: Colors.indigo,
  //           captionTextSize: 20.0,
  //           alpha: 0.8,
  //           captionOffset: 30,
  //           anchor: AnchorPoint(0.5, 1),
  //           width: 45,
  //           height: 45,
  //           infoWindow: data[i]["lineIntro"]?? ' ',
  //           //onMarkerTab: _onMarkerTap
  //       ));
  //     }
  //     setState(() {});
  //   }
  // }

  // void GoMarker(LatLng latLng) {
  //   if (_currentMode == MODE_ADD) {
  //     _markers.add(Marker(
  //       markerId: DateTime.now().toIso8601String(),
  //       position: latLng,
  //       infoWindow: '테스트',
  //       onMarkerTab: _onMarkerTap,
  //     ));
  //     setState(() {});
  //   }
  // }

  // void _onMarkerTap(Marker marker, Map<String, int> iconSize) {
  //   int pos = _markers.indexWhere((m) => m.markerId == marker.markerId);
  //   setState(() {
  //     _markers[pos].captionText = '선택됨';
  //   });
  //   if (_currentMode == MODE_REMOVE) {
  //     setState(() {
  //       _markers.removeWhere((m) => m.markerId == marker.markerId);
  //     });
  //   }
  // }
}