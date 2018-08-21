//
//  FxGraph.h
//  i2iDevelopment
//
//  Created by Deepika Nahar on 10/03/17.
//  Modified by Pradeep Yadav on 19/03/17.
//  Copyright © 2017 i2i Logic (Australia) Pty Ltd. All rights reserved.
//

#ifndef I2IFxGraph_h
#define I2IFxGraph_h

#import <Foundation/Foundation.h>
#import "MSIWidgetViewer.h"
#import "MSIWidgetHelper.h"
#import <UIKit/UIKit.h>
#import "MSIPropertyGroup.h"
#import "MSIHeaderValue.h"
#import "AttributeHeader.h"
#import "AttributeElement.h"
#import "Attribute.h"
#import "MetricHeader.h"
#import "MetricValue.h"
#import "I2IFxPlotV.h"
#import "PlistData.h"
#import "FormulaEvaluator.h"

@interface I2IFxGraph : MSIWidgetViewer {
    
    UIView *hostView;
    I2IFxPlotV *fxGraph;
    NSString *keySuffix;
    
}

@property (retain, nonatomic) MSIModelData *dataModel;
-(void)readData;

@end

#endif

/* FxGraph_h */
