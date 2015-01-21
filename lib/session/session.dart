library cs_elements.session;

import 'dart:async';
import 'dart:convert' show UTF8;
import 'dart:html';

import 'package:crypto/crypto.dart' show CryptoUtils;

import 'package:polymer/polymer.dart';

import 'package:cookies/cookies.dart';

import '../context_panel/context_panel.dart';

/**
 * A [SessionElement] defines various global parameters
 * to the application.
 */
@CustomTag('cs-session')
class SessionElement extends PolymerElement {

  CookieJar _cookies;

  void _saveCookies() {
    document.cookie = _cookies.values.map((v) => '$v').join(';');
  }

  bool get loggedIn => authToken != null;

  @published
  String csrfToken;

  @published
  String username;

  AuthToken get authToken {
    //TODO: Storing a base64 encoded user:pass is *very* insecure.
    var c = _cookies['authToken'];
    if (c == null)
      return null;
    return AuthToken.parse(c.value);
  }

  ObservableMap<String,String> sessionHeaders;

  SessionElement.created(): super.created() {
    this._cookies = new CookieJar(document.cookie);
    this.sessionHeaders = toObservable(<String,String>{});
  }

  void attached() {
    this.sessionHeaders['Authorization'] = '$authToken';
    this.sessionHeaders['x-csrftoken'] = '$csrfToken';
  }

  ContextPanel contextPanel;
}

abstract class AuthToken {
  static AuthToken parse(String rawToken) {
    rawToken = Uri.decodeComponent(rawToken);
    var components = rawToken.split(' ');
    if (components[0] == 'Basic') {
      var userPass = UTF8.decode(CryptoUtils.base64StringToBytes(components[1]))
          .split(':');
      return new BasicAuthToken(userPass[0], userPass[1]);
    } else {
      throw new ParseError(0, 'Unrecognised authType: ${components[0]}');
    }
  }

  String get authType;

  String get token;

  String toString() => '$authType $token';
}

class BasicAuthToken extends AuthToken {

  final String authType = 'Basic';

  final String _username;
  final String _password;

  BasicAuthToken(this._username, this._password);

  String get token =>
      CryptoUtils.bytesToBase64(UTF8.encode('$_username:$_password'));
}

class ParseError extends StateError {
  ParseError(int position, String message):
    super('Parse error at $position: $message');

  toString() => 'ParseError: $message';
}