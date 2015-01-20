library cs_elements.asset_details;

import 'dart:html';

import 'package:polymer/polymer.dart';

import '../../session/session.dart';
import '../base/asset_base.dart';


@CustomTag('asset-details')
class AssetDetails extends PolymerElement with AssetBase {

  @observable
  SessionElement session;

  AssetDetails.created(): super.created();

  void attached() {
    super.attached();
    Polymer.onReady.then((_) {
      session = document.querySelector('cs-session');
    });
  }

  void detached() {
    super.detached();
    asset.dispose();
  }

  void saveAssetChanges() {

  }

  void resetAssetChanges() {
    asset.reset();
  }
}