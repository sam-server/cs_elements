library cs_elements.context_pane_history_test;

import 'dart:async';

import 'package:unittest/unittest.dart';

import 'package:cs_elements/context_panel/src/history.dart';

BrowserHistory browserHistory = new BrowserHistory();

class MockTracker implements HistoryTracker {
  
  Completer<Map<String,dynamic>> completer;
  
  HistoryTracker() {
    browserHistory.registerTracker('mock-tracker', this);
  }
  
  
  @override
  void restoreState(Map<String, dynamic> savedState) {
    print('restoring state');
    completer.complete(savedState);
  }

  @override
  Map<String, dynamic> saveStateOnPageEntry() {
    return {'page_entry': true};
  }

  @override
  Map<String, dynamic> saveStateOnPageExit() {
    return {'page_exit': true};
  }
}

void main() {
  group("history tests", () {
    MockTracker mockTracker = new MockTracker();
    
    setUp(() {
      mockTracker.completer = new Completer<Map<String,dynamic>>();
    });
    
    test("should be able to save and restore a history", () {
      print('testing history');
      browserHistory.save();
      return mockTracker.completer.future.then((saveData) {
        print(saveData);
      })
      .timeout(new Duration(seconds: 1));
      
    });
  });
}