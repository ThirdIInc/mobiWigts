//
//  I2IAxisFormatter.m
//  i2iDevelopment
//
//  Created by Pradeep Yadav on 14/04/15.
//  Modified by Pradeep Yadav on 14/03/17.
//  Copyright © 2017 i2i Logic (Australia) Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "I2IAxisFormatter.h"

@implementation I2IAxisFormatter

static const char sUnits[] = { '\0', 'k', 'm', 'b'};
static int sMaxUnits = sizeof sUnits - 1;

-(id)init {
    
    if (self = [super init]) {
        
        numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setNumberStyle: NSNumberFormatterDecimalStyle];
        numberFormatter.maximumFractionDigits = 1;
        numberFormatter.minimumFractionDigits = 1;
        
    }
    return self;
    
}

-(NSString *) stringForObjectValue:(id)obj {
    
    int multiplier = 1000;
    int exponent = 0;
    float bytes = [(NSNumber *)obj floatValue];
    while ((fabs(bytes) >= multiplier) && (exponent < sMaxUnits)) {
        
        bytes /= multiplier;
        exponent++;
        
    }
    NSString *convertedStr;
    if ([obj floatValue] == 0.0) convertedStr = @"0";
    else convertedStr = [NSString stringWithFormat:@"%.1f%c", bytes, sUnits[exponent]];
    return convertedStr;
    
}

@end
