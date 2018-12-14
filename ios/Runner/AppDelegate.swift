import Foundation
#if os(iOS)
import MobileCoreServices
#endif

import UIKit
import Flutter


/*
Consult https://gitlab.com/theswiftdev/icloud-drive/blob/master/iCloudDrive/Sources/ViewController.swift

for the use of the FileManager singleton. This may cut a ton of BS
*/
@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate , UIDocumentPickerDelegate {
	var shippable : FlutterResult?
	var txtToWrite : String?
	
	private func localDocumentsDirectoryURL() -> URL? {
		guard let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else { return nil }
		
		let localDocumentsDirectoryURL = URL(fileURLWithPath: documentPath)
		return localDocumentsDirectoryURL
	  }
	  
	 func fileUrlForDocumentNamed(_ name: String) -> URL? {
		guard let baseURL = localDocumentsDirectoryURL() else { return nil }

		let protectedName: String
		if name.isEmpty {
		  protectedName = "Untitled"
		} else {
		  protectedName = name
		}

		return baseURL.appendingPathComponent(protectedName)
		  .appendingPathExtension("csv")
	}
	
	private func primaryFileDlg(controller:FlutterViewController, save: Bool, result: @escaping FlutterResult) {
		if(!save)
		{
			startOpenDlg(controller:controller,result:result)
		}
		else
		{
			startSaveDlg(controller:controller,result:result)
		}
	}
	
	private func startSaveDlg(controller:FlutterViewController, result: @escaping FlutterResult) {
			shippable = result
			let alert = UIAlertController(title: "Export as CSV", message: nil, preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

			alert.addTextField(configurationHandler: { textField in
				textField.placeholder = "Give intended filename"
			})

			alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in

				if let name = alert.textFields?.first?.text {
					//let fileURL = self.fileUrlForDocumentNamed(name)
					self.shippable?(name)
				}
			}))

			controller.present(alert, animated: true)

			/* demonstrates last-resort action
			
			
			guard let fileURL = fileUrlForDocumentNamed("shipout") else { 
				shippable?("FAILED")
				return 
			}
			
			let text="Amount,What,Date\n10.00,test,2018-11-05"
		
			do {
				try text.write(to:fileURL,atomically: false, encoding: .utf8)
			}
			catch let error {
				shippable?(FlutterError(code:"PROBE",message:"brute write failed \(error)",details:nil))
				return
			}
			*/
			
			/*
			var toMove = URL(fileURLWithPath:"shipout")
			var filePathToUpload = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"testing" ofType:@"csv"]]  
			*/
			/*
			documentPicker = UIDocumentPickerViewController(url: fileURL, in: UIDocumentPickerMode.exportToService)
			*/
			
	}
	
	private func startOpenDlg(controller:FlutterViewController, result: @escaping FlutterResult) {
		
		shippable = result
		var transfer = kUTTypeCommaSeparatedText as NSString
		var utiCSV : String = transfer as String
		var documentPicker: UIDocumentPickerViewController?
		
		
		 	documentPicker = UIDocumentPickerViewController(documentTypes: [utiCSV], in: UIDocumentPickerMode.import)
		 
		 documentPicker?.delegate = self
		documentPicker?.modalPresentationStyle = UIModalPresentationStyle.fullScreen
		controller.present(documentPicker!, animated: true, completion: nil)
	}
	
	private func startExportDlg(controller:FlutterViewController, localFileUrl: String, result: @escaping FlutterResult) {
		
		shippable = result
		var transfer = kUTTypeCommaSeparatedText as NSString
		var utiCSV : String = transfer as String
		var documentPicker : UIDocumentPickerViewController?
		var potential : Bool = true
		
		var fileURL : URL? 
		
		var outUrl : URL? = FileManager.default.url(forUbiquityContainerIdentifier:nil)
		
		if(outUrl == nil)
		{
			shippable?(FlutterError(code:"UNSPECIFIED",message:"we have no ubiquity. Try logging into iCloud first",details:nil))
			return
		}
		
		if(FileManager.default.ubiquityIdentityToken == nil)
		{
			shippable?(FlutterError(code:"UNSPECIFIED",message:"no identity token" ,details:nil))
			return
		}
		
		
		/*
		shippable?(FlutterError(code:"UNSPECIFIED",message:"success:" + outUrl!.path ,details:nil))
		return
		*/
		/* demo of crude write - last-resort tactic
		fileURL = fileUrlForDocumentNamed("shipout")
		let text="Amount,What,Date\n10.00,test,2018-11-05"
		
		do {
			try text.write(to:fileURL!,atomically: false, encoding: .utf8)
		}
		catch let error {
			shippable?(FlutterError(code:"PROBE",message:"brute write failed \(error)",details:nil))
			return
		}
		
			shippable?(FlutterError(code:"PROBE",message:"crude write seemed to work",details:nil))
			return
		*/
		//fileURL = try URL(fileURLWithPath:localFileUrl,isDirectory:false)
		fileURL = self.fileUrlForDocumentNamed(localFileUrl)
		
		let text="Amount,What,Date\n10.00,test,2018-11-05"
		
		do {
			try txtToWrite?.write(to:fileURL!,atomically: false, encoding: .utf8)
		}
		catch let error {
			shippable?(FlutterError(code:"PROBE",message:"CSV export failed \(error)",details:nil))
			return
		}
		
		do {
			
			
			try FileManager.default.setUbiquitous(true,itemAt:fileURL!,destinationURL:outUrl!)
			
			documentPicker = UIDocumentPickerViewController(url: fileURL!, in: UIDocumentPickerMode.exportToService)
			
		}
		catch let error {
			shippable?(FlutterError(code:"UNSPECIFIED",message:"missed \(error)",details:nil))
			return
		}
		
		if(potential == false)
		{
			shippable?(FlutterError(code:"UNSPECIFIED",message:"could not move file",details:nil))
			return
		}
		
		if(documentPicker == nil)
		{
			shippable?(FlutterError(code:"UNSPECIFIED",message:"constructor disliked localFileUrl",details:nil))
			return
		}
		
		//shippable?("CREATED") //remove
		
			 documentPicker?.delegate = self
			documentPicker?.modalPresentationStyle = UIModalPresentationStyle.formSheet
			controller.present(documentPicker!, animated: true, completion: nil)
		
			//drat, missed for some other reason
			
		
		
	}
	
	func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
		if controller.documentPickerMode == UIDocumentPickerMode.import {
			// This is what it should be
			//self.newNoteBody.text = String(contentsOfFile: url.path!)
			//call.arguments as! Int
			
			/*
			rough version of last-resort technique
			guard let fileURL = fileUrlForDocumentNamed("shipout") else { 
				//shippable?("FAILED")
				shippable?(FlutterError(code:"PROBE",message:"get fileURL failed",details:nil))
				return 
		}
		
		var text : String = "" 
		do {
			text = try String(contentsOfFile: fileURL.path)
		}
		catch let error {
			shippable?(FlutterError(code:"PROBE",message:"brute read failed \(error)",details:nil))
			return
		}
		
		shippable?("Goods:"+text)
		return
		*/
			//shippable?(urls[0].path) //should've been 
			
			var text : String = "" 
			do {
				text = try String(contentsOfFile: urls[0].path)
			}
			catch let error {
				shippable?(FlutterError(code:"PROBE",message:"brute read failed \(error)",details:nil))
				return
			}
			
			shippable?(text)
		}
		if controller.documentPickerMode == UIDocumentPickerMode.exportToService {
			shippable?(urls[0].path)
		}
	}

    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
		shippable?(nil)
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
      if(call.method == "exportToExternal")
      {
		calledAction = 2
      }
      //TODO: make a proper switch block out of these
      if(calledAction == -1)
      {
		result(FlutterMethodNotImplemented)
		return
      }
      
      if(calledAction == 1)
      {
			self.primaryFileDlg(controller:controller,save: write,result: result)
		}
		if(calledAction == 2)
		{
			if let args = call.arguments as? [String] 
			{
				if(args.count == 2)
				{
					self.txtToWrite = args[1];
					self.startExportDlg(controller:controller,localFileUrl: args[0],result: result)
				}
				else
				{
					result(FlutterError(code:"BADPARAMETER", message:"Needed exactly 1 URL string and a block of text-ish data",details:nil))
				}
				
			}
			else
			{
				result(FlutterError(code:"BADPARAMETER", message:"Failed to receive arguments as String array",details:nil))
			}
			
		}
    })
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
