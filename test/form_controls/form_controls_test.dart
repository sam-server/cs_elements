
import 'dart:async';
import 'dart:html';

import 'package:unittest/unittest.dart';
import 'package:polymer/polymer.dart';

import 'package:cs_elements/form_controls/form_controls.dart';

import '../utils.dart';

void main() {
  initPolymer();
  group("form controls", () {
    FormControlPanel controlPanel;

    setUp(() => polymerReady.then((_) {
      controlPanel = document.querySelector('cs-form-control-panel');
    }));

    tearDown(() {
      controlPanel.state = 'enabled';
    });

    test("elements should be visible if state selected", () {
      expect(
          controlPanel.visibleControls.map((ctrl) => ctrl.id),
          ['edit']
      );
      controlPanel.state = 'disabled';
      //Wait for event loop.
      return new Future.value().then((_) {
        expect(
            controlPanel.visibleControls.map((ctrl) => ctrl.id),
            ['save', 'cancel']
        );
      });
    });

  });

}