//
//  CustomControl.h
//  Adage
//
//  Created by Pradeep Yadav on 13/12/16.
//  Copyright © 2016 Third I, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CustomControl : NSObject {
	
	UILabel *lblValue;
	// Unique ID of the control
	NSString *uid;
	// Type of the control i.e Slider = 1, LessMore = 2, Reset = 3
	int type;
	// Default value of the control
	NSString *defaultCV;
	// Minimum value that the control can take.
	int min;
	// Maximum value of the control.
	int max;
	// Value for increments/decrements of control
	int step;
	// Suffix for the labels.
	NSString *suffix;
	// Position for control
	NSString *position;
	// Font face for the label.
	NSString *fFace;
	// Font size of the label.
	int fSize;
	NSMutableArray *colors;
	// Number Formatting for display
	int category;
	NSString *format;
	int align;
	
}

@property (retain,nonatomic) NSString *uid;
@property (assign,nonatomic) int type;
@property (retain,nonatomic) NSString *defaultCV;
@property (assign,nonatomic) int min;
@property (assign,nonatomic) int max;
@property (assign,nonatomic) int step;
@property (retain,nonatomic) NSString *suffix;
@property (retain,nonatomic) NSString *position;
@property (retain,nonatomic) NSString *fFace;
@property (assign,nonatomic) int fSize;
@property (retain,nonatomic) NSMutableArray *colors;
@property (assign,nonatomic) int category;
@property (retain,nonatomic) NSString *format;
@property (assign,nonatomic) int align;

@end
