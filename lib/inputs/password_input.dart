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

  StreamSubscription _inputOnFocus;
  StreamSubscription _inputOnBlur;

  PasswordInput.created(): super.created();

  void attached() {
    super.attached();
    _inputOnFocus = shadowRoot.querySelector('input[is=core-input]').onFocus.listen((Event evt) {
      this.fire('password-input-focus', detail: evt);
    });
    _inputOnBlur = shadowRoot.querySelector('input[is=core-input]').onBlur.listen((Event evt) {
      this.fire('password-input-blur', detail: evt);
    });
  }

  void detached() {
    super.detached();
    _inputOnFocus.cancel();
    _inputOnBlur.cancel();
  }
}