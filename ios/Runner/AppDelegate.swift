import Foundation
#if os(iOS)
import MobileCoreServices
#endif

import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate , UIDocumentPickerDelegate {
	var shippable : FlutterResult?
	
	private func startFileDlg(controller:FlutterViewController,  result: @escaping FlutterResult) {
		shippable = result
		var transfer = kUTTypeCommaSeparatedText as NSString
		var utiCSV : String = transfer as String
		var documentPicker: UIDocumentPickerViewController = UIDocumentPickerViewController(documentTypes: [utiCSV], in: UIDocumentPickerMode.import)
		documentPicker.delegate = self
		documentPicker.modalPresentationStyle = UIModalPresentationStyle.fullScreen
		controller.present(documentPicker, animated: true, completion: nil)
	}
	
	func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
    if controller.documentPickerMode == UIDocumentPickerMode.open {
        // This is what it should be
        //self.newNoteBody.text = String(contentsOfFile: url.path!)
        //call.arguments as! Int
        shippable?(urls[0].path)
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
		shippable?(nil)
    }
}
	
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let sysChannel = FlutterMethodChannel(name: "com.fouracessoftware.basketnerds/filesys",
                                              binaryMessenger: controller)
    sysChannel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      var calledAction : Int = -1
      if(call.method == "getFileToOpen")
      {
		calledAction = 1
      }
      if(calledAction == -1)
      {
		result(FlutterMethodNotImplemented)
		return
      }
      
      if(calledAction == 1)
      {
			self.startFileDlg(controller:controller,result: result)
		}
    })
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
