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
 * A [SessionElement] defines various global parameters
 * to the application.
 */
@CustomTag('cs-session')
class SessionElement extends PolymerElement {
  
  CookieJar _cookies;
  
  @published
  String csrfToken;
  
  String authToken = 'Authorization test';
  
  SessionElement.created(): super.created() {
    this._cookies = new CookieJar(document.cookie);
  }
  
  void attached() {
    //TODO: Handle authentication
    /*
    var authTokenCookie = this._cookies['session_auth'];
    if (authTokenCookie == null) {
      //window.location.href = 'http://REDIRECT_TO_AUTH?cb=${window.location.href}';
    }
    this.authToken = UTF8.decode(CryptoUtils.base64StringToBytes(authTokenCookie.value)); 
   */
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
      request.headers['X-CSRFToken'] = sessionElement.csrfToken;
      request.headers['Authorization'] = sessionElement.authToken;
      return _baseClient.send(request);
    });
  }
}