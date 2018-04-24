//
//  AppDelegate.swift
//  EvenWuKey
//
//  Created by Yung-Luen Lan on 2018/4/23.
//  Copyright © 2018 yllan.org. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    let defaultOrder: [UInt16] = [
        59, // Control
        58, // Option
        61, // Option
        56, // Shift
        60, // Shift
        55, // Command
        54, // Command
        
        51, // Delete
        48, // Tab
        
        
        53, // Esc
        50, // `
        18, // 1
        19, // 2
        20, // 3
        21, // 4
        23, // 5
        22, // 6
        26, // 7
        28, // 8
        25, // 9
        29, // 0
        27, // -
        24, // =
        
        0, // A
        11, // B
        8, // C
        2, // D
        14, // E
        3, // F
        5, // G
        4, // H
        34, // I
        38, // J
        40, // K
        37, // L
        46, // M
        45, // N
        31, // O
        35, // P
        12, // Q
        15, // R
        1, // S
        17, // T
        32, // U
        9, // V
        13, // W
        7, // X
        16, // Y
        6, // Z
        
        33, // [
        30, // ]
        42, // \\
        41, // ;
        39, // '
        36, // Return
        43, // ,
        47, // .
        44, // /
        
        49, // Space
        
        126, // Up
        125, // Down
        123, // Left
        124, // Right
        
        57, // CapsLock
    ]
    let defaultNames: [UInt16: String] = [
        53: "Esc",
        50: "`",
        18: "1",
        19: "2",
        20: "3",
        21: "4",
        23: "5",
        22: "6",
        26: "7",
        28: "8",
        25: "9",
        29: "0",
        27: "-",
        24: "=",
        51: "Delete",
        48: "Tab",
        12: "Q",
        13: "W",
        14: "E",
        15: "R",
        17: "T",
        16: "Y",
        32: "U",
        34: "I",
        31: "O",
        35: "P",
        33: "[",
        30: "]",
        42: "\\",
        57: "CapsLock",
        0: "A",
        1: "S",
        2: "D",
        3: "F",
        5: "G",
        4: "H",
        38: "J",
        40: "K",
        37: "L",
        41: ";",
        39: "'",
        36: "Return",
        56: "Shift",
        60: "Shift",
        6: "Z",
        7: "X",
        8: "C",
        9: "V",
        11: "B",
        45: "N",
        46: "M",
        43: ",",
        47: ".",
        44: "/",
        59: "Control",
        58: "Option",
        61: "Option",
        55: "Command",
        54: "Command",
        49: "Space",
        126: "Up",
        125: "Down",
        123: "Left",
        124: "Right"
    ]
    
    var keys: Set<UInt16> = Set()
    var window: NSWindow = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 300, height: 80), styleMask: [], backing: .buffered, defer: false, screen: nil)
    var label = NSTextField(labelWithString: "")
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String : true]
        let accessEnabled = AXIsProcessTrustedWithOptions(options)
        
        if !accessEnabled {
            print("Access Not Enabled")
            // TODO:
        }

        label.font = NSFont.boldSystemFont(ofSize: 28)
        label.textColor = NSColor.white
        label.alignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        if let v = window.contentView {
            v.addSubview(label)
            NSLayoutConstraint.activate([
                label.centerXAnchor.constraint(equalTo: v.centerXAnchor),
                label.centerYAnchor.constraint(equalTo: v.centerYAnchor),
            ])
        }
        window.isOpaque = false
        window.backgroundColor = NSColor(white: 0, alpha: 0.5)
        window.center()
        window.level = .statusBar
        window.makeKeyAndOrderFront(nil)
        
        let handler: ((NSEvent) -> NSEvent?) = { (event: NSEvent) in
            print("\(event)")
            switch event.type {
            case .keyDown:
                self.keys.insert(event.keyCode)
                self.refreshDisplay()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.10, execute: self.refreshDisplay)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: self.refreshDisplay)
            case .keyUp:
                self.keys.remove(event.keyCode)
            case .flagsChanged:
                self.handleFlagsChanged(event)
            default:
                break
            }
            return event
        }
        
        NSEvent.addGlobalMonitorForEvents(matching: [.keyUp, .keyDown, .flagsChanged], handler: { _ = handler($0) })
        NSEvent.addLocalMonitorForEvents(matching: [.keyUp, .keyDown, .flagsChanged], handler: handler)
    }
    
    func handleFlagsChanged(_ event: NSEvent) {
        var keyDown = false
        switch event.keyCode {
        case 55, 54: // Command
            keyDown = event.modifierFlags.contains(.command)
        case 58, 61: // Option
            keyDown = event.modifierFlags.contains(.option)
        case 59:     // Control
            keyDown = event.modifierFlags.contains(.control)
        case 56, 60: // Shift
            keyDown = event.modifierFlags.contains(.shift)
        case 57:     // Caps Lock
            keyDown = event.modifierFlags.contains(.capsLock)
        default:
            return
        }
        
        if keyDown {
            self.keys.insert(event.keyCode)
            self.refreshDisplay()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.10, execute: self.refreshDisplay)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: self.refreshDisplay)
        } else {
            self.keys.remove(event.keyCode)
        }
    }
    
    func refreshDisplay() {
        if self.keys.isEmpty {
            label.stringValue = ""
        } else {
            label.stringValue = self.pressingKeys()
        }
    }
    
    func pressingKeys() -> String {
        let overrideNames: [UInt16: String] = [
            51: "Delete",
            48: "Tab",
            57: "CapsLock",
            36: "⏎",
            56: "⇧",
            60: "⇧",
            59: "⌃",
            58: "⌥",
            61: "⌥",
            55: "⌘",
            54: "⌘",
            49: "Space",
            126: "↑",
            125: "↓",
            123: "←",
            124: "→"
        ]
        let names = defaultNames.merging(overrideNames) { $1 }
        return defaultOrder.filter(self.keys.contains).map({names[$0] ?? "?"}).joined(separator: "")
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}

