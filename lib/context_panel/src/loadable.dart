part of cs_elements.context_manager;

/**
 * A [LoadableElement] represents a [PolymerElement] which
 * can be routed to the 
 */
abstract class LoadableElement implements Polymer, Observable {
  
  /// The [ContextPanel] that this element is loaded into.
  /// Will be `null` until the element has been full created and attached
  /// to the DOM.
  ContextPanel get contextPanel;
  set contextPanel(ContextPanel panel);
  
  /// Saves the current state of the element, so that it can be restored
  /// if the [ContextPanel] which loaded this element is tracking 
  /// history via the URL hash.
  /// 
  /// Can return `null` if the element has no mutable state.
  Map<String,dynamic> saveData();
  
  /// Load the data for the element from the given URI. 
  Future loadFromUri(String uri, {Map<String,dynamic> restoreData});
}

class LoadError extends Error {
  final String message;
  final innerException;
  
  LoadError(this.message, this.innerException);
  
  toString() {
    var msg = message;
    if (innerException != null) {
      msg += '\n';
      msg += innerException;
    }
    return msg;
  }
  
}