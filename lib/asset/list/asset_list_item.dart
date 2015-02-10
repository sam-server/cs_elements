
library cs_elements.asset_list_item;

import 'dart:async';
import 'dart:html';

import 'package:polymer/polymer.dart';
import 'package:core_elements/core_ajax_dart.dart';
import '../base/asset_base.dart';
import '../../session/session.dart';

@CustomTag('asset-list-item')
class AssetListItem extends PolymerElement with AssetBase {

  Stream get onAssetDeleted => on['asset-deleted'];

  @observable bool deletingAsset;

  SessionElement get session {
    return document.querySelector('cs-session');
  }

  AssetListItem.created(): super.created() {
    deletingAsset = false;
  }

  @override
  void attached() {
    super.attached();
    Polymer.onReady.then((_) {
      //session = document.querySelector('cs-session');
      //print(session.sessionHeaders);
    });
  }

  @override
  void detached() {
    super.detached();
  }

  void navigateTo() {
    window.location.href = '/asset/${asset.id}';
  }

  void deleteAsset() {
    CoreAjax coreAjax = shadowRoot.querySelector('core-ajax-dart');
    HttpRequest request = coreAjax.go();
    deletingAsset = true;

    request.onLoad.first.then((_) {
      if (request.status == 200) {
        deletingAsset = false;
        this.fire('asset-deleted', detail: this);
      }
    });

  }
}
