//
//  I2IGraphH.h
//  i2iDevelopment
//
//
//  Created by Pradeep Yadav on 30/12/14.
//  Modified by Pradeep Yadav on 14/03/17.
//  Copyright © 2017 i2i Logic (Australia) Pty Ltd. All rights reserved.
//

#ifndef I2IGraphH_h
#define I2IGraphH_h

#import <Foundation/Foundation.h>
#import "MSIWidgetViewer.h"
#import "MSIWidgetHelper.h"
#import <UIKit/UIKit.h>
#import "MSIPropertyGroup.h"
#import "MSIHeaderValue.h"
#import "MetricHeader.h"
#import "MetricValue.h"
#import "I2IBarPlotH.h"
#import "PlistData.h"
#import "FormulaEvaluator.h"

#import "DonutPlot.h"

@interface I2IGraphH : MSIWidgetViewer{
    FormulaEvaluator *eval;
    UIView *hostView;
    
    //I2IBarPlotH *graph;
    DonutPlot *graph;
    
    // Title of the graph
    NSString *title;
    // Holds the number of sub-titles to be displayed. Should be equal to Bars - 1
    NSMutableArray *subtitles;
    // Holds the values for the subtitles to be displayed i.e. equal to Bars - 1
    NSMutableArray *subtitleData;
    // Size of font to be displayed on the graph title
    NSString *fsTitle;
    // Size of font to be displayed on the graph sub-titles
    NSString *fsSubTitle;
    // Data dictionary to hold supporting metrics
    NSMutableDictionary *metrics;
}
@property (retain,nonatomic) MSIModelData *modelData;

-(void)readDataValues;
-(void)readConstants;
-(void)readFormulae;
-(void)readFormattingInfo;

-(UIView *)renderWidgetContainer:(CGRect)frameRect;
-(UILabel *)createLableWithFrame:(CGRect)frmLabel text:(NSString *)txtLabel textColor:(UIColor *)clrLabel font:(UIFont *)fLabel align:(NSTextAlignment)txtAlignment;
@end
#endif
