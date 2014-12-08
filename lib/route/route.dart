library cs_elements.route;

import 'dart:html';

import 'package:polymer/polymer.dart';

/**
 * A [Route] for a given context. Each route element in a context pane is matched
 * against the [:href:] attribute of the pane.
 */
@CustomTag("cs-route")
class RouteElement extends PolymerElement {
  
  RegExp _compiled;
  
  RegExp get compiledPattern {
    if (_compiled == null || _compiled.pattern != this.pattern) {
      _compiled = new RegExp(this.pattern);
    }
    return _compiled;
  }
  
  @published
  String get pattern => readValue(#pattern);
  set pattern(String value) => writeValue(#pattern, value);
  
  // TODO: Should replace with an 'action' or 'match' attribute 
  // instead of 'tag'. Then a <cs-route> can be used for more than 
  // just the context pane routing :D
  @published
  String get tag => readValue(#tag);
  set tag(String value) => writeValue(#tag, value);
  
  RouteElement.created(): super.created();
  
  Iterable<Node> get _children => 
      (shadowRoot.querySelector('content') as ContentElement)
      .getDistributedNodes();
  
  /**
   * Routes the given path against the route and all it's children.
   */
  Element route(String path) {
    var visitedPatterns = [];
    var elem;
    if (pattern == null) {
      //This is just a container for a collection of routers.
      elem = _routeChildren(path, 0, visitedPatterns);
    } else {
      elem = _route(path, 0, visitedPatterns);
    }
    if (elem == null) {
      throw new RouteError('No match for \'$path\'', visitedPatterns);
    }
    return elem;
  }
  
  Element _routeChildren(String path, int depth, List visitedPatterns) {
    for (RouteElement subroute in _children.where((elem) => elem is RouteElement)) {
      var elem = subroute._route(path, depth, visitedPatterns);
      if (elem != null)
        return elem;
    }
    return null;
  }
  
  /**
   * Test whether the pattern matches against the href fragment.
   * First the [:remainingHref:] is matched against the route's pattern,
   * then the matching portion is stripped from the start of the path
   * and the remainder is matched against each of the children of the [RouteElement].
   * 
   * When the most specific route that matches [:compiledPattern:] is found,
   * the element which is declared in the route's [:tag:] attribute is created
   * in the DOM and returned.
   */
  Element _route(String path, int depth, List visitedPatterns) {
    visitedPatterns.add([depth, this.pattern]);
    
    var match = this.compiledPattern.matchAsPrefix(path);
    if (match == null) {
      return null;
    }
    
    path = path.substring(match.end);
    // Look for a more specific route in the children who are also [RouteElement]s
    var elem = this._routeChildren(path, depth + 1, visitedPatterns);
    if (elem != null)
      return elem;
    if (this.tag == null)
      return null;
    return document.createElement(this.tag);
  }
}

class RouteError extends StateError {
  List visitedPaths;
  RouteError(String message, [List this.visitedPaths]): super(message);
  
  toString() {
    var msg = 'RouteError: ($message)';
    if (this.visitedPaths != null) {
      msg += '\nThe following paths were visited in order, but no match was found:\n';
      for (var path in visitedPaths) {
        var depth = path[0];
        var pattern = path[1];
        msg +='${'  ' * depth}$pattern\n';
      }
    }
    return msg;
  }
}
