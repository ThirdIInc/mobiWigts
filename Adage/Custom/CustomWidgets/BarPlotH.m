//
//  BarPlotH.m
//  Adage
//
//  Created by Deepika Nahar on 26/12/16.
//  Copyright © 2016 Third I, Inc. All rights reserved.
//

#import "BarPlotH.h"

@implementation BarPlotH

@synthesize dataForPlot;
@synthesize delegate;
@synthesize intGraphID;
@synthesize intNoOfBars; // How many bars to display in the graph
@synthesize strXAxisLabel; // Label to be displayed on x-axis
@synthesize arrYAxisLabels; // Labels to be displayed on y-axis. Array size to be equal to intNoOfBars
@synthesize arrColors; // Fill colors for the bars. Array size to be equal to intNoOfBars
@synthesize fsGraphLabels; // Size of font to be displayed on x & y axis labels & data values
@synthesize ffGraph; // Font face for all the lables and data values

-(CPTColor *) getCPTColor:(UIColor *)uiColor {
	CPTColor *cptColor = [[CPTColor alloc] initWithCGColor:uiColor.CGColor];
	return cptColor;
}

-(void)renderInLayerForYAxis:(CPTGraphHostingView *)hostView identifier:(NSString *)identifier {
	
	isNegative = NO;
	isPositive = NO;
	
	// Variables to help in calculation of manual x-axis ticks and range
	float maxPoint = 0;
	float minPoint = 0;
	
	for (int i = 0; i < intNoOfBars; i++) {
		
		float myNumber = [[dataForPlot objectAtIndex:i] floatValue];
		
		if (myNumber < minPoint) {
			minPoint = myNumber;
		}
		if (myNumber > maxPoint){
			maxPoint = myNumber;
		}
	}
	
	// Set positive & negative flags
	for (NSNumber *number in self.dataForPlot) {
		if ([number floatValue] < 0) {
			isNegative = YES;
		}
		else {
			isPositive = YES;
		}
	}
	
	if (fabs(minPoint) <= 0.5 && fabs(maxPoint) <= 0.5) {
		minPoint = -1;
		maxPoint = 1;
	}
	
	float maxTicks = 5.0f;
	float range = [self niceNum:(maxPoint - minPoint) round:false];
	float tickSpacing = [self niceNum:range / (maxTicks - 1) round:true];
	float niceMin;
	float niceMax;
	
	// Handle niceMin and niceMax for the nature of graphs i.e. All Positive, All Negative and combination
	if (isNegative && !isPositive) {
		// All Negative
		niceMin = floorf(minPoint / tickSpacing) * tickSpacing - (1.5 * tickSpacing);
		niceMax = - niceMin;
	}
	else if (isPositive && isNegative) {
		//Combination
		niceMin = floorf(minPoint / tickSpacing) * tickSpacing - (1.5 * tickSpacing);
		niceMax = - niceMin + floorf(maxPoint / tickSpacing) * tickSpacing + (1.5 * tickSpacing);
	}
	else {
		// All Positive
		niceMin = 0;
		niceMax = floorf(maxPoint / tickSpacing) * tickSpacing + (1.5 * tickSpacing);
	}
	
	// 1 - Create and initialize graph
	graph = [[CPTXYGraph alloc] initWithFrame:hostView.bounds];
	hostView.hostedGraph = graph;
	graph.plotAreaFrame.borderLineStyle = nil;
	graph.plotAreaFrame.cornerRadius = 0.0f;
	
	// Style for the axis lines
	CPTMutableLineStyle *axisLineStyle = [CPTMutableLineStyle lineStyle];
	axisLineStyle.lineCap = kCGLineCapRound;
	axisLineStyle.lineWidth = 1.0f;
	axisLineStyle.lineColor = [self getCPTColor:[arrColors objectAtIndex:1]];
	
	graph.paddingLeft = 0.0f;
	graph.paddingTop = 0.0f;
	graph.paddingRight = 0.0f;
	graph.paddingBottom = 0.0f;
	
	graph.plotAreaFrame.masksToBorder = NO;
	graph.plotAreaFrame.paddingTop = 10.0;
	graph.plotAreaFrame.paddingBottom = 35.0;
	
	// change the chart layer orders so the axis line is on top of the bar in the chart.
	NSArray *chartLayers = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:CPTGraphLayerTypeAxisLines],
													[NSNumber numberWithInt:CPTGraphLayerTypePlots],
													[NSNumber numberWithInt:CPTGraphLayerTypeMajorGridLines],
													[NSNumber numberWithInt:CPTGraphLayerTypeMinorGridLines],
													[NSNumber numberWithInt:CPTGraphLayerTypeAxisLabels],
													[NSNumber numberWithInt:CPTGraphLayerTypeAxisTitles], nil];
	
	graph.topDownLayerOrder = chartLayers;
	
	// Add plot space for horizontal bar charts
	CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
	
	plotSpace.xRange = [CPTPlotRange plotRangeWithLocationDecimal:CPTDecimalFromFloat(niceMin) lengthDecimal:CPTDecimalFromFloat(niceMax)];
	plotSpace.yRange = [CPTPlotRange plotRangeWithLocationDecimal:CPTDecimalFromInt(0) lengthDecimal:CPTDecimalFromInt(intNoOfBars+1)];
	
	// Setting y-axis
	CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;
	CPTXYAxis *y = axisSet.yAxis;
	y.labelingPolicy = CPTAxisLabelingPolicyNone;
	y.axisLineStyle = axisLineStyle;
	y.titleOffset = 20.0f;
	y.majorTickLineStyle = nil;
	y.minorTickLineStyle = nil;
	y.majorIntervalLength = [NSNumber numberWithFloat:1.0f];
	y.orthogonalPosition = [NSNumber numberWithFloat:0.0f];
	y.labelExclusionRanges = [NSArray arrayWithObjects:[CPTPlotRange plotRangeWithLocationDecimal:CPTDecimalFromInt(2) lengthDecimal:CPTDecimalFromInt(1)], nil];
	
	y.labelRotation = 0.0f;
	
	CPTMutableTextStyle *textStyle = [[CPTMutableTextStyle alloc] init];
	
	textStyle.color = [self getCPTColor:[arrColors objectAtIndex:1]];
	textStyle.fontSize = [fsGraphLabels floatValue];
	textStyle.fontName = ffGraph;
	
	CGSize padSize = CGSizeMake(0, 0);
	
	// Use custom y-axis label so it will display LTM, NEW, HEDGED, UNHEDGED... instead of 1, 2, 3, 4
	NSMutableArray *labels = [[NSMutableArray alloc] init];
	int idx = 1.0f;
	for (int i=0; i < intNoOfBars; i++) {
		CPTAxisLabel *newLabel = [[CPTAxisLabel alloc] initWithText:arrYAxisLabels[i] textStyle:textStyle];
		newLabel.tickLocation = [NSNumber numberWithFloat:idx];
		CGSize textSize = [arrYAxisLabels[i] sizeWithTextStyle:textStyle];
		
		if ([[dataForPlot objectAtIndex:i] floatValue] < 0.0) {
			newLabel.offset = -5.0f - textSize.width;
			newLabel.alignment = CPTTextAlignmentRight;
		}
		else{
			newLabel.offset = 1.0f;
		}
		if (padSize.width <= textSize.width) {
			padSize = textSize;
		}
		[labels addObject:newLabel];
		idx++;
	}
	// Handle Left and Right Padding for the nature of graphs i.e. All Positive, All Negative and combination
	if (isPositive && !isNegative) {
		// All Positive
		graph.plotAreaFrame.paddingLeft = padSize.width;
		graph.plotAreaFrame.paddingRight = 10.0;
	}
	else if (!isPositive && isNegative) {
		// All Negative
		graph.plotAreaFrame.paddingLeft = 10.0;
		graph.plotAreaFrame.paddingRight = padSize.width;
	}
	else {
		// Combination of Positive and Negative
		graph.plotAreaFrame.paddingLeft = 10.0;
		graph.plotAreaFrame.paddingRight = 10.0;
	}
	
	y.axisLabels = [NSSet setWithArray:labels];
	
	// Setting up x-axis
	CPTXYAxis *x = axisSet.xAxis;
	
	x.majorIntervalLength = [NSNumber numberWithFloat:tickSpacing];
	x.minorTicksPerInterval = 0;
	x.minorGridLineStyle = nil;
	x.majorTickLineStyle = nil;
	x.minorTickLineStyle = nil;
	x.titleOffset = 20.0f;
	x.axisLineStyle = axisLineStyle;
	x.orthogonalPosition = [NSNumber numberWithFloat:0.0f];
	x.labelTextStyle = textStyle;
	x.titleTextStyle = textStyle;
	//x.title = strXAxisLabel;
	
	AxisFormatter *formatter = [[AxisFormatter alloc] init];
	x.labelFormatter = formatter;
	
	CPTBarPlot *barPlot = [[CPTBarPlot alloc] init];
	
	barPlot.barsAreHorizontal = YES;
	
	axisLineStyle.lineColor = [CPTColor clearColor];
	
	barPlot.lineStyle = axisLineStyle;
	barPlot.barWidth = [NSNumber numberWithFloat:0.5f];
	barPlot.baseValue = [NSNumber numberWithFloat:0.0f];
	
	barPlot.dataSource = self;
	barPlot.barOffset  = [NSNumber numberWithFloat:1.0f];
	barPlot.barCornerRadius = 0.0f;
	barPlot.identifier = identifier;
	barPlot.delegate = self;
	
	// Code added below for animation
	if (isNegative) {
		CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
		[animation setDuration:1.0f];
		CATransform3D transform = CATransform3DMakeScale(0,1,1);
		transform = CATransform3DConcat(transform, CATransform3DMakeTranslation(0,0,0));
		animation.fromValue = [NSValue valueWithCATransform3D:transform];
		animation.toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
		animation.fillMode = kCAFillModeForwards;
		float xAnchor = - niceMin / niceMax;
		if (isPositive) {
			barPlot.anchorPoint = CGPointMake(xAnchor,0.0);
		}
		else {
			barPlot.anchorPoint = CGPointMake(1.0,0.0);
		}
		[barPlot addAnimation:animation forKey:@"barGrowth"];
	}
	else
	{
		CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"transform.scale.x"];
		[anim setDuration:1.0f];
		anim.toValue = [NSNumber numberWithFloat:1.0f];
		anim.fromValue = [NSNumber numberWithFloat:0.0f];
		anim.removedOnCompletion = NO;
		anim.delegate = self;
		anim.fillMode = kCAFillModeForwards;
		barPlot.anchorPoint = CGPointMake(0.0,0.0);
		[barPlot addAnimation:anim forKey:@"grow"];
	}
	
	[graph addPlot:barPlot toPlotSpace:plotSpace];
}

