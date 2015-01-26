library cs_elements.asset_details;

import 'dart:html';

import 'package:polymer/polymer.dart';
import 'package:polymer_ajax_form/ajax_form.dart';

import '../../session/session.dart';
import '../base/asset_base.dart';


@CustomTag('asset-details')
class AssetDetails extends PolymerElement with AssetBase {

  @PublishedProperty(reflect: true)
  bool get create => readValue(#create, () => false);
  set create(bool value) => writeValue(#create, value);

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
  }

  void saveAssetChanges([Event e]) {
    if (e != null)
      e.preventDefault();
    $['mainform'].submit().then((FormResponse response) {
      print(response.responseText);
      var body = response.responseJson;
      if (response.status >= 200 && response.status < 300) {
        if (create) {
          this.create = false;
        }

        this.asset = new Asset.fromResource(body);
      } else {
        print(body);
      }
    });
  }

  void resetAssetChanges([Event e]) {
    if (e != null)
      e.preventDefault();
    asset.reset();
  }

  void captureImage([Event e]) {
    if (e != null)
      e.preventDefault();
    var fileInput = shadowRoot.querySelector('input[type=file');
    fileInput.onChange.first.then((Event e) {
      if (fileInput.files.isNotEmpty) {
        var file = fileInput.files.first;
        _loadFileIntoAsset(file);
      }
    });
    fileInput.click();
  }

  void _loadFileIntoAsset(File file) {
    var fileReader = new FileReader();
    fileReader.onLoad.first.then((_) {
      asset.imageSrc = fileReader.result;
    });
    fileReader.readAsDataUrl(file);
  }
}