//
//  I2IDynamicText.h
//  i2iDevelopment
//
//  Created by Neha Salankar on 08/04/15.
//  Modified by Pradeep Yadav on 14/03/17.
//  Copyright © 2017 i2i Logic (Australia) Pty Ltd. All rights reserved.
//

#ifndef I2IDynamicText_h
#define I2IDynamicText_h
#import <Foundation/Foundation.h>
#import "MSIWidgetViewer.h"
#import "MSIWidgetHelper.h"
#import <UIKit/UIKit.h>
#import "MSIPropertyGroup.h"
#import "MSIHeaderValue.h"
#import "MetricHeader.h"
#import "MetricValue.h"

@interface I2IDynamicText : MSIWidgetViewer {
    
    int intMetrics;
    int intTexts;
    NSMutableDictionary *metrics;
    // Text properties
    NSMutableAttributedString *strFullText;
    NSString *strPosition;
    int intNoFormulae;
    NSMutableArray *arrFormulae;
    NSString *strFontFace;
    int intFontSize;
    UIColor *fontColor;
    NSString *strTextAlignment;
    NSMutableString *strImage;
    
}

@property (retain,nonatomic) MSIModelData *modelData;

@end
#endif
