//
//  CustomController.h
//  Adage
//
//  Created by Pradeep Yadav on 13/12/16.
//  Copyright © 2016 Third I, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#import "CustomLabel.h"
#import "EvaluateFormulae.h"
#import "GoldmineReader.h"
#import "CustomControl.h"

#import <MicroStrategyMobileSDK/MSIWidgetViewer.h>
#import <MicroStrategyMobileSDK/MSIWidgetHelper.h>

@interface CustomController : MSIWidgetViewer {
	
	// Number of controls like Sliders, toggles
	int noOfControls;
	// Number of labels
	int noOfLabels;
	
	NSMutableArray *customControls;
	NSMutableArray *customLabels;
	
	EvaluateFormulae *evalFormula;
	NSMutableDictionary *supportingMetrics;
	
}

@property (retain,nonatomic) MSIModelData *modelData;

-(void)readData;
-(void)updateLabels;
-(UIView *)renderControl:(CustomControl*) control;

@end
