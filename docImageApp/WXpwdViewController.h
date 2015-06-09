//
//  WXpwdViewController.h
//  docImageApp
//
//  Created by 侯建政 on 10/14/14.
//  Copyright (c) 2014 jianzheng. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol WXpwdViewControllerDelegate <NSObject>

- (void)loadHttpRequest;
@end
@interface WXpwdViewController : UIViewController
@property (nonatomic, strong) NSString *openid;
@property (nonatomic, strong) NSString *unionid;
@property (nonatomic, strong) NSString *mobileNumber;
@property (nonatomic, weak) id<WXpwdViewControllerDelegate> pwddelegate;
@end
