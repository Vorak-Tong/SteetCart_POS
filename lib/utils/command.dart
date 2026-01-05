import 'package:flutter/widgets.dart';

// P = Param type, R = Return type
class CommandWithParam<P, R> extends ChangeNotifier {
  CommandWithParam(this._action);

  final Future<R> Function(P param) _action;

  bool _running = false;
  bool get running => _running;

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
    if (_running) return;
    _running = true;
    _error = null;
    _stackTrace = null;
    notifyListeners();

    try {
      await _action(param);
    } catch (e, st) {
      _error = e;
      _stackTrace = st;
      notifyListeners();
      rethrow;
    } finally {
      _running = false;
      notifyListeners();
    }
  }
}

class Command<R> extends ChangeNotifier {
  Command(this._action);

  final Future<R> Function() _action;

  bool _running = false;
  bool get running => _running;

  Future<void> execute() async {
    if (_running) return;
    _running = true;
    notifyListeners();

    try {
      await _action();
    } finally {
      _running = false;
      notifyListeners();
    }
  }
}
