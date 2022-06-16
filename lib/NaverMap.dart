// 네이버 맵 api 불러오기 테스트
// 임시로 두번째 탭(주변 캠핑장) 화면에 띄움

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:naver_map_plugin/naver_map_plugin.dart';
import 'LocationBasedList.dart';

class NaverMapTest extends StatefulWidget {
  @override
  _NaverMapTestState createState() => _NaverMapTestState();
}

class _NaverMapTestState extends State<NaverMapTest> {
  Completer<NaverMapController> _controller = Completer();
  MapType _mapType = MapType.Basic; // 일반 지도 타입

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
            child: NaverMap(
              activeLayers: [],
              onMapCreated: onMapCreated,
              mapType: _mapType,
            ),
          ),
    );
  }

  void onMapCreated(NaverMapController controller) {
    if (_controller.isCompleted) _controller = Completer();
    _controller.complete(controller);
  }
}
