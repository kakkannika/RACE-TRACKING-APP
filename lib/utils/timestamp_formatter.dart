

/// Utility class for timestamp related operations
class TimestampFormatter {
  /// Formats a timestamp to display in HH:MM:SS format
  static String formatTimestamp(DateTime timestamp) {
    return timestamp.toIso8601String().substring(11, 19);
  }

  /// Formats a timestamp from a segmentTime object
  static String? getTimestampFromSegment(dynamic segmentTime) {
    if (segmentTime == null) return null;

    if (segmentTime.endTime != null) {
      // Format the end time without milliseconds
      final endTime = segmentTime.endTime!;
      return formatTimestamp(endTime);
    } else if (segmentTime.startTime != null) {
      // For active segment, show the starting time
      final startTime = segmentTime.startTime;
      return formatTimestamp(startTime);
    }

    return null;
  }
}
