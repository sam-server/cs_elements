part of cs_elements.context_manager;

final Random _random = new Random();

_genRandomHash() {
  StringBuffer sbuf = new StringBuffer();
  for (var i=0;i<6;i++) {
    sbuf.write(_random.nextInt(16).toRadixString(16));
  }
  return sbuf.toString();
}

/**
 * Tracks history for the application via the url fragment.
 */
class History {
  final Map<String,_HistoryItem> _historyItems;
  
  History(): _historyItems = <String,_HistoryItem>{} {
    window.onHashChange.listen((evt) {
      restoreHistoryItem(evt);
    });
  }
  
  UnmodifiableMapView get trackedItems {
    return new UnmodifiableMapView(_historyItems);
  }
  
  /// Save the history and generate a new window hash.
  /// Returns a [Future] which completes with the new window hash. 
  /// [:saveData:] is a JSON like map containing serializable data.
  /// [:callback:] is called with the saved data.
  Future<String> saveHistory(
      Map<String,dynamic> saveData, 
      void restore(Map<String,dynamic> restoreData)) {
    return new Future.sync(() {
      var h = _genRandomHash();
      while (_historyItems.containsKey(h)) {
        h = _genRandomHash();
      }
      var savLocation = window.location.hash;
      _historyItems[savLocation] = new _HistoryItem(saveData, restore);
      window.location.hash = h;
      return savLocation;
    });
  }
  
  void restoreHistoryItem(HashChangeEvent evt) {
    var fragment = Uri.parse(evt.newUrl).fragment;
    
    var historyItem = _historyItems[fragment];
    if (historyItem == null)
      return;
    print('Restoring history saved at ${historyItem.saved}');
    historyItem.callback(historyItem.saveData);
  }
}

class _HistoryItem {
  final DateTime saved;
  final Map<String,dynamic> saveData;
  final Function callback;
  
  _HistoryItem(this.saveData, this.callback):
    this.saved = new DateTime.now();
  
}

