import Foundation
#if os(iOS)
import MobileCoreServices
#endif

import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate , UIDocumentPickerDelegate {
	var shippable : FlutterResult?
	
	private func startFileDlg() {
		var transfer = kUTTypeCommaSeparatedText as NSString
		var utiCSV : String = transfer
		var documentPicker: UIDocumentPickerViewController = UIDocumentPickerViewController(documentTypes: [utiCSV], inMode: UIDocumentPickerMode.import)
		documentPicker.delegate = self
		documentPicker.modalPresentationStyle = UIModalPresentationStyle.FullScreen
		self.presentViewController(documentPicker, animated: true, completion: nil)
	}
	
	func documentPicker(controller: UIDocumentPickerViewController, didPickDocumentAtURL url: NSURL) {
    if controller.documentPickerMode == UIDocumentPickerMode.open {
        // This is what it should be
        //self.newNoteBody.text = String(contentsOfFile: url.path!)
        //call.arguments as! Int
        shippable?(url.path)
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
		shippable?(null)
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
      (call: FlutterMethodCall, result: FlutterResult) -> Void in
      calledAction = -1
      if(call.method == "getFileToOpen")
      {
		calledAction = 1
      }
      if(calledAction == -1)
      {
		result(FlutterMethodNotImplemented)
		return
      }
      shippable = result
      if(calledAction == 1)
      {
			startFileDlg()
		}
    })
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
