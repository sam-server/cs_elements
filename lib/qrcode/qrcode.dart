library cs_elements.qrcode;
import 'dart:html';
import 'dart:js' show JsObject;
import 'dart:js' as js;

import 'package:polymer/polymer.dart';

@CustomTag('cs-qrcode')
class QRCode extends PolymerElement {
  
  JsObject _qrCode;
  
  /**
   * The value of the underlying text used to generate the qr code.
   */
  @published
  String get value => readValue(#value, () => '');
  set value(String value) => writeValue(#value, value);
  void valueChanged(oldValue, newValue) => _refreshCode();
  
  /// The error correction level of the code generation algorithm
  /// The following values are supported:
  /// 
  /// "low": 7% of codewords can be restored
  /// "medium": 15% of codewords can be restored
  /// "quartile": 25% of codewords can be restored
  /// "high" (default): 32% of codewords can be restored
  @published
  String get correctionLevel => readValue(#correctionLevel, () => 'high');
  set correctionLevel(String value) => writeValue(#correctionLevel, value);
  void correctionLevelChanged(o, n) => _makeCode();
  
  @published
  String get width => readValue(#width, () => '256');
  set width(String value) => writeValue(#width, value);
  void widthChanged(o, n) => _makeCode();
  
  @published
  String get height => readValue(#height, () => '256');
  set height(String value) => writeValue(#height, value);
  void heightChanged(o, n) => _makeCode();
  
  @published
  String get colorDark => readValue(#colorDark, () => '#000000');
  set colorDark(String value) => writeValue(#colorDark, value);
  void colorDarkChanged(o, n) => _makeCode();
  
  @published
  String get colorLight => readValue(#colorLight, () => '#ffffff');
  set colorLight(String value) => writeValue(#colorLight, value);
  void colorLightChanged(o, n) => _makeCode();
  
  QRCode.created(): super.created() {
    this.onResize.listen(_resize);
  }
  
  void attached() {
    super.attached();
    _makeCode();
  }
  
  void _resize(Event evt) {
    evt.preventDefault();
    _makeCode();
  }
  
  int get _jsCorrectionLevel {
    var correctLevel = js.context['QRCode']['CorrectLevel'];
    switch (correctionLevel) {
      case 'low':
        return correctLevel['L'];
      case 'medium':
        return correctLevel['M'];
      case 'quartile':
        return correctLevel['Q'];
      case 'high':
      default:
        return correctLevel['H'];
    }
  }
  
  /// Called when just the text is changed.
  void _refreshCode() {
    if (_qrCode == null)
      return _makeCode();
    if (this.value.isEmpty)
      return _qrCode.callMethod('clear', []);
    _qrCode.callMethod('makeCode', [this.value]);
  }
  
  
  void _makeCode() {
    if (_qrCode != null) {
      _qrCode.callMethod('clear', []);
      $['qrcode'].innerHtml = '';
    }
    this.correctionLevel = 'medium';
    _qrCode = new JsObject(js.context['QRCode'], [
      shadowRoot.getElementById('qrcode'),
      new JsObject.jsify({
        'text': this.value,
        'width': width,
        'height': height,
        'colorDark': colorDark,
        'colorLight': colorLight,
        'correctLevel': _jsCorrectionLevel
      })
    ]);
  }
}