//
//  CustomController.m
//  Adage
//
//  Created by Pradeep Yadav on 13/12/16.
//  Copyright © 2016 Third I, Inc. All rights reserved.
//

#import "CustomController.h"

@implementation CustomController

//  This is the initialization method of the widget. It is called only once, when MicroStrategy Mobile creates the widget the first time a document is rendered (i.e., it is not called when a user changes a selector in the document). This method should include the code to perform any initialization tasks that need to be done only once, such as initializing variables and preparing external data.
-(id)initViewer:(ViewerDataModel*)_viewerDataModel withCommanderDelegate:(id<MSICommanderDelegate>)_commander
			withProps:(NSString*)_props {
	
	self = [super initViewer:_viewerDataModel
		 withCommanderDelegate:_commander
								 withProps:_props];
	
	if(self) {
		
		customControls = [[NSMutableArray alloc] init];
		customLabels = [[NSMutableArray alloc] init];
		evalFormula = [[EvaluateFormulae alloc] init];
		
	}
	
	return self;
}

//  This method is used to clear all the widget’s views in order to save memory. It is called the first time the widget is loaded, and later if the widget needs to be recreated or deleted.
-(void)cleanViews {
	
	for (UIView *view in self.subviews) {
		
		if([view isKindOfClass:[UIView class]]) {
			
			UIView *v = (UIView *)view;
			[v removeFromSuperview];
			
		}
		
	}
	
}

//  This method is called every time the widget is recreated, which could be during initialization, when a layout or panel changes, or when the widget’s source selector is changed.
-(void)recreateWidget {
	
	[self reInitDataModels];
	
	for (CustomControl *control in customControls) {
		
		[self addSubview:[self renderControl:control]];
		
	}
	
	int i = 0;
	
	for (CustomLabel *label in customLabels) {
		
		NSArray *position = [[NSArray alloc] initWithArray:[label.position componentsSeparatedByString:@","]];
		CGRect frame = CGRectMake([[position firstObject] floatValue], [[position objectAtIndex:1] floatValue], [[position objectAtIndex:2] floatValue], [[position lastObject] floatValue]);
		
		// -777<i> is tag for Dynamic label.
		int tag = [[NSString stringWithFormat:@"%@%d", @"-777", i] intValue];
		
		[self addSubview:[label initializeLabel:frame
																		withTag:tag]];
		
		i++;
	}
	
	// Evaluates the formulae and updates the value of dynamic labels.
	[self updateLabels];
	
}

//  Method that refreshes the data from the widget from MicroStrategy and that builds the widget's internal data models.
-(void)reInitDataModels {
	
	//  Update the widget's data.
	[self.widgetHelper reInitDataModels];
	[self readData];
	
}

#pragma mark Data Retrieval Method

