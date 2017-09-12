//
//  TimelineAnimationNameExtensions.swift
//  TimelineAnimations
//
//  Created by Georges Boumis on 19/04/2017.
//  Copyright © 2017 AbZorba Games. All rights reserved.
//

import Foundation

public extension TimelineAnimation {
    
    @objc final public func append(name n: String) {
        var name = ""
        if let _name = self.name {
            name = _name
        }
        self.name = name + n
    }
}
