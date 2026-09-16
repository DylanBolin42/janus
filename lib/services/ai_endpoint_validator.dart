/// Utility for validating AI service API endpoints for secure transport.
class AiEndpointValidator {
  AiEndpointValidator._();

  /// Validates whether [url] is a secure AI endpoint URL.
  ///
  /// Enforces HTTPS for remote connections to prevent plaintext credential
  /// interception via MITM attacks, while permitting HTTP for local loopback hosts
  /// (`localhost`, `127.0.0.1`, `::1`) used during local LLM development.
  static bool isValidEndpoint(String url) {
    if (url.trim().isEmpty) return false;
    final uri = Uri.tryParse(url.trim());
    if (uri == null || !uri.hasScheme) return false;

    final scheme = uri.scheme.toLowerCase();
    if (scheme == 'https') return true;
    if (scheme == 'http') {
      final host = uri.host.toLowerCase();
      return host == 'localhost' ||
          host == '127.0.0.1' ||
          host == '::1' ||
          host == '[::1]';
    }
    return false;
  }
}