-(CPTFill *)barFillForBarPlot:(CPTBarPlot *)barPlot recordIndex:(NSUInteger)index {
	CPTFill *fillColor = [CPTFill fillWithColor:[arrColors objectAtIndex:index+2]];
	return fillColor;
}

#pragma mark CPTBarPlot delegate method
-(void)barPlot:(CPTBarPlot *)plot barWasSelectedAtRecordIndex:(NSUInteger)index {
}

// This method is call to put the number figure on the top tip of the bar.
-(CPTLayer *)dataLabelForPlot:(CPTPlot *)plot recordIndex:(NSUInteger)index {
	
	CPTTextLayer *lyrDataLabel = [CPTTextLayer layer];
	
	CPTMutableTextStyle *labelTextStyle = [CPTMutableTextStyle textStyle];
	labelTextStyle.fontSize = [fsGraphLabels floatValue]-1;
	
	labelTextStyle.fontName = ffGraph;
	labelTextStyle.color = [self getCPTColor:[arrColors objectAtIndex:1]];
	lyrDataLabel.textStyle = labelTextStyle;
	
	NSString *labelString = [NSString stringWithFormat:@"%@",[self.dataForPlot objectAtIndex:index]];
	if ([labelString length] == 0) {
		lyrDataLabel.text = @"";
	}
	else
	{
		/*if ([strXAxisLabel isEqualToString:@"%"]) {
			lyrDataLabel.text = [NSString stringWithFormat:@"%.2f",[[self.dataForPlot objectAtIndex:index] floatValue]];
		}
		else{ */
			static const char sUnits[] = {'\0', 'k' , 'm', 'b'};
			static int sMaxUnits = sizeof sUnits - 1;
			int multiplier =  1000;
			int exponent = 0;
			
			float bytes = [[self.dataForPlot objectAtIndex:index] floatValue];
			
			while ((fabs(bytes) >= multiplier) && (exponent < sMaxUnits)) {
				bytes /= multiplier;
				exponent++;
			}
			NSString *convertedStr = [NSString stringWithFormat:@"%.2f%c", bytes, sUnits[exponent]];
			lyrDataLabel.text = convertedStr;
		//}
	}
	plot.labelOffset = 0.4;
	
	[lyrDataLabel sizeToFit];
	return lyrDataLabel;
}

