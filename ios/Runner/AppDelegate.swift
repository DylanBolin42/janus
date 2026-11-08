import Flutter
import UIKit
import Security

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    if let registrar = registrar(forPlugin: "JanusSyncCredentials") {
      let channel = FlutterMethodChannel(name: "janus/sync_credentials",
        binaryMessenger: registrar.messenger())
      channel.setMethodCallHandler { call, result in
        let query: [String: Any] = [
          kSecClass as String: kSecClassGenericPassword,
          kSecAttrService as String: "janus.sync.credentials.v1",
          kSecAttrAccount as String: "webdav",
        ]
        switch call.method {
        case "read":
          var request = query
          request[kSecReturnData as String] = true
          request[kSecMatchLimit as String] = kSecMatchLimitOne
          var item: CFTypeRef?
          let status = SecItemCopyMatching(request as CFDictionary, &item)
          if status == errSecItemNotFound { result(nil) }
          else if status == errSecSuccess, let data = item as? Data,
            let value = String(data: data, encoding: .utf8) { result(value) }
          else { result(FlutterError(code: "secure_storage",
            message: "Secure credential storage failed", details: nil)) }
        case "write":
          guard let value = call.arguments as? String,
            let data = value.data(using: .utf8) else {
            result(FlutterError(code: "secure_storage", message: "Invalid value", details: nil))
            return
          }
          let attributes: [String: Any] = [
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
          ]
          var status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
          if status == errSecItemNotFound {
            status = SecItemAdd(query.merging(attributes) { _, new in new } as CFDictionary, nil)
          }
          if status == errSecSuccess { result(nil) }
          else { result(FlutterError(code: "secure_storage",
            message: "Secure credential storage failed", details: nil)) }
        default: result(FlutterMethodNotImplemented)
        }
      }
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
