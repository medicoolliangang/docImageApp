//
//  UIImageExt.m
//  SmartBox
//
//  Created by roy on 11-12-9.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "UIImageExt.h"

@implementation UIImage (UIImageExt)

- (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize
{
	UIImage *sourceImage = self;
	UIImage *newImage = nil;
	CGSize imageSize = sourceImage.size;
	CGFloat width = imageSize.width;
	CGFloat height = imageSize.height;
	CGFloat targetWidth = targetSize.width;
	CGFloat targetHeight = targetSize.height;
	CGFloat scaleFactor = 0.0;
	CGFloat scaledWidth = targetWidth;
	CGFloat scaledHeight = targetHeight;
	CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
	
	if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth= width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else if (widthFactor < heightFactor)
        {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
	
	UIGraphicsBeginImageContext(targetSize); // this will crop
    
	CGRect thumbnailRect = CGRectZero;
	thumbnailRect.origin = thumbnailPoint;
	thumbnailRect.size.width= scaledWidth;
	thumbnailRect.size.height = scaledHeight;
	
	[sourceImage drawInRect:thumbnailRect];
	
	newImage = UIGraphicsGetImageFromCurrentImageContext();
	if(newImage == nil)
		NSLog(@"could not scale image");
	
	//pop the context to get back to the default
	UIGraphicsEndImageContext();
	return newImage;
}

//等比缩小大小
-(CGSize)sizeFitSize:(CGSize)target
{
    CGSize size = self.size;
    CGFloat widthFactor = size.width / target.width;
    CGFloat heightFactor = size.height / target.height;
    if (widthFactor <= 1.0 && heightFactor <= 1.0) return CGSizeZero;
    
    CGFloat scaleFactor = widthFactor > heightFactor ? widthFactor : heightFactor;
    return CGSizeMake(size.width / scaleFactor, size.height / scaleFactor);
}

//等比缩小
- (UIImage *)imageByScalingFitSize:(CGSize)targetSize
{
	CGSize scaleSize = [self sizeFitSize:targetSize];
    if (CGSizeEqualToSize(scaleSize, CGSizeZero)) return self;
    UIGraphicsBeginImageContext(scaleSize);
    CGRect rect = CGRectMake(0.0,0.0,scaleSize.width,scaleSize.height);
    [self drawInRect:rect];
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return outputImage;
}
@end
