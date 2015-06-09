//
//  activation ViewController.h
//  docImageApp
//
//  Created by 侯建政 on 10/13/14.
//  Copyright (c) 2014 jianzheng. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol activation_ViewControllerDelegate <NSObject>

- (void)loadHttpRequest;
@end

@interface activation_ViewController : UIViewController
@property (nonatomic, strong) NSString *openid;
@property (nonatomic, strong) NSString *unionid;
@property (nonatomic, weak) id<activation_ViewControllerDelegate> activedelegate;
@end
