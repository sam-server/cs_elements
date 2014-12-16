import 'dart:async';
import 'dart:convert' show JSON;
import 'dart:html' hide Request;

import 'package:http/src/base_client.dart';
import 'package:http/src/request.dart';
import 'package:http/src/response.dart';
import 'package:http/browser_client.dart';

import 'package:polymer/polymer.dart';

import '../money_input/money_input.dart';

@CustomTag('cs-json-form')
class JsonFormElement extends FormElement with Polymer, Observable {
  
  @override
  @published
  String method;
  
  ContentElement get _content => shadowRoot.querySelector('content');
  
  BaseClient _httpClient = new BrowserClient();
  
  BaseClient get httpClient {
    var session = document.querySelector('cs-session');
    if (session == null) {
      throw 'No session element found in document';
    }
    return session.httpClient;
  }
  set httpClient(BaseClient value) => _httpClient = value;
  
  JsonFormElement.created(): super.created() {
    polymerCreated();
  }
  
  void attached() {
    for (var elem in _content.getDistributedNodes()) {
      if (elem is InputElement && elem.type == 'submit') {
        elem.onClick.listen(this.submitJson);
      }
    }
  }
  
  /**
   * Submit the form. If a [:client:] is provided, then it
   * will be used for form submission, otherwise uses [:httpClient:].
   */
  Future<Response> submit({BaseClient client}) {
    
    if (client == null)
      client = httpClient;
    
    var formAction = action;
    if (formAction == null || formAction.isEmpty) {
      formAction = window.location.href;
    }
    
    var request = new Request(this.method, Uri.parse(formAction));
    request.body = JSON.encode(_formJson());
    request.headers['Content-Type'] = 'application/json';
   
    print('Sending $method request to $formAction');
    print(request.body);
    
    return client.send(request).then(Response.fromStream).then((response) {
      this.fire('submit', onNode: this, detail: new FormResponseDetail(response));
      return response;
    });
    
  }
  
  /// Submit the content of the form.
  /// When the server returns a response, a CustomEvent with 'detail' set to
  /// a [FormResponseDetail] object will be returned.
  Future submitJson(Event evt) {
    evt.preventDefault();
    return this.submit();
  }
  
  Iterable<Element> _gatherFormInputs(Element elem) {
    List<Element> formInputs = <Element>[];
    if (elem is ContentElement) {
      var distributedElems = elem.getDistributedNodes()
          .where((node) => node is Element);
      for (var distributedElem in distributedElems) {
        formInputs.addAll(_gatherFormInputs(distributedElem));
      }
    } else if (elem is InputElement) {
      formInputs.add(elem);
    } else if (elem is SelectElement) {
      formInputs.add(elem);
    } else if (elem is TextAreaElement) {
      formInputs.add(elem);
    } else if (elem is MoneyInput) {
      //FIXME: Needs to be publishable by value
      formInputs.add(elem);
      
    } else if (elem.shadowRoot != null) {
      for (var shadowedElem in elem.shadowRoot.children) {
        formInputs.addAll(_gatherFormInputs(shadowedElem));
      }
    } else {
      for (var child in elem.children) {
        formInputs.addAll(_gatherFormInputs(child));
      }
    }
    return formInputs;
  }
  
  Iterable<Element> get _formInputs {
    return _gatherFormInputs(_content);
  }
  
  Map<String,dynamic> _formJson() {
    Map<String,dynamic> result = <String,dynamic>{};
    for (Element elem in _formInputs) {
      if (elem is InputElement) {
        print('Adding json for: ${elem.name}');
        if (elem.type == 'submit')
          continue;
        if (elem.name == null || elem.name.isEmpty)
          continue;
        if (!elem.checkValidity()) {
          throw new FormError('Invalid element (${elem.name}) in form');
        }
        var steps = _Steps.parse(elem.name);
        var value;
        if (elem.type == 'file') {
          throw new FormError("'file' type on input elements not supported");
        } else if (elem.type == 'checkbox') {
          value = elem.checked;
        } else if (elem.type == 'radio') {
          if (elem.checked) {
            if (elem.multiple) {
              value = (value == null ? [] : value)..add(elem.value);
            } else {
              value = elem.value;
            }
          }
        } else {
          value = elem.value;
        }
        print('\tElement value: $value');
        if (value != null)
          steps.setJsonValue(result, value);
      } else if (elem is MoneyInput) {
        var value = {
          'code': elem.currencyCode,
          'value': elem.value,
        };
        var steps = _Steps.parse(elem.name);
        steps.setJsonValue(result, value);
        
      } else if (elem is SelectElement) {
        //TODO: Handle <select>
      } else if (elem is TextAreaElement) {
        //TODO: Handle <textarea>
      }
    }
    return result;
  }
}

