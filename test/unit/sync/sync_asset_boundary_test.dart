import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'TLS test credentials are excluded from the Flutter asset bundle',
    () async {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      expect(
        manifest.listAssets().where(
          (asset) => asset.contains('test/fixtures/sync'),
        ),
        isEmpty,
      );
      for (final filename in ['localhost-key.pem', 'localhost.pem']) {
        await expectLater(
          () => rootBundle.load('test/fixtures/sync/$filename'),
          throwsA(isA<FlutterError>()),
        );
      }
    },
  );
}
