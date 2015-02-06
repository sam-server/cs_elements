
library cs_elements.generic.optional_image;

import 'dart:async';
import 'dart:html';

import 'package:polymer/polymer.dart';

@CustomTag('optional-image')
class OptionalImage extends PolymerElement {

  @published
  String get src => readValue(#src, () => null);
  set src(String value) => writeValue(#src, value);

  @observable
  bool showControls;

  @observable
  bool phoneScreen;

  InputElement get _input =>
      shadowRoot.querySelector('input[type=file]');

  List<StreamSubscription> _subscriptions;

  OptionalImage.created(): super.created() {
    showControls = false;
    _subscriptions = <StreamSubscription>[];
  }

  @override
  void attached() {
    super.attached();

    _subscriptions.add(this.onMouseEnter.listen((_) {
     showControls = true;
   }));

   _subscriptions.add(this.onMouseLeave.listen((_) {
     showControls = false;
   }));
  }

  @override
  void detached() {
    super.detached();
  }

  void chooseImage([Event e]) {
    if (e != null) e.preventDefault();
    _input.onChange.first.then((_) {
      _loadFileSrc(_input.files);
    });
    _input.click();
  }

  void clearImage([Event e]) {
    if (e != null) e.preventDefault();
    _input.value = '';
    _loadFileSrc(_input.files);
  }

  void _loadFileSrc(Iterable<File> files) {
    if (files.isEmpty) {
      this.src = null;
    } else {
      var file = files.first;
      var fileReader = new FileReader();
      fileReader.onLoad.first.then((_) {
        this.src = fileReader.result;
      });
      fileReader.readAsDataUrl(file);
    }
  }
}
