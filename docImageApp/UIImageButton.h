//
//  UIImageButton.h
//  igridviewdemo
//
//  Created by vincent_guo on 13-12-12.
//  Copyright (c) 2013年 vincent_guo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageButton : UIButton

@property(nonatomic,assign)int section;//第几个
@property(nonatomic,assign)int row;//第几行
@property(nonatomic,assign)int column;//第几列
- (void) loadImage:(NSString*)name;
@end
