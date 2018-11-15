/**
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit

class DocumentPickerViewController: UIDocumentPickerExtensionViewController {

  // MARK: - Properties
  var notes = [Note]()
  lazy var fileCoordinator: NSFileCoordinator = {
    let fileCoordinator = NSFileCoordinator()
    fileCoordinator.purposeIdentifier = self.providerIdentifier
    return fileCoordinator
  }()

  // MARK: - IBOutlets
  @IBOutlet weak var confirmButton: UIButton!
  @IBOutlet weak var confirmView: UIView!
  @IBOutlet weak var extensionWarningLabel: UILabel!
  @IBOutlet weak var tableView: UITableView!

  // MARK: - View Life Cycle
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    notes = Note.getAllNotesInFileSystem()

    tableView.reloadData()
  }

  // MARK: - Overridden Instance Methods
  override func prepareForPresentation(in mode: UIDocumentPickerMode) {

    // If the source URL does not have a path extension supported
    // show the extension warning label. Should only apply in
    // Export and Move services
    if let sourceURL = originalURL,
      sourceURL.pathExtension != Note.fileExtension {
        confirmButton.isHidden = true
        extensionWarningLabel.isHidden = false
    }

    switch mode {
    case .exportToService:
      //Show confirmation button
      confirmButton.setTitle("Export to CleverNote", for: UIControlState())
    case .moveToService:
      //Show confirmation button
      confirmButton.setTitle("Move to CleverNote", for: UIControlState())
    case .open:
      //Show file list
      confirmView.isHidden = true
    case .import:
      //Show file list
      confirmView.isHidden = true
    }
  }
}

// MARK: - IBActions
extension DocumentPickerViewController {

  @IBAction func confirmButtonTapped(_ sender: AnyObject) {
    guard let sourceURL = originalURL else {
      return
    }
    
    switch documentPickerMode {
    case .moveToService, .exportToService:
      let fileName = sourceURL.deletingPathExtension().lastPathComponent
      guard let destinationURL = Note.fileUrlForDocumentNamed(fileName) else {
          return
      }

      fileCoordinator.coordinate(readingItemAt: sourceURL, options: .withoutChanges, error: nil, byAccessor: { [weak self] newURL in
        do {
          try FileManager.default.copyItem(at: sourceURL, to: destinationURL)
          self?.dismissGrantingAccess(to: destinationURL)
        } catch _ {
          print("error copying file")
        }
      })

    default:
      dismiss(animated: true, completion: nil)
    }
  }
}

// MARK: - UITableViewDataSource
extension DocumentPickerViewController: UITableViewDataSource {

  // MARK: - CellIdentifiers
  fileprivate enum CellIdentifier: String {
    case NoteCell = "noteCell"
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return notes.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.NoteCell.rawValue, for: indexPath)
    let note = notes[(indexPath as NSIndexPath).row]
    cell.textLabel?.text = note.title
    return cell
  }
}

// MARK: - UITableViewDelegate
extension DocumentPickerViewController: UITableViewDelegate {

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    let note = notes[(indexPath as NSIndexPath).row]
    dismissGrantingAccess(to: note.fileURL)
  }
}
