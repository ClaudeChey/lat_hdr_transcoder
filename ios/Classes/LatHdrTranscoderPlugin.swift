import Flutter
import UIKit

public class LatHdrTranscoderPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "lat_hdr_transcoder", binaryMessenger: registrar.messenger())
        let instance = LatHdrTranscoderPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        print("\(call.method), \(String(describing: call.arguments))")
        switch call.method {
        case "isHDR":
            guard let args = call.arguments as? [String: Any],
                  let path = args["path"] as? String else {
                TranscodeErrorType.invalidArgs.occurs(result: result)
                return
            }
            
            guard #available(iOS 14.0, *) else {
                TranscodeErrorType.notSupportVersion.occurs(result: result)
                return
            }
            
            let inputURL = URL(fileURLWithPath: path)
            let isHDR = Transcoder().isHDR(inputURL: inputURL)
            result(isHDR)
            
        case "transcode":
            guard let args = call.arguments as? [String: Any],
                  let path = args["path"] as? String else {
                TranscodeErrorType.invalidArgs.occurs(result: result)
                return
            }
            
            let inputURL = URL(fileURLWithPath: path)
            let outputURL = outputFileURL(inputPath: path)
            
            guard deleteFileIfExists(url: outputURL) else {
                TranscodeErrorType.existsOutputFile.occurs(result: result)
                return
            }
            
            Transcoder().convert(inputURL: inputURL, outputURL: outputURL) { progress in
                print(progress)
            } completion: { error in
                if let error = error {
                    TranscodeErrorType.failedConvert.occurs(result: result, extra: error.localizedDescription)
                } else {
                    result(outputURL.relativePath)
                }
            }
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    
    private func outputFileURL(inputPath: String) -> URL {
        let inputUrl = URL(fileURLWithPath: inputPath)
        let fileName = inputUrl.deletingPathExtension().lastPathComponent
        let newFileName = fileName + "_sdr"
        
        let tempDirURL = createTempDirIfNot()
        let newURL = tempDirURL.appendingPathComponent(newFileName).appendingPathExtension("mp4")
        return newURL
    }
    
    private func fileExists(url: URL) -> Bool {
        return FileManager.default.fileExists(atPath: url.relativePath)
    }
    
    private func createTempDirIfNot() -> URL {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("to_sdr", isDirectory: true)
        do {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
            return url
        } catch {
            print(error)
            return url
        }
    }
    
    private func deleteFileIfExists(url: URL) -> Bool {
        let manager = FileManager.default
        guard manager.fileExists(atPath: url.relativePath) else {
            return true
        }
        
        do {
            try manager.removeItem(atPath: url.relativePath)
            return true
        } catch  {
            print("error \(error)")
            return false
        }
        
    }
}
