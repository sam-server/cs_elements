library cs_elements.money_input;

import 'dart:html';
import 'dart:math';

import 'package:polymer/polymer.dart';

import 'package:core_elements/core_input.dart';

@CustomTag('cs-money-input')
class MoneyInput extends PolymerElement {

  @published
  String symbol;

  @published
  String currencyCode;

  /// Display the symbol *after* the input element?
  @published
  bool appendSymbol;

  @published
  int get numDigits => readValue(#numDigits, () => 2);
  set numDigits(int value) => writeValue(#numDigits, value);

  @published
  String name;

  @published
  String label;

  @published
  String placeholder;

  @published
  String value;

  @published
  bool disabled;

  @observable
  String get committedValue => _input.committedValue;
  set committedValue(String value) => _input.committedValue = value;

  @observable
  double get inputStep => pow(10, -numDigits);

  CoreInput get _input => shadowRoot.querySelector('input[is=core-input]');

  MoneyInput.created(): super.created();

  factory MoneyInput() => new Element.tag('input', 'money-input');

  void commit() {
    this.committedValue = this.value;
  }

}