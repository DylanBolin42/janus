import 'package:flutter_test/flutter_test.dart';
import 'package:janus/services/ai_endpoint_validator.dart';

void main() {
  group('AiEndpointValidator', () {
    test('allows valid HTTPS remote URLs', () {
      expect(
        AiEndpointValidator.isValidEndpoint('https://api.openai.com/v1'),
        isTrue,
      );
      expect(
        AiEndpointValidator.isValidEndpoint('https://api.deepseek.com'),
        isTrue,
      );
    });

    test('rejects unencrypted HTTP remote URLs', () {
      expect(
        AiEndpointValidator.isValidEndpoint('http://api.openai.com/v1'),
        isFalse,
      );
      expect(
        AiEndpointValidator.isValidEndpoint('http://example.com/api'),
        isFalse,
      );
    });

    test('allows HTTP URLs for local development loopback hosts', () {
      expect(
        AiEndpointValidator.isValidEndpoint('http://localhost:11434'),
        isTrue,
      );
      expect(
        AiEndpointValidator.isValidEndpoint('http://127.0.0.1:8080/v1'),
        isTrue,
      );
      expect(AiEndpointValidator.isValidEndpoint('http://[::1]:11434'), isTrue);
    });

    test('rejects empty, invalid, or non-http/https URIs', () {
      expect(AiEndpointValidator.isValidEndpoint(''), isFalse);
      expect(AiEndpointValidator.isValidEndpoint('   '), isFalse);
      expect(AiEndpointValidator.isValidEndpoint('ftp://server.com'), isFalse);
      expect(AiEndpointValidator.isValidEndpoint('not_a_url'), isFalse);
    });
  });
}
