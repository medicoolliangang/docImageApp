//
//  VerifyCheckcodeViewController.h
//  docImageApp
//
//  Created by 侯建政 on 11/18/14.
//  Copyright (c) 2014 jianzheng. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol VerifyCheckcodeViewControllerDelegate <NSObject>

- (void)loadHttpRequest;
@end
@interface VerifyCheckcodeViewController : UIViewController
@property (nonatomic, strong) NSString *phoneNumber;
@property (nonatomic, strong) NSString *passNumber;
@property (nonatomic, weak) id<VerifyCheckcodeViewControllerDelegate> codedelegate;

- (IBAction)postCode;
@end
