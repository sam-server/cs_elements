library cs_elements.context_manager.history;

import 'dart:async';
import 'dart:html';
import 'dart:indexed_db' as idb;
import 'dart:math' show Random;

import 'package:quiver/async.dart' show reduceAsync;

abstract class HistoryTracker {
  Map<String,dynamic> saveDataOnPageEntry(String uriEnter);
  Map<String,dynamic> saveDataOnPageExit(String uriEnter, String uriExit);
  
  void restoreState(Map<String,dynamic> savedData);
}

Random _random = new Random();

_genRandomHash() {
  StringBuffer sbuf = new StringBuffer();
  for (var i=0;i<6;i++) {
    sbuf.write(_random.nextInt(16).toRadixString(16));
  }
  return sbuf.toString();
}

class BrowserHistory {
  
  final String historyName;
  final HistoryTracker tracker;
  final BrowserHistoryStore historyStore;
  
  BrowserHistory(this.historyName, this.tracker):
    this.historyStore = new BrowserHistoryStore._() {
    window.onHashChange.listen((HashChangeEvent evt) {
      var oldHash = Uri.parse(evt.oldUrl).fragment;
      var newHash = Uri.parse(evt.newUrl).fragment;
      //Test to see if we are navigating through a back or forward button
      historyStore.lookupAll([oldHash, newHash]).then((items) {
        if (items.every((item) => item != null)) {
          print('both exist');
          var item = items.last;
          if (item.historyName == historyName) {
            tracker.restoreState(item.saveData);
          }
        }
      });
    });
  }
  
  /// Save the history of the given uri when first entering a new page.
  Future saveOnPageEntry(String uriEnter, {String oldHash: null}) {
    var currHash = _windowHash;
    return historyStore.lookup(currHash).then((HistoryItem item) {
      if (item == null) {
        //We've moved to a new page.
        var item = new HistoryItem(historyName, oldHash, currHash);
        item.saveData = tracker.saveDataOnPageEntry(uriEnter);
        print('saving on entry $item');
        return historyStore.save(item);
      } else {
        print('navigating history');
        //This is a page we've already visited.
        //If we match this history, restore any state that was saved on exit.
        if (item.historyName == historyName) {
          tracker.restoreState(item.saveData); 
        }
      }
    });
  }
  
  String get _windowHash {
    var hash = window.location.hash;
    if (hash.startsWith('#'))
      hash = hash.substring(1);
    return hash;
  }
  set _windowHash(String value) {
    window.location.hash = value;
  }
  
  Future saveOnPageExit(String uriExit, String uriEnter) {
    var currHash = _windowHash;
    return historyStore.lookup(currHash).then((item) {
      if (item == null) {
        //throw new StateError('$hash was not saved when entering page $uriEnter');
        return null;
      }
      item.saveData.clear();
      item.saveData = tracker.saveDataOnPageExit(uriEnter, uriExit);
      print('saving on exit: $item');
      return historyStore.save(item);
    }).then((_) {
      var newHash = _genRandomHash();
      _windowHash = newHash;
      return saveOnPageEntry(uriEnter, oldHash: currHash);
    });
    
  }
  
  Future initialLoad() {
    var hash = _windowHash;
    if (hash.startsWith('#'))
      hash = hash.substring(1);
    if (hash.isEmpty) {
      // Clear all expired history from the server.
      // We don't store history older than 1 day
      return historyStore.clearExpiredHistory();
    }
    return historyStore.lookup(hash).then((item) {
      if (item != null && item.historyName == historyName) {
        tracker.restoreState(item.saveData);
      }
    });
  }
}

class BrowserHistoryStore {
  static const _DB_NAME = 'history';
  static const _HISTORY_ITEM_STORE = 'historyItem';
  static const _PREV_HASH_INDEX = 'prevHash_index';
  static const _VERSION = 3;
  static const _EXPIRE_DURATION = const Duration(days: 1);
  
  static Future<idb.Database> _openDb;
  
  Future<idb.Database> _open() {
    if (_openDb == null) {
      initDatabase(idb.VersionChangeEvent evt) {
        idb.Database db = (evt.target as idb.Request).result;
        var objStore = db.createObjectStore(_HISTORY_ITEM_STORE, keyPath: 'hash');
        objStore.createIndex(_PREV_HASH_INDEX, 'prevHash', unique: true);
      }
      var openDbCompleter = new Completer();
      _openDb = openDbCompleter.future;
      window.indexedDB.open(
          _DB_NAME,
          version: _VERSION, 
          onUpgradeNeeded: initDatabase)
      .then(openDbCompleter.complete)
      .catchError(openDbCompleter.completeError);
    }
    return _openDb;
  }
  
  BrowserHistoryStore._();
  
