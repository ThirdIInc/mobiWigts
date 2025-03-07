//
//  I2IEmailScreen.h
//  i2iDevelopment
//
//  Created by Deepika Nahar on 04/02/17.
//  Copyright © 2017 i2iLogic (Australia) Pty Ltd. All rights reserved.
//

#ifndef I2IEmailScreen_h
#define I2IEmailScreen_h
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MSIWidgetViewer.h"
#import "MSIWidgetHelper.h"
#import "MSIHeaderValue.h"
#import "MetricHeader.h"
#import "MetricValue.h"
#import <MessageUI/MessageUI.h>

@interface I2IEmailScreen : MSIWidgetViewer

@property (retain,nonatomic) MSIModelData *modelData;
@property (retain,nonatomic) NSString *disclaimer;
@property (retain,nonatomic) NSString *emailDomains;
@property (retain,nonatomic) NSString *companyName;
-(void)readData;

@end

#endif

/* I2IEmailScreen_h */
