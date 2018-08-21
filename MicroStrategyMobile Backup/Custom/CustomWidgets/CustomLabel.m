//
//  CustomLabel.m
//  Adage
//
//  Created by Pradeep Yadav on 13/12/16.
//  Copyright © 2016 Third I, Inc. All rights reserved.
//

#import "CustomLabel.h"

@implementation CustomLabel

@synthesize lblValue;
@synthesize position;
@synthesize key;
@synthesize formula;
// Font parameters
@synthesize fFace;
@synthesize fSize;
@synthesize fColor;
@synthesize fBold;
@synthesize fItalic;
@synthesize fUnderline;
// Text alignment parameters
@synthesize align;
@synthesize wrap;
// Number format parameters
@synthesize category;
@synthesize format;

-(UIView *)initializeLabel:(CGRect)frame withTag:(int)tag {
	
	UIView *uivContainer = [[UIView alloc]initWithFrame:frame];
	lblValue = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
	lblValue.tag = tag;
	lblValue.font = [UIFont fontWithName:fFace size:fSize];
	
	if (fBold == -1) {
		lblValue.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@-Bold",fFace] size:fSize];
	}
	
	if (fItalic == -1) {
		lblValue.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@-BoldItalic",fFace] size:fSize];
	}
	lblValue.textColor = fColor;
	
	//  Text Alignment Settings
	switch (align) {
		case 4:
			lblValue.textAlignment = NSTextAlignmentRight;
			break;
		case 3:
			lblValue.textAlignment = NSTextAlignmentCenter;
			break;
		default:
			lblValue.textAlignment = NSTextAlignmentLeft;
			break;
	}
	
	if (wrap == 0) {
		lblValue.numberOfLines = 1;
	}
	else {
		lblValue.numberOfLines = 0;
	}
	
	lblValue.text = @"0";
	[lblValue sizeToFit];
	lblValue.frame = CGRectMake(0, 0, frame.size.width, lblValue.frame.size.height);
	lblValue.lineBreakMode = NSLineBreakByWordWrapping;
	// Uncomment the line below for building and validating the label size and position
	//lblValue.backgroundColor = [UIColor cyanColor];
	[uivContainer addSubview:lblValue];
	return uivContainer;
}

@end