-(void)readData {
	
	MSIHeaderValue *metricCell = [[MSIHeaderValue alloc] init];
	NSMutableArray *row = [[NSMutableArray alloc] init];
	
	// Keep a reference to the grid's data.
	self.modelData = (MSIModelData *)[widgetHelper dataProvider];
	
	NSMutableArray *current = self.modelData.metricHeaderArray;
	MSIMetricHeader *metricHeader = [current objectAtIndex:0];
	
	supportingMetrics = [[NSMutableDictionary alloc]init];
	
	// Always expect first metric to be the number of controls.
	MSIMetricValue *metricValue = [metricHeader.elements objectAtIndex:0];
	noOfControls = [metricValue.rawValue intValue];
	
	int rowID = 0;
	if (noOfControls > 0) {
		
		for (int i = 0; i < noOfControls; i++) {
			
			// To get control details from grid.
			rowID = 1 + (5 * i);
			
			CustomControl *control = [[CustomControl alloc] init];
			
			// This variable stores the unique ID of the control.
			control.uid = [[metricHeader.elements objectAtIndex:rowID] rawValue];
			
			row = [self.modelData arrayWithHeaderValueOfWholeRowByAxisType:ROW_AXIS
																												 andRowIndex:rowID];
			MSIMetricValue *metricProperties = [row objectAtIndex:1];
			MSIPropertyGroup *propertyGroup = metricProperties.format;
			
			// These variables store font face and font size for the control labels.
			control.fFace = [propertyGroup propertyByPropertySetID:FormattingFont
																									propertyID:FontFormattingName];
			control.fSize = [[propertyGroup propertyByPropertySetID:FormattingFont
																									 propertyID:FontFormattingSize] intValue];
			
			control.colors = [[NSMutableArray alloc] init];
			
			// Primary color for the control and its label.
			[control.colors addObject:[self colorConvertor:[propertyGroup propertyByPropertySetID:FormattingFont
																																								 propertyID:FontFormattingColor]]];
			
			// Used to identify the type of control.
			// 1 = Slider, 2 = LessMore, 3 = Reset.
			control.type = [[[metricHeader.elements objectAtIndex:rowID + 1] rawValue] intValue];
			
			row = [self.modelData arrayWithHeaderValueOfWholeRowByAxisType:ROW_AXIS
																												 andRowIndex:rowID + 1];
			metricProperties = [row objectAtIndex:1];
			propertyGroup = metricProperties.getFormat;
			
			// Secondary color for the control and its label.
			[control.colors addObject:[self colorConvertor:[propertyGroup propertyByPropertySetID:FormattingFont
																																								 propertyID:FontFormattingColor]]];
			
			// Default value of the control.
			control.defaultCV = [[metricHeader.elements objectAtIndex:rowID + 2] rawValue];
			
			row = [self.modelData arrayWithHeaderValueOfWholeRowByAxisType:ROW_AXIS
																												 andRowIndex:rowID + 2];
			metricProperties = [row objectAtIndex:1];
			propertyGroup = metricProperties.format;
			
			// Number format and category for the control values and its label.
			control.category = [[propertyGroup propertyByPropertySetID:FormattingNumber
																											propertyID:NumberFormattingCategory] intValue];
			control.format = [propertyGroup propertyByPropertySetID:FormattingNumber
																									 propertyID:NumberFormattingFormat];
			
			// Tertiary color for the control and its label.
			[control.colors addObject:[self colorConvertor:[propertyGroup propertyByPropertySetID:FormattingFont
																																								 propertyID:FontFormattingColor]]];
			
			//comma separated values for (min, max, step, pos-x, pos-y, width, height)*************
			NSString *strValues = [[metricHeader.elements objectAtIndex:rowID + 3] rawValue];
			NSArray *arrValues = [strValues componentsSeparatedByString:@","];
			
			// Minimum value that the control can have.
			control.min = [[arrValues objectAtIndex:0] doubleValue];
			
			// Maximum value that the control can have.
			control.max = [[arrValues objectAtIndex:1] doubleValue];
			
			// Lowest value by which the control can incerement/decrement it's value. Only applicable to sliders.
			control.step = [[arrValues objectAtIndex:2] doubleValue];
			
			// Position of the control on the screen.
			// Format is "x,y,width,height". It is relative to the grid position in the document.
			control.position = [NSString stringWithFormat:@"%i,%i,%i,%i", [[arrValues objectAtIndex:3] intValue], [[arrValues objectAtIndex:4] intValue], [[arrValues objectAtIndex:5] intValue], [[arrValues objectAtIndex:6] intValue]];
			
			row = [self.modelData arrayWithHeaderValueOfWholeRowByAxisType:ROW_AXIS
																												 andRowIndex:rowID + 3];
			metricProperties = [row objectAtIndex:1];
			propertyGroup = metricProperties.format;
			
			// Additional color for the control and its label.
			[control.colors addObject:[self colorConvertor:[propertyGroup propertyByPropertySetID:FormattingFont
																																								 propertyID:FontFormattingColor]]];
			
			// Horizontal aligment for the control's label.
			control.align = [[propertyGroup propertyByPropertySetID:FormattingAlignment
																									 propertyID:AlignmentFormattingHorizontal] intValue];
			
			// Suffix for the control's label.
			control.suffix = [[metricHeader.elements objectAtIndex:rowID+4] rawValue];
			
			[self setDefaultValues:control];
			[customControls addObject:control];
			
		}
		
	}
	
	rowID = 1 + (5 * noOfControls);
	
	// Always expect this metric to be the number of dynamic labels.
	metricValue = [metricHeader.elements objectAtIndex:rowID];
	noOfLabels = [metricValue.rawValue intValue];
	
	if (noOfLabels > 0) {
		
		for (int i = 0; i < noOfLabels; i++) {
			
			// To get dynamic label details from grid.
			rowID = 2 + (5 * noOfControls) + (2 * i);
			
			CustomLabel *label = [[CustomLabel alloc]init];
			
			// Gets the header value of the dynamic label.
			row = [self.modelData arrayWithHeaderValueOfWholeRowByAxisType:ROW_AXIS
																												 andRowIndex:rowID];
		  metricCell = [row objectAtIndex:0];
			label.key = [[NSString alloc] initWithFormat:@"%@", metricCell.headerValue];
			
			MSIPropertyGroup *propertyGroup = metricCell.format;
			
			label.colorNegative = [self colorConvertor:[propertyGroup propertyByPropertySetID:FormattingFont
																																						 propertyID:FontFormattingColor]];
			
			// Gets the formula used to dynamically evaluate the value of dynamic label.
			label.formula = [[metricHeader.elements objectAtIndex:rowID] rawValue];
			
			row = [self.modelData arrayWithHeaderValueOfWholeRowByAxisType:ROW_AXIS
																												 andRowIndex:rowID];
			
			MSIMetricValue *metricProperties = [row objectAtIndex:1];
			propertyGroup = metricProperties.format;
			
			// Font parameters for the dynamic label.
			label.fFace = [propertyGroup propertyByPropertySetID:FormattingFont
																								propertyID:FontFormattingName];
			
			label.fBold = [[propertyGroup propertyByPropertySetID:FormattingFont
																								 propertyID:FontFormattingBold] intValue];
			label.fItalic = [[propertyGroup propertyByPropertySetID:FormattingFont
																									 propertyID:FontFormattingItalic] intValue];
			label.fUnderline = [[propertyGroup propertyByPropertySetID:FormattingFont
																											propertyID:FontFormattingUnderline] intValue];
			
			label.fSize = [[propertyGroup propertyByPropertySetID:FormattingFont
																								 propertyID:FontFormattingSize] intValue];
			label.colorPositive = [self colorConvertor:[propertyGroup propertyByPropertySetID:FormattingFont
																																						 propertyID:FontFormattingColor]];
			
			// Horizontal alignment parameters for the dynamic label.
			label.align = [[propertyGroup propertyByPropertySetID:FormattingAlignment
																								 propertyID:AlignmentFormattingHorizontal] intValue];
			label.wrap = [[propertyGroup propertyByPropertySetID:FormattingAlignment
																								propertyID:AlignmentFormattingTextWrap] intValue];
			
			// Number formatting parameters for the dynamic label.
			label.category = [[propertyGroup propertyByPropertySetID:FormattingNumber
																										propertyID:NumberFormattingCategory] intValue];
			label.format = [propertyGroup propertyByPropertySetID:FormattingNumber
																								 propertyID:NumberFormattingFormat];
			label.format = [label.format stringByReplacingOccurrencesOfString:@"\""
																														 withString:@""];
			
			// Position of the dynamic label on the screen.
			// Format is "x,y,width,height". It is relative to the grid position in the document.
			label.position = [[metricHeader.elements objectAtIndex:rowID + 1] rawValue];
			[customLabels addObject:label];
			
		}
		
	}
	
	// Sets the index to the row containing the first supporting/base metric.
	if (noOfControls > 0) {
		
		rowID = 2 + (5 * noOfControls) + (2 * noOfLabels);
		
	}
	
	for (NSString *strKey in [[GoldmineReader getValue] allKeys]) {
		
		NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
		NSNumber *number = [f numberFromString:[NSString stringWithFormat:@"%@", [[GoldmineReader getValue] valueForKey:strKey]]];
		
		if (number!=nil) {
			
			[supportingMetrics setValue:[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%@", [[GoldmineReader getValue] valueForKey:strKey]]]
													 forKey:strKey];
			
		}
		else {
			
			[supportingMetrics setValue:[NSString stringWithFormat:@"%@", [[GoldmineReader getValue] valueForKey:strKey]]
													 forKey:strKey];
			
		}
		
	}
	
#pragma mark Supporting Metrics
	
	// Loop through all the supporting metrics and add to the key-value pair to metrics dictionary.
	for(int i = rowID; i < current.count; i++) {
		
		row = [self.modelData arrayWithHeaderValueOfWholeRowByAxisType:ROW_AXIS
																											 andRowIndex:i];
		
		//Number of columns in grid
		metricCell = [row objectAtIndex:0];
		NSString *metricKey = metricCell.headerValue;
		metricValue = [row objectAtIndex:1];
		NSString *rawMetricValue = metricValue.rawValue;
		
		NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
		f.numberStyle = NSNumberFormatterDecimalStyle;
		NSNumber *number = [f numberFromString:rawMetricValue];
		NSDecimalNumber *fMetricAvg = [NSDecimalNumber decimalNumberWithString:@"0"];
		
		if (row.count > 2) {
			
			for (int j = 1; j < row.count; j++) {
				
				MSIMetricValue *metricVal = [row objectAtIndex:j];
				fMetricAvg = [fMetricAvg decimalNumberByAdding:[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%@", metricVal.rawValue]]];
				
			}
			
			fMetricAvg = [fMetricAvg decimalNumberByDividingBy:[[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%lu", (unsigned long)row.count]] decimalNumberBySubtracting:[NSDecimalNumber decimalNumberWithString:@"1"]]];
			
			if (number != nil) {
				
				[supportingMetrics setValue:fMetricAvg
														 forKey:metricKey];
				
			}
			else {
				
				[supportingMetrics setValue:metricValue.rawValue
														 forKey:metricKey];
				
			}
			
		}
		else {
			
			if (number != nil) {
				
				[supportingMetrics setValue:[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%@", metricValue.rawValue]]
														 forKey:metricKey];
				
			}
			else {
				
				[supportingMetrics setValue:metricValue.rawValue
														 forKey:metricKey];
				
			}
			
		}
		
	}
	
}

#pragma mark handleEvent Methods
//  When a selector changes its selection, this widget will reload its data and update its views.
-(void)handleEvent:(NSString*)ipEventName {
	
	[self cleanViews];
	[customControls removeAllObjects];
	[customLabels removeAllObjects];
	[supportingMetrics removeAllObjects];
	[self recreateWidget];
	
}

#pragma mark Converts BGR value to UIColor object
-(UIColor *)colorConvertor:(NSString *)color {
	
	//  We got B G R here, but we need RGB
	int bgrValue = [color intValue];
	
	return [UIColor colorWithRed:(bgrValue & 0xFF)/255.0f
												 green:((bgrValue & 0xFF00)>>8)/255.0f
													blue:((bgrValue & 0xFF0000) >> 16)/255.0f
												 alpha:1.0f];
	
}

#pragma mark Implementation of Control objects
-(UIView *)renderControl:(CustomControl*)control {
	
	// Renders the container for the control.
	NSArray *position = [[NSArray alloc] initWithArray:[control.position componentsSeparatedByString:@","]];
	CGRect frame = CGRectMake([[position firstObject] floatValue], [[position objectAtIndex:1] floatValue], [[position objectAtIndex:2] floatValue], [[position lastObject] floatValue]);
	UIView *container = [[UIView alloc]initWithFrame:frame];
	
	switch (control.type) {
			
		case 1:
			//  Code for Slider.
			container = [self createSlider:frame
													withParams:control];
			break;
			
		case 2:
			//  Code for LessMore.
			container = [self createLessMore:frame
														withParams:control];
			break;
			
		case 3:
			//  Code for Reset.
			container = [self createReset:frame
												 withParams:control];
			break;
			
		default:
			break;
			
	}
	
	return container;
	
}

-(UIView *)createSlider:(CGRect)frame
						 withParams:(CustomControl*)control {
	
	UIView *slider = [[UIView alloc] initWithFrame:frame];
	
	UIButton *btnMinus = [UIButton buttonWithType:UIButtonTypeCustom];
	btnMinus.frame = CGRectMake(0, 0, frame.size.height, frame.size.height);;
	[btnMinus setTitle:@""
						forState:UIControlStateNormal];
	btnMinus.titleLabel.font = [UIFont fontWithName:control.fFace
																						 size:control.fSize];
	btnMinus.backgroundColor = [UIColor clearColor];
	
	[btnMinus addTarget:self
							 action:@selector(handleMinus:)
		 forControlEvents:UIControlEventTouchUpInside];
	[btnMinus setBackgroundImage:[UIImage imageNamed:@"minus.png"]
											forState:UIControlStateNormal];
	[slider addSubview:btnMinus];
	
	CGRect frameSlider = CGRectMake(frame.size.height + 5, 0, frame.size.width - (frame.size.height * 2 + 10), frame.size.height);
	
	UISlider *sliderControl = [[UISlider alloc] init];
	sliderControl.frame = frameSlider;
	sliderControl.tag = [[control.uid stringByReplacingOccurrencesOfString:@"Slider"
																															withString:@"999"] integerValue];
	sliderControl.minimumValue = control.min;
	sliderControl.maximumValue = control.max;
	
	sliderControl.value = [[[GoldmineReader getValue] valueForKey:control.uid] floatValue];
	
	sliderControl.continuous = YES;
	sliderControl.minimumTrackTintColor = [control.colors objectAtIndex:1];
	sliderControl.maximumTrackTintColor = [control.colors objectAtIndex:2];
	
	[sliderControl setThumbImage:[UIImage imageNamed:@"sliderThumb.png"]
											forState:UIControlStateNormal];
	
	[sliderControl addTarget:self
										action:@selector(handleSlider:)
					forControlEvents:UIControlEventValueChanged];
	[slider addSubview:sliderControl];
	
	UIButton *btnPlus = [UIButton buttonWithType:UIButtonTypeCustom];
	btnPlus.frame = CGRectMake(frame.size.width - frame.size.height, 0, frame.size.height, frame.size.height);
	[btnPlus setTitle:@""
					 forState:UIControlStateNormal];
	btnPlus.titleLabel.font = [UIFont fontWithName:control.fFace
																						size:control.fSize];
	btnPlus.backgroundColor = [UIColor clearColor] ;
	
	[btnPlus addTarget:self
							action:@selector(handlePlus:)
		forControlEvents:UIControlEventTouchUpInside];
	[btnPlus setBackgroundImage:[UIImage imageNamed:@"plus.png"]
										 forState:UIControlStateNormal];
	[slider addSubview:btnPlus];
	
	return slider;
	
}

-(UIView *)createLessMore:(CGRect)frame
							 withParams:(CustomControl*)control {
	
	UIView *lessMore = [[UIView alloc] initWithFrame:frame];
	
	CGRect frameLabel = CGRectMake(frame.size.height, 0, frame.size.width - (frame.size.height * 2), frame.size.height);
	UILabel *lblValue = [[UILabel alloc] initWithFrame:frameLabel];
	
	// Tags the label object for reference and updating the value in event handlers.
	lblValue.tag = [[control.uid stringByReplacingOccurrencesOfString:@"LessMore"
																												 withString:@"666"] integerValue];
	lblValue.font = [UIFont fontWithName:control.fFace
																	size:control.fSize];
	
	lblValue.text = [self setNumberFormat:[[GoldmineReader getValue] valueForKey:control.uid]
													 withCategory:control.category
														 withFormat:control.format];
	lblValue.text = [NSString stringWithFormat:@"%@", lblValue.text];
	lblValue.textAlignment = NSTextAlignmentCenter;
	
	// This color is set on the minimum value para-metric
	lblValue.textColor = [control.colors objectAtIndex:3];
	lblValue.numberOfLines = 0;
	lblValue.lineBreakMode = NSLineBreakByWordWrapping;
	[lessMore addSubview:lblValue];
	
	UIButton *btnLess = [UIButton buttonWithType:UIButtonTypeCustom];
	btnLess.frame = CGRectMake(0, 0, frame.size.height, frame.size.height);
	[btnLess setTitle:@""
					 forState:UIControlStateNormal];
	btnLess.titleLabel.font = [UIFont fontWithName:control.fFace
																						size:control.fSize];
	btnLess.backgroundColor = [UIColor clearColor];
	
	[btnLess addTarget:self
							action:@selector(handleLess:)
		forControlEvents:UIControlEventTouchUpInside];
	[btnLess setBackgroundImage:[UIImage imageNamed:@"less.png"]
										 forState:UIControlStateNormal];
	[lessMore addSubview:btnLess];
	
	UIButton *btnMore = [UIButton buttonWithType:UIButtonTypeCustom];
	btnMore.frame = CGRectMake(frame.size.width-frame.size.height, 0, frame.size.height, frame.size.height);
	[btnMore setTitle:@""
					 forState:UIControlStateNormal];
	btnMore.titleLabel.font = [UIFont fontWithName:control.fFace
																						size:control.fSize];
	btnMore.backgroundColor = [UIColor clearColor] ;
	
	[btnMore addTarget:self
							action:@selector(handleMore:)
		forControlEvents:UIControlEventTouchUpInside];
	[btnMore setBackgroundImage:[UIImage imageNamed:@"more.png"]
										 forState:UIControlStateNormal];
	[lessMore addSubview:btnMore];
	
	return lessMore;
	
}

-(UIView *)createReset:(CGRect)frame
						withParams:(CustomControl*)control {
	
	UIView *reset = [[UIView alloc] initWithFrame:frame];
	UIButton *btnReset = [UIButton buttonWithType:UIButtonTypeCustom];
	btnReset.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
	btnReset.tag = [[control.uid stringByReplacingOccurrencesOfString:@"Reset"
																												 withString:@"888"] intValue];
	[btnReset addTarget:self
							 action:@selector(handleReset:)
		 forControlEvents:UIControlEventTouchUpInside];
	btnReset.userInteractionEnabled = YES;
	[btnReset setBackgroundImage:[UIImage imageNamed:@"reset.png"]
											forState:UIControlStateNormal];
	[reset addSubview:btnReset];
	
	return reset;
	
}

#pragma mark Event Handlers for Controls

//  Called when slider value changes
-(void)handleSlider:(id)sender {
	
	UISlider *slider = (UISlider *)sender;
	
	for (CustomControl *control in customControls) {
		
		if ([control.uid isEqualToString:[[@(slider.tag) stringValue] stringByReplacingOccurrencesOfString:@"999"
																																														withString:@"Slider"]]) {
			
			[GoldmineReader setValue:[NSString stringWithFormat:@"%.2f", slider.value]
												forKey:control.uid];
			[supportingMetrics setValue:[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%.2f", slider.value]]
													 forKey:control.uid];
			break;
			
		}
		
	}
	
	[self updateLabels];
	
}

//  Calls when minus button is pressed
-(void)handleMinus:(id)sender {
	
	UISlider *slider;
	for (UIView *view in [[sender superview] subviews]) {
		
		if ([view isKindOfClass:[UISlider class]]) {
			
			slider = (UISlider *)view;
			break;
			
		}
		
	}
	
	for(CustomControl *control in customControls) {
		
		if ([control.uid isEqualToString:[[@(slider.tag) stringValue] stringByReplacingOccurrencesOfString:@"999"
																																														withString:@"Slider"]]) {
			
			slider.value -= control.step;
			break;
			
		}
		
	}
	
	[self handleSlider:slider];
	
}

//  Calls when plus button is pressed
-(void)handlePlus:(id)sender {
	
	UISlider *slider;
	for (UIView *view in [[sender superview] subviews]) {
		
		if ([view isKindOfClass:[UISlider class]]) {
			
			slider = (UISlider *)view;
			break;
			
		}
		
	}
	
	for(CustomControl *control in customControls) {
		
		if ([control.uid isEqualToString:[[@(slider.tag) stringValue] stringByReplacingOccurrencesOfString:@"999"
																																														withString:@"Slider"]]) {
			
			slider.value += control.step;
			break;
			
		}
		
	}
	
	[self handleSlider:slider];
}

//  Calls when less button is pressed
-(void)handleLess:(id)sender {
	
	UILabel *less;
	for (UIView *view in [[sender superview] subviews]) {
		
		if ([view isKindOfClass:[UILabel class]]) {
			
			less = (UILabel *)view;
			break;
			
		}
		
	}
	
	for (CustomControl *control in customControls) {
		
		if ([control.uid isEqualToString:[[@(less.tag) stringValue] stringByReplacingOccurrencesOfString:@"666"
																																													withString:@"LessMore"]]) {
			
			NSString *lblValue = [[GoldmineReader getValue] valueForKey:control.uid];
			double currentValue = lblValue.doubleValue;
			
			if (currentValue > control.min) {
				
				currentValue -= control.step;
				
				if ([control.suffix isEqualToString:@"%"]) {
					
					currentValue *= 100;
					less.text = [NSString stringWithFormat:@"%d%@", (int)currentValue, control.suffix];
					[GoldmineReader setValue:[NSString stringWithFormat:@"%f", currentValue / 100.0f]
														forKey:control.uid];
					[supportingMetrics setValue:[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%f", currentValue / 100.0f]]
															 forKey:control.uid];
					
				}
				else {
					
					less.text = [NSString stringWithFormat:@"%i", (int)currentValue];
					[GoldmineReader setValue:[NSString stringWithFormat:@"%i", (int)currentValue]
														forKey:control.uid];
					[supportingMetrics setValue:[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%i", (int)currentValue]]
															 forKey:control.uid];
					
				}
				
			}
			
			break;
			
		}
		
	}
	
	[self updateLabels];
	
}

//  Calls when more button is pressed
-(void)handleMore:(id)sender {
	
	UILabel *more;
	for (UIView *view in [[sender superview] subviews]) {
		
		if ([view isKindOfClass:[UILabel class]]) {
			
			more = (UILabel *)view;
			break;
			
		}
		
	}
	
	for (CustomControl *control in customControls) {
		
		if ([control.uid isEqualToString:[[@(more.tag) stringValue] stringByReplacingOccurrencesOfString:@"666"
																																													withString:@"LessMore"]]) {
			
			NSString *lblValue = [[GoldmineReader getValue] valueForKey:control.uid];
			double currentValue = lblValue.doubleValue;
			
			if (currentValue < control.max) {
				
				currentValue += control.step;
				
				if ([control.suffix isEqualToString:@"%"]) {
					
					currentValue *= 100;
					more.text = [NSString stringWithFormat:@"%d%@", (int)currentValue, control.suffix];
					[GoldmineReader setValue:[NSString stringWithFormat:@"%f", currentValue / 100.0f]
														forKey:control.uid];
					[supportingMetrics setValue:[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%f", currentValue / 100.0f]]
															 forKey:control.uid];
					
				}
				else {
					
					more.text = [NSString stringWithFormat:@"%i", (int)currentValue];
					[GoldmineReader setValue:[NSString stringWithFormat:@"%i", (int)currentValue]
														forKey:control.uid];
					[supportingMetrics setValue:[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%i", (int)currentValue]]
															 forKey:control.uid];
					
				}
				
			}
			
			break;
			
		}
		
	}
	
	[self updateLabels];
	
}

-(void)handleReset:(id)sender {
	
	UIButton *reset = (UIButton *)sender;
	
	for(CustomControl *control in customControls) {
		
		if ([control.uid isEqualToString:[[@(reset.tag) stringValue] stringByReplacingOccurrencesOfString:@"888"
																																													 withString:@"Reset"]]) {
			
			NSArray *components = [[NSArray alloc] initWithArray:[control.suffix componentsSeparatedByString:@";"]];
			
			for (NSString *str in components) {
				
				NSArray *mapping = [[NSArray alloc] initWithArray:[str componentsSeparatedByString:@","]];
				
				NSString *key = [mapping firstObject];
				NSString *value = [mapping lastObject];
				
				[GoldmineReader setValue:value forKey:key];
				
			}
		
			break;
			
		}
		
	}
	
	[self handleEvent:@"nil"];
	
}

#pragma mark Sets and Gets Default Values
-(void)setDefaultValues:(CustomControl *)control {
	
	NSString *tempControl = [NSString stringWithFormat:@"%@", [[GoldmineReader getValue] valueForKey:control.uid]];
	
	if ([tempControl isEqualToString:@"(null)"]) {
		
		NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
		NSNumber *number = [f numberFromString:control.defaultCV];
		
		if (number == nil) {
			
			control.defaultCV = [[evalFormula evaluateFormula:control.defaultCV
																						withMetrics:[GoldmineReader getValue]] stringValue];
			
		}
		
		if ([control.suffix isEqualToString:@"%"]) {
			
			control.defaultCV = [NSString stringWithFormat:@"%.2f", [control.defaultCV floatValue] / 100];
			
		}
		else {
			
			control.defaultCV = [NSString stringWithFormat:@"%d", [control.defaultCV intValue]];
			
		}
		
		[GoldmineReader setValue:control.defaultCV
											forKey:[NSString stringWithFormat:@"%@",control.uid]];
		
	}
	else {
		
		NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
		NSNumber *number = [f numberFromString:control.defaultCV];
		
		if (number == nil) {
			
			control.defaultCV = [[evalFormula evaluateFormula:control.defaultCV
																						withMetrics:[GoldmineReader getValue]] stringValue];
			
			[GoldmineReader setValue:control.defaultCV
												forKey:[NSString stringWithFormat:@"%@", control.uid]];
			
		}
		else {
			
			control.defaultCV = [[GoldmineReader getValue] valueForKey:control.uid];
			
		}
		
	}
	
}

#pragma mark Updates Dynamic Labels

-(void)updateLabels {
	
	for (int i = 0; i < noOfLabels; i++) {
		
		CustomLabel *tempLabel = [customLabels objectAtIndex:i];
		NSString *calculatedValue;
		
		NSMutableString *str = [[NSMutableString alloc] initWithString:tempLabel.formula];
		
		if ([str hasPrefix:@"#"]) {
			
			[str deleteCharactersInRange:[str rangeOfString:@"#"]];
			calculatedValue = [NSString stringWithFormat:@"%@",[evalFormula evaluateFormula:str
																																					withMetrics:supportingMetrics]];
			
			[GoldmineReader setValue:[NSString stringWithFormat:@"%@",calculatedValue]
												forKey:tempLabel.key];
			[supportingMetrics setValue:[NSDecimalNumber decimalNumberWithString:calculatedValue]
													 forKey:tempLabel.key];
			
		}
		else {
			
			calculatedValue = [NSString stringWithFormat:@"%@",[evalFormula evaluateFormula:tempLabel.formula
																																					withMetrics:supportingMetrics]];
			
		}
		
		int tag = [[NSString stringWithFormat:@"%@%d",@"-777", i] intValue];
		
		//-777 is tag for Custom label
		UILabel *targetLabel = (UILabel *)[self viewWithTag:tag];
		
		targetLabel.text = [self setNumberFormat:calculatedValue
																withCategory:tempLabel.category
																	withFormat:tempLabel.format];
		
		if ([calculatedValue floatValue] >=0) {
			
			targetLabel.textColor = tempLabel.colorPositive;
			
		}
		else {
			
			targetLabel.textColor = tempLabel.colorNegative;
			
		}
		
	}
	
}

#pragma mark Sets Number Formatting

-(NSString*)setNumberFormat:(NSString*)value
							 withCategory:(int)category
								 withFormat:(NSString*)format {
	
	NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
	
	switch (category) {
			
		case 0: // Represents Decimal Formatting
			formatter.numberStyle = NSNumberFormatterDecimalStyle;
			formatter.positiveFormat = format;
			break;
			
		case 1: // Represents Currency Formatting
			formatter.numberStyle = NSNumberFormatterCurrencyStyle;
			formatter.positiveFormat = format;
			break;
			
		case 4: // Represents Percentage Formatting
			formatter.numberStyle = NSNumberFormatterPercentStyle;
			formatter.positiveFormat = format;
			break;
			
		default:
			break;
			
	}
	
	return [formatter stringFromNumber:[NSDecimalNumber decimalNumberWithString:value]];
	
}

@end
