//
//  BarPlotH.h
//  Adage
//
//  Created by Deepika Nahar on 26/12/16.
//  Copyright © 2016 Third I, Inc. All rights reserved.
//

#ifndef BarPlotH_h
#define BarPlotH_h

#import <Foundation/Foundation.h>
#import <CorePlot/CorePlot.h>
#import "AxisFormatter.h"

@protocol BarPlotH;

@interface BarPlotH : NSObject <CPTBarPlotDataSource, CPTBarPlotDelegate> {
	
@private
	CPTGraph *graph;
	BOOL isNegative, isPositive;
	
}

@property (unsafe_unretained, nonatomic) id<BarPlotH> delegate;
@property (nonatomic, retain) NSMutableArray *dataForPlot;

// Unique ID of the graph
@property (assign, nonatomic) int intGraphID;
// How many bars to display in the graph
@property (assign, nonatomic) int intNoOfBars;
// Label to be displayed on x-axis
@property (retain, nonatomic) NSString *strXAxisLabel;
// Labels to be displayed on y-axis. Array size to be equal to intNoOfBars
@property (retain, nonatomic) NSMutableArray *arrYAxisLabels;
// Fill colors for the bars. Array size to be equal to intNoOfBars
@property (retain, nonatomic) NSMutableArray *arrColors;
// Size of font to be displayed on x & y axis labels & data values
@property (retain, nonatomic) NSString *fsGraphLabels;
// Font face for all the lables and data values
@property (retain, nonatomic) NSString *ffGraph;
// Render the chart on the hosting view from the view controller with the default theme.
-(void)renderInLayerForYAxis:(CPTGraphHostingView *)hostView
									identifier:(NSString *)identifier;
-(CPTColor *) getCPTColor:(UIColor *)uiColor;

@end

// Bar Plot delegate to notify when the bar is selected.
@protocol BarPlotH <NSObject>

-(void)barPlot:(BarPlotH *)plot barWasSelectedAtRecordIndex:(NSUInteger)index;

@end

#endif /* BarPlotH_h */
