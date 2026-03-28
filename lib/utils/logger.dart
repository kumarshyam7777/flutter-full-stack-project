import 'package:logger/logger.dart';

/// A global logger instance to be used throughout the application.
/// Provides structured logging with levels (info, debug, warning, error).
final Logger logger = Logger(
  printer: PrettyPrinter(
    methodCount: 0,        // Number of method calls to be displayed
    errorMethodCount: 8,   // Number of method calls if stacktrace is provided
    lineLength: 80,        // Width of the output
    colors: true,          // Colorful log messages
    printEmojis: true,     // Print an emoji for each log message
    printTime: false       // Should each log print contain a timestamp
  ),
);
