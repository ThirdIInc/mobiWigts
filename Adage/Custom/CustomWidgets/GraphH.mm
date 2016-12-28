//
//  GraphH.m
//  Adage
//
//  Created by Deepika Nahar on 26/12/16.
//  Copyright © 2016 Third I, Inc. All rights reserved.
//

#import "GraphH.h"
#import "MicroStrategyMobileSDK/MSIGraphicUtils.h"

@implementation GraphH

//  This is the initialization method of the widget. It is called only once, when MicroStrategy Mobile creates the widget the first time a document is rendered (i.e., it is not called when a user changes a selector in the document). This method should include the code to perform any initialization tasks that need to be done only once, such as initializing variables and preparing external data.
- (id)initViewer:(ViewerDataModel*)_viewerDataModel withCommanderDelegate:(id<MSICommanderDelegate>)_commander withProps:(NSString*)_props {
	self = [super initViewer:_viewerDataModel withCommanderDelegate:_commander withProps:_props];
	
	if(self){
		
		dictSupportingMetrics = [[NSMutableDictionary alloc] init];
		
		barGraph = [[BarPlotH alloc] init];
		//initialize noOfBars to 2
		barGraph.intNoOfBars = 2;
		
		[self getSliderValues];
		objEvaluateFormulae = [[EvaluateFormulae alloc]init];
		[self reInitDataModels];
		//Initialize all widget's subviews as well as any instance variable
	}
	return self;
}

//  This method is used to clear all the widget’s views in order to save memory. It is called the first time the widget is loaded, and later if the widget needs to be recreated or deleted.
- (void)cleanViews {
}

//  This method is called every time the widget is recreated, which could be during initialization, when a layout or panel changes, or when the widget’s source selector is changed.
- (void)recreateWidget {
	
	[self addSubview:[self renderWidgetContainer:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)]];
	
	// CGrect offset to account for graph title and subtitles position
	CGRect graphFrame;
	graphFrame = CGRectMake(5, 17, self.frame.size.width-10, self.frame.size.height-17);

	barHostView = [[CPTGraphHostingView alloc] initWithFrame:graphFrame];
	[barGraph renderInLayerForYAxis:barHostView identifier:[NSString stringWithFormat:@"%d", barGraph.intGraphID]];
	[self addSubview:barHostView];
}

// Method that refreshes the data from the widget from MicroStrategy and that builds the widget's internal data models.
-(void)reInitDataModels {
	
	//Update the widget's data
	[self.widgetHelper reInitDataModels];
	
	[self readConstants];
	
	[self readDataValues];
	
	[self readFormattingInfo];
	
	[self readFormulae];
	
}

#pragma mark Data Retrieval Methods
-(void)readDataValues {
	
	int metricCount = [self.modelData metricCount];
	NSMutableArray *current = self.modelData.metricHeaderArray;
	MSIMetricHeader *metricHeader =[current objectAtIndex:0];
	
	//read supporting metrics
	int supportingMetricsStart = 3;
	for (int i = supportingMetricsStart; i < metricCount; i++) {
		MSIMetricValue *metricValue =[metricHeader.elements objectAtIndex:i];
		MSIHeaderValue *value = [[self.modelData arrayWithHeaderValueOfWholeRowByAxisType:ROW_AXIS andRowIndex:i] objectAtIndex:0];
		[dictSupportingMetrics setValue:[NSNumber numberWithDouble:[metricValue.rawValue doubleValue]] forKey:value.headerValue];
	}
}

-(void)readConstants {
	//Keep a reference to the grid's data
	
	self.modelData = (MSIModelData *)[widgetHelper dataProvider];
	
	// Always expect first metric header to be the graph title
    strGraphTitle = [[[self.modelData arrayWithHeaderValueOfWholeRowByAxisType:ROW_AXIS andRowIndex:0] objectAtIndex:0] rawValue];
	
	// Always expect first metric value to be the graph ID
    barGraph.intGraphID = [[[[self.modelData arrayWithHeaderValueOfWholeRowByAxisType:ROW_AXIS andRowIndex:0] objectAtIndex:1] rawValue] intValue];
	
	// Always expect 2+noOfBars metric headers to be Y-Axis header
    barGraph.arrYAxisLabels = [[NSMutableArray alloc] init];
    for (int i = 0; i<barGraph.intNoOfBars; i++) {
        [barGraph.arrYAxisLabels addObject:[[[self.modelData arrayWithHeaderValueOfWholeRowByAxisType:ROW_AXIS andRowIndex:i+1] objectAtIndex:0] rawValue]];
    }

}
				 
-(void)readFormattingInfo {
	//Keep a reference to the grid's data
	self.modelData = (MSIModelData *)[widgetHelper dataProvider];
	
	barGraph.arrColors = [[NSMutableArray alloc] init];
	
	// 0 Header - Get the color, font face and font size for the graph title
	MSIHeaderValue *value = [[self.modelData arrayWithHeaderValueOfWholeRowByAxisType:ROW_AXIS andRowIndex:0] objectAtIndex:0];
	MSIPropertyGroup *propertyGroup = value.format;
	[barGraph.arrColors addObject:[self colorConvertor:[propertyGroup propertyByPropertySetID:FormattingFont propertyID:FontFormattingColor]]];
	barGraph.ffGraph = [propertyGroup propertyByPropertySetID:FormattingFont propertyID:FontFormattingName];
	fsTitle = [propertyGroup propertyByPropertySetID:FormattingFont propertyID:FontFormattingSize];
	
	// 0 Value - Get the color and font size for the axis and data labels
	value = [[self.modelData arrayWithHeaderValueOfWholeRowByAxisType:ROW_AXIS andRowIndex:0] objectAtIndex:1];
	propertyGroup = value.format;
	[barGraph.arrColors addObject:[self colorConvertor:[propertyGroup propertyByPropertySetID:FormattingFont propertyID:FontFormattingColor]]];
	barGraph.fsGraphLabels = [propertyGroup propertyByPropertySetID:FormattingFont propertyID:FontFormattingSize];
	
	// 1 to (1+intNoOfBars) - Populate the bar colors in the array. Size is equal to number of bars to be displayed  i.e. graphData.intNoOfBars
	for (int i = 0; i < barGraph.intNoOfBars; i++) {
		value = [[self.modelData arrayWithHeaderValueOfWholeRowByAxisType:ROW_AXIS andRowIndex:i+1] objectAtIndex:1];
		propertyGroup = value.format;
		[barGraph.arrColors addObject:[self colorConvertor:[propertyGroup propertyByPropertySetID:FormattingFont propertyID:FontFormattingColor]]];
	}
	
}
         
