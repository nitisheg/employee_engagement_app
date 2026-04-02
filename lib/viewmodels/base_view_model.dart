import 'package:flutter/foundation.dart';

enum ViewState { idle, loading, success, error }

abstract class BaseViewModel extends ChangeNotifier {
  ViewState _state = ViewState.idle;
  String? _error;

  ViewState get state => _state;
  String? get error => _error;
  bool get isLoading => _state == ViewState.loading;
  bool get isSuccess => _state == ViewState.success;
  bool get hasError => _state == ViewState.error;

  void setState(ViewState newState, {String? error}) {
    _state = newState;
    _error = error;
    notifyListeners();
  }

  void setLoading() => setState(ViewState.loading);
  void setSuccess() => setState(ViewState.success);
  void setError(String error) => setState(ViewState.error, error: error);
  void setIdle() => setState(ViewState.idle);
  void reset() => setState(ViewState.idle);
}
