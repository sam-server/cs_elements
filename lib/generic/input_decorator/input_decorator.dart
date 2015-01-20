library cs_elements.auth.form_container;

import 'dart:async';
import 'dart:html';

import 'package:polymer/polymer.dart';

@CustomTag('input-decorator')
class InputDecorator extends PolymerElement {

  @published
  String get icon => readValue(#icon, () => 'none');
  set icon(String value) => writeValue(#icon, value);

  InputDecorator.created(): super.created();

  List<StreamSubscription> _focusListeners;
  List<StreamSubscription> _blurListeners;

  Iterable<Element> get inputs {
    return [
      this.querySelectorAll('input[is=core-input]'),
      this.querySelectorAll('password-input'),
      this.querySelectorAll('textarea'),
      this.querySelectorAll('money-input'),
    ].expand((i) => i);
  }

  void attached() {
    _focusListeners = <StreamSubscription>[];
    _blurListeners = <StreamSubscription>[];


    inputs.forEach((elem) {
      _focusListeners.add(elem.onFocus.listen((evt) {
        $['container'].classes.add('focused');
      }));
      _blurListeners.add(elem.onBlur.listen((evt) {
        $['container'].classes.remove('focused');
      }));
    });

  }

  void focusInput(Event e) {
    //e.preventDefault();
    var input = inputs.first;
    input.focus();
  }

  void detached() {
    _focusListeners.forEach((subscription) => subscription.cancel());
    _blurListeners.forEach((subscription) => subscription.cancel());
  }
}