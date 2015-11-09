//
//  ViewController.swift
//  ConstraintsIdentifier
//
//  Created by Ryan Moniz on 2015-11-06.
//  Copyright © 2015 Ryan Moniz. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, DragDropImageViewDelegate {

    @IBOutlet weak var dragDropImageView: DragDropImageView!
    
    var progressController: ProgressViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.progressController = ProgressViewController()

        self.dragDropImageView.delegate = self
        self.dragDropImageView.dragDropEnabled = true
    
        
//    displayProgress()
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func processXML(file: String, finalPath:String) {
        guard let
            data = NSData(contentsOfFile: file)
            else { return }
        
        do {
            let xmlDoc = try AEXMLDocument(xmlData: data)
            
            // prints the same XML structure as original
//            print("BEFORE: xmlDoc.xmlString: " + xmlDoc.xmlString)
            self.searchChildrenFor("constraints", inParent: xmlDoc.root.children)
            
//            print("AFTER: xmlDoc.xmlString: " + xmlDoc.xmlString)
            let fileURL = NSURL(fileURLWithPath: file)
            if let filename = fileURL.lastPathComponent {
                do {
                    let filePath = finalPath + "/" + filename
                    NSLog("filePath:\(filePath)")
                    try xmlDoc.xmlString.writeToFile(filePath, atomically: true, encoding: NSASCIIStringEncoding)
                } catch {
                    print("error:\(error)")
                }
            }
        }
        catch {
            print("\(error)")
        }
    }
    
    func searchChildrenFor(element: String, inParent parent:[AEXMLElement]) {
        for child in parent {
            //print("child: " + child.name)
            
            if child.name == element {
                print("found the child/element: \(child.name)")
                if element == "constraints" {
                    searchChildrenFor("constraint", inParent: child.children)
                } else if element == "constraint" {
                    //get the child's attributes, create a new child and add identifier attribute
                    if let parent = child.parent {
                        var childAttributes = child.attributes
                        childAttributes["identifier"] = NSUUID().UUIDString
                        
                        //remove the old child from parent
                        child.removeFromParent()
                        
                        parent.addChild(name: "constraint", attributes: childAttributes)
                    }
                    
                    searchChildrenFor("constraint", inParent: child.children)
                }
            } else {
                let grandchildrenArray = child.children
                searchChildrenFor(element, inParent: grandchildrenArray)
            }
        }
    }
    
    //display alert sheet to save modified storyboards
    func displayProgress() {
        self.view.addSubview(self.progressController.view)
        
        self.progressController.startAnimating()
        
        self.dragDropImageView.dragDropEnabled = false
    }
    
    func hideProgress() {
        self.progressController.view.removeFromSuperview()
        
        self.progressController.stopAnimating()
        
        self.dragDropImageView.dragDropEnabled = true
    }
    
    func parseXcodeProject(files: [String], destinationURL: NSURL) {
        let fileManager = NSFileManager.defaultManager()
        
        for project in files {
            if let enumerator = fileManager.enumeratorAtPath(project) {
                while let file = enumerator.nextObject() {
                    if file.pathExtension == "storyboard" {
                        let filePath = "\(project)/\(file)"
                        NSLog("storyboarde filePath:\(filePath)")
                        processXML(filePath, finalPath: destinationURL.path!)
                    } else if file.pathExtension == "xib" {
                        let filePath = "\(project)/\(file)"
                        NSLog("xib filePath:\(filePath)")
                        processXML(filePath, finalPath: destinationURL.path!)
                    }
                }
            } else {
                NSLog("could not enumerate at path:\(project)")
            }
        }
        
        self.hideProgress()
        
        //finished alert
        self.finishedAlert()
    }
    
    func finishedAlert() {
        let alert = NSAlert()
        alert.addButtonWithTitle("OK")
        alert.messageText = "Finished adding identifiers to constraints in project."
        alert.alertStyle = NSAlertStyle.CriticalAlertStyle
        
        alert.beginSheetModalForWindow(self.view.window!, completionHandler: { modalResponse in
            self.dragDropImageView.dragDropEnabled = true
        })
    }

    //MARK: - DragDropImageViewDelegate Method
    
    func dragDropImageViewDidReceiveFiles(files: [String]) {
        if files.count > 0 {
            dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                self.dragDropImageView.dragDropEnabled = false
                let alert = NSAlert()
                alert.addButtonWithTitle("Select")
                alert.addButtonWithTitle("Cancel")
                alert.messageText = "Select final destination for modified files."
                alert.alertStyle = NSAlertStyle.CriticalAlertStyle
                
                alert.beginSheetModalForWindow(self.view.window!, completionHandler: { modalResponse in
                    if modalResponse == NSAlertFirstButtonReturn {
                        let openSheet = NSOpenPanel()
                        openSheet.canChooseDirectories = true
                        openSheet.canChooseFiles = false
                        
                        openSheet.allowsMultipleSelection = false
                        openSheet.canCreateDirectories = true
                        
                        //use existing file path
                        let fileURL = NSURL(fileURLWithPath: files.first!)
                        openSheet.directoryURL = fileURL
                        
                        openSheet.beginSheetModalForWindow(self.view.window!, completionHandler: { result in
                            if result == NSFileHandlingPanelOKButton {
                                //TODO: use NSOperationQueue/NSOperation to do tasks for each file in files?
                                if let finalDestinationURL = openSheet.URL {
                                    self.displayProgress()
                                    self.parseXcodeProject(files, destinationURL:finalDestinationURL)
                                } else {
                                    //display error?
                                    self.dragDropImageView.dragDropEnabled = true
                                }
                            } else {
                                //display error?
                                self.dragDropImageView.dragDropEnabled = true
                            }
                        })
                    } else {
                        //display error?
                        self.dragDropImageView.dragDropEnabled = true
                    }
                })
            }
            
        } else {
            //display error
            self.dragDropImageView.dragDropEnabled = true
        }
    }
}

