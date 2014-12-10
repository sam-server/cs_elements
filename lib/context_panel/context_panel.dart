library cs_elements.context_manager;

import 'dart:async';
import 'dart:html';

import 'package:polymer/polymer.dart';

import 'src/history2.dart';
part 'src/loadable.dart';

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
class ContextPanel extends PolymerElement implements HistoryTracker {
  static const _ELEMENT_LOADED_EVT = 'context-panel-element-loaded';
  
  Stream<CustomEvent> get onElementLoaded => on[_ELEMENT_LOADED_EVT];
  
  /// By default, [ContextPanel]s do not track history.
  /// Override this to track history for the panel.
  /// 
  /// If [:trackHistory:] is enabled, the following conditions must
  /// be met by the panel:
  /// 1. The panel must be created on initial load of the page and never
  /// removed from the DOM
  /// 2. An implementation of a unique [:trackName:] should be provided
  /// for the element.
  /// 
  /// NOTE: History tracking should only be enabled for a few 
  /// major context panels in the application, to avoid spamming
  /// hash changes to the url.
  
  /// If [:trackHistory:] is enabled, must provide a unique name for the
  /// panel. In addition, the panel must be created when the app is created
  /// and never destroyed.
  String get trackName => null;
  
  bool get trackHistory => trackName != null;
  
  /// Suppress changing the window hash when loading the element after a 
  /// restored state.
  /// Also true when creating the element, since we're loading a fresh state.
  bool _restoringElement = false;
  
  BrowserHistory _history;
  
  Map<String,LoadableElement> _restoreData;
  
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
    if (trackHistory) {
      this._history = new BrowserHistory(trackName, this);
      this._restoreData = <String,LoadableElement>{};
    }
  }
  
  void attached() {
    super.attached();
    
    // FIXME: Chromium does not yet support distributed nodes in <shadow> elements
    // in implementing defining templates although the functionality is in the shadow dom spec
    // (https://www.w3.org/Bugs/Public/show_bug.cgi?id=22344)
    // Until this is fixed, the following hack manually adds the items to the base shadow DOM.
    var parentShadowRoot = shadowRoot.olderShadowRoot;
    for (var route in shadowRoot.querySelectorAll('shadow > cs-route')) {
      parentShadowRoot.getElementById('router').append(route);
    }
    
    if (trackHistory) {
      _history.initialLoad();
    }
  }
  
  LoadableElement _route(String href) {
    LoadableElement elem;
    if (href == null) 
      throw new ArgumentError('Cannot route `null` href');
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
    print('href changed ($oldValue -> $newValue)');
    if (_restoringElement) {
      print('restoring element');
      _restoringElement = false;
      return;
    }
    this._loadElement(newValue).then((elem) {
      if (trackHistory) {
        if (loadedElement == null) {
          _history.saveOnPageEntry(newValue);
        } else {
          _restoreData[oldValue] = loadedElement;
          _history.saveOnPageExit(oldValue, newValue);
        }
      }
      _replaceContext(elem);
      this.fire(_ELEMENT_LOADED_EVT, detail: elem);
    }).catchError((err, stack) {
      throw new LoadError('An error occurred when loading the element from $href', err);            
    });
  }
  
  Future<Element> _loadElement(String href, {Map<String,dynamic> restoreData: const {}}) {
    var elem = _route(href);
    return elem.loadFromUri(href, restoreData: restoreData)
        .then((_) => elem);
  }
    
  void _replaceContext(LoadableElement elem) {
    $['container'].innerHtml = '';
    $['container'].append(elem);
    elem.contextPanel = this;
  }
    
  @override
  void restoreState(Map<String, dynamic> savedState) {
    var href = savedState['href'];
    var elemData = savedState['element'];
    if (elemData == null)
      elemData = <String,dynamic>{};
    _loadElement(href, restoreData: elemData).then((elem) {
      _restoringElement = true;
      this.href = href;
      _replaceContext(elem);
    });
  }

  @override
  Map<String, dynamic> saveDataOnPageEntry(String uriEnter) {
    print('href: $href');
    return {'href': href, 'element': {}};
  }

  @override
  Map<String, dynamic> saveDataOnPageExit(String uriEnter, String uriExit) {
    var prevLoadedElement = _restoreData.remove(uriExit);
    var elemState = {};
    if (prevLoadedElement != null) {
      elemState = prevLoadedElement.saveData();
    }
    return {'href': uriExit, 'element': elemState};
  }
}
