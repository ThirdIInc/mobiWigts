//
//  Initialisation.h
//  i2iDevelopment
//
//  Created by Pradeep Yadav on 15/10/15.
//  Modified by Pradeep Yadav on 14/03/17.
//  Copyright © 2017 i2i Logic (Australia) Pty Ltd. All rights reserved.
//

#ifndef Initialisation_h
#define Initialisation_h
#import <Foundation/Foundation.h>
#import "MSIWidgetViewer.h"
#import "MSIWidgetHelper.h"
#import <UIKit/UIKit.h>
#import "MSIPropertyGroup.h"
#import "MSIHeaderValue.h"
#import "MetricHeader.h"
#import "MetricValue.h"
#import "PlistData.h"
#import "FormulaEvaluator.h"

@interface Initialisation : MSIWidgetViewer {
    
    int intVariables;
    FormulaEvaluator *eval;
    NSMutableDictionary *metrics;
    NSString *companyID;
    NSString *companyKey;
    
}

@property (retain,nonatomic) MSIModelData *modelData;
-(void)readData;

@end

#endif
