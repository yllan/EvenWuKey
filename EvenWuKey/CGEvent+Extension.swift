//
//  CGEvent+Extension.swift
//  EvenWuKey
//
//  Created by Yung-Luen Lan on 2018/4/24.
//  Copyright © 2018 yllan.org. All rights reserved.
//

import Foundation
import CoreGraphics

extension CGEvent {
    func keyCode() -> CGKeyCode {
        return CGKeyCode(self.getIntegerValueField(.keyboardEventKeycode))
    }
}
