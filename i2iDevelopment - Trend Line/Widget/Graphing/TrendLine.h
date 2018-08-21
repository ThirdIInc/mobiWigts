//
//  TrendLine.h
//  i2iDevelopment
//
//  Created by Deepika Nahar on 14/06/17.
//  Copyright © 2017 i2i Logic (Australia) Pty Ltd. All rights reserved.
//

#ifndef TrendLine_h
#define TrendLine_h

#import <Foundation/Foundation.h>
#import <ShinobiCharts/ShinobiCharts.h>

@interface CustomLineSeries : SChartLineSeries
@property (retain, nonatomic) NSMutableArray *arrColors;
@property (assign, nonatomic) int noOFBars;
@end

@interface CustomNumberLineXAxis : SChartNumberAxis
@end

@interface CustomNumberLineYAxis : SChartCategoryAxis
@end

@interface TrendLine : NSObject <SChartDelegate, SChartDatasource> {
    ShinobiChart* ieChart;
    BOOL isInitialRender;
}
@property (retain, nonatomic) NSMutableArray *dataForPlot;
// Unique ID of the graph
@property (assign, nonatomic) int gID;
// How many bars to display in the graph
@property (assign, nonatomic) int bars;
// Label to be displayed on x-axis
@property (retain, nonatomic) NSString *xLabel;
// Labels to be displayed on y-axis. Array size to be equal to bars
@property (retain, nonatomic) NSMutableArray *yLabels;
// Fill colors for the bars. Array size to be equal to bars
@property (retain, nonatomic) NSMutableArray *colors;
@property (retain, nonatomic) NSString *fSize;
// Font face for all the lables and data values
@property (retain, nonatomic) NSString *fFace;

// Render the chart on the hosting view from the view controller with the default theme.
-(void)renderChart:(UIView *)hostView identifier:(NSString *)identifier;
@end

#endif /* TrendLine_h */
