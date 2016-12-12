//
//  CustomLabel.swift
//  Adage
//
//  Created by Deepika Nahar on 12/12/16.
//  Copyright © 2016 Third I, Inc. All rights reserved.
//

import Foundation
import UIKit

class CustomLabel: NSObject {
    
    var key: String = ""
    var formula: String = ""
    var position: String = ""
    var lblValue: UILabel!
    //  Font parameters
    var fFace: String = ""
    var fSize: Int = 0
    var fColor: UIColor!
    var fBold: Int = 0
    var fItalic: Int = 0
    var fUnderline: Int = 0
    //  Text alignment parameters
    var align: Int = 0
    var wrap: Int = 0
    //  Number format parameters
    var category: Int = 0
    var format: Int = 0
    
    func initializeLabel(frame: CGRect, withTag intTag: Int) -> UIView? {
        
        let uivContainer = UIView(frame: frame)
        lblValue = UILabel(frame: CGRect(x:0, y:0, width:frame.size.width, height:frame.size.height))
        lblValue.tag = intTag
        lblValue.font = UIFont(name: fFace as String, size: CGFloat(fSize))
        
        if fBold == -1 {
            lblValue.font = UIFont(name: "\(fFace)-Bold", size: CGFloat(fSize))
        }
        
        if fItalic == -1 {
            lblValue.font = UIFont(name: "\(fFace)-BoldItalic", size: CGFloat(fSize))
        }
        
        lblValue.textColor = fColor
        
        switch align {
        case 4:
            lblValue.textAlignment = .right
            break;
        case 3:
            lblValue.textAlignment = .center
            break;
        default:
            lblValue.textAlignment = .left
            break;
        }
        
        if wrap == 0 {
            lblValue.numberOfLines = 1
        }
        else {
            lblValue.numberOfLines = 0
        }
        
        lblValue.text = "100"
        lblValue.sizeToFit()
        lblValue.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        lblValue.lineBreakMode = .byWordWrapping
        uivContainer.addSubview(lblValue)
        return uivContainer
 
    }
    
}
