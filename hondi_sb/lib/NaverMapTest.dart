import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:naver_map_plugin/naver_map_plugin.dart';

import 'LocationBasedList.dart';

class BaseMapPage extends StatefulWidget {
  const BaseMapPage({Key? key}) : super(key: key);

  @override
  _BaseMapPageState createState() => _BaseMapPageState();
}

class _BaseMapPageState extends State<BaseMapPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  Completer<NaverMapController> _controller = Completer();

  MapType _mapType = MapType.Basic;
  final LocationTrackingMode _trackingMode = LocationTrackingMode.Follow;

  List<Marker> _markers = [];

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
      print("body \n $body"); // 확인용
      var json = jsonDecode(body);
      setState((){
        data = json['response']['body']['items']['item'];
      });
      print("data \n $data"); // 확인용
    } else {
      throw Exception('Failed to load post');
    }
  }

  start() async {
    await getPosition();
    await getData();
  }

  @override
  void initState() {
    super.initState();
    loading = true;
    start();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: Stack(
        children: <Widget>[
          NaverMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(37.566570, 126.978442),
              zoom: 17,
            ),
            onMapCreated: onMapCreated,
            mapType: _mapType,
            markers: _markers,
            initLocationTrackingMode: _trackingMode,
            locationButtonEnable: true,
            indoorEnable: true,
            onCameraChange: _onCameraChange,
            onCameraIdle: _onCameraIdle,
            onMapLongTap: _onMapLongTap,
            onMapDoubleTap: _onMapDoubleTap,
            onMapTwoFingerTap: _onMapTwoFingerTap,
            onSymbolTap: _onSymbolTap,
            useSurface: kReleaseMode,
          ),
          ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              // padding: const EdgeInsets.fromLTRB(10, 10, 20, 10)
          ),
          onPressed: (){
            Navigator.push(context,
              MaterialPageRoute(builder: (context) => NearbyCampingSites()),);
            },
            icon: Icon(Icons.near_me,),
            label: Text('주변 캠핑장 목록 조회'),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(220, 10, 50, 0),
            child: _mapTypeSelector(),
          ),
          _trackingModeSelector(),
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

  _onMapDoubleTap(LatLng position) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
          '[onDoubleTap] lat: ${position.latitude}, lon: ${position.longitude}'),
      duration: const Duration(milliseconds: 500),
      backgroundColor: Colors.black,
    ));
  }

  _onMapTwoFingerTap(LatLng position) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
          '[onTwoFingerTap] lat: ${position.latitude}, lon: ${position.longitude}'),
      duration: const Duration(milliseconds: 500),
      backgroundColor: Colors.black,
    ));
  }

  _onSymbolTap(LatLng? position, String? caption) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
          '[onSymbolTap] caption: $caption, lat: ${position?.latitude ?? '-'}, lon: ${position?.longitude ?? '-'}'),
      duration: const Duration(milliseconds: 500),
      backgroundColor: Colors.black,
    ));
  }

  _mapTypeSelector() {
    return SizedBox(
      height: kToolbarHeight,
      child: ListView.separated(
        itemCount: MapType.values.length,
        scrollDirection: Axis.horizontal,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (_, index) {
          ElevatedButton.icon(
            onPressed: (){
              Navigator.push(context,
                MaterialPageRoute(builder: (context) => NearbyCampingSites()),);
            },
            icon: Icon(Icons.near_me,),
            label: Text('주변 캠핑장 목록 조회'),
          );
          final type = MapType.values[index];
          String title;
          switch (type) {
            case MapType.Basic:
              title = '기본';
              break;
            case MapType.Navi:
              title = '내비';
              break;
            case MapType.Satellite:
              title = '위성';
              break;
            case MapType.Hybrid:
              title = '위성혼합';
              break;
            case MapType.Terrain:
              title = '지형도';
              break;
          }
          return GestureDetector(
            onTap: () => _onTapTypeSelector(type),
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 3)]),
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              child: Text(
                title,
                style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                    fontSize: 13),
              ),
            ),
          );
        },
      ),
    );
  }

  _trackingModeSelector() {
    return Align(
      alignment: Alignment.bottomRight,
      child: GestureDetector(
        onTap: _onTapTakeSnapShot,
        child: Container(
          margin: const EdgeInsets.only(right: 16, bottom: 48),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: Colors.white,
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 2,
                )
              ]),
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const <Widget>[
              Icon(
                Icons.photo_camera,
                color: Colors.black54,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 지도 생성 완료시
  void onMapCreated(NaverMapController controller) {
    if (_controller.isCompleted) _controller = Completer();
    _controller.complete(controller);
  }

  /// 지도 유형 선택시
  void _onTapTypeSelector(MapType type) async {
    if (_mapType != type) {
      setState(() {
        _mapType = type;
      });
    }
  }

  void _onCameraChange(
      LatLng? latLng, CameraChangeReason? reason, bool? isAnimated) {
    print(
        '카메라 움직임 >>> 위치 : ${latLng?.latitude ?? '-'}, ${latLng?.longitude ?? '-'}'
            '\n원인: $reason'
            '\n에니메이션 여부: $isAnimated');
  }

  void _onCameraIdle() {
    print('카메라 움직임 멈춤');
  }

  /// 지도 스냅샷
  void _onTapTakeSnapShot() async {
    final controller = await _controller.future;
    controller.takeSnapshot((path) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              contentPadding: EdgeInsets.zero,
              content: path != null
                  ? Image.file(
                File(path),
              )
                  : const Text("path is null!"),
              titlePadding: EdgeInsets.zero,
            );
          });
    });
  }
}
