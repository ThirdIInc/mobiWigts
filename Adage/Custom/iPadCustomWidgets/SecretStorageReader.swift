//
//  SecretStorageReader.swift
//  Adage
//
//  Created by Deepika Nahar on 12/12/16.
//  Copyright © 2016 Third I, Inc. All rights reserved.
//

import Foundation

class SecretStorageReader: NSObject {
    
    //  Function to set values in plist
    class func setValue(Value: String, keyForSlider Key: String) {
        var documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentFolder = documentPath[0]
        
        let newPlistFile = NSURL(fileURLWithPath: documentFolder).appendingPathComponent("UpdatedVariableMine.plist")?.absoluteString
        
        let bundleFile = Bundle.main.path(forResource: "VariableGoldmine", ofType: "plist")!
        // Copy the file from the bundle to the documents directory
        do {
            try FileManager.default.copyItem(atPath: bundleFile, toPath: newPlistFile!)
        }
        catch let error {
            print(error)
        }
        let addData = NSMutableDictionary(contentsOfFile: newPlistFile!)
        // Adding the new objects to the plist
        addData?.setValue(Value, forKey: Key)
        
        // Saving the changes
        addData?.write(toFile: newPlistFile!, atomically: true)
    }
    
    //  Function to get values from plist
    class func getValue() -> NSDictionary {
        var documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentFolder = documentPath[0]
        let bundlePlistFilePath = NSURL(fileURLWithPath: documentFolder).appendingPathComponent("UpdatedVariableMine.plist")?.absoluteString
        let plistDataDict = NSMutableDictionary(contentsOfFile: bundlePlistFilePath!)
        return plistDataDict!
    }
    
    //  Function to delete key from plist
    class func removeKey(Key: String) {
        var documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentFolder = documentPath[0]
        let bundlePlistFilePath = NSURL(fileURLWithPath: documentFolder).appendingPathComponent("UpdatedVariableMine.plist")?.absoluteString
        let plistDataDict = NSMutableDictionary(contentsOfFile: bundlePlistFilePath!)
        plistDataDict?.removeObject(forKey: Key)
        plistDataDict?.write(toFile: bundlePlistFilePath!, atomically: true)
    }
    
}
