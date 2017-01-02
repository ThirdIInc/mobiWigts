//
//  CustomGraph.m
//  Adage
//
//  Created by Deepika Nahar on 26/12/16.
//  Copyright © 2016 Third I, Inc. All rights reserved.
//

#import "CustomGraph.h"
#import <MicroStrategyMobileSDK/MSIGraphicUtils.h>

@implementation CustomGraph

//  This is the initialization method of the widget. It is called only once, when MicroStrategy Mobile creates the widget the first time a document is rendered (i.e., it is not called when a user changes a selector in the document). This method should include the code to perform any initialization tasks that need to be done only once, such as initializing variables and preparing external data.
-(id)initViewer:(ViewerDataModel*)_viewerDataModel withCommanderDelegate:(id<MSICommanderDelegate>)_commander
			withProps:(NSString*)_props {
	
	self = [super initViewer:_viewerDataModel
		 withCommanderDelegate:_commander
								 withProps:_props];
	
	if(self) {
		
		supportingMetrics = [[NSMutableDictionary alloc] init];
		
		barGraph = [[CustomBarPlot alloc] init];
		//initialize noOfBars to 2
		barGraph.noOfBars = 2;
		
		[self getStoredVariables];
		evalFormulae = [[EvaluateFormulae alloc] init];
		[self reInitDataModels];
		//Initialize all widget's subviews as well as any instance variable
		
	}
	
	return self;
	
}

//  This method is used to clear all the widget’s views in order to save memory. It is called the first time the widget is loaded, and later if the widget needs to be recreated or deleted.
-(void)cleanViews {
	
}

//  This method is called every time the widget is recreated, which could be during initialization, when a layout or panel changes, or when the widget’s source selector is changed.
-(void)recreateWidget {
	
	[self addSubview:[self renderContainer:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)]];
	
	// CGrect offset to account for graph title and subtitles position
	CGRect graphFrame;
	graphFrame = CGRectMake(5, 17, self.frame.size.width - 10, self.frame.size.height - 17);
	
	barHostView = [[CPTGraphHostingView alloc] initWithFrame:graphFrame];
	[barGraph renderInLayerForYAxis:barHostView
											 identifier:[NSString stringWithFormat:@"%d", barGraph.uid]];
	[self addSubview:barHostView];
	
}

// Method that refreshes the data from the widget from MicroStrategy and that builds the widget's internal data models.
-(void)reInitDataModels {
	
	//Update the widget's data
	[self.widgetHelper reInitDataModels];
	
	[self readConstants];
	
	[self readData];
	
	[self readFormatting];
	
	[self readFormulae];
	
}

#pragma mark Data Retrieval Methods
-(void)readData {
	
	int metricCount = (int)[self.modelData metricCount];
	NSMutableArray *current = self.modelData.metricHeaderArray;
	MSIMetricHeader *metricHeader =[current objectAtIndex:0];
	
	//read supporting metrics
	int supportingMetricsStart = 3;
	
	for (int i = supportingMetricsStart; i < metricCount; i++) {
		
		MSIMetricValue *metricValue = [metricHeader.elements objectAtIndex:i];
		MSIHeaderValue *value = [[self.modelData arrayWithHeaderValueOfWholeRowByAxisType:ROW_AXIS
																																					andRowIndex:i] objectAtIndex:0];
		[supportingMetrics setValue:[NSNumber numberWithDouble:[metricValue.rawValue doubleValue]]
														 forKey:value.headerValue];
		
	}
	
}

-(void)readConstants {
	
	//Keep a reference to the grid's data
	self.modelData = (MSIModelData *)[widgetHelper dataProvider];
	
	// Always expect first metric header to be the graph title
	graphTitle = [[[self.modelData arrayWithHeaderValueOfWholeRowByAxisType:ROW_AXIS
																															andRowIndex:0] objectAtIndex:0] rawValue];
	
	// Always expect first metric value to be the graph ID
	barGraph.uid = [[[[self.modelData arrayWithHeaderValueOfWholeRowByAxisType:ROW_AXIS
																																 andRowIndex:0] objectAtIndex:1] rawValue] intValue];
	
	// Always expect 2+noOfBars metric headers to be Y-Axis header
	barGraph.yAxisLabels = [[NSMutableArray alloc] init];
	
	for (int i = 0; i < barGraph.noOfBars; i++) {
		
		[barGraph.yAxisLabels addObject:[[[self.modelData arrayWithHeaderValueOfWholeRowByAxisType:ROW_AXIS
																																									 andRowIndex:i+1] objectAtIndex:0] rawValue]];
		
	}
	
}

