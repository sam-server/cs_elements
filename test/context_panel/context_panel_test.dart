
import 'dart:html';

import 'package:unittest/unittest.dart';
import 'package:polymer/polymer.dart';

import 'package:cs_elements/context_panel/context_panel.dart';

import 'test_elements/loadables.dart';

import 'history_test.dart' as history;
import '../utils.dart';

void main() {
  initPolymer();
  history.main();
  
  group("context panel", () {
    //TODO: Context pane tests.
    ContextPanel contextPanel;
    setUp(() {
      return polymerReady.then((_) {
        contextPanel = document.querySelector('my-context');
      });
    });
    
    tearDown(() {
      if (contextPanel.href != 'loadable_1') {
        contextPanel.href = 'loadable_1';
        return contextPanel.onElementLoaded.first;
      }
    });
    
    test("should be able to switch contexts", () {
      contextPanel.href = 'loadable_2';
      return contextPanel.onElementLoaded.first.then((evt) {
        expect(evt.detail, new isInstanceOf<LoadableElement2>());
        contextPanel.href = 'loadable_1';
        return contextPanel.onElementLoaded.first;
      }).then((evt) {
        expect(evt.detail, new isInstanceOf<LoadableElement1>());
      })
      .timeout(new Duration(seconds: 1));
    });
    
    test("should track the history", () {
      /*
      var initHistory = new Map.from(contextPanel.history);
      print(initHistory);
      contextPanel.href='loadable_2';
      return contextPanel.onElementLoaded.first.then((evt) {
        var addedKey = null;
        print(contextPanel.history);
        for (var k in contextPanel.history.keys) {
          if (!initHistory.containsKey(k)) {
            addedKey = k;
          }
        }
        expect(addedKey, isNotNull);
        //Should have saved the element data for loadable_1 against loadable_2
        expect(contextPanel.history[addedKey], {
          'href': 'loadable_1',
          'element': {'value': 4}
        });
      });
      * 
       */
    });
  });
}
