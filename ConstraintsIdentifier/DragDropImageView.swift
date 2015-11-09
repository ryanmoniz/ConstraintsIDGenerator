//
//  DragDropImageView.swift
//  ConstraintsIdentifier
//
//  Created by Ryan Moniz on 2015-11-08.
//  Copyright © 2015 Ryan Moniz. All rights reserved.
//

import AppKit

let PrivateDragUTI = "com.mobilefirst.ibm.constraintsidentifier.cocoadraganddrop"

protocol DragDropImageViewDelegate {
    func dragDropImageViewDidReceiveFiles(files: [String])
}

class DragDropImageView: NSImageView, NSDraggingSource {
    
    var highlightDropZone: Bool
    var dragDropEnabled: Bool
    var sourceFilenameString: [String] = [String]()
    
    var delegate: DragDropImageViewDelegate?
    
    //Init method called for Interface Builder objects
    required init?(coder: NSCoder) {
        self.highlightDropZone = false
        self.dragDropEnabled = true
        
        super.init(coder: coder)

        //register for all the image types we can display
        self.registerForDraggedTypes([NSFilenamesPboardType])
    }
    
    //MARK: - Destination Operations
    
    //method called whenever a drag enters our drop zone
    override func draggingEntered(sender: NSDraggingInfo) -> NSDragOperation {
        // Check if the pasteboard contains image data and source/user wants it copied
        
        let sourceDragMask = sender.draggingSourceOperationMask()
        let pboard = sender.draggingPasteboard()
        
        if pboard.availableTypeFromArray([NSFilenamesPboardType]) == NSFilenamesPboardType {
            if sourceDragMask.rawValue & NSDragOperation.Generic.rawValue != 0 {
                highlightDropZone = true
                return NSDragOperation.Copy
            }
        }
        
        return NSDragOperation.None
    }
    
    //method called whenever a drag exits our drop zone
    override func draggingExited(sender: NSDraggingInfo?) {
        //remove highlight of the drop zone
        highlightDropZone = false
        
        self.setNeedsDisplay()
    }
    
    //draw method is overridden to do drop highlighing
    override func drawRect(dirtyRect: NSRect) {
        //do the usual draw operation to display the image
        super.drawRect(dirtyRect)
        
        if ( highlightDropZone ) {
            //highlight by overlaying a gray border
            NSColor.redColor().set()

            NSBezierPath.fillRect(dirtyRect)
        }
    }
    
    //method to determine if we can accept the drop
    override func prepareForDragOperation(sender: NSDraggingInfo) -> Bool {
        let pboard = sender.draggingPasteboard()
        
        //finished with the drag so remove any highlighting
        highlightDropZone = false
        
        self.setNeedsDisplay()
        
        if self.dragDropEnabled == false {
            return false
        }
        
        //check to see if we can accept the data
        if pboard.availableTypeFromArray([NSFilenamesPboardType]) == NSFilenamesPboardType {
            return true
        }
        return false
    }
    
    //method that should handle the drop data
    override func performDragOperation(sender: NSDraggingInfo) -> Bool {
        let pboard = sender.draggingPasteboard()
        
        // Make sure that there are filenames in the pasteboard
        if pboard.availableTypeFromArray([NSFilenamesPboardType]) == NSFilenamesPboardType {
            // Get the filenames from the pasteboard
            let files = filesFromPboard(pboard)
            
            // Add the filenames to the datasource
            sourceFilenameString = files
            
            delegate?.dragDropImageViewDidReceiveFiles(self.sourceFilenameString)
            
            // Update the view
            self.needsDisplay = true
            
            // The drop was accepted
            return true
        }
        
        return false
    }
    
    func filesFromPboard(pboard: NSPasteboard) -> [String] {
        var files: [String] = [String]()
        if let data:NSData = pboard.dataForType(NSFilenamesPboardType) {
            do {
                let filenames:NSArray = try NSPropertyListSerialization.propertyListWithData(data, options: NSPropertyListMutabilityOptions.Immutable, format: nil) as! NSArray
                for filename in filenames {
                    files.append(filename as! String)
                    NSLog("adding url:\(filename)")
                }
            } catch {
                NSLog("error:\(error)")
            }
        } else {
            //no data?
        }
        
        return files
    }
    
    //MARK: - Source Operations
    
    //NSDraggingSource protocol method.  Returns the types of operations allowed in a certain context.
    func draggingSession(session: NSDraggingSession, sourceOperationMaskForDraggingContext context: NSDraggingContext) -> NSDragOperation {
        switch(context) {
        case NSDraggingContext.OutsideApplication:
            return NSDragOperation.Copy
        case NSDraggingContext.WithinApplication:
            return NSDragOperation.Copy
        }
    }
    
    //accept activation click as click in window
    override func acceptsFirstMouse(theEvent: NSEvent?) -> Bool {
        return true
    }
    
}
