//
//  I2IFxGrid.h
//  i2iDevelopment
//
//  Created by Deepika Nahar on 14/03/17.
//  Modified by Pradeep Yadav on 06/04/17.
//  Copyright © 2017 i2i Logic (Australia) Pty Ltd. All rights reserved.
//

#ifndef I2IFxGrid_h
#define I2IFxGrid_h

#import <Foundation/Foundation.h>
#import "MSIWidgetViewer.h"
#import "MSIWidgetHelper.h"
#import <UIKit/UIKit.h>
#import "MSIPropertyGroup.h"
#import "MSIHeaderValue.h"
#import "MetricHeader.h"
#import "MetricValue.h"
#import "AttributeHeader.h"
#import "AttributeElement.h"
#import "Attribute.h"
#import "PlistData.h"

@interface I2IFxGrid : MSIWidgetViewer <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource> {
    
    UICollectionView *i2iGridView;
    
    NSString *rowPrefix;
    NSString *keySuffix;
    
    NSString *fontFace;
    int fontSize;
    UIColor *gridColor;
    UIColor *textColor;
    int noOfColumns;
    int noOfRows;
    
}

@property (retain, nonatomic) MSIModelData *dataModel;
-(void)readData;

@end

#endif

/* I2IFxGrid_h */
