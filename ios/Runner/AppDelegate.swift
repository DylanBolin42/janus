import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, UIDocumentPickerDelegate {
  private var pendingImport: FlutterResult?
  private let maxImportBytes = 20 * 1024 * 1024
  private var importChannel: FlutterMethodChannel?
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(name: "janus/storage_import", binaryMessenger: controller.binaryMessenger)
      importChannel = channel
      channel.setMethodCallHandler { [weak self] call, result in
        guard let self = self else { return }
        guard call.method == "pickJson" else { result(FlutterMethodNotImplemented); return }
        guard self.pendingImport == nil else {
          result(FlutterError(code: "already_active", message: "A snapshot picker is already active", details: nil)); return
        }
        self.pendingImport = result
        // Open-in-place avoids the system Import mode's eager, unbounded copy.
        let picker = UIDocumentPickerViewController(documentTypes: ["public.json"], in: .open)
        picker.allowsMultipleSelection = false
        picker.delegate = self
        var presenter: UIViewController = controller
        while let presented = presenter.presentedViewController { presenter = presented }
        presenter.present(picker, animated: true)
      }
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
    let result = pendingImport
    pendingImport = nil
    result?(nil)
  }

  func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
    guard let result = pendingImport else { return }
    guard let url = urls.first else {
      pendingImport = nil
      result(FlutterError(code: "unreadable", message: "No document was returned", details: nil))
      return
    }
    controller.dismiss(animated: true)
    DispatchQueue.global(qos: .userInitiated).async {
      let scoped = url.startAccessingSecurityScopedResource()
      defer { if scoped { url.stopAccessingSecurityScopedResource() } }
      if let size = (try? url.resourceValues(forKeys: [.fileSizeKey]))?.fileSize, size > self.maxImportBytes {
        DispatchQueue.main.async {
          self.pendingImport = nil
          result(FlutterError(code: "too_large", message: "Document exceeds 20 MiB", details: nil))
        }
        return
      }
      var temporary: URL?
      var failure: Error?
      var payload: [String: Any]?
      var coordinationError: NSError?
      // Cloud providers may download while coordinating. The provider/OS owns
      // that network cache, but our own copy is always bounded below.
      NSFileCoordinator().coordinate(readingItemAt: url, options: .withoutChanges, error: &coordinationError) { readable in
        do {
          let declared = (try? readable.resourceValues(forKeys: [.fileSizeKey]))?.fileSize
          if let declared = declared, declared > self.maxImportBytes { throw SnapshotReadError.tooLarge }
          let target = FileManager.default.temporaryDirectory.appendingPathComponent("janus_import_\(UUID().uuidString).json")
          temporary = target
          guard FileManager.default.createFile(atPath: target.path, contents: nil) else { throw SnapshotReadError.unreadable }
          let output = try FileHandle(forWritingTo: target)
          defer { try? output.close() }
          guard let input = InputStream(url: readable) else { throw SnapshotReadError.unreadable }
          input.open()
          defer { input.close() }
          var buffer = [UInt8](repeating: 0, count: 8192)
          var total = 0
          while true {
            let count = input.read(&buffer, maxLength: 8192)
            if count < 0 { throw input.streamError ?? SnapshotReadError.unreadable }
            if count == 0 { break }
            total += count
            if total > self.maxImportBytes { throw SnapshotReadError.tooLarge }
            try output.write(contentsOf: Data(buffer.prefix(count)))
          }
          try output.synchronize()
          payload = ["path": target.path, "size": total]
        } catch { failure = error }
      }
      if let error = coordinationError { failure = error }
      if failure != nil || payload == nil {
        if let temporary = temporary { try? FileManager.default.removeItem(at: temporary) }
      }
      DispatchQueue.main.async {
        self.pendingImport = nil
        if let error = failure {
          let cocoaError = error as NSError
          let code: String
          if (error as? SnapshotReadError) == .tooLarge { code = "too_large" }
          else if cocoaError.domain == NSCocoaErrorDomain && cocoaError.code == NSFileReadNoPermissionError { code = "permission_denied" }
          else { code = "unreadable" }
          result(FlutterError(code: code, message: error.localizedDescription, details: nil))
        } else if let payload = payload { result(payload) }
        else { result(FlutterError(code: "unreadable", message: "Document is unreadable", details: nil)) }
      }
    }
  }
}

private enum SnapshotReadError: Error, Equatable {
  case tooLarge
  case unreadable
}
