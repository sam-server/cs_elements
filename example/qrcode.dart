import 'dart:html';
import 'package:polymer/polymer.dart';

InputElement codeText;
InputElement codeWidth;

void main() {
  initPolymer();
  codeText = document.getElementById('codeText');
  codeText..onBlur.listen((_) => makeCode());
  codeText..onKeyDown.where((evt) => evt.keyCode == 13).listen((_) => makeCode());
  codeWidth = document.getElementById('width');
  codeWidth..value = '16';
  codeWidth..onKeyDown.where((evt) => evt.keyCode == 13).listen((_) => makeCode());
}

void makeCode() {
  var qrcode = document.getElementById('qrcode');
  qrcode.width = codeWidth.value;
  qrcode.value = codeText.value;
}