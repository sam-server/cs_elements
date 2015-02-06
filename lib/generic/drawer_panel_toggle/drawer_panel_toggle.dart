
library cs_elements.drawer_panel_toggle;

import 'package:polymer/polymer.dart';

@CustomTag('drawer-panel-toggle')
class DrawerPanelToggle extends PolymerElement {

  @published
  bool get expanded => readValue(#expanded, () => false);
  set expanded(bool value) => writeValue(#expanded, value);

  DrawerPanelToggle.created(): super.created() {
    print('drawer panel toggle created');
  }

  @override
  void attached() {
    super.attached();
  }

  @override
  void detached() {
    super.detached();
  }


}
