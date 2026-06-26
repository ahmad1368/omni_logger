import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:omni_logger/omni_logger.dart';

void main() {
  // این دستور ریشه فلاتر را در محیط تست فعال می‌کند تا خطای بایندینگ برطرف شود
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.testMode = true;
  });

  group('OmniLogger Architectural Testing', () {
    test('Verify Logger executes successfully with global fallback', () {
      expect(
        () => OmniLogger.info(
          title: 'Test Title',
          message: 'Testing system integration pipeline',
        ),
        returnsNormally,
      );
    });

    test('Verify Logger works seamlessly with specific bottlenecks', () {
      expect(
        () => OmniLogger.warning(
          title: 'Database Sync Alert',
          message: 'Testing local storage IO capacity limitations',
          bottleneck: LogBottleneck.database,
        ),
        returnsNormally,
      );
    });

    test('Verify Performance Latency tracker executes normally', () {
      expect(
        () => OmniLogger.traceTime(
          bottleneck: LogBottleneck.aiOcr,
          operation: 'Model Weight Vector Parsing',
          duration: const Duration(milliseconds: 120),
        ),
        returnsNormally,
      );
    });
  });
}
