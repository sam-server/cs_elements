library cs_elements.generic.spinner;

import 'dart:html';
import 'dart:js' as js;

import 'package:polymer/polymer.dart';

/*
enum SpinnerDirection {
  CLOCKWISE;
  COUNTER_CLOCKWISE;
}
*/

@CustomTag('progress-spinner')
class SpinnerElement extends PolymerElement {

  /// The number of lines to draw
  @published
  int get lines => readValue(#lines, () => 7);
  set lines(int value) => writeValue(#lines, value);

  /// The length of each line
  @published
  int get length => readValue(#length, () => 3);
  set length(int value) => writeValue(#length, value);

  /// The thickness of each line
  @published
  int get width => readValue(#width, () => 5);
  set width(int value) => writeValue(#width, value);

  /// The radius of the circle
  @published
  int get radius => readValue(#radius, () => 5);
  set radius(int value) => writeValue(#radius, value);

  /// Roundness of the corners (value between 0 and 1)
  @published
  double get corners => readValue(#corners, () => 1.0);
  set corners(double value) => writeValue(#corners, value);

  /// The rotation offset
  @published
  int get rotate => readValue(#rotate, () => 0);
  set rotate(int value) => writeValue(#rotate, value);

  /// The direction of rotation
  //TODO: Use the SpinnerDirection enum
  // Currently: -1 is counterclockwise, 1 is clockwise
  @published
  int get direction => readValue(#direction, () => 1);
  set direction(int value) => writeValue(#direction, value);

  /// The color of the spinner (as #RGB or #RRGGBB)
  @published
  String get color => readValue(#color, () => '#fff');
  set color(String value) => writeValue(#color, value);

  /// The speed of rotation
  @published
  double get speed => readValue(#speed, () => 1);
  set speed(double value) => writeValue(#speed, value);

  /// The duration of the afterglow (as a percentage)
  @published
  int get trail => readValue(#trail, () => 60);
  set trail(int value) => writeValue(#trail, () => value);

  /// Render a shadow for the spinner
  @published
  bool get shadow => readValue(#shadow, () => false);
  set shadow(bool value) => writeValue(#shadow, value);

  /// Should the animation be hardware accelerated
  @published
  bool get hwAccel => readValue(#hwAccel, () => false);
  set hwAccel(bool value) => writeValue(#hwAccel, value);

  /// The css classname to apply to the spinner
  @published
  String get className => readValue(#className, () => 'spinner');
  set className(String value) => writeValue(#className, value);

  @published
  int get zIndex => readValue(#zIndex, () => 40);
  set zIndex(int value) => writeValue(#zIndex, () => value);

  js.JsObject _spinner;

  SpinnerElement.created(): super.created();

  void attached() {
    Polymer.onReady.then((_) {
    var opts = new js.JsObject.jsify(_opts);
    _spinner = new js.JsObject(js.context['Spinner'], [opts]);
    this.spin();
    });
  }

  void spin() {
    _spinner.callMethod('spin', [$['content']]);
  }

  void stop() {
    _spinner.callMethod('stop', []);
  }

  Map<String,dynamic> get _opts =>
      {
        'lines': lines,
        'length': length,
        'width': width,
        'radius': radius,
        'corners': corners,
        'rotate': rotate,
        'direction': direction,
        'color': color,
        'speed': speed,
        'trail': trail,
        'shadow': shadow,
        'hwaccel': hwAccel,
        'className': className,
        'zIndex': zIndex,
      };
}