class FormResponseDetail {
  final Response response;
  
  int get statusCode => response.statusCode;
  
  /**
   * The body of the response as a JSON map (if the returned object was
   *  
   */
  Map<String,dynamic> get responseJson {
    return JSON.decode(response.body);
  }
  
  FormResponseDetail(this.response);
}


/**
 * A [_Step] is a singly linked list of elements of a JSON path, representing
 * the key into the top level json object to insert a value.
 * 
 * Each element of the list has a [:type:] and a [:key:].
 * 
 */
class _Steps {
  /// Matches a nonempty list of characters up to the first '[' character in the path
  static final INIT_PATTERN = new RegExp(r'[^[]+');
  /// Matches an index into a JSON array
  static final INDEX_PATTERN = new RegExp(r'\[(\d+)\]');
  /// Matches a key lookup on a JSON object
  static final KEY_PATTERN = new RegExp(r'\[(.*?)\]');
  
  final String type;
  final String key;
  
  _Steps next;
  
  _Steps(this.type, this.key);
  
  bool get isLast => next == null;
  String get nextType => isLast ? null : next.type;
  
  int get index {
    if (type == 'array') {
      return int.parse(key);
    }
    throw new StateError("'object' step has no index");
  }
  
  static _Steps parse(String path) {
    var match = INIT_PATTERN.matchAsPrefix(path);
    if (match == null) {
      throw new FormatException(0, 'No match for INIT_PATTERN');
    }
    
    var initStep = new _Steps('object', match.group(0));
    var currStep = initStep;
    var position = match.end;
    
    while (position < path.length) {
      print('position: $position');
      match = INDEX_PATTERN.matchAsPrefix(path, position);
      if (match != null) {
        position = match.end;
        currStep.next = new _Steps('array', match.group(1)); 
        currStep = currStep.next;
        continue;
      }
      match = KEY_PATTERN.matchAsPrefix(path, position);
      if (match != null) {
        position = match.end;
        currStep.next = new _Steps('object', match.group(1));
        currStep = currStep.next;
      }
    }
    return initStep;
  }
  
  void setJsonValue(Map<String,dynamic> obj, var entryValue) {
    // initial step value is always an 'object'
    _setJsonObjectValue(obj, entryValue);
  }
  
  void _setJsonObjectValue(Map<String,dynamic> obj, var entryValue) {
    if (isLast) {
      obj[key] = entryValue;
    } else {
      if (obj[key] == null) {
        if (nextType == 'array') {
          obj[key] = [];
          return next._setJsonArrayValue(obj[key], entryValue);
        } else {
          obj[key] = {};
          return next._setJsonObjectValue(obj[key], entryValue);
        }
      } else if (obj[key] is Map) {
        return next._setJsonObjectValue(obj[key], entryValue);
      } else if (obj[key] is List) {
        if (nextType == 'object') {
          //convert value to object
          obj[key] = obj[key].toMap();
          return next._setJsonObjectValue(obj[key], entryValue);
        } else {
          return next._setJsonArrayValue(obj[key], entryValue);
        }
      }
    }
  }
  
  void _setJsonArrayValue(List<dynamic> arr, var entryValue) {
    assert(type == 'array');
    var index = this.index;
    if (isLast) {
      if (arr.length <= index) {
        arr.length = index + 1;
      }
      arr[index] = entryValue;
    } else {
      if (arr[index] == null) {
        if (nextType == 'object') {
          arr[index] = {};
          return next._setJsonObjectValue(arr[index], entryValue);
        } else if (nextType == 'array') {
          arr[index] = [];
          return next._setJsonArrayValue(arr[index], entryValue);
        }
      } else if (arr[index] is Map) {
        return next._setJsonObjectValue(arr[index], entryValue);
      } else if (arr[index] is List) {
        if (nextType == 'object') {
          //convert value to object
          arr[index] = arr[index].toMap();
          return next._setJsonObjectValue(arr[index], entryValue);
        } else {
          return next._setJsonArrayValue(arr[index], entryValue);
        }
      }
    }
  }
}

class FormError extends ArgumentError {
  FormError(String message): super(message);
}

class FormatException implements Exception {
  final int position;
  final String message;
  FormatException(this.position, this.message);
  
  toString() => 'Format exception at ($position): $message';
}

