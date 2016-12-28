//
//  GoldmineReader.h
//  Adage
//
//  Created by Pradeep Yadav on 13/12/16.
//  Copyright © 2016 Third I, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GoldmineReader : NSObject

//  Function to set values in plist
+(void)setValue:(NSString *)Value
				 forKey:(NSString *)Key;

//  Function to get values from plist
+(NSDictionary *)getValue;

//  Function to delete key from plist
+(void)removeKey:(NSString *)Key;

@end
