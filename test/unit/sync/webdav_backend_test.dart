import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:janus/services/sync/sync_backend.dart';

void main() {
  late HttpServer server;
  late WebDavBackend backend;
  late List<String> requests;
  String snapshot = '{}';
  int? failure;
  setUp(() async {
    requests = [];
    final serverContext = SecurityContext()
      ..useCertificateChain('test/fixtures/sync/localhost.pem')
      ..usePrivateKey('test/fixtures/sync/localhost-key.pem');
    server = await HttpServer.bindSecure(
      InternetAddress.loopbackIPv4,
      0,
      serverContext,
    );
    final clientContext = SecurityContext(withTrustedRoots: true)
      ..setTrustedCertificates('test/fixtures/sync/localhost.pem');
    backend = WebDavBackend(
      SyncConfig(
        'https://localhost:${server.port}/dav',
        'user',
        'pass',
        'janus.json',
      ),
      clientFactory: () => HttpClient(context: clientContext),
    );
    server.listen((request) async {
      requests.add('${request.method} ${request.uri.path}');
      expect(
        request.headers.value(HttpHeaders.authorizationHeader),
        'Basic ${base64Encode(utf8.encode('user:pass'))}',
      );
      if (failure != null) {
        request.response.statusCode = failure!;
        request.response.headers.set('location', 'https://example.com/steal');
      } else if (request.method == 'PROPFIND') {
        expect(request.headers.value('Depth'), '0');
        request.response.statusCode = 207;
      } else if (request.method == 'PUT') {
        snapshot = await utf8.decoder.bind(request).join();
        request.response.statusCode = 201;
      } else {
        request.response.write(snapshot);
      }
      await request.response.close();
    });
  });
  tearDown(() async {
    failure = null;
    await server.close(force: true);
  });

  test('real HTTPS PROPFIND PUT GET with auth and exact paths', () async {
    await backend.verify();
    await backend.upload('{"version":1,"title":"测试"}');
    expect(await backend.download(), '{"version":1,"title":"测试"}');
    expect(requests, [
      'PROPFIND /dav/',
      'PUT /dav/janus.json',
      'GET /dav/janus.json',
    ]);
  });
  test('auth failure then retry makes a fresh request', () async {
    failure = 401;
    await expectLater(backend.verify(), throwsA(isA<SyncFailure>()));
    failure = null;
    await backend.verify();
    expect(requests.length, 2);
  });
  test('404 and server failures propagate, no success response', () async {
    for (final code in [404, 500]) {
      failure = code;
      await expectLater(backend.download(), throwsA(isA<SyncFailure>()));
    }
  });
  test('redirect rejected without forwarding credentials', () async {
    failure = 302;
    await expectLater(backend.verify(), throwsA(isA<SyncFailure>()));
    expect(requests, ['PROPFIND /dav/']);
  });
  test(
    'untrusted TLS certificates are rejected by production client',
    () async {
      final untrusted = WebDavBackend(
        SyncConfig(
          'https://localhost:${server.port}/dav',
          'user',
          'pass',
          'janus.json',
        ),
      );
      await expectLater(untrusted.verify(), throwsA(isA<SyncFailure>()));
      expect(requests, isEmpty);
    },
  );
  test('oversized downloads are rejected', () async {
    snapshot = 'x' * (WebDavBackend.maxBytes + 1);
    await expectLater(backend.download(), throwsA(isA<SyncFailure>()));
  });
  test('oversized uploads rejected before data transfer', () async {
    await expectLater(
      backend.upload('x' * (WebDavBackend.maxBytes + 1)),
      throwsA(isA<SyncFailure>()),
    );
  });
}
