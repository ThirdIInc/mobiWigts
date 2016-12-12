//
//  CustomControl.swift
//  Adage
//
//  Created by Deepika Nahar on 12/12/16.
//  Copyright © 2016 Third I, Inc. All rights reserved.
//

import Foundation
import UIKit

class CustomControl: NSObject {
    
    var lblValue: UILabel!
    var uid: String = ""
    var type: Int = 0
    var defaultCV: String = ""
    var min: String = ""
    var max: String = ""
    var step: String = ""
    var suffix: String = ""
    var position: String = ""
    var fFace: String = ""
    var fSize: String = ""
    var colors = [UIColor]()
    // Number Formatting for display
    var category: String = ""
    var format: String = ""
    var align: String = ""
    
}
