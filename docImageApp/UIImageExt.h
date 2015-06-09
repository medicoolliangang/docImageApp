//
//  UIImageExt.h
//  SmartBox
//
//  Created by roy on 11-12-9.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIImage (UIImageExt)

- (UIImage *)imageByScalingAndCroppingForSize:(CGSize)targetSize;

- (CGSize)sizeFitSize:(CGSize)target;

- (UIImage *)imageByScalingFitSize:(CGSize)targetSize;
@end
