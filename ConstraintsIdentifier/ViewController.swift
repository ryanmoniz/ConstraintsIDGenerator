//
//  ViewController.swift
//  ConstraintsIdentifier
//
//  Created by Ryan Moniz on 2015-11-06.
//  Copyright © 2015 Ryan Moniz. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func processStoryboard() {
        guard let
            xmlPath = NSBundle.mainBundle().pathForResource("Main.storyboard", ofType: "xml"),
            data = NSData(contentsOfFile: xmlPath)
            else { return }
        
        do {
            let xmlDoc = try AEXMLDocument(xmlData: data)
            
            // prints the same XML structure as original
            print("BEFORE: xmlDoc.xmlString: " + xmlDoc.xmlString)
            
            
            // prints cats, dogs
            
            self.searchChildrenFor("constraints", inParent: xmlDoc.root.children)
            
            print("AFTER: xmlDoc.xmlString: " + xmlDoc.xmlString)
        }
        catch {
            print("\(error)")
        }
    }
    
    func searchChildrenFor(element: String, inParent parent:[AEXMLElement]) {
        for child in parent {
            print("child: " + child.name)
            
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
    


}

