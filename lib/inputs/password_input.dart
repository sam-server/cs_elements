library cs_elements.inputs.password_input;

import 'dart:async';
import 'dart:html';
import 'package:polymer/polymer.dart';

import 'package:polymer_ajax_form/form_input.dart';

@CustomTag('password-input')
class PasswordInput extends PolymerElement with FormInput {

  Stream<Event> get onFocus => on['password-input-focus'];
  Stream<Event> get onBlur => on['password-input-blur'];

  @published
  bool get displayMeter => readValue(#displayMeter, () => false);
  set displayMeter(bool value) => writeValue(#displayMeter, value);

  List<StreamSubscription> _subscriptions;

  PasswordInput.created(): super.created() {
    _subscriptions = <StreamSubscription>[];
  }

  InputElement get _input => shadowRoot.querySelector('input[is=core-input]');

  @override
  void attached() {
    super.attached();
    _subscriptions.add(_input.onFocus.listen((Event evt) {
      print('input focused');
      this.fire('password-input-focus', detail: evt);
    }));
    _subscriptions.add(_input.onBlur.listen((Event evt) {
      this.fire('password-input-blur', detail: evt);
    }));
  }

  @override
  void detached() {
    _subscriptions.forEach((subscription) => subscription.cancel());
  }

  @override
  void focus() {
    _input.focus();
  }

  @override
  void blur() {
    _input.blur();
  }
}