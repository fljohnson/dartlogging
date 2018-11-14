import Foundation
#if os(iOS)
import MobileCoreServices
#endif

import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate , UIDocumentPickerDelegate {
	var shippable : FlutterResult?
	
	private func startFileDlg(controller:FlutterViewController, save: Bool, result: @escaping FlutterResult) {
		shippable = result
		var transfer = kUTTypeCommaSeparatedText as NSString
		var utiCSV : String = transfer as String
		var documentPicker: UIDocumentPickerViewController?
		documentPicker.delegate = self
		documentPicker.modalPresentationStyle = UIModalPresentationStyle.fullScreen
		
		if(save) 
		{
			var toMove = URL(fileURLWithPath:"output.csv")
			documentPicker = UIDocumentPickerViewController(url: toMove, in: UIDocumentPickerMode.exportToService)
		}
		else
		{
		 	documentPicker = UIDocumentPickerViewController(documentTypes: [utiCSV], in: UIDocumentPickerMode.import)
		 }
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
      var write : Bool = false
      if(call.method == "getFileToOpen")
      {
		calledAction = 1
		if let args = call.arguments as? [Bool] 
		{
			if(args.count > 0)
			{
				write = args[0]
			}
		}
      }
      if(calledAction == -1)
      {
		result(FlutterMethodNotImplemented)
		return
      }
      
      if(calledAction == 1)
      {
			self.startFileDlg(controller:controller,save: write,result: result)
		}
    })
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
