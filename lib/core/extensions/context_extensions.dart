import 'package:flutter/material.dart';
import '../../app/localization/app_localizations.dart';
import '../helpers/responsive_helper.dart';
import '../presentation/widgets/kickoff_toast.dart';

/// Extension methods on [BuildContext] for clean, concise UI code.
extension ContextExtensions on BuildContext {
  // Localization
  AppLocalizations get l10n => AppLocalizations.of(this);

  // Theme & Styling
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
  bool get isRtl {
    try {
      if (l10n.isArabic) return true;
      return Directionality.of(this) == TextDirection.rtl;
    } catch (_) {
      return true;
    }
  }

  // Media Query & Screen Dimensions
  Size get screenSize => MediaQuery.sizeOf(this);
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;
  EdgeInsets get mediaQueryPadding => MediaQuery.paddingOf(this);
  EdgeInsets get viewInsets => MediaQuery.viewInsetsOf(this);

  // Responsive classification & helpers
  ScreenType get screenType => ResponsiveHelper.getScreenType(this);
  bool get isCompact => screenType == ScreenType.compact;
  bool get isStandard => screenType == ScreenType.standard;
  bool get isTablet => screenType == ScreenType.tablet;

  double get horizontalPadding => ResponsiveHelper.horizontalPadding(this);
  double get verticalPadding => ResponsiveHelper.verticalPadding(this);

  T responsive<T>({
    required T standard,
    T? compact,
    T? largeMobile,
    T? tablet,
  }) {
    return ResponsiveHelper.value<T>(
      this,
      standard: standard,
      compact: compact,
      largeMobile: largeMobile,
      tablet: tablet,
    );
  }

  // Kickoff Floating Pill Toasts
  void showToast(
    String message, {
    KickoffToastType type = KickoffToastType.success,
    Duration duration = const Duration(seconds: 3),
  }) =>
      KickoffToast.show(this, message: message, type: type, duration: duration);

  void showSuccessToast(
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) =>
      KickoffToast.showSuccess(this, message, duration: duration);

  void showErrorToast(
    String message, {
    Duration duration = const Duration(seconds: 4),
  }) =>
      KickoffToast.showError(this, message, duration: duration);

  void showWarningToast(
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) =>
      KickoffToast.showWarning(this, message, duration: duration);

  void showInfoToast(
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) =>
      KickoffToast.showInfo(this, message, duration: duration);
}
