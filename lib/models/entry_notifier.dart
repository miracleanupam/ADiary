import 'package:adiary/models/entry.dart';
import 'package:flutter/widgets.dart';

class EntryNotifier extends ChangeNotifier {
  int _count = 0;
  int get count => _count;

  void refresh() async {
    _count = await EntryProvider().getCount();
    notifyListeners();
  }
}

class EntryNotifierScope extends InheritedNotifier<EntryNotifier> {
  const EntryNotifierScope({
    super.key,
    required EntryNotifier notifier,
    required super.child,
  }) : super(notifier: notifier);

  static EntryNotifier of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<EntryNotifierScope>()!
        .notifier!;
  }
}