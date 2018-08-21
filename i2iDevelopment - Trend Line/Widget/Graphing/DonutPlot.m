//
//  DonutPlot.m
//  i2iDevelopment
//
//  Created by Deepika Nahar on 08/06/17.
//  Copyright © 2017 i2i Logic (Australia) Pty Ltd. All rights reserved.
//

#import "DonutPlot.h"

@implementation CustomDonutSeries
@synthesize arrColors;
/*-(SChartDonutSeriesStyle*)styleForPoint:(id<SChartData>)point {
    SChartDonutSeriesStyle *newStyle = [super styleForPoint:point];
    newStyle.showArea = YES;
    newStyle.showAreaWithGradient = FALSE;
    newStyle.lineColor = [UIColor clearColor];
    newStyle.lineColorBelowBaseline = [UIColor clearColor];
    newStyle.areaColorGradient = [UIColor clearColor];
    newStyle.areaColor = [arrColors objectAtIndex:[point sChartDataPointIndex]+2];
    newStyle.areaColorBelowBaseline  = [arrColors objectAtIndex:[point sChartDataPointIndex]+2];
    return newStyle;
}*/

@end

@implementation DonutPlot

@synthesize dataForPlot;
@synthesize gID;
@synthesize bars;
@synthesize xLabel;
@synthesize yLabels;
@synthesize colors;
@synthesize fSize;
@synthesize fFace;
@synthesize xMin;
@synthesize xMax;
@synthesize yLongest;
@synthesize type;

-(void)renderChart:(UIView *)hostView identifier:(NSString *)identifier {
    // Create the chart
    hChart = [[ShinobiChart alloc] initWithFrame:CGRectMake(0, 0, hostView.bounds.size.width, hostView.bounds.size.height)];
    hChart.autoresizingMask = ~UIViewAutoresizingNone;
    hChart.backgroundColor = [UIColor clearColor];
    
    
    
    // add to the view
    [hostView addSubview:hChart];
    hChart.datasource = self;
    hChart.delegate = self;
    
    // hide the legend
    hChart.legend.hidden = YES;
    isInitialRender = YES;
    
    
}

#pragma mark - SChartDatasource methods
-(NSInteger)numberOfSeriesInSChart:(ShinobiChart *)chart {
    
    return 1;
    
}

-(SChartSeries *)sChart:(ShinobiChart *)chart seriesAtIndex:(NSInteger)index {
    
    CustomDonutSeries *donutSeries = [[CustomDonutSeries alloc] init];
    donutSeries.innerRadius = 40;
    donutSeries.outerRadius = 60;
    donutSeries.drawDirection = SChartRadialSeriesDrawDirectionClockwise;
    [donutSeries setArrColors:[NSMutableArray arrayWithObjects:[UIColor cyanColor], [UIColor grayColor], nil]];
    donutSeries.style.showLabels = NO;
    
    donutSeries.style.flavourColors = [NSMutableArray arrayWithObjects:[UIColor colorWithRed:0 green:0.56 blue:0.8 alpha:1], [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1], nil];
    
    UILabel *lbl = [[UILabel alloc] init];
    lbl.frame = CGRectMake([donutSeries getDonutCenter].x-15, [donutSeries getDonutCenter].y, 30, 15);
    lbl.textColor = [UIColor colorWithRed:0 green:0.56 blue:0.8 alpha:1], [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1];
    lbl.text = @"85%";
    //Add this subview
//    [donutSeries setStyle:(SChartDonutSeriesStyle *)]
    
    return donutSeries;
    
}

-(NSInteger)sChart:(ShinobiChart *)chart numberOfDataPointsForSeriesAtIndex:(NSInteger)seriesIndex {
 
    return dataForPlot.count;
    
}

-(id<SChartData>)sChart:(ShinobiChart *)chart dataPointAtIndex:(NSInteger)dataIndex forSeriesAtIndex:(NSInteger)seriesIndex {
    
    //dataForPlot[0] = [NSNumber numberWithInteger:55];
    //return dataForPlot[0];
    return dataForPlot[dataIndex];
    
}

@end

