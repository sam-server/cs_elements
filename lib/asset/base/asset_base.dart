library cs_elements.asset.base;

import 'dart:async';

import 'package:polymer/polymer.dart';
import 'dart:convert' show JSON;

/// A mixin class for elements which publish an [:asset:] attribute
/// which accepts a JSON asset resource.
abstract class AssetBase implements Polymer, Observable {


  /// The asset associated with the element.
  /// The element should dispose the asset during its detach phase.
  @published
  Asset get asset => readValue(#asset, () => new Asset());
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

  Asset() {
    _resetData = <Symbol,dynamic>{};
    _dirtyObserver = this.changes.listen((List<PropertyChangeRecord> changes) {
      changes.forEach((record) {
        //Currently just two editable fields.
        if (record.name == #description ||
            record.name == #price) {
          // Only want to store the original value
          if (_resetData[record.name] != null)
            return;
          _resetData[record.name] = record.oldValue;
        }
      });
    });
  }

  void reset() {
    if (_resetData[#description] != null)
      description = _resetData[#description];
    if (_resetData[#price] != null)
      price = _resetData[#price];
    // Wait for the event loop to run before clearing the reset data,
    // since the dirty observer will be called with the old value.
    new Future.value().then((_) => _resetData.clear());
  }

  void dispose() {
    _dirtyObserver.cancel();
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
    asset.price = resource['price'];
    if (resource['date_purchased'] != null) {
      asset.datePurchased = DateTime.parse(resource['date_purchased']);
    } else {
      asset.datePurchased = null;
    }
    return asset;
  }

  factory Asset.fromResourceString(String resource) =>
      new Asset.fromResource(JSON.decode(resource));

  Map<String,dynamic> toResource() {
    var resource = <String,dynamic>{};
    resource['kind'] = 'assets#asset';
    resource['id'] = this.id;
    resource['qr_code'] = this.href;
    resource['name'] = this.name;
    resource['description'] = this.description;
    resource['use'] = this.use;
    resource['model_number'] = this.modelNumber;
    if (this.price != null)
      resource['price'] = this.price;
    if (this.datePurchased != null)
      resource['date_purchased'] = this.datePurchased.toString();
    return resource;
  }

  String toResourceString() => JSON.encode(toResource());
}