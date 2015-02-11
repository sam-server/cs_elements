
library cs_elements.nav_bar;

import 'dart:async';
import 'dart:html';

import 'package:polymer/polymer.dart';

@CustomTag('nav-bar')
class NavBar extends PolymerElement {

  @observable bool phoneScreen;
  phoneScreenChanged(oldValue, newValue) {
    if (newValue == false) {
      $['links'].classes.add('enable-transition');
    } else {
      $['links'].classes.remove('enable-transition');
    }
  }

  @observable bool hover;

  List<StreamSubscription> _listeners = [];

  NavBar.created(): super.created() {
    this.phoneScreen = false;
    this.hover = false;
  }

  @override
  void attached() {
    super.attached();
    this._listeners.add(this.onMouseEnter.listen((_) {
      $['links'].classes.add('hover');
    }));

    this._listeners.add(this.onMouseLeave.listen((_) {
      $['links'].classes.remove('hover');
    }));
  }

  @override
  void detached() {
    super.detached();
    _listeners.forEach((subscription) => subscription.cancel());
  }

  void goHome() {
    window.location.href = '/';
  }
}
