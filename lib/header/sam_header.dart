
library cs_elements.sam_header;

import 'dart:html';

import 'package:polymer/polymer.dart';

@CustomTag('sam-header')
class SamHeader extends HeadingElement with Polymer, Observable {

  SamHeader.created(): super.created() {
    polymerCreated();
  }

  @override
  void attached() {
    super.attached();
  }

  @override
  void detached() {
    super.detached();
  }

  ImageElement get logo => shadowRoot.querySelector('img');

  goHome() {
    window.location.href = '/';
  }
}
