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
-(id)initViewer:(ViewerDataModel*)_viewerDataModel withCommanderDelegate:(id<MSICommanderDelegate>)_commander withProps:(NSString*)_props {
	
	self = [super initViewer:_viewerDataModel withCommanderDelegate:_commander withProps:_props];
	
	if(self){
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
		
		// -999<i> is tag for Dynamic label.
		NSInteger tag = [[NSString stringWithFormat:@"%@%d",@"-999",i] integerValue];
		
		[self addSubview:[label initializeLabel:frame withTag:tag]];
		
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
	return [UIColor colorWithRed:(bgrValue & 0xFF)/255.0f green:((bgrValue & 0xFF00)>>8)/255.0f blue:((bgrValue & 0xFF0000) >> 16)/255.0f alpha:1.0f];
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
			container = [self createSlider:frame withParams:control];
			break;
		case 2:
			//  Code for Toggle.
			container = [self createToggle:frame withParams:control];
			break;
		case 3:
			//  Code for Reset Button.
			if ([control.defaultCV isEqualToString:@"1"]) {
				container = [self createReset:frame withParams:control];
			}
			break;
		default:
			break;
	}
	return container;
}

-(UIView *)createSlider:(CGRect)frame withParams:(CustomControl*)control {
	
	UIView *slider = [[UIView alloc] initWithFrame:frame];
	
	CGRect frameLabel = CGRectMake(0, 0, frame.size.width, 20);
	UILabel *lblValue = [[UILabel alloc] initWithFrame:frameLabel];
	
	// Tags the label object for reference and updating the value in event handlers.
	lblValue.tag = [[control.uid stringByReplacingOccurrencesOfString:@"Slider" withString:@"909"] integerValue];
	lblValue.font = [UIFont fontWithName:control.fFace size:[control.fSize intValue]];
	
	lblValue.text = [self setNumberFormat:[[GoldmineReader getValue] valueForKey:control.uid] withFormatCategory:control.category withFormat:control.format];
	lblValue.text = [NSString stringWithFormat:@"%@ %@",lblValue.text,control.suffix];
	
	// Horizontal alignment for the control's label.
	switch ([control.align intValue]) {
		case 4:
			lblValue.textAlignment = NSTextAlignmentRight;
			break;
		case 3:
			lblValue.textAlignment = NSTextAlignmentCenter;
			break;
		default:
			lblValue.textAlignment = NSTextAlignmentLeft;
			break;
	}
	
	// This color is set on the minimum value para-metric
	lblValue.textColor = [control.colors objectAtIndex:3];
	lblValue.numberOfLines = 0;
	lblValue.lineBreakMode = NSLineBreakByWordWrapping;
	[slider addSubview:lblValue];
	
	UIButton *btnMinus = [UIButton buttonWithType:UIButtonTypeCustom];
	CGRect frameMinusButton = CGRectMake(0, frame.size.height-35, 25, 25);
	btnMinus.frame = frameMinusButton;
	[btnMinus setTitle:@"" forState:UIControlStateNormal];
	btnMinus.titleLabel.font = [UIFont fontWithName:control.fFace size:[control.fSize intValue]];
	btnMinus.backgroundColor = [UIColor clearColor];
	
	[btnMinus addTarget:self action:@selector(handleMinus:) forControlEvents:UIControlEventTouchUpInside];
	[btnMinus setBackgroundImage:[UIImage imageNamed:@"minus.png"] forState:UIControlStateNormal];
	[slider addSubview:btnMinus];
	
	CGRect frameSlider = CGRectMake(35, frame.size.height-35, frame.size.width-70, 25);
	
	UISlider *sliderControl = [[UISlider alloc] init];
	sliderControl.frame = frameSlider;
	sliderControl.tag = [[control.uid stringByReplacingOccurrencesOfString:@"Slider" withString:@"999"] integerValue];
	sliderControl.minimumValue = [control.min floatValue];
	sliderControl.maximumValue = [control.max floatValue];
	
	sliderControl.value = [lblValue.text floatValue];
	
	sliderControl.continuous = YES;
	sliderControl.minimumTrackTintColor = [control.colors objectAtIndex:0];
	sliderControl.maximumTrackTintColor = [control.colors objectAtIndex:2];
	
	[sliderControl addTarget:self action:@selector(handleSliderChange:) forControlEvents:UIControlEventValueChanged];
	[slider addSubview:sliderControl];
	
	CGRect framePlusButton = CGRectMake(frame.size.width-25, frame.size.height-35, 25, 25);
	UIButton *btnPlus = [UIButton buttonWithType:UIButtonTypeCustom];
	btnPlus.frame = framePlusButton;
	[btnPlus setTitle:@"" forState:UIControlStateNormal];
	btnPlus.titleLabel.font = [UIFont fontWithName:control.fFace size:[control.fSize intValue]];
	btnPlus.backgroundColor = [UIColor clearColor] ;
	
	[btnPlus addTarget:self action:@selector(handlePlus:) forControlEvents:UIControlEventTouchUpInside];
	[btnPlus setBackgroundImage:[UIImage imageNamed:@"plus.png"] forState:UIControlStateNormal];
	[slider addSubview:btnPlus];
	
	return slider;
}

