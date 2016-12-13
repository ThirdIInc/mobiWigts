//
//  CustomLabel.h
//  Adage
//
//  Created by Pradeep Yadav on 13/12/16.
//  Copyright © 2016 Third I, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CustomLabel : NSObject {
    
    NSString *key;
    NSString *formula;
    NSString *position;
    UILabel *lblValue;
    //  Font parameters
    NSString *fFace;
    int fSize;
    UIColor *fColor;
    int fBold;
    int fItalic;
    int fUnderline;
    //  Text alignment parameters
    int align;
    int wrap;
    //  Number format parameters
    int category;
    NSString *format;
}

@property (retain,nonatomic) NSString *key;
@property (strong,nonatomic) NSString *formula;
@property (strong,nonatomic) NSString *position;
@property (strong,nonatomic) UILabel *lblValue;
//  Font parameters
@property (strong,nonatomic) NSString *fFace;
@property (assign,nonatomic) int fSize;
@property (strong,nonatomic) UIColor *fColor;
@property (assign,nonatomic) int fBold;
@property (assign,nonatomic) int fItalic;
@property (assign,nonatomic) int fUnderline;
//  Text alignment parameters
@property (assign,nonatomic) int align;
@property (assign,nonatomic) int wrap;
//  Number format parameters
@property (assign,nonatomic) int category;
@property (strong,nonatomic) NSString *format;
//  Padding parameters

-(UIView*)initializeLabel:(CGRect)frame withTag:(NSInteger)tag;

@end
