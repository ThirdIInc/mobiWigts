//
//  GoldmineReader.m
//  Adage
//
//  Created by Pradeep Yadav on 13/12/16.
//  Copyright © 2016 Third I, Inc. All rights reserved.
//

#import "GoldmineReader.h"

@implementation GoldmineReader

// Function to set values in plist
+(void)setValue:(NSString *)Value forKey:(NSString *)Key {
	NSArray *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentFolder = [documentPath objectAtIndex:0];
	
	// The below variable is an instance of the NSString class and is declared in the .h file
	NSString* newPlistFile = [documentFolder stringByAppendingPathComponent:@"UpdatedVariableGoldmine.plist"];
	NSString *bundleFile = [[NSBundle mainBundle]pathForResource:@"VariableGoldmine" ofType:@"plist"];
	// Copy the file from the bundle to the documents directory
	[[NSFileManager defaultManager]copyItemAtPath:bundleFile toPath:newPlistFile error:nil];
	NSMutableDictionary *addData = [NSMutableDictionary dictionaryWithContentsOfFile:newPlistFile];
	// Adding the new objects to the plist
	[addData setObject:Value forKey:Key];
	// Saving the changes
	[addData writeToFile:newPlistFile atomically:YES];
}
// Function to get values from plist
+(NSDictionary *)getValue {
	NSArray *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentFolder = [documentPath objectAtIndex:0];
	NSString *bundlePlistFilePath = [documentFolder stringByAppendingPathComponent:@"UpdatedVariableGoldmine.plist"];
	NSMutableDictionary *plistDataDict = [NSMutableDictionary dictionaryWithContentsOfFile:bundlePlistFilePath];
	return plistDataDict;
}
// Function to delete key from plist
+(void)removeKey:(NSString *)Key {
	NSArray *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentFolder = [documentPath objectAtIndex:0];
	
	// The below variable is an instance of the NSString class and is declared in the .h file
	NSString *bundlePlistFilePath = [documentFolder stringByAppendingPathComponent:@"UpdatedVariableGoldmine.plist"];
	NSMutableDictionary *plistDataDict = [NSMutableDictionary dictionaryWithContentsOfFile:bundlePlistFilePath];
	[plistDataDict removeObjectForKey:Key];
	// Saving the changes
	[plistDataDict writeToFile:bundlePlistFilePath atomically:YES];
}

@end
