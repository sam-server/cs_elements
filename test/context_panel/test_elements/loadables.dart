library loadable_1_test;

import 'dart:async';

import 'package:polymer/polymer.dart';
import 'package:cs_elements/context_panel/context_panel.dart';

@CustomTag('loadable-element1')
class LoadableElement1 extends PolymerElement implements LoadableElement {
  
  @override
  ContextPanel contextPanel;
  
  String uri;
  Map<String,dynamic> restoreData;
  
  LoadableElement1.created(): super.created();
  
  @override
  Future loadFromUri(String uri, {Map<String, dynamic> restoreData}) {
    this.uri = uri;
    this.restoreData = restoreData;
    return new Future.value();
  }

  @override
  Map<String, dynamic> saveData() {
    return {
      'value': 4
    };
  }
}

@CustomTag('loadable-element2')
class LoadableElement2 extends PolymerElement implements LoadableElement {
  String uri;
  Map<String,dynamic> restoreData;
 
  ContextPanel contextPanel;
  
  LoadableElement2.created(): super.created();
  
  Future loadFromUri(String uri, {Map<String,dynamic> restoreData}) {
    this.uri = uri;
    this.restoreData = restoreData;
    return new Future.value();
  }
  
  Map<String,dynamic> saveData() => {};
}