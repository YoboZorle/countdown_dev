import 'package:flutter/material.dart';

enum ViewType { grid, tree, timeline, board }

class ViewProvider extends ChangeNotifier {
  ViewType _currentView = ViewType.grid;
  
  ViewType get currentView => _currentView;
  
  void setView(ViewType view) {
    _currentView = view;
    notifyListeners();
  }
}