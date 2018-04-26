//
//  AppDelegate.swift
//  EvenWuKey
//
//  Created by Yung-Luen Lan on 2018/4/23.
//  Copyright © 2018 yllan.org. All rights reserved.
//

import Cocoa
import CoreGraphics

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var display: DisplayStyle = HUDStyle() {
        didSet {
            oldValue.hide()
        }
    }
    
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
    var statusItem: NSStatusItem? = nil
    
    var font: NSFont {
        get {
            let defaultFont = NSFont.boldSystemFont(ofSize: 34)
            if let fontName = UserDefaults.standard.string(forKey: "FontName"),
                UserDefaults.standard.double(forKey: "FontSize") > 0 {
                let fontSize = UserDefaults.standard.double(forKey: "FontSize")
                return NSFont(name: fontName, size: CGFloat(fontSize)) ?? defaultFont
            } else {
                return defaultFont
            }
        }
        set {
            UserDefaults.standard.set(newValue.fontName, forKey: "FontName")
            UserDefaults.standard.set(Double(newValue.pointSize), forKey: "FontSize")
            UserDefaults.standard.synchronize()
        }
    }
    var foregroundColor: NSColor {
        get { return UserDefaults.standard.color(forKey: "ForegroundColor") ?? NSColor.white }
        set {
            UserDefaults.standard.set(newValue, forKey: "ForegroundColor")
            UserDefaults.standard.synchronize()
        }
    }
    var backgroundColor: NSColor
    {
        get { return UserDefaults.standard.color(forKey: "BackgroundColor") ?? NSColor(calibratedWhite: 0.0, alpha: 0.3) }
        set {
            UserDefaults.standard.set(newValue, forKey: "BackgroundColor")
            UserDefaults.standard.synchronize()
        }
    }
    
    @IBOutlet var prefWindw: NSWindow? = nil
    @IBOutlet var foregroundColorWell: NSColorWell!
    @IBOutlet var backgroundColorWell: NSColorWell!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String : true]
        let accessEnabled = AXIsProcessTrustedWithOptions(options)
        
        if !accessEnabled {
            print("Access Not Enabled")
            // TODO:
        }
        
        updateSetting()
        
        installKeyEventListener()
        installStatusItem()
    }
    
    func installStatusItem() {
        let statusBar = NSStatusBar.system
        let item = statusBar.statusItem(withLength: NSStatusItem.squareLength)
        let menu = NSMenu(title: "")
        menu.addItem(withTitle: "Preferences", action: #selector(showPreferences), keyEquivalent: "")
        menu.addItem(NSMenuItem.separator())
        menu.addItem(withTitle: "Quit", action: #selector(quitApp), keyEquivalent: "")
        item.menu = menu
        item.highlightMode = true
        item.button?.image = NSImage(named: NSImage.Name("MenuItem"))
        self.statusItem = item
    }
    
    @IBAction func showPreferences(_ sender: Any) {
        if NSNib(nibNamed: NSNib.Name("Pref"), bundle: nil)?.instantiate(withOwner: self, topLevelObjects: nil) ?? false {
            if let prefWindow = self.prefWindw {
                NSApp.activate(ignoringOtherApps: true)
                prefWindow.center()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.foregroundColorWell.color = self.foregroundColor
                    self.backgroundColorWell.color = self.backgroundColor
                    NSColorPanel.shared.showsAlpha = true
                    prefWindow.makeKeyAndOrderFront(nil)
                }
            }
        }
    }
    
    @IBAction func quitApp(_ sender: Any) {
        NSApp.terminate(sender)
    }
    
    func installKeyEventListener() {
        let eventMaskList = [
            CGEventType.keyDown.rawValue,
            CGEventType.keyUp.rawValue,
            CGEventType.flagsChanged.rawValue,
            UInt32(NX_SYSDEFINED) // Media key Event
        ]
        
        let eventMask: UInt64 = eventMaskList.reduce(UInt64(0)) { $0 | (1 << $1) }
        let observer = UnsafeMutableRawPointer(Unmanaged.passRetained(self).toOpaque())
        if let eventTap = CGEvent.tapCreate(tap: .cghidEventTap, place: .tailAppendEventTap, options: .listenOnly, eventsOfInterest: eventMask, callback: { (proxy, type, event, refcon) -> Unmanaged<CGEvent>? in
            if let observer = refcon {
                let mySelf = Unmanaged<AppDelegate>.fromOpaque(observer).takeUnretainedValue()
                switch type {
                case .keyDown:
                    mySelf.keyDown(event)
                case .keyUp:
                    mySelf.keyUp(event)
                case .flagsChanged:
                    let flagFor: [CGKeyCode: CGEventFlags] = [54: CGEventFlags.maskCommand,
                                                              55: CGEventFlags.maskCommand,
                                                              56: CGEventFlags.maskShift,
                                                              60: CGEventFlags.maskShift,
                                                              59: CGEventFlags.maskControl,
                                                              62: CGEventFlags.maskControl,
                                                              58: CGEventFlags.maskAlternate,
                                                              61: CGEventFlags.maskAlternate,
                                                              63: CGEventFlags.maskSecondaryFn,
                                                              57: CGEventFlags.maskAlphaShift]
                    if let flag = flagFor[event.keyCode()] {
                        event.flags.contains(flag) ? mySelf.modifierDown(event) : mySelf.modifierUp(event)
                    } else {
                        // TODO: error handle
                    }
                default:
                    break
                }
                
            }
            return Unmanaged.passUnretained(event)
        }, userInfo: observer) {
            let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
            CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
            CGEvent.tapEnable(tap: eventTap, enable: true)
            CFRunLoopRun()
        }
    }
    
    func keyDown(_ event: CGEvent) {
        keys.insert(event.keyCode())
        refreshDisplay()
    }
    
    func keyUp(_ event: CGEvent) {
        keys.remove(event.keyCode())
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6, execute: self.refreshDisplay)
    }

    func modifierDown(_ event: CGEvent) {
        keys.insert(event.keyCode())
        refreshDisplay()
    }
    
    func modifierUp(_ event: CGEvent) {
        keys.remove(event.keyCode())
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6, execute: self.refreshDisplay)
    }
    
    func refreshDisplay() {
        let magic = Set<UInt16>([14, 9, 45, 13, 32])
        if self.keys.intersection(magic) == magic {
            self.display = EvenWuStyle()
        }
        
        if self.keys.isEmpty {
            display.hide()
        } else {
            display.show(self.pressingKeys())
        }
    }
    
    @IBAction func changeForegroundColor(_ sender: Any?) {
        self.foregroundColor = self.foregroundColorWell.color
        updateSetting()
    }
    
    @IBAction func changeBackgroundColor(_ sender: Any?) {
        self.backgroundColor = self.backgroundColorWell.color
        updateSetting()
    }
    
    @IBAction func displayFontPanel(_ sender: Any?) {
        NSFontManager.shared.setSelectedFont(self.font, isMultiple: false)
        NSFontManager.shared.target = self
        NSFontManager.shared.action = #selector(changeFont)
        NSFontManager.shared.fontPanel(true)?.makeKeyAndOrderFront(sender)
    }
    
    @IBAction override func changeFont(_ sender: Any?) {
        self.font = NSFontManager.shared.convert(self.font)
        updateSetting()
    }
    
    func updateSetting() {
        self.display.updateSetting(foregroundColor: self.foregroundColor, backgroundColor: self.backgroundColor, font: self.font)
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
