import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/browser_tab.dart';
import '../services/storage_service.dart';
abstract class BrowserEvent {}
class LoadTabs extends BrowserEvent {}
class AddTab extends BrowserEvent {
  final String url;
  AddTab(this.url);
}
abstract class BrowserState {}
class BrowserInitial extends BrowserState {}
class BrowserLoaded extends BrowserState {
  final List<BrowserTab> tabs;
  final int currentIndex;
  BrowserLoaded(this.tabs, this.currentIndex);
}
class BrowserBloc extends Bloc<BrowserEvent, BrowserState> {
  final StorageService _storage;
  List<BrowserTab> _tabs = [];
  BrowserBloc(this._storage) : super(BrowserInitial()) {
    on<LoadTabs>((event, emit) {
      _tabs = _storage.getTabs();
      if (_tabs.isEmpty) {
        _tabs.add(BrowserTab(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: 'New Tab',
          url: 'https://www.google.com',
          isActive: true,
          lastAccessed: DateTime.now(),
        ));
      }
      emit(BrowserLoaded(_tabs, 0));
    });
  }
}
