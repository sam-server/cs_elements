
library cs_elements.asset_list;

import 'dart:html';

import 'package:polymer/polymer.dart';
import '../base/asset_list_base.dart';
import 'asset_list_item.dart';

@CustomTag('asset-list')
class AssetList extends PolymerElement with AssetListBase {
  AssetList.created(): super.created();

  @override
  void attached() {
    super.attached();
  }

  @override
  void detached() {
    super.detached();
  }

  void createAsset(Event e) {
    e.preventDefault();
    window.location.href = '/asset/create';
  }

  void handleAssetDeleted([Event e]) {
    print('asset deleted');
    print((e.target as AssetListItem).asset);
    this.assetList.assets.removeWhere(
        (asset) => asset.id == (e.target as AssetListItem).asset.id
    );

  }
}
