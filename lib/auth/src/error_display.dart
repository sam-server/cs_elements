library cs_elements.auth.error_display;

import 'package:polymer/polymer.dart';

@CustomTag('error-display')
class ErrorDisplay extends PolymerElement {

  @published
  String get error => readValue(#error);
  set error(String value) => writeValue(#error, value);

  ErrorDisplay.created(): super.created();
}

