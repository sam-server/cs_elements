library cs_elements.auth.form_container;

import 'dart:async';

import 'package:polymer/polymer.dart';

@CustomTag('input-decorator')
class InputDecorator extends PolymerElement {

  @published
  String get icon => readValue(#icon, () => 'none');
  set icon(String value) => writeValue(#icon, value);

  InputDecorator.created(): super.created();

  List<StreamSubscription> _focusListeners;
  List<StreamSubscription> _blurListeners;

  void attached() {
    _focusListeners = <StreamSubscription>[];
    _blurListeners = <StreamSubscription>[];
    var inputs = [
      this.querySelectorAll('input[is=core-input]'),
      this.querySelectorAll('password-input')
    ].expand((i) => i);

    inputs.forEach((elem) {
      _focusListeners.add(elem.onFocus.listen((evt) {
        $['container'].classes.add('focused');
      }));
      _blurListeners.add(elem.onBlur.listen((evt) {
        $['container'].classes.remove('focused');
      }));
    });

  }

  void detached() {
    _focusListeners.forEach((subscription) => subscription.cancel());
    _blurListeners.forEach((subscription) => subscription.cancel());
  }
}