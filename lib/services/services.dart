// Ascend – Services barrel file

export 'habit_service.dart';
export 'mood_service.dart';
export 'premium_service.dart';
export 'stats_service.dart';
export 'settings_service.dart';

// Platform-specific exports
export 'ad_service_web.dart' if (dart.library.io) 'ad_service.dart';
export 'notification_service_web.dart' if (dart.library.io) 'notification_service.dart';
export 'purchase_service_web.dart' if (dart.library.io) 'purchase_service.dart';
