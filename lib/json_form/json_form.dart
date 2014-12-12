import 'dart:async';
import 'dart:convert' show JSON;
import 'dart:html' hide Request;

import 'package:http/src/base_client.dart';
import 'package:http/src/request.dart';
import 'package:http/src/response.dart';
import 'package:http/browser_client.dart';

import 'package:polymer/polymer.dart';

@CustomTag('cs-json-form')
class JsonFormElement extends FormElement with Polymer, Observable {
  
  @override
  @published
  String method;
  
  ContentElement get _content => shadowRoot.querySelector('content');
  
  BaseClient _httpClient = new BrowserClient();
  
  BaseClient get httpClient => _httpClient;
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
    
    var request = new Request(this.method, Uri.parse(this.action));
    request.body = JSON.encode(_formJson());
    request.headers['Content-Type'] = 'application/json';
   
    print('Sending $method request to $action');
    print(request.body);
    
    return client.send(request).then(Response.fromStream).then((response) {
      if (response.statusCode != 200) {
        print(response.body);
        throw new FormError('Submit failed. Server returned status ${response.statusCode}');
      }
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
  
  Iterable<InputElement> get _formInputs {
    List<InputElement> formInputs = <InputElement>[];
    for (var elem in _content.getDistributedNodes()) {
      if (elem is InputElement) {
        formInputs.add(elem);
      }
      if (elem is HtmlElement) {
        formInputs.addAll(elem.querySelectorAll('input'));
      }
    }
    return formInputs;
  }
  
  Iterable<SelectElement> get _formSelects {
    List<SelectElement> formSelects = <SelectElement>[];
    for (var elem in _content.getDistributedNodes()) {
      if (elem is SelectElement) {
        formSelects.add(elem);
      }
      if (elem is HtmlElement) {
        formSelects.addAll(elem.querySelectorAll('select'));
      }
    }
    return formSelects;
  }
  
  Map<String,dynamic> _formJson() {
    Map<String,dynamic> result = <String,dynamic>{};
    for (InputElement elem in _formInputs) {
      print('Adding json for: ${elem.name}');
      if (elem.type == 'submit')
        continue;
      if (elem.name == null)
        throw new FormError('Element with `null` name');
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
    }
    
    for (SelectElement elem in _formSelects) {
      //TODO: Handle form <select>s
      //value = elem.selectedOptions.map((opt) => opt.text).toList();
      //var _steps = _Steps.parse(elem.name); 
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

