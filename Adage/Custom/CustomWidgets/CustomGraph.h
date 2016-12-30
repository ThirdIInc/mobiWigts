//
//  CustomGraph.h
//  Adage
//
//  Created by Deepika Nahar on 26/12/16.
//  Copyright © 2016 Third I, Inc. All rights reserved.
//

#ifndef CustomGraph_h
#define CustomGraph_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import <MicroStrategyMobileSDK/MSIWidgetViewer.h>
#import <MicroStrategyMobileSDK/MSIWidgetHelper.h>
#import <MicroStrategyMobileSDK/MSIPropertyGroup.h>
#import <MicroStrategyMobileSDK/MSIHeaderValue.h>
#import <MicroStrategyMobileSDK/MetricHeader.h>
#import <MicroStrategyMobileSDK/MetricValue.h>

#import "BarPlotH.h"
#import "GoldmineReader.h"
#import "EvaluateFormulae.h"

@interface CustomGraph : MSIWidgetViewer {
	
	EvaluateFormulae *evalFormulae;
	CPTGraphHostingView *barHostView;
	BarPlotH *barGraph;
	
	// Title of the graph
	NSString *graphTitle;
	
	// Size of font to be displayed on the graph title
	NSString *fsTitle;
	
	//Data dictionary to hold supporting metrics
	NSMutableDictionary *supportingMetrics;
	
}

@property (retain, nonatomic) MSIModelData *modelData;

-(void)readData;
-(void)readConstants;
-(void)readFormulae;
-(void)readFormatting;

-(UIView *)renderContainer:(CGRect)frame;

-(UILabel *)createLabel:(CGRect)frame
									 text:(NSString *)text
									color:(UIColor *)color
									 font:(UIFont *)font
									align:(NSTextAlignment)align;

@end

#endif /* CustomGraph_h */
