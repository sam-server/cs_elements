library cs_elements.session;

import 'dart:async';
import 'dart:convert' show UTF8;
import 'dart:html';

import 'package:crypto/crypto.dart' show CryptoUtils;

import 'package:polymer/polymer.dart';
import 'package:http/src/base_client.dart';
import 'package:http/src/base_request.dart';
import 'package:http/src/streamed_response.dart';
import 'package:http/browser_client.dart';

import 'package:cookies/cookies.dart';

import '../context_panel/context_panel.dart';

/**
 * Gets the session from the body of the html (if one is present)
 */
SessionElement get session => querySelector('cs-session');

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
  
  AuthToken get authToken {
    var c = _cookies['authToken'];
    if (c == null)
      return null;
    return AuthToken.parse(c.value);
  }
  
  SessionElement.created(): super.created() {
    this._cookies = new CookieJar(document.cookie);
  }
  
  SessionClient get httpClient => new SessionClient._(this);

  ContextPanel contextPanel;
}

class SessionClient extends Object with BaseClient {
  static final _async = new Future.value();
  
  SessionElement sessionElement;
  
  BaseClient _baseClient;
  
  SessionClient._(this.sessionElement):
    this._baseClient = new BrowserClient();
  
  @override
  Future<StreamedResponse> send(BaseRequest request) {
    return _async.then((_) {
      print('attching csrf token ${sessionElement.csrfToken}');
      request.headers['X-CSRFToken'] = sessionElement.csrfToken;
      
      if (sessionElement.authToken != null) {
        print('Attaching auth token ${sessionElement.authToken}');
        request.headers['Authorization'] = '${sessionElement.authToken}';
      }
      return _baseClient.send(request);
    });
  }
}

abstract class AuthToken {
  static AuthToken parse(String rawToken) {
    rawToken = rawToken.replaceAll('"', '');
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
}

class BasicAuthToken implements AuthToken {
  
  final String authType = 'Basic';
  
  final String _username;
  final String _password;
  
  BasicAuthToken(this._username, this._password);
  
  String get token =>
      CryptoUtils.bytesToBase64(UTF8.encode('$_username:$_password'));
  
  String toString() => '$authType $token';
}

class ParseError extends StateError {
  ParseError(int position, String message):
    super('Parse error at $position: $message');
  
  toString() => 'ParseError: $message';
}