-(void)readFormatting {
	
	//Keep a reference to the grid's data
	self.modelData = (MSIModelData *)[widgetHelper dataProvider];
	barGraph.colors = [[NSMutableArray alloc] init];
	
	// 0 Header - Get the color, font face and font size for the graph title
	MSIHeaderValue *value = [[self.modelData arrayWithHeaderValueOfWholeRowByAxisType:ROW_AXIS
																																				andRowIndex:0] objectAtIndex:0];
	MSIPropertyGroup *propertyGroup = value.format;
	[barGraph.colors addObject:[self colorConvertor:[propertyGroup propertyByPropertySetID:FormattingFont
																																							propertyID:FontFormattingColor]]];
	barGraph.fontFace = [propertyGroup propertyByPropertySetID:FormattingFont
																									propertyID:FontFormattingName];
	fsTitle = [propertyGroup propertyByPropertySetID:FormattingFont
																				propertyID:FontFormattingSize];
	
	// 0 Value - Get the color and font size for the axis and data labels
	value = [[self.modelData arrayWithHeaderValueOfWholeRowByAxisType:ROW_AXIS
																												andRowIndex:0] objectAtIndex:1];
	propertyGroup = value.format;
	[barGraph.colors addObject:[self colorConvertor:[propertyGroup propertyByPropertySetID:FormattingFont
																																							propertyID:FontFormattingColor]]];
	barGraph.fontSize = [propertyGroup propertyByPropertySetID:FormattingFont
																									propertyID:FontFormattingSize];
	
	// 1 to (1+intNoOfBars) - Populate the bar colors in the array. Size is equal to number of bars to be displayed  i.e. graphData.intNoOfBars
	for (int i = 0; i < barGraph.noOfBars; i++) {
		
		value = [[self.modelData arrayWithHeaderValueOfWholeRowByAxisType:ROW_AXIS
																													andRowIndex:i+1] objectAtIndex:1];
		propertyGroup = value.format;
		[barGraph.colors addObject:[self colorConvertor:[propertyGroup propertyByPropertySetID:FormattingFont
																																									 propertyID:FontFormattingColor]]];
		
	}
	
}

-(void)readFormulae {
	
	NSMutableArray *current = self.modelData.metricHeaderArray;
	MSIMetricHeader *metricHeader =[current objectAtIndex:0];
	
	int intIndex = 1;
	NSDecimalNumber *calcValue = 0;
	barGraph.dataForPlot = [[NSMutableArray alloc] init];
	
	for (int i = 0; i < barGraph.noOfBars; i++) {
		
		MSIMetricValue *metricValue =[metricHeader.elements objectAtIndex:intIndex+i];
		NSMutableArray *row = [self.modelData arrayWithHeaderValueOfWholeRowByAxisType:ROW_AXIS
																																			 andRowIndex:intIndex];
		MSIHeaderValue *attributeCell = [row objectAtIndex:0];
		
		calcValue = [self handleFormulae:[metricValue.rawValue mutableCopy]
														storeKey:attributeCell.headerValue];
		
		[barGraph.dataForPlot addObject:calcValue];
		
	}
	
}

#pragma mark - handleEvent Methods
//When a selector changes its selection, this widget will reload its data and update its views.
-(void)handleEvent:(NSString*)ipEventName {
	
	for (UIView *view in self.subviews) {
		
		if ([view isKindOfClass:[UIView class]]) {
			
			[view removeFromSuperview];
			
		}
		
	}
	
	[self reInitDataModels];
	[self recreateWidget];
	
}

#pragma mark Render Widget Container
-(UIView *)renderContainer:(CGRect)frame {
	
	UIView *container = [[UIView alloc] initWithFrame:frame];
	
	// Remove any hardcoding later. Values & properties should be from the data dictionary object
	// Make hieght dynamic based on font size or the hieght of cell
	UILabel *graphTitleLabel = [self createLabel:CGRectMake(0, 0, frame.size.width, 16)
																					text:graphTitle
																				 color:[barGraph.colors objectAtIndex:0]
																					font:[UIFont fontWithName:barGraph.fontFace
																															 size:[fsTitle intValue]]
																				 align:NSTextAlignmentCenter];
	
	[container addSubview:graphTitleLabel];
	
	return container;
	
}

#pragma mark Creating formatted labels
-(UILabel *)createLabel:(CGRect)frame
									 text:(NSString *)text
									color:(UIColor *)color
									 font:(UIFont *)font
									align:(NSTextAlignment)align {
	
	UILabel *label = [[UILabel alloc] initWithFrame:frame];
	label.font = font;
	label.text = text;
	label.textAlignment = align;
	label.textColor = color;
	label.numberOfLines = 0;
	label.lineBreakMode = NSLineBreakByWordWrapping;
	
	return label;
	
}

-(void)getStoredVariables {
	
	for (NSString *key in [[GoldmineReader getValue] allKeys]) {
		
		NSNumber *value = [NSNumber numberWithDouble:[[[GoldmineReader getValue] valueForKey:key] doubleValue]];
		[supportingMetrics setValue:value
												 forKey:key];
		
	}
	
}

#pragma mark Converts BGR value to UIColor object
-(UIColor *)colorConvertor:(NSString *)strColor {
	
	// We got B G R here, but we need RGB
	int bgrValue = [strColor intValue];
	int rgbValue = (bgrValue >> 16) + (bgrValue & 0x00FF00) + ((bgrValue & 0x0000FF) << 16);
	NSString *color = [NSString stringWithFormat:@"%06x", rgbValue];
	return [MSIGraphicUtils colorForColorCode:color];
	
}

-(NSDecimalNumber *)handleFormulae:(NSMutableString *)formula
													storeKey:(NSString *)key {
	
	NSDecimalNumber *calculatedValue;
	
	if ([formula hasPrefix:@"#"]) {
		
		[formula deleteCharactersInRange:[formula rangeOfString:@"#"]];
		calculatedValue = [evalFormulae evaluateFormula:formula
																				withMetrics:supportingMetrics];
		
		[GoldmineReader setValue:[NSString stringWithFormat:@"%@", calculatedValue]
											forKey:key];
		[supportingMetrics setValue:[NSNumber numberWithDouble:[calculatedValue floatValue]]
												 forKey:key];
		
	}
	else {
		
		calculatedValue = [evalFormulae evaluateFormula:formula
																		 withMetrics:supportingMetrics];
		
	}
	
	return calculatedValue;
	
}

@end
