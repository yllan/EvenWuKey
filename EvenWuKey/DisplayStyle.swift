//
//  DisplayStyle.swift
//  EvenWuKey
//
//  Created by Yung-Luen Lan on 2018/4/24.
//  Copyright © 2018 yllan.org. All rights reserved.
//

import Cocoa

protocol DisplayStyle {
    func show(_ info: String)
    func hide()
}

class HUDStyle : DisplayStyle {
    var window: NSWindow = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 300, height: 100), styleMask: [.borderless, .resizable], backing: .buffered, defer: true, screen: nil)
    var label = NSTextField(labelWithString: "")
    
    init() {
        label.font = NSFont.boldSystemFont(ofSize: 34)
        label.textColor = NSColor.white
        label.alignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        if let v = window.contentView {
            v.addSubview(label)
            NSLayoutConstraint.activate([
                label.centerXAnchor.constraint(equalTo: v.centerXAnchor),
                label.centerYAnchor.constraint(equalTo: v.centerYAnchor),
                ])
            v.wantsLayer = true
            if let layer = v.layer {
                layer.cornerRadius = 10
                layer.masksToBounds = true
                layer.backgroundColor = NSColor(calibratedWhite: 0.0, alpha: 0.3).cgColor
            }
        }
        window.isOpaque = false
        window.backgroundColor = NSColor.clear
        window.isMovableByWindowBackground = true
        window.level = .statusBar
        window.setFrameAutosaveName(NSWindow.FrameAutosaveName("HUD"))
    }
    
    func show(_ info: String) {
        if !window.isVisible {
            window.orderFrontRegardless()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                self.label.stringValue = info
            }
        } else {
            window.alphaValue = 1.0
            self.label.stringValue = info
        }
    }
    
    func hide() {
        label.stringValue = ""
        window.animator().alphaValue = 0.0
    }
    
    deinit {
        window.orderOut(nil)
    }
}


class EvenWuStyle : DisplayStyle {
    var window: NSWindow = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 467, height: 337), styleMask: [.borderless], backing: .buffered, defer: true, screen: nil)
    var evenwu = NSImageView()
    var label = NSTextField(labelWithString: "")
    
    init() {
        label.font = NSFont.boldSystemFont(ofSize: 34)
        label.textColor = NSColor.black
        label.alignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        evenwu.translatesAutoresizingMaskIntoConstraints = false
        evenwu.image = NSImage(imageLiteralResourceName: "evenwu")
        
        if let v = window.contentView {
            v.addSubview(evenwu)
            v.addSubview(label)
            NSLayoutConstraint.activate([
                evenwu.leftAnchor.constraint(equalTo: v.leftAnchor),
                evenwu.topAnchor.constraint(equalTo: v.topAnchor),
                evenwu.rightAnchor.constraint(equalTo: v.rightAnchor),
                evenwu.bottomAnchor.constraint(equalTo: v.bottomAnchor),
                
                label.centerXAnchor.constraint(equalTo: v.leftAnchor, constant: 670 / 2),
                label.centerYAnchor.constraint(equalTo: v.bottomAnchor, constant: -502 / 2)
            ])
        }
        window.isOpaque = false
        window.backgroundColor = NSColor.clear
        window.isMovableByWindowBackground = true
        window.level = .statusBar
        window.setFrameAutosaveName(NSWindow.FrameAutosaveName("EvenWu"))
    }
    
    func show(_ info: String) {
        if !window.isVisible {
            let frame = CGRect(origin: CGPoint(x: 100, y: -window.frame.size.height), size: window.frame.size)
            window.setFrame(frame, display: false, animate: false)
            window.orderFrontRegardless()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                self.label.stringValue = info
            }
        } else {
            self.label.stringValue = info
        }

        var newFrame = window.frame
        newFrame.origin.y = 0
        window.animator().setFrame(newFrame, display: true, animate: true)
        evenwu.image = arc4random() % 2 == 0 ? NSImage(imageLiteralResourceName: "evenwu") : NSImage(imageLiteralResourceName: "evenwu-speak")
    }
    
    func hide() {
        label.stringValue = ""
        var newFrame = window.frame
        newFrame.origin.y = -window.frame.size.height
        window.animator().setFrame(newFrame, display: true, animate: true)
        //        window.animator().alphaValue = 0.0
    }
}
