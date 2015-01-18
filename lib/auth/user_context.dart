library cs_elements.user_context;

import 'dart:async';
import 'dart:html';

import 'package:polymer/polymer.dart';

import '../session/session.dart';

@CustomTag('user-context')
class UserContext extends PolymerElement {

  @observable
  SessionElement session;

  ///
  /// The mode of the selection to display the
  /// login or signup form.
  /// Acceptable values are "login" and "signup"
  ///
  @observable
  String mode;

  UserContext.created(): super.created() {
    mode = "login";
  }

  void attached() {
    Polymer.onReady.then((_) {
      session = document.querySelector('cs-session');
    });
  }

}