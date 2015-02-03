library web_client.auth.signup_form;

import 'dart:html';
import 'dart:convert' show JSON, UTF8;

import 'package:polymer/polymer.dart';
import 'package:polymer_ajax_form/ajax_form.dart';
import 'package:cs_elements/session/session.dart';


@CustomTag('signup-form')
class SignupForm extends PolymerElement {

  @published
  String callback;

  @observable
  String username;

  @observable
  String email;

  @observable
  String password;

  @observable
  String errorMessage;

  @observable
  SessionElement session;

  bool get hasError => errorMessage != null && errorMessage.isNotEmpty;

  PathObserver _scoreObserver;

  SignupForm.created(): super.created() {
    this.errorMessage = 'Username not provided';
    this.password = '';
  }

  void attached() {
    InputElement confirmPassword = $['confirmPassword'];
    confirmPassword.onInput.listen(checkPasswordsMatch);

    this._scoreObserver = new PathObserver($['passwordStrength'], 'score');
    var currentScore = _scoreObserver.open((newValue, oldValue) {
      errorMessage = (newValue <= 1) ? 'Password too weak': '';
    });

    Polymer.onReady.then((_) {
      session = document.querySelector('cs-session');
    });
  }

  void detached() {
    _scoreObserver.close();
  }

  void validateForm([Event e]) {
    var emailInput = $['email'] as InputElement;
    if (!emailInput.validity.valid)
      errorMessage = emailInput.validationMessage;
    if (email == null || email.isEmpty)
      errorMessage = 'Email must be provided';
    if (username == null || username.isEmpty)
      errorMessage = 'Username must be provided';

    if (errorMessage != null && errorMessage.isNotEmpty) {
      return;
    }
  }

  void checkPasswordsMatch(Event e) {
    var password = $['password'].value;
    var confirmPassword = $['confirmPassword'].value;
    if (password != confirmPassword) {
      errorMessage = 'passwords do not match';
    } else {
      errorMessage = '';
    }
  }

  void submitForm([Event e]) {
    e.preventDefault();
    validateForm();
    if (hasError) {
      print('error: $errorMessage');
      print('pwd1: ${$['password'].value}');
      print('pwd2: ${$['confirmPassword'].value}');
      return;
    }

    AjaxFormElement form = $['mainform'];
    form.submit().then((response) {
      print(response.responseText);
      var body = JSON.decode(UTF8.decode(response.content));
      if (response.status >= 200 && response.status < 300) {
        window.location.href =
            callback != null
            ? Uri.decodeComponent(callback)
            : '/';
      } else {
        this.errorMessage = body['error'];
      }
    });
  }
}