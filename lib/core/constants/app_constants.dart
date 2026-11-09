/// Global Application Constants for Kickoff.
abstract class AppConstants {
  static const String appName = 'Kickoff';
  static const String appTagline = 'إدارة وتنظيم مجموعات كرة القدم';

  // Responsive Layout Constants
  static const double maxContentWidth = 500.0;
  static const double compactScreenWidth = 360.0;
  static const double standardScreenWidth = 480.0;
  static const double tabletScreenWidth = 768.0;

  // Design System Radii
  static const double radiusCircular = 100.0; // Capsule pill shape
  static const double radiusLarge = 24.0; // Main Cards & Hero Media
  static const double radiusMedium = 16.0; // Chips, Dialogs, Slots
  static const double radiusSmall = 12.0; // Sub-items, Micro-cards
  static const double radiusTiny = 8.0; // Tiny badges

  // Animation Timers
  static const Duration quickAnimation = Duration(milliseconds: 200);
  static const Duration normalAnimation = Duration(milliseconds: 350);
  static const Duration slowAnimation = Duration(milliseconds: 500);

  // Localization
  static const String defaultLocale = 'ar';
  static const String fallbackLocale = 'en';
}
