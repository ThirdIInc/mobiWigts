//
//  EvaluateFormulae.m
//  Adage
//
//  Created by Pradeep Yadav on 13/12/16.
//  Copyright © 2016 Third I, Inc. All rights reserved.
//

#import "EvaluateFormulae.h"

@implementation EvaluateFormulae

- (instancetype)init {
	self = [super init];
	if (self) {
	}
	return self;
}

//  This function evaluates formula using NSPredicate and NSExperssion method. It gets all variables values in formula from a dictionary.
- (NSDecimalNumber *)evaluateFormula:(NSString *)formula withMetrics:(NSDictionary *)metrics; {
	NSDecimalNumber *evaluatedValue;
	
	formula = [formula stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
	
	if ([formula hasPrefix:@"if"]) {
		
		NSString *substring = [formula substringWithRange:NSMakeRange(3,[formula length]-4)];
		NSMutableArray *args = [[NSMutableArray alloc] initWithArray:[substring componentsSeparatedByString:@"?"]];
		
		if ([args count]==1) {
			args = [[NSMutableArray alloc] initWithArray:[substring componentsSeparatedByString:@","]];
			if ([args count]==1) {
				args = [[NSMutableArray alloc] initWithArray:[substring componentsSeparatedByString:@";"]];
				if ([args count]==1) {
					args = [[NSMutableArray alloc] initWithArray:[substring componentsSeparatedByString:@":"]];
				}
			}
		}
		
		NSPredicate *predicate = [NSPredicate predicateWithFormat:args[0]];
		BOOL trueFalseFlag = [predicate evaluateWithObject:metrics];
		
		if (trueFalseFlag) {
			
			evaluatedValue = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%@",[self evaluateFormula:args[1] withMetrics:metrics]]];
		}
		else {
			evaluatedValue = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%@",[self evaluateFormula:args[2] withMetrics:metrics]]];
		}
		
	}
	else {
		
		NSExpression *expr = [NSExpression expressionWithFormat:formula];
		evaluatedValue = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%@",[expr expressionValueWithObject:metrics context:nil]]];
	}
	
	if ([NSDecimalNumber notANumber] == evaluatedValue) {
		evaluatedValue = [NSDecimalNumber decimalNumberWithString:@"0"];
	}
	
	return evaluatedValue;
}

@end
