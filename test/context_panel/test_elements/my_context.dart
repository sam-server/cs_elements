library my_context_test;

import 'dart:html';

import 'package:polymer/polymer.dart';
import 'package:cs_elements/context_panel/context_panel.dart';

@CustomTag('my-context')
class MyContext extends ContextPanel {
  @override
  bool get trackHistory => true;
  
  MyContext.created(): super.created();
  
}