library cs_elements.user_context;

import 'dart:html';

import 'package:polymer/polymer.dart';

import '../session/session.dart';

@CustomTag('user-context')
class UserContext extends PolymerElement {

  static final _CB_PATTERN = new RegExp(r'.*cb=([^&]+)');

  @observable
  SessionElement session;

  ///
  /// The mode of the selection to display the
  /// login or signup form.
  /// Acceptable values are "login" and "signup"
  ///
  @observable
  String mode;

  @observable
  String callback;

  UserContext.created(): super.created() {
    mode = "login";
  }

  void attached() {
    Polymer.onReady.then((_) {
      session = document.querySelector('cs-session');
    });

    var cb_match = _CB_PATTERN.matchAsPrefix(window.location.search);
    if (cb_match != null) {
      this.callback = Uri.decodeQueryComponent(cb_match.group(1));
    }
  }

}