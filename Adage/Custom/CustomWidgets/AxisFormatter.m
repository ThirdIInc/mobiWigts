//
//  AxisFormatter.m
//  Adage
//
//  Created by Deepika Nahar on 26/12/16.
//  Copyright © 2016 Third I, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AxisFormatter.h"

@implementation AxisFormatter

static const char sUnits[] = { '\0', 'k', 'm', 'b'};
static int sMaxUnits = sizeof sUnits - 1;

-(id)init {
    if(self = [super init])
    {
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
    if (abs([obj intValue]) < 10) {
        convertedStr = [NSString stringWithFormat:@"%.1f%c", bytes, sUnits[exponent]];
    }
    else {
        convertedStr = [NSString stringWithFormat:@"%d%c", (int)bytes, sUnits[exponent]];
    }
    return convertedStr;
}
@end