  withTransaction(String mode, Future<dynamic> action(idb.ObjectStore objStore)) {
    return _open().then((db) {
      var transaction = db.transaction(_HISTORY_ITEM_STORE, mode);
      var store = transaction.objectStore(_HISTORY_ITEM_STORE);
      var runAction = action(store);
      if (runAction == null) {
        throw 'An action cannot return `null`';
      }
      return runAction.then((result) {
        return transaction.completed.then((_) => result);
      });
    });
  }
  
  Future<HistoryItem> save(HistoryItem item) {
    return withTransaction('readwrite', (objStore) {
      print('HASH: ${item.hash}');
      return _lookup(objStore, item.hash).then((existing) {
        bool isUpdate = (existing == null);
        if (isUpdate)
          item.updated = new DateTime.now();
        return _deleteNext(objStore, item.prevHash).then((_) {
          var deleteExisting = (isUpdate ? objStore.delete(item.hash) : new Future.value());
          return deleteExisting;
        }).then((_) {
          return objStore.add(item._toRaw());
        });
      });
    }).then((_) => item);
  }
  
  Future<bool> allExist(List<String> hashes) {
    return withTransaction('readonly', (objStore) {
      return reduceAsync(hashes, true, (currValue, hash) {
        return _lookup(objStore, hash).then((item) => currValue || (item == null));
      });
    });
  }
  
  Future<List<HistoryItem>> lookupAll(List<String> hashes) {
    return withTransaction('readonly', (objStore) {
      return reduceAsync(hashes, [], (items, hash) {
        return _lookup(objStore, hash).then((item) => items..add(item));
      });
    });
  }
  
  /**
   * Lookup the [HistoryItem] associated with the given [:hash:].
   * 
   * Runs in a new readonly transaction.
   */
  Future<dynamic> lookup(String hash) {
    return withTransaction('readonly', (objStore) => _lookup(objStore, hash));
  }
  /// Lookup the [HistoryItem] associated with the given [:hash:].
  Future<dynamic> _lookup(idb.ObjectStore objStore, String hash) {
    return objStore.getObject(hash).then((raw) {
      if (raw == null)
        return null;
      return new HistoryItem._fromRaw(raw);
    });
  }
  
  /**
   * Lookup the [HistoryItem] which succeeds this value.
   * 
   * Runs in a new readonly transaction
   */
  Future<HistoryItem> lookupNext(String hash) {
    return withTransaction('readonly', (objStore) => _lookupNext(objStore, hash));
  }
  
  Future<HistoryItem> _lookupNext(idb.ObjectStore objStore, String hash) {
    if (hash == null)
      return _lookup(objStore, '');
    var index = objStore.index(_PREV_HASH_INDEX);
    return index.get(hash).then((var raw) {
      if (raw == null)
        return null;
      return new HistoryItem._fromRaw(raw);
    });
  }
  
  Future clearExpiredHistory() {
    return withTransaction('readwrite', (objStore) {
      var expireBefore = new DateTime.now().subtract(_EXPIRE_DURATION);
      return objStore.openCursor().forEach((cursor) {
        var item = new HistoryItem._fromRaw(cursor.value);
        if (item.updated.isBefore(expireBefore))
          objStore.delete(item);
      });
    });
  }
  
  /// Deletes the item immediately succeeding [:hash:]
  Future _deleteNext(idb.ObjectStore objStore, String hash) {
    return _lookupNext(objStore, hash).then((item) {
      if (item == null)
        return null;
      return objStore.delete(item.hash);
    });
  }
}

class HistoryItem {
  
  final String historyName;
  
  // The hash of the page when this item was stored.
  final String hash;
  
  // The hash immediately before this item in the history.
  final String prevHash;
  
  // The time this hash was updated
  DateTime updated;
  
  // The data that was saved with this item.
  Map<String,dynamic> saveData;
  
  HistoryItem(this.historyName, this.prevHash, String this.hash, [DateTime updated]):
    this.updated = (updated != null ? updated : new DateTime.now()),
    this.saveData = new Map<String,dynamic>();
    
  factory HistoryItem._fromRaw(Map<String,dynamic> rawValue) {
    var item = new HistoryItem(
        rawValue['historyName'], 
        rawValue['prevHash'], 
        rawValue['hash'], 
        DateTime.parse(rawValue['updated']));
    item.saveData = rawValue['saveData'];
    return item;
  }
  
  Map<String,dynamic> _toRaw() {
    return {
      'hash': hash,
      'historyName': historyName,
      'prevHash': prevHash,
      'saveData': saveData,
      'updated': '$updated'
    };
  }
  
  toString() => 'HistoryItem($prevHash -> $hash, at: $updated)';
  
  
  
  
}