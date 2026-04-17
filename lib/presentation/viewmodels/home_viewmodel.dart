import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pdftest/core/constants/app_constants.dart';
import 'package:pdftest/core/services/injection_container.dart';

final homeViewModelProvider = StateNotifierProvider<HomeViewModel, List<String>>((ref) {
  return HomeViewModel();
});

class HomeViewModel extends StateNotifier<List<String>> {
  HomeViewModel() : super([]) {
    loadRecentFiles();
  }

  void loadRecentFiles() {
    final prefs = sl<SharedPreferences>();
    state = prefs.getStringList(AppConstants.recentFilesKey) ?? [];
  }

  void addRecentFile(String path) {
    final prefs = sl<SharedPreferences>();
    List<String> recent = List.from(state);
    if (recent.contains(path)) {
      recent.remove(path);
    }
    recent.insert(0, path);
    if (recent.length > 10) {
      recent = recent.sublist(0, 10);
    }
    state = recent;
    prefs.setStringList(AppConstants.recentFilesKey, recent);
  }

  void removeRecentFile(String path) {
    final prefs = sl<SharedPreferences>();
    List<String> recent = List.from(state);
    recent.remove(path);
    state = recent;
    prefs.setStringList(AppConstants.recentFilesKey, recent);
  }

  void renameRecentFile(String oldPath, String newPath) {
    final prefs = sl<SharedPreferences>();
    List<String> recent = List.from(state);
    final index = recent.indexOf(oldPath);
    if (index != -1) {
      recent[index] = newPath;
      state = recent;
      prefs.setStringList(AppConstants.recentFilesKey, recent);
    }
  }
}
