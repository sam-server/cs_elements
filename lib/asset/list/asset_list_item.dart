
library cs_elements.asset_list_item;

import 'dart:html';

import 'package:polymer/polymer.dart';
import '../base/asset_base.dart';

@CustomTag('asset-list-item')
class AssetListItem extends PolymerElement with AssetBase {

  AssetListItem.created(): super.created();

  @override
  void attached() {
    super.attached();
  }

  @override
  void detached() {
    super.detached();
  }

  void navigateTo() {
    window.location.href = '/asset/${asset.id}';
  }
}
