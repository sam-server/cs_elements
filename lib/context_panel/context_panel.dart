library cs_elements.context_manager;

import 'dart:async';
import 'dart:html';

import 'dart:math' show Random;

import 'package:polymer/polymer.dart';
import 'package:collection/collection.dart' show UnmodifiableMapView;

part 'src/history.dart';
part 'src/loadable.dart';

// Declare a global [History]. We don't want multiple panels maintaining
// different histories.
final History _history = new History();

/// 
/// A [ContextPanel] is a container for elements fetched from the server
/// by URL.
/// When the [:href:] attribute is set, the uri is routed using the routes
/// defined in the template, in the order they are declared. The given element
/// is then loaded into the container.
/// 
/// A [ContextPanel] is not intended to be used directly. Instead a polymer element
/// containing the routes of the element should be defined and should contain
/// links to any elements matched by the routes.
/// 
/// All elements loaded into the [ContextPanel] must implement the [LoadableElement]
/// interface.
/// 
/// eg.
///     <link rel="import" href="path/to/polymer.html">
///     
///     <link rel="import" href="path/to/cs_elements/context_pane.html">
///     <link rel="import" href="path/to/cs_elements/router.html">
///     
///     <link rel="import" href="path/to/loadable_1.html">
///     <link rel="import" href="path/to/loadable_2.html">
///     
///     <polymer-element name="my-context-panel" extends="cs-context-panel">
///       <template>
///         <!-- template html goes here -->
///         <shadow>
///           <!-- the shadow element should be inserted wherever the
///                loadable element should appear in the panel.
///                
///                Routes to the elements children must be defined as 
///                children of the shadow element
///           -->
///           <cs-route pattern="^/path/to/loadable_1" tag="loadable_1-element">
///           <cs-route pattern="^/path/to/loadable_2" tag="loadable_2-element">
///         </shadow>
///           
///       </template>
///       <script type="application/dart" src="path/to/script/src.dart"></script>
///     </polymer-element>
///     
@CustomTag('cs-context-panel')
class ContextPanel extends PolymerElement {
  
  Stream<CustomEvent> get onElementLoaded => on['context-panel-element-loaded'];
  
  /// By default, [ContextPanel]s do not track history.
  /// Override this to track history for the panel.
  /// 
  /// NOTE: History tracking should only be enabled for a few 
  /// major context panels in the application, to avoid spamming
  /// hash changes to the url.
  final bool trackHistory = false;
  
  List<String> _trackedHistory;
  
  Map<String,Map<String,dynamic>> get history {
    return new Map.fromIterable(
        _trackedHistory, 
        value: (k) => _history._historyItems[k].saveData
    );
  }
  
  /// The currently loaded element
  LoadableElement get loadedElement {
    var loadedElements = $['container'].children;
    if (loadedElements.isEmpty)
      return null;
    return loadedElements.single;
  }
  
  @published
  String get href => readValue(#href, () => '');
  set href(String value) => writeValue(#href, value);
  
  ContextPanel.created(): super.created() {
    _trackedHistory = [];
  }
  
  void attached() {
    super.attached();
    // FIXME: Chromium does not yet support distributed nodes in <shadow> elements
    // in implementing defining templates although the functionality is in the shadow dom spec
    // (https://www.w3.org/Bugs/Public/show_bug.cgi?id=22344)
    // Until this is fixed, the following hack manually adds the items to the base shadow DOM.
    var parentShadowRoot = shadowRoot.olderShadowRoot;
    print(parentShadowRoot.children);
    var shadowElem = shadowRoot.querySelector('shadow');
    for (var route in shadowElem.querySelectorAll('cs-route')) {
      parentShadowRoot.getElementById('router').append(route);
    }
  }
  
  LoadableElement _route(String href) {
    LoadableElement elem;
    try {
      elem = $['router'].route(href);
    } on TypeError catch (e) {
      throw new LoadError('Elements in ContextPanels must implement the '
                          'LoadableElement interface (got $elem)', e);
    }
    return elem;
  }
    
  /// Load the context into the given [:href:]
  void hrefChanged(String oldValue, String newValue) {
    var elem = _route(newValue);
    elem.loadFromUri(newValue).then((_) {
      DivElement panelContainer = $['container'];
      if (trackHistory && loadedElement != null) {
        var saveData = {'href': oldValue};
        saveData['element'] = loadedElement.saveData();
        print('Saving history for $oldValue');
        return _history.saveHistory(saveData, _restoreContext).then((savLocation) {
          _trackedHistory.add(savLocation);
        });
      }
    }).then((_) {
      _replaceContext(elem);
      this.fire('context-panel-element-loaded', detail: elem);
    }).catchError((err, stackTrace) {
      throw new LoadError('An error occurred when loading the element'
                          'from $href', err);
    });
  }
    
    void _replaceContext(LoadableElement elem) {
      $['container'].innerHtml = '';
      $['container'].append(elem);
      elem.contextPanel = this;
    }
    
    void _restoreContext(Map<String,dynamic> restoreData) {
      var href = restoreData['href'];
      var elem = _route(href);
      elem.loadFromUri(href, restoreData: restoreData['element']).then((_) {
        _replaceContext(elem);
      });
    }
}
