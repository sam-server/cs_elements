library polymer_ajax_form.inputs.money_input;

import 'dart:async';
import 'dart:html';

import 'package:polymer/polymer.dart';
import 'package:polymer_ajax_form/form_input.dart';
import 'package:rational/rational.dart';

@CustomTag('money-input')
class MoneyInput extends PolymerElement with FormInput {

  static final _MONEY = new RegExp(r'(\.)?(\d+\.(\d+)) ([A-Z]{3})');

  static const int _DEFAULT_NUM_DIGITS = 2;

  @override
  @published
  String get value => readValue(#value, () => '0.00 AUD');
  set value(String value) => writeValue(#value, value);

  @observable
  Money moneyValue;

  StreamSubscription _changeObserver;

  InputElement get _input => shadowRoot.querySelector('input');
  StreamSubscription _inputOnInput;
  StreamSubscription _inputOnBlur;
  StreamSubscription _inputOnKeyDown;

  SpanElement get _symbolSpan => shadowRoot.querySelector('#symbolSpan');

  MoneyInput.created(): super.created() {
    this.moneyValue = Money.parse('0.00 AUD');
    _changeObserver = this.changes.listen(_handlePropertyChange);
  }

  void attached() {
    _inputOnInput = _input.onInput.listen((Event evt) {
      if (_input.validity.valid) {
        this.classes.remove('inputInvalid');
      } else {
        this.classes.add('inputInvalid');
      }
    });

    _inputOnBlur = _input.onBlur.listen((Event evt) {
      commitValue();
    });
    _inputOnKeyDown = _input.onKeyDown.listen((KeyEvent evt) {
      if (evt.keyCode == 13) {
        commitValue();
      }
    });
  }

  void detached() {
    _changeObserver.cancel();
    if (_inputOnInput != null)
      _inputOnInput.cancel();
    if (_inputOnBlur != null)
      _inputOnBlur.cancel();
    if (_inputOnKeyDown != null)
      _inputOnKeyDown.cancel();
  }

  void commitValue() {
    print('Commiting value ${moneyValue.toString()}');
    this.value = moneyValue.toString();
  }

  void _handlePropertyChange(Iterable<ChangeRecord> changes) {
    var propChanges = changes.where((change) => change is PropertyChangeRecord);
    var valueChanges = propChanges.where((change) => change.name == #value);
    for (PropertyChangeRecord change in valueChanges) {
      var money = Money.parse(change.newValue);
      print('Money: $money');
      this.moneyValue.currencyCode = money.currencyCode;
      this.moneyValue.value = money.value;
      this.moneyValue.fractionalDigits = money.fractionalDigits;
    }
  }

  @override
  void focus() => shadowRoot.querySelector('input').focus();
}

class Money extends Observable {
  static final REGEX = new RegExp(r'([-+]?\d+\.(\d+)) ([A-Z]{3})$');

  static Money parse(String value) {
    var match = REGEX.matchAsPrefix(value);
    if (match == null)
      throw new FormatException('Monetary value must match ${REGEX.pattern}');
    var rat = Rational.parse(match.group(1));
    var numDigits = match.group(2).length;
    var currCode = match.group(3);
    return new Money(rat, currCode, numDigits);
  }

  @observable
  String currencyCode;

  @observable
  int fractionalDigits;

  @observable
  String value;

  Rational get rational => Rational.parse(value);
  set rational(Rational value) {
    this.value = value.toStringAsFixed(fractionalDigits);
  }

  Money(Rational rational, String this.currencyCode, int this.fractionalDigits) {
    this.rational = rational;
  }

  /// Truncate any unnecessary decimal points from the current value
  void truncate() {
    this.value = this.rational.toStringAsFixed(fractionalDigits);
  }

  String toString() => '${rational.toStringAsFixed(fractionalDigits)} $currencyCode';
}