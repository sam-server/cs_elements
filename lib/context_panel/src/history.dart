part of cs_elements.context_manager;

final Random _random = new Random();

_genRandomHash() {
  StringBuffer sbuf = new StringBuffer();
  for (var i=0;i<6;i++) {
    sbuf.write(_random.nextInt(16).toRadixString(16));
  }
  return sbuf.toString();
}

typedef void RestoreCallback(String atHash, Map<String,dynamic> savedData);

/**
 * Tracks history for the application via the url fragment.
 */
class History {
  static const EXPIRE_DURATION = const Duration(minutes: 15);
  
  final Map<String,_HistoryItem> _historyItems;
  
  History(): _historyItems = <String,_HistoryItem>{} {
    window.onHashChange.listen((evt) {
      restoreHistoryItem(evt);
    });
    new Timer.periodic(EXPIRE_DURATION, _deleteExpiredData);
  }
  
  UnmodifiableMapView get trackedItems {
    return new UnmodifiableMapView(_historyItems);
  }
  
  /// Save the history and generate a new window hash.
  /// Returns a [Future] which completes with the new window hash. 
  /// [:saveData:] is a JSON like map containing serializable data.
  /// [:callback:] is called with the saved data when the hash is changed
  /// to the created value.
  Future<String> saveHistory(
      Map<String,dynamic> saveData, 
      RestoreCallback restore,
      {String atHash: null}) {
    return new Future.sync(() {
      if (atHash == null)
        atHash = window.location.hash;
      print('Saving history at hash $atHash');
      print(saveData);
      _historyItems[atHash] = new _HistoryItem(saveData, restore);
      
      if (atHash == window.location.hash) {
        var h = _genRandomHash();
        while (_historyItems.containsKey(h)) {
          h = _genRandomHash();
        }
        print('updating window hash');
        window.location.hash = h;
      }
      return atHash;
    });
  }
  
  void restoreHistoryItem(HashChangeEvent evt) {
    var fragment = Uri.parse(evt.newUrl).fragment;
    var historyItem = _historyItems[fragment];
    if (historyItem == null)
      return;
    var oldHash = Uri.parse(evt.oldUrl).fragment;
    print('Restoring history \'${fragment}\' saved at ${historyItem.saved}');
    
    historyItem.callback(oldHash, historyItem.saveData);
  }
  
  void _deleteExpiredData(Timer timer) {
    var now = new DateTime.now();
    var toRemove = <String>[];
    _historyItems.forEach((k, v) {
      if (v.saved.add(EXPIRE_DURATION).isBefore(now)) {
        toRemove.add(k);
      }
    });
    toRemove.forEach(_historyItems.remove);
  }
}

class _HistoryItem {
  DateTime saved;
  Map<String,dynamic> saveData;
  final Function callback;
  
  
  _HistoryItem(this.saveData, this.callback):
    this.saved = new DateTime.now();
}

