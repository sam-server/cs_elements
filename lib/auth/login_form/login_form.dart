library cs_elements.auth.login_form;

import 'dart:async';
import 'dart:html';
import 'dart:convert' show UTF8;

import 'package:polymer/polymer.dart';
import 'package:polymer_ajax_form/ajax_form.dart';
import '../../session/session.dart';

@CustomTag('login-form')
class LoginForm extends PolymerElement {

  @published
  String username;

  @published
  String password;

  @published
  String confirmPassword;

  @observable
  String errorMessage;

  @observable
  SessionElement session;

  @published
  String callback;

  AjaxFormElement get _form => shadowRoot.querySelector('form[is=ajax-form]');

  LoginForm.created(): super.created() {
    errorMessage = '';
  }

  void attached() {
    super.attached();
    Polymer.onReady.then((_) {
      session = document.querySelector('cs-session');
    });
  }


  void submitForm(Event e) {
    //TODO: prevent default not working.
    e.preventDefault();
    if (username == null || username.isEmpty) {
      errorMessage = 'No username provided';
    } else if (password == null || password.isEmpty) {
      errorMessage = 'Password required';
    } else {
      errorMessage = null;
    }

    if (errorMessage != null)
      return;

    _form.submit().then((FormResponse response) {
      if (response.status >= 200 && response.status < 300) {
        // TODO: Should set session values. At the moment just
         // reload the page.
        window.location.href =
            callback != null
            ? Uri.decodeComponent(callback)
            : '/';
      } else {
        errorMessage = UTF8.decode(response.content);
      }
    });
  }


}