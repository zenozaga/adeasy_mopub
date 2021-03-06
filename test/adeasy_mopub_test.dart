import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:adeasy_mopub/adeasy_mopub.dart';

void main() {
  const MethodChannel channel = MethodChannel('adeasy_mopub');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await AdeasyMopub.platformVersion, '42');
  });
}
