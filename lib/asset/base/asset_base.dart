library cs_elements.asset.base;

import 'dart:async';
import 'dart:html';

import 'package:polymer/polymer.dart';
import 'dart:convert' show JSON;

/// A mixin class for elements which publish an [:asset:] attribute
/// which accepts a JSON asset resource.
abstract class AssetBase implements Polymer, Observable {


  /// The asset associated with the element.
  /// The element should dispose the asset during its detach phase.
  @published
  Asset get asset {
    var value = readValue(#asset, () => new Asset());
    if (value is String) {
      value = new Asset.fromResourceString(value);
    } else if (value is Map<String,dynamic>) {
      value = new Asset.fromResource(value);
    }
    return value;
  }
  set asset(dynamic value) {
    if (value is String) {
      value = new Asset.fromResourceString(value);
    } else if (value is Map<String,dynamic>) {
      value = new Asset.fromResource(value);
    }
    writeValue(#asset, value);
  }

}

class Asset extends Observable {

  Map<Symbol, dynamic> _resetData;

  bool get isDirty => _resetData.isNotEmpty;

  @observable
  String id;

  @observable
  String userId;

  @observable
  String imageSrc;

  @observable
  String href;

  @observable
  String name;

  @observable
  String description;

  @observable
  String use;

  @observable
  String modelNumber;

  @observable
  String price;

  @observable
  DateTime datePurchased;

  StreamSubscription _dirtyObserver;

  void _initResetData() {
    _resetData[#name] = this.name;
    _resetData[#description] = this.description;
    _resetData[#price] = this.price;
  }

  Asset() {
    _resetData = <Symbol,dynamic>{};
  }

  void reset() {
    name = _resetData[#name];
    description = _resetData[#description];
    price = _resetData[#price];
    // Wait for the event loop to run before clearing the reset data,
    // since the dirty observer will be called with the old value.
    new Future.value().then((_) => _resetData.clear());
  }

  factory Asset.fromResource(Map<String,dynamic> resource){
    var asset = new Asset();
    asset.id = resource['id'];
    asset.userId = resource['userId'];
    asset.href = resource['qr_code'];
    asset.name = resource['name'];
    asset.description = resource['description'];
    asset.use = resource['use'];
    asset.modelNumber = resource['model_number'];
    asset.imageSrc = resource['image_src'];
    asset.price = resource['price'];
    if (resource['date_purchased'] != null) {
      asset.datePurchased = DateTime.parse(resource['date_purchased']);
    } else {
      asset.datePurchased = null;
    }
    asset._initResetData();
    return asset;
  }

  factory Asset.fromResourceString(String resource) =>
      new Asset.fromResource(JSON.decode(resource));

  Map<String,dynamic> toJson() {
    var resource = <String,dynamic>{};
    resource['kind'] = 'assets#asset';
    resource['id'] = this.id;
    resource['qr_code'] = this.href;
    resource['name'] = this.name;
    resource['description'] = this.description;
    resource['use'] = this.use;
    resource['model_number'] = this.modelNumber;
    resource['image_src'] = this.imageSrc;
    if (this.price != null)
      resource['price'] = this.price;
    if (this.datePurchased != null)
      resource['date_purchased'] = this.datePurchased.toString();
    return resource;
  }

  String toJsonString() => JSON.encode(toJson());
}