#pragma mark - CPTPlotDataSource Delegates
-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
	return dataForPlot.count;
}

-(NSArray *)numbersForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndexRange:(NSRange)indexRange {
	NSArray *nums = nil;
	
	switch ( fieldEnum ) {
		case CPTBarPlotFieldBarLocation:
			nums = [NSMutableArray arrayWithCapacity:indexRange.length];
			for ( NSUInteger i = indexRange.location; i < NSMaxRange(indexRange); i++ ) {
				[(NSMutableArray *)nums addObject : @(i)];
			}
			break;
			
		case CPTBarPlotFieldBarTip:
			nums = [self.dataForPlot objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:indexRange]];
			break;
			
		default:
			break;
	}
	
	return nums;
}

#pragma mark - Nice x-axis Label Methods
-(float)niceNum:(float)range round:(BOOL)round {
	
	float exponent = floorf(log10f(range));
	float fraction = range / pow(10, exponent);
	float niceFraction;
	
	if (round) {
		if (fraction < 1.5) {
			niceFraction = 1;
		}
		else if (fraction < 3) {
			niceFraction = 2;
		}
		else if (fraction < 7) {
			niceFraction = 5;
		}
		else{
			niceFraction = 10;
		}
	}
	else {
		if (fraction <= 1) {
			niceFraction = 1;
		}
		else if (fraction <= 2) {
			niceFraction = 2;
		}
		else if (fraction <= 5) {
			niceFraction = 5;
		}
		else{
			niceFraction = 10;
		}
	}
	return niceFraction * pow(10, exponent);
}

@end
