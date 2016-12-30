//
//  CustomBarPlot.h
//  Adage
//
//  Created by Deepika Nahar on 26/12/16.
//  Copyright © 2016 Third I, Inc. All rights reserved.
//

#ifndef CustomBarPlot_h
#define CustomBarPlot_h

#import <Foundation/Foundation.h>
#import <CorePlot/CorePlot.h>
#import "CustomAxis.h"

@protocol CustomBarPlot;

@interface CustomBarPlot : NSObject <CPTBarPlotDataSource, CPTBarPlotDelegate> {
	
@private
	CPTGraph *graph;
	BOOL isNegative, isPositive;
	
}

@property (unsafe_unretained, nonatomic) id<CustomBarPlot> delegate;
@property (nonatomic, retain) NSMutableArray *dataForPlot;

// Unique ID of the graph
@property (assign, nonatomic) int uid;
// How many bars to display in the graph
@property (assign, nonatomic) int noOfBars;
// Label to be displayed on x-axis
@property (retain, nonatomic) NSString *xAxisLabel;
// Labels to be displayed on y-axis. Array size to be equal to intNoOfBars
@property (retain, nonatomic) NSMutableArray *yAxisLabels;
// Fill colors for the bars. Array size to be equal to intNoOfBars
@property (retain, nonatomic) NSMutableArray *colors;
// Size of font to be displayed on x & y axis labels & data values
@property (retain, nonatomic) NSString *fontSize;
// Font face for all the lables and data values
@property (retain, nonatomic) NSString *fontFace;

// Render the chart on the hosting view from the view controller with the default theme.
-(void)renderInLayerForYAxis:(CPTGraphHostingView *)hostView
									identifier:(NSString *)identifier;

-(CPTColor *)getCPTColor:(UIColor *)uiColor;

@end

// Bar Plot delegate to notify when the bar is selected.
@protocol CustomBarPlot <NSObject>

-(void)barPlot:(CustomBarPlot *)plot barWasSelectedAtRecordIndex:(NSUInteger)index;

@end

#endif /* CustomBarPlot_h */
