
library cs_elements.nav_bar_item;

import 'dart:html';

import 'package:polymer/polymer.dart';

@CustomTag('nav-bar-item')
class NavBarItem extends PolymerElement {

  @published
  String get href => readValue(#href);
  set href(String value) => writeValue(#href, value);

  NavBarItem.created(): super.created();

  @override
  void attached() {
    super.attached();
  }

  @override
  void detached() {
    super.detached();
  }

  void navigate() {
    window.location.href = this.href;
  }
}
