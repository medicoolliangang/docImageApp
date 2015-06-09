//
//  UpLoadPictureViewController.h
//  docImageApp
//
//  Created by 侯建政 on 8/6/14.
//  Copyright (c) 2014 jianzheng. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol UpLoadPictureViewControllerDelegate <NSObject>
- (void)loadgetNewResourceRequest;
@end
@interface UpLoadPictureViewController : UIViewController
@property (nonatomic, strong) NSArray *dateImageArr;
@property (nonatomic, assign) float imgHeightMax;
@property (nonatomic, weak) id<UpLoadPictureViewControllerDelegate> delegate;
@property (nonatomic, strong) UIImage *cameraImage;
@property (nonatomic, strong) NSString *cameraImagePath;
@end
