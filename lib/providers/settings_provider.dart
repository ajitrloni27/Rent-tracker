import 'package:flutter_riverpod/flutter_riverpod.dart';

class DarkModeNotifier extends Notifier<bool> {
  @override
  bool build() {
    return false; // Default to light mode
  }

  void toggle() {
    state = !state;
  }
}

final darkModeProvider = NotifierProvider<DarkModeNotifier, bool>(() {
  return DarkModeNotifier();
});
