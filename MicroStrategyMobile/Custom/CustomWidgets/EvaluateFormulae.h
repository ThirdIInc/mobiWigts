//
//  EvaluateFormulae.h
//  Adage
//
//  Created by Pradeep Yadav on 13/12/16.
//  Copyright © 2016 Third I, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EvaluateFormulae : NSObject

-(NSDecimalNumber *)evaluateFormula:(NSString *)formula withMetrics:(NSDictionary *)metrics;

@end
