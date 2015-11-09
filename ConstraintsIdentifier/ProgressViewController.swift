//
//  ProgressViewController.swift
//  ConstraintsIdentifier
//
//  Created by Ryan Moniz on 2015-11-08.
//  Copyright © 2015 Ryan Moniz. All rights reserved.
//

import AppKit

import ProgressKit

class ProgressViewController: NSViewController {
    
    @IBOutlet weak var progressView: RotatingArc!
    @IBOutlet weak var blurView: NSView!
        
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)!
        // Custom initialization
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init() {
        self.init(nibName: "ProgressView", bundle:nil)
    }
    
    func startAnimating() {
        self.progressView.animate = true
    }
    
    func stopAnimating() {
        self.progressView.animate = false
    }
    
//     func instantiateFromNib<T: NSView>(viewType: T.Type) -> T {
//        var subviewArray:NSArray?
//        NSBundle.mainBundle().loadNibNamed("ProgressView", owner: nil, topLevelObjects: &subviewArray)
//        return subviewArray?.firstObject as! T
//    }
}
