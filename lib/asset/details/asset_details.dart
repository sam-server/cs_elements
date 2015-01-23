library cs_elements.asset_details;

import 'dart:html';

import 'package:polymer/polymer.dart';
import 'package:polymer_ajax_form/ajax_form.dart';

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

  void saveAssetChanges([Event e]) {
    e.preventDefault();
    $['mainform'].submit().then((FormResponse response) {
      var body = response.responseJson;
      if (response.status >= 200 && response.status < 300) {
        print('success');
        this.asset = new Asset.fromResource(body);
      } else {
        print(body);
      }

    });
  }

  void resetAssetChanges() {
    asset.reset();
  }
}