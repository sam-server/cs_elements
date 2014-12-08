import 'dart:async';
import 'dart:html';

import 'package:unittest/html_config.dart';
import 'package:unittest/unittest.dart';
import 'package:polymer/polymer.dart';

import 'package:cs_elements/qrcode/qrcode.dart';
import 'package:cs_elements/route/route.dart';

Future _polymerReady;

Future get polymerReady {
  if (_polymerReady == null) {
    Completer completer = new Completer();
    document.addEventListener('polymer-ready', completer.complete);
    _polymerReady = completer.future;
  }
  return _polymerReady;
  
}


void main() {
  useHtmlConfiguration();
  initPolymer();
  
  group("route", () {
    setUp(() => polymerReady);
    
    test("should be able to route a simple path", () {
      RouteElement router = document.getElementById('router');
      expect(
          router.route('topLevel/'), 
          new isInstanceOf<DivElement>());
    });
    
    test("should be able to route a subroute", () {
      RouteElement router = document.getElementById('router');
      expect(router.route('topLevel/subRoute/'), new isInstanceOf<LIElement>());
    });
    
    test("should be able to route a subroute and obtain a polymer element", () {
      RouteElement router = document.getElementById('router');
      expect(router.route('topLevel/subRoutePolymer/'), new isInstanceOf<QRCode>());
    });
    
    
  });
  
  
}