library cs_elements.asset.asset_list_base;

import 'dart:convert' show JSON;

import 'package:polymer/polymer.dart';

import 'asset_base.dart';

abstract class AssetListBase implements Polymer, Observable {

  @published
  AssetListResource get assetList => readValue(#assetList, () => new AssetListResource());
  set assetList(dynamic value) {
    if (value is String) {
      print(value);
      value = new AssetListResource.fromJsonString(value);
    } else if (value is Map) {
      value = new AssetListResource.fromJson(value);
    }
    writeValue(#assetList, value);
  }
}

class AssetListResource extends Observable {

  @observable
  String nextPageToken;

  @observable
  String userId;

  ObservableList<Asset> assets;

  AssetListResource(): super() {
    this.assets = new ObservableList<Asset>();
  }

  factory AssetListResource.fromJson(Map<String,dynamic> json) {
    var assetList = new AssetListResource();
    assetList.nextPageToken = json['next_page_token'];
    assetList.userId = json['user_id'];
    assetList.assets.addAll(json['assets'].map(
        (assetResource) => new Asset.fromResource(assetResource)
    ));
    return assetList;
  }

  factory AssetListResource.fromJsonString(String resource) =>
      new AssetListResource.fromJson(JSON.decode(resource));

  Map<String,dynamic> toJson() {
    var json = <String,dynamic>{};
    json['nextPageToken'] = nextPageToken;
    json['userId'] = userId;
    json['assets'] = new List.from(assets.map((asset) => asset.toJson()));
    return json;
  }

  String toJsonString() => JSON.encode(toJson());

}