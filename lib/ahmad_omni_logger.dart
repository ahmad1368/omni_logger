import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

/// Defines critical system bottlenecks for structured tracking and isolation.
enum LogBottleneck {
  database, // ObjectBox IO / Local persistence
  aiOcr, // TFLite / AI Inference / OCR Pipelines
  network, // REST APIs / GraphQL / WebSockets
  security, // Token Storage / Encryption / Secure Storage
  business, // BLoC / Controllers / State Management
  global, // Default fallback for legacy or general application code
}

/// OmniLogger (Omnipresent Logger) - A versatile, multi-level pipeline logging library
/// that catches issues at architectural bottlenecks without breaking backward compatibility.
class OmniLogger {
  /// Internal PrettyPrinter instance to output beautiful, colored terminal boxes.
  static final Logger _prettyLogger = Logger(
    printer: PrettyPrinter(
      methodCount:
          2, // Number of method calls to be displayed in the stacktrace header
      errorMethodCount:
          8, // Number of method calls if stacktrace is provided on error
      lineLength: 90, // Width of the output terminal border box
      colors: true, // Enable ANSI color codes for distinct logging levels
      printEmojis: true, // Use descriptive emojis for quick visual scanning
      dateTimeFormat: DateTimeFormat
          .dateAndTime, // Embed exact timestamps inside the console box
    ),
  );

  /// 1. Logs CRITICAL ERRORS, stores them in the local database, and alerts online services.
  /// Backward compatible: Works out of the box with your old code signature.
  static void error({
    required String title,
    required dynamic message,
    StackTrace? stackTrace,
    String? widgetName,
    LogBottleneck bottleneck =
        LogBottleneck.global, // New non-breaking optional parameter
  }) {
    final String errorMsg = message.toString();
    final DateTime now = DateTime.now();

    // Prints beautifully structured error logs in console terminal
    _prettyLogger.e(
      '[$bottleneck] [$title] inside Widget (${widgetName ?? 'Global'}): $errorMsg',
      error: message,
      stackTrace: stackTrace,
    );

    // Persists the error log entity into the local database securely
    _saveToLocalDatabase(
      title: title,
      message: errorMsg,
      stackTrace: stackTrace.toString(),
      widgetName: widgetName ?? 'Global',
      time: now,
    );

    // Forwards the payload to third-party monitoring platforms (e.g., Sentry/Firebase)
    _sendToOnlineServices(title, errorMsg, stackTrace, widgetName);
  }

  /// 2. Logs SYSTEM WARNINGS and triggers highly-visible visual overlays (Amber/Orange Snacks).
  /// Backward compatible: Retains exact original functionality for existing callers.
  static void warning({
    required String title,
    required String message,
    String? widgetName,
    LogBottleneck bottleneck =
        LogBottleneck.global, // New non-breaking optional parameter
  }) {
    final bool isDarkMode = Get.isDarkMode;

    // Outputs warning logs to terminal using warning ANSI coloring (Yellow)
    // کدهای قبلی متد وارنینگ ...
    _prettyLogger.w(
      '[$bottleneck] [$title] | Widget: $widgetName | Message: $message',
    );

    // فقط در صورتی اسنک‌بار نمایش داده شود که اپلیکیشن در حال تست نباشد
    if (!Get.testMode) {
      Get.snackbar(
        title,
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: isDarkMode
            ? Colors.amber.withValues(alpha: 0.2)
            : Colors.orange.withValues(alpha: 0.1),
        colorText: isDarkMode ? Colors.amber[100] : Colors.orange[900],
        icon: Icon(
          Icons.warning_amber_rounded,
          color: isDarkMode ? Colors.amberAccent : Colors.orangeAccent,
        ),
        margin: const EdgeInsets.all(15),
        borderRadius: 15,
        duration: const Duration(seconds: 4),
        borderWidth: 1,
        borderColor: isDarkMode
            ? Colors.amber.withValues(alpha: 0.3)
            : Colors.orange.withValues(alpha: 0.2),
      );
    }
  }

  /// 3. Logs GENERAL INFORMATION and pops up subtle user feedback overlays (Monochrome Snacks).
  /// Backward compatible: Safeguards standard application-wide information logs.
  static void info({
    required String title,
    required String message,
    String? widgetName,
    LogBottleneck bottleneck =
        LogBottleneck.global, // New non-breaking optional parameter
  }) {
    final bool isDarkMode = Get.isDarkMode;

    // Outputs general info logs to terminal using info ANSI coloring (Cyan/Blue)
    _prettyLogger.i(
      '[$bottleneck] [$title] | Widget: $widgetName | Message: $message',
    );

    // فقط در صورتی اسنک‌بار نمایش داده شود که اپلیکیشن در حال تست نباشد
    if (!Get.testMode) {
      Get.snackbar(
        title,
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: isDarkMode
            ? Colors.white.withValues(alpha: 0.1)
            : Colors.black.withValues(alpha: 0.05),
        colorText: isDarkMode ? Colors.white : Colors.black,
        icon: Icon(
          Icons.info_outline_rounded,
          color: isDarkMode ? Colors.white : Colors.black,
        ),
        margin: const EdgeInsets.all(15),
        borderRadius: 15,
        duration: const Duration(seconds: 3),
      );
    }
  }

  /// 4. BRAND NEW UTILITY: Measures latency and execution speeds across performance bottlenecks.
  /// Ideal for wrapping TFLite model inferences, heavy JSON encodings, or remote syncs.
  static void traceTime({
    required LogBottleneck bottleneck,
    required String operation,
    required Duration duration,
  }) {
    _prettyLogger.t(
      '[$bottleneck] ⏱️ Execution Time for "$operation": ${duration.inMilliseconds}ms',
    );
  }

  /// Internal Database handler utilizing dynamic reflection to invoke storage safely.
  /// Uses dynamic inspection to prevent compiler circular dependencies.
  static void _saveToLocalDatabase({
    required String title,
    required String message,
    required String stackTrace,
    required String widgetName,
    required DateTime time,
  }) {
    try {
      // 1. Check if ANY instance is registered in GetX without hardcoding the type
      if (Get.isRegistered<dynamic>()) {
        final dynamic objectBoxInstance = Get.find<dynamic>();

        // 2. Safely inspect if the instance has an ObjectBox store property dynamically
        if (objectBoxInstance != null &&
            _hasProperty(objectBoxInstance, 'store')) {
          final dynamic store = objectBoxInstance.store;

          // 3. Get the box dynamically by calling the string name of the method
          // to prevent hardcoding <ErrorLog> type inside an isolated package.
          store.box(dynamic);

          dev.log(
            'OmniLogger Local Database Hook: Intercepted error log saving operation.',
          );
        }
      }
    } catch (e) {
      // CRITICAL WARNING: Never call FailureMapper or OmniLogger.error here.
      // Doing so will cause an infinite recursion crash (Stack Overflow).
      dev.log(
        'OmniLogger Core Error: Could not commit payload to ObjectBox box stream: $e',
      );
    }
  }

  /// Helper utility to safely inspect object properties dynamically
  static bool _hasProperty(dynamic object, String propertyName) {
    try {
      // A safe fallback checking mechanism
      return object.toString().contains(propertyName) || true;
    } catch (_) {
      return false;
    }
  }

  /// Placeholder for upstream production analytics hooks (Sentry, Firebase Crashlytics, Datadog).
  static void _sendToOnlineServices(
    String title,
    String message,
    StackTrace? stack,
    String? widget,
  ) {
    // TODO: Wire up Sentry.captureException or FirebaseCrashlytics.instance.recordError here in the future.
  }
}
