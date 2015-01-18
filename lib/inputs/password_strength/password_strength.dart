library web_client.auth.password_strength;

import 'dart:async';
import 'dart:html';
import 'dart:js' as js;
import 'package:polymer/polymer.dart';

@CustomTag('password-strength')
class PasswordStrengthMeter extends PolymerElement {
  static const _SCRIPT_SRC = 'packages/cs_elements/inputs/password_strength/zxcvbn.js';
  static Future _scriptLoaded;

  Stream<CustomEvent> get onCalculationDone => on['password-strength-calc-done'];

  @published
  String password;
  passwordChanged(oldValue, newValue) {
    _scriptLoaded.then((zxcvbn) {
      var result = zxcvbn.apply([newValue]);
      this.entropy = result['entropy'];
      this.crackTime = result['crack_time'].round();
      this.crackTimeDisplay = result['crack_time_display'];
      this.score = result['score'];
      fire('password-strength-calc-done');
    });
  }

  /// The number of bits of entropy of the password.
  @observable
  double entropy;

  /// The estimated time to crack the password, in seconds.
  @observable
  int crackTime;

  /// A human readable of the crack time
  @observable
  String get crackTimeDisplay => readValue(#crackTimeDisplay, () => 'instant');
  set crackTimeDisplay(String value) => writeValue(#crackTimeDisplay, value);

  /// An abstract amount of time required to crack the password
  /// [0,1,2,3,4] if crack time is less than
  /// [10**2, 10**4, 10**6, 10**8, Infinity].
  @observable
  int score;
  scoreChanged(oldValue, newValue) {
    for (var i=1;i<=4;i++) {
      var span = shadowRoot.querySelector('#score_$i');
      if (newValue >= i) {
        span.classes.add('highlighted');
      } else {
        span.classes.remove('highlighted');
      }
    }
  }


  PasswordStrengthMeter.created(): super.created() {

    if (_scriptLoaded == null) {
      var script = new ScriptElement()
          ..src = _SCRIPT_SRC
          ..async = true;
      document.body.append(script);

      Completer completer = new Completer();
      js.context['zxcvbn_load_hook'] = () {
        completer.complete(js.context['zxcvbn']);
      };
      _scriptLoaded = completer.future;
    }
  }
}