library cs_elements.context_pane_history_test;

import 'dart:async';

import 'package:unittest/unittest.dart';

import 'package:cs_elements/context_panel/context_panel.dart';

void main() {
  group("history tests", () {
    History history;
    setUp(() {
      history = new History();
    });
    
    test("should be able to save and restore a history", () {
      var saveData = {'value': 4};
      var callbackComplete = new Completer();
      void callback(Map<String,dynamic> restoreData) {
        try {
          expect(restoreData['value'], 4);
        } catch (e) {
          callbackComplete.completeError(e);
        }
      }
      return history.saveHistory(saveData, callback)
          .then((_) => callbackComplete);
    });
  });
}