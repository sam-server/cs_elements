
library cs_elements.asset_details_content;

import 'package:polymer/polymer.dart';

import '../base/asset_base.dart';

@CustomTag('asset-details-content')
class AssetDetailsContent extends PolymerElement with AssetBase {

  @published
  bool get readonly => readValue(#readonly, () => false);
  set readonly(bool value) => writeValue(#readonly, value);

  AssetDetailsContent.created(): super.created();

  @override
  void attached() {
    super.attached();
  }

  @override
  void detached() {
    super.detached();
  }
}