-(UIView *)createToggle:(CGRect)frame withParams:(CustomControl*)control {
	
	UIView *toggle = [[UIView alloc] initWithFrame:frame];
	
	CGRect frameLabel = CGRectMake(25, 0, frame.size.width-25, frame.size.height);
	UILabel *lblValue = [[UILabel alloc] initWithFrame:frameLabel];
	
	// Tags the label object for reference and updating the value in event handlers.
	lblValue.tag = [[control.uid stringByReplacingOccurrencesOfString:@"Slider" withString:@"909"] integerValue];
	lblValue.font = [UIFont fontWithName:control.fFace size:[control.fSize intValue]];
	
	lblValue.text = [self setNumberFormat:[[GoldmineReader getValue] valueForKey:control.uid] withFormatCategory:control.category withFormat:control.format];
	lblValue.text = [NSString stringWithFormat:@"%@ %@",lblValue.text,control.suffix];
	
	// Horizontal alignment for the control's label.
	switch ([control.align intValue]) {
		case 4:
			lblValue.textAlignment = NSTextAlignmentRight;
			break;
		case 3:
			lblValue.textAlignment = NSTextAlignmentCenter;
			break;
		default:
			lblValue.textAlignment = NSTextAlignmentLeft;
			break;
	}
	
	// This color is set on the minimum value para-metric
	lblValue.textColor = [control.colors objectAtIndex:3];
	lblValue.numberOfLines = 0;
	lblValue.lineBreakMode = NSLineBreakByWordWrapping;
	[toggle addSubview:lblValue];
	
	UIButton *btnMinus = [UIButton buttonWithType:UIButtonTypeCustom];
	CGRect frameMinusButton = CGRectMake(0, 0, 25, 25);
	btnMinus.frame = frameMinusButton;
	[btnMinus setTitle:@"" forState:UIControlStateNormal];
	btnMinus.titleLabel.font = [UIFont fontWithName:control.fFace size:[control.fSize intValue]];
	btnMinus.backgroundColor = [UIColor clearColor];
	
	[btnMinus addTarget:self action:@selector(handleLess:) forControlEvents:UIControlEventTouchUpInside];
	[btnMinus setBackgroundImage:[UIImage imageNamed:@"less.png"] forState:UIControlStateNormal];
	[toggle addSubview:btnMinus];
	
	CGRect framePlusButton = CGRectMake(frame.size.width-25, 0, 25, 25);
	UIButton *btnPlus = [UIButton buttonWithType:UIButtonTypeCustom];
	btnPlus.frame = framePlusButton;
	[btnPlus setTitle:@"" forState:UIControlStateNormal];
	btnPlus.titleLabel.font = [UIFont fontWithName:control.fFace size:[control.fSize intValue]];
	btnPlus.backgroundColor = [UIColor clearColor] ;
	
	[btnPlus addTarget:self action:@selector(handleMore:) forControlEvents:UIControlEventTouchUpInside];
	[btnPlus setBackgroundImage:[UIImage imageNamed:@"more.png"] forState:UIControlStateNormal];
	[toggle addSubview:btnPlus];
	
	return toggle;
}

@end
