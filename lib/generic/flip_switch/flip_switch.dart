library cs_elements.flip_switch;

import 'package:polymer/polymer.dart';

@CustomTag('flip-switch')
class FlipSwitch extends PolymerElement {

  /// The text to display on the left of the switch
  @published
  String get leftLabel => readValue(#leftLabel, () => 'On');
  set leftLabel(String value) => writeValue(#leftLabel, value);

  Object get leftValue => readValue(#leftValue, () => 'on');
  set leftValue(Object value) => writeValue(#leftValue, value);

  /// The text to display on the right side of the switch
  /// default is 'off'
  @published
  String get rightLabel => readValue(#rightLabel, () => 'Off');
  set rightLabel(String value) => writeValue(#rightLabel, value);

  Object get rightValue => readValue(#rightValue, () => 'off');
  set rightValue(Object value) => writeValue(#rightValue, value);

  @published
  Object get selectedValue => readValue(#selectedValue, () => leftValue);
  set selectedValue(Object value) => writeValue(#selectedValue, value);

  FlipSwitch.created(): super.created();

}