-(void)readFormulae {
	NSMutableArray *current = self.modelData.metricHeaderArray;
	MSIMetricHeader *metricHeader =[current objectAtIndex:0];
	
	int intIndex = 1;
	NSDecimalNumber *calcValue = 0;
	barGraph.dataForPlot = [[NSMutableArray alloc] init];
	for (int i = 0; i < barGraph.intNoOfBars; i++) {
		/*NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
		 [f setNumberStyle:NSNumberFormatterDecimalStyle];
		 NSNumber *myNumber = [f numberFromString:metricValue.rawValue];
		 
		 [barGraph.dataForPlot addObject:myNumber];
		 */
		
		MSIMetricValue *metricValue =[metricHeader.elements objectAtIndex:intIndex+i];
		NSMutableArray *row = [self.modelData arrayWithHeaderValueOfWholeRowByAxisType:ROW_AXIS andRowIndex:intIndex];
		MSIHeaderValue *attributeCell = [row objectAtIndex:0];
		
		calcValue = [self handleFormulae:[metricValue.rawValue mutableCopy] storeKey:attributeCell.headerValue];
		
		[barGraph.dataForPlot addObject:calcValue];
	}
	
}

#pragma mark -
#pragma mark handleEvent Methods
//When a selector changes its selection, this widget will reload its data and update its views.
- (void)handleEvent:(NSString*)ipEventName {
	for (UIView *view in self.subviews) {
		if ([view isKindOfClass:[UIView class]]) {
			[view removeFromSuperview];
		}
	}
	[self reInitDataModels];
	[self recreateWidget];
}

#pragma mark Render Widget Container
-(UIView *)renderWidgetContainer:(CGRect)frameRect {
	UIView *uivContainer = [[UIView alloc] initWithFrame:frameRect];
	
	// Remove any hardcoding later. Values & properties should be from the data dictionary object
	// Make hieght dynamic based on font size or the hieght of cell
	UILabel *graphTitle =[self createLableWithFrame:CGRectMake(0, 0, frameRect.size.width, 16) text:strGraphTitle textColor:[barGraph.arrColors objectAtIndex:0] font:[UIFont fontWithName:barGraph.ffGraph size:[fsTitle intValue]] align:NSTextAlignmentCenter];
	
	[uivContainer addSubview:graphTitle];

	return uivContainer;
}

#pragma mark Creating formatted labels
- (UILabel *)createLableWithFrame:(CGRect)frmLabel text:(NSString *)txtLabel textColor:(UIColor *)clrLabel font:(UIFont *)fLabel align:(NSTextAlignment)txtAlignment {
	UILabel *uiLabel = [[UILabel alloc] initWithFrame:frmLabel];
	uiLabel.font = fLabel;
	uiLabel.text = txtLabel;
	uiLabel.textAlignment=txtAlignment;
	uiLabel.textColor = clrLabel;
	uiLabel.numberOfLines = 0;
	uiLabel.lineBreakMode = NSLineBreakByWordWrapping;
	
	return uiLabel;
}

-(void)getSliderValues {
	for (NSString *strKey in [[GoldmineReader getValue] allKeys]) {
		NSNumber *numValue = [NSNumber numberWithDouble:[[[GoldmineReader getValue] valueForKey:strKey] doubleValue]];
		[dictSupportingMetrics setValue:numValue forKey:strKey];
	}
}

#pragma mark Converts BGR value to UIColor object
-(UIColor *)colorConvertor:(NSString *)strColor {
	int bgrValue = [strColor intValue]; // We got B G R here, but we need RGB
	int rgbValue = (bgrValue >> 16) + (bgrValue & 0x00FF00) + ((bgrValue & 0x0000FF) << 16);
	NSString *color = [NSString stringWithFormat:@"%06x", rgbValue];
	return [MSIGraphicUtils colorForColorCode:color];
}

-(NSDecimalNumber *)handleFormulae:(NSMutableString *)strFormula storeKey:(NSString *)strHeader {
	NSDecimalNumber *strCalcValue;
	if ([strFormula hasPrefix:@"#"]) {
			[strFormula deleteCharactersInRange:[strFormula rangeOfString:@"#"]];
			strCalcValue = [objEvaluateFormulae evaluateFormula:strFormula withMetrics:dictSupportingMetrics];
	
			[GoldmineReader setValue:[NSString stringWithFormat:@"%@",strCalcValue] forKey:strHeader];
			[dictSupportingMetrics setValue:[NSNumber numberWithDouble:[strCalcValue floatValue]] forKey:strHeader];
		
	}
	else {
		strCalcValue = [objEvaluateFormulae evaluateFormula:strFormula withMetrics:dictSupportingMetrics];
	}
	return strCalcValue;
}

@end
