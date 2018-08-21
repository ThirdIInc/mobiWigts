//
//  I2IBarPlotIE.h
//  i2iDevelopment
//
//
//  Created by Pradeep Yadav on 03/02/15.
//  Modified by Pradeep Yadav on 14/03/17.
//  Copyright © 2017 i2i Logic (Australia) Pty Ltd. All rights reserved.
//

#ifndef I2IBarPlotIE_h
#define I2IBarPlotIE_h

#import <Foundation/Foundation.h>
#import <ShinobiCharts/ShinobiCharts.h>

@interface CustomIEBarSeries : SChartBarSeries
@property (retain, nonatomic) NSMutableArray *arrColors;
@property (assign, nonatomic) int noOFBars;
@end

@interface CustomNumberIEXAxis : SChartNumberAxis
@end

@interface CustomNumberIEYAxis : SChartCategoryAxis
@end

@interface I2IBarPlotIE : NSObject <SChartDelegate, SChartDatasource> {
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
#endif
