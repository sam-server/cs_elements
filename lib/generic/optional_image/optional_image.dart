
library cs_elements.generic.optional_image;

import 'package:polymer/polymer.dart';

@CustomTag('optional-image')
class OptionalImage extends PolymerElement {

  @published
  String get src => readValue(#src, () => null);
  set src(String value) => writeValue(#src, value);

  OptionalImage.created(): super.created();

  @override
  void attached() {
    super.attached();
  }

  @override
  void detached() {
    super.detached();
  }
}
