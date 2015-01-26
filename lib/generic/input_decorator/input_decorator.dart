library cs_elements.auth.form_container;

import 'dart:async';
import 'dart:html';

import 'package:polymer/polymer.dart';

@CustomTag('input-decorator')
class InputDecorator extends PolymerElement {
  /// The element tags which are recognised as valid input elements
  static const List<String> INPUT_TAGS =
      const [ 'input',
              'password-input',
              'textarea',
              'money-input',
            ];


  @published
  String get icon => readValue(#icon);
  set icon(String value) => writeValue(#icon, value);

  @published
  String get iconSrc => readValue(#iconSrc);
  set iconSrc(String value) => writeValue(#iconSrc, value);

  List<StreamSubscription> _subscriptions;

  InputDecorator.created(): super.created() {
    this._subscriptions = <StreamSubscription>[];
  }

  /**
   * Gets the single input-type element (see INPUT_TAGS) which
   * is a light DOM child of the selector.
   */
  Element get input {
    var inputs = INPUT_TAGS.expand(this.querySelectorAll);
    try {
      return inputs.single;
    } on StateError catch (e) {
      var msg = 'Only one child of an <input-decorator> can have the tags ';
      msg += '(${INPUT_TAGS.join(', ')}).\n';
      msg += 'The following matching children were found:\n\t- ';
      msg += inputs.join('\n\t- ');
      throw new StateError(msg);
    }
  }
  @override
  void attached() {
    super.attached();
    _subscriptions.add(input.onFocus.listen((evt) {
      if (input.attributes['readonly'] == null) {
        $['container'].classes.add('focused');
      }
    }));
    _subscriptions.add(input.onBlur.listen((evt) {
      $['container'].classes.remove('focused');
    }));

    if (input.attributes['readonly'] != null) {
      $['container'].classes.add('readonly');
      this.classes.add('readonly');
    }
  }

  @override
  void detached() {
    super.detached();
    _subscriptions.forEach((subscription) => subscription.cancel());
  }

  @override
  void focus() {
    this.fire('input-decorator-focus');
    this.classes.add('focus');
    input.focus();
  }

  @override
  void blur() {
    this.fire('input-decorator-focus');
    this.classes.remove('focus');
    input.blur();
  }
}