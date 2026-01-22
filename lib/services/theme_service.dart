import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../config/app_themes.dart';

/// Service for managing app theme state and persistence.
///
/// Features:
/// - Streams the current theme based on user preferences
/// - Persists theme selection to Firestore
/// - Supports theme unlocking based on volunteer hours
class ThemeService extends ChangeNotifier {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  AppThemeConfig _currentTheme = AppThemes.light;
  String _currentThemeId = AppThemes.defaultThemeId;
  double _totalHours = 0;
  bool _initialized = false;

  ThemeService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance {
    _init();
  }

  /// Current theme configuration
  AppThemeConfig get currentTheme => _currentTheme;

  /// Current theme ID
  String get currentThemeId => _currentThemeId;

  /// Current ThemeData built from the theme config
  ThemeData get themeData => AppThemeBuilder.build(_currentTheme);

  /// Whether the service has been initialized
  bool get initialized => _initialized;

  /// User's total volunteer hours
  double get totalHours => _totalHours;

  /// All available themes
  List<AppThemeConfig> get allThemes => AppThemes.allThemes;

  /// Themes unlocked for the current user
  List<AppThemeConfig> get unlockedThemes => AppThemes.getUnlockedThemes(_totalHours);

  /// Initialize the service and listen for auth/user changes
  void _init() {
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        _listenToUserDoc(user.uid);
      } else {
        _resetToDefault();
      }
    });
  }

  /// Listen to user document for theme preference and hours
  void _listenToUserDoc(String uid) {
    _firestore.collection('users').doc(uid).snapshots().listen(
      (snap) {
        if (!snap.exists) return;

        final data = snap.data() ?? {};
        final savedThemeId = data['themeId'] as String? ?? AppThemes.defaultThemeId;
        final hours = (data['TimeTracker'] as num?)?.toDouble() ?? 0;

        _totalHours = hours;

        // Get the theme config, fallback to default if not found or locked
        final themeConfig = AppThemes.getById(savedThemeId);
        if (themeConfig != null && themeConfig.isUnlocked(hours)) {
          _currentTheme = themeConfig;
          _currentThemeId = savedThemeId;
        } else {
          _currentTheme = AppThemes.light;
          _currentThemeId = AppThemes.defaultThemeId;
        }

        _initialized = true;
        notifyListeners();
      },
      onError: (e) {
        debugPrint('[ThemeService] Error listening to user doc: $e');
        _resetToDefault();
      },
    );
  }

  /// Reset to default theme
  void _resetToDefault() {
    _currentTheme = AppThemes.light;
    _currentThemeId = AppThemes.defaultThemeId;
    _totalHours = 0;
    _initialized = true;
    notifyListeners();
  }

  /// Change the current theme
  ///
  /// Returns true if successful, false if theme is locked or doesn't exist.
  Future<bool> setTheme(String themeId) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    final themeConfig = AppThemes.getById(themeId);
    if (themeConfig == null) {
      debugPrint('[ThemeService] Theme not found: $themeId');
      return false;
    }

    if (!themeConfig.isUnlocked(_totalHours)) {
      debugPrint('[ThemeService] Theme locked: $themeId (requires ${themeConfig.hoursRequired} hours)');
      return false;
    }

    try {
      await _firestore.collection('users').doc(user.uid).update({
        'themeId': themeId,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _currentTheme = themeConfig;
      _currentThemeId = themeId;
      notifyListeners();

      return true;
    } catch (e) {
      debugPrint('[ThemeService] Error setting theme: $e');
      return false;
    }
  }

  /// Check if a specific theme is unlocked
  bool isThemeUnlocked(String themeId) {
    final config = AppThemes.getById(themeId);
    if (config == null) return false;
    return config.isUnlocked(_totalHours);
  }

  /// Get hours required to unlock a theme (null if already unlocked or always available)
  int? hoursToUnlock(String themeId) {
    final config = AppThemes.getById(themeId);
    if (config == null) return null;
    if (config.hoursRequired == null) return null;
    if (config.isUnlocked(_totalHours)) return null;
    return config.hoursRequired;
  }
}
