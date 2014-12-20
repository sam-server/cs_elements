library cs_elements.form_controls;

import 'dart:html';

import 'package:polymer/polymer.dart';

@CustomTag('cs-form-control-panel')
class FormControlPanel extends PolymerElement {

  /// The state that the [Controls] are in.
  /// This affects which of the child controls are currently displayed in the element
  @PublishedProperty(reflect: true)
  String state;

  Iterable<FormControlElement> get visibleControls =>
      _content.getDistributedNodes()
      .where((node) => node is FormControlElement && node.visible);


  PathObserver _stateChanged;

  ContentElement get _content => shadowRoot.querySelector('content');

  FormControlPanel.created(): super.created() {
    _stateChanged = new PathObserver(this, 'state');
    _stateChanged.open(_redrawControls);
  }

  void detached() {
    _stateChanged.close();
  }

  void _redrawControls(newState) {
    var controlElements = _content.getDistributedNodes()
        .where((elem) => elem is FormControlElement);
    controlElements.forEach((FormControlElement elem) {
      elem.visible = (elem.visibleState == newState);
    });
  }
}

@CustomTag('cs-form-control')
class FormControlElement extends PolymerElement {

  /// The state of the parent in which this will be active.
  @published
  String get visibleState => readValue(#visibleState, () => 'enabled');
  set visibleState(String value) => writeValue(#visibleState, value);

  /// Whether the control element is visible.
  @observable
  bool visible;

  FormControlElement.created(): super.created();

  void attached() {
    if (parent is FormControlPanel) {
      var panel = parent as FormControlPanel;
      this.visible = (panel.state == visibleState);
    }
  }
}