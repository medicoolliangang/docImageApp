//
//  CategorizeViewController.h
//  docImageApp
//
//  Created by 侯建政 on 8/11/14.
//  Copyright (c) 2014 jianzheng. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol CategorizeViewControllerDelegate <NSObject>
- (void)selectCategorize:(NSMutableArray *)arr departMent:(NSMutableArray *)deparmentArray;
@end
@interface CategorizeViewController : UIViewController
@property (nonatomic, unsafe_unretained) id<CategorizeViewControllerDelegate> delegate;
@property (nonatomic, strong) NSMutableArray *selectArr;
@property (nonatomic, strong) NSMutableArray *selectArr2;
@end