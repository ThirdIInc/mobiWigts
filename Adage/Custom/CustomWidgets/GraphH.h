//
//  GraphH.h
//  Adage
//
//  Created by Deepika Nahar on 26/12/16.
//  Copyright © 2016 Third I, Inc. All rights reserved.
//

#ifndef GraphH_h
#define GraphH_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "MicroStrategyMobileSDK/MSIWidgetViewer.h"
#import "MicroStrategyMobileSDK/MSIWidgetHelper.h"
#import "MicroStrategyMobileSDK/MSIPropertyGroup.h"
#import "MicroStrategyMobileSDK/MSIHeaderValue.h"
#import "MicroStrategyMobileSDK/MetricHeader.h"
#import "MicroStrategyMobileSDK/MetricValue.h"

#import "BarPlotH.h"
#import "GoldmineReader.h"
#import "EvaluateFormulae.h"

@interface GraphH : MSIWidgetViewer{
	EvaluateFormulae *objEvaluateFormulae;
	CPTGraphHostingView *barHostView;
	BarPlotH *barGraph;
	
	NSString *strGraphTitle; // Title of the graph
	
	NSString *fsTitle; // Size of font to be displayed on the graph title
	NSString *fsSubTitle; // Size of font to be displayed on the graph sub-titles
	
	//Data dictionary to hold supporting metrics
	NSMutableDictionary *dictSupportingMetrics;
}
@property (retain,nonatomic) MSIModelData *modelData;

-(void)readDataValues;
-(void)readConstants;
-(void)readFormulae;
-(void)readFormattingInfo;

-(UIView *)renderWidgetContainer:(CGRect)frameRect;
-(UILabel *)createLableWithFrame:(CGRect)frmLabel text:(NSString *)txtLabel textColor:(UIColor *)clrLabel font:(UIFont *)fLabel align:(NSTextAlignment)txtAlignment;

@end

#endif /* GraphH_h */
