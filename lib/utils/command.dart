import 'package:flutter/widgets.dart';

// P = Param type, R = Return type
class CommandWithParam<P, R> extends ChangeNotifier {
  CommandWithParam(this._action);

  final Future<R> Function(P param) _action;

  bool _running = false;
  bool get running => _running;

  bool _hasQueued = false;
  P? _queuedParam;

  Object? _error;
  Object? get error => _error;
  bool get hasError => _error != null;

  StackTrace? _stackTrace;
  StackTrace? get stackTrace => _stackTrace;

  void clearError() {
    if (_error == null) return;
    _error = null;
    _stackTrace = null;
    notifyListeners();
  }

  // Execute now accepts a parameter of type P
  Future<void> execute(P param) async {
    if (_running) {
      _queuedParam = param;
      _hasQueued = true;
      return;
    }

    var currentParam = param;
    while (true) {
      _running = true;
      _error = null;
      _stackTrace = null;
      notifyListeners();

      try {
        await _action(currentParam);
      } catch (e, st) {
        _error = e;
        _stackTrace = st;
        notifyListeners();
        rethrow;
      } finally {
        _running = false;
        notifyListeners();
      }

      if (!_hasQueued) {
        break;
      }
      currentParam = _queuedParam as P;
      _queuedParam = null;
      _hasQueued = false;
    }
  }
}
