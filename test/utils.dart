import 'dart:async';
import 'dart:html';

Future _polymerReady;

// A future which completes when polymer is ready
Future get polymerReady {
  if (_polymerReady == null) {
    Completer completer = new Completer();
    document.addEventListener('polymer-ready', completer.complete);
    _polymerReady = completer.future;
  }
  return _polymerReady;
}