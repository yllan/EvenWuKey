//
//  UserDefaults+Color.swift
//  EvenWuKey
//
//  Created by Yung-Luen Lan on 2018/4/26.
//  Copyright © 2018 yllan.org. All rights reserved.
//

import Cocoa

extension UserDefaults {
    func color(forKey key: String) -> NSColor? {
        if let colorData = data(forKey: key) {
            return NSKeyedUnarchiver.unarchiveObject(with: colorData) as? NSColor
        } else {
            return nil
        }
    }
    
    func set(_ value: NSColor?, forKey key: String) {
        if let color = value {
            let colorData = NSKeyedArchiver.archivedData(withRootObject: color)
            set(colorData, forKey: key)
        } else {
            removeObject(forKey: key)
        }
    }
}
