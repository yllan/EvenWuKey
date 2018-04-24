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
            self.label.stringValue = info
        }
    }
    
    func hide() {
        label.stringValue = ""
//        window.animator().alphaValue = 0.0
    }
}
