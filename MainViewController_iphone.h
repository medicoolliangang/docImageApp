//
//  MainViewController_iphone.h
//  docImageApp
//
//  Created by 侯建政 on 8/5/14.
//  Copyright (c) 2014 jianzheng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlideNavigationController.h"
#import "WXpwdViewController.h"
#import "activation_ViewController.h"
#import "EAIntroPage.h"
#import "EAIntroView.h"
#import "VerifyCheckcodeViewController.h"

@interface MainViewController_iphone : UIViewController <SlideNavigationControllerDelegate,UITableViewDataSource,UITableViewDelegate,WXpwdViewControllerDelegate,activation_ViewControllerDelegate,EAIntroDelegate,VerifyCheckcodeViewControllerDelegate>

@property(nonatomic, strong) UINavigationController *loginNav;
  //已经清除缓存
@property(nonatomic, strong) NSString *clean;

  //跳转更新的url
@property (nonatomic, strong) NSString *updateUrl;
@property (nonatomic, strong) NSString *serverVersion;
@property (nonatomic, strong) NSString *updateMessage;
- (void)showSearch;
- (void)hiddenSearch;
- (void)loadHttpRequest;
- (void)loadgetNewResourceRequest;
- (void)checkVersion;
-(void) showHelp;
-(void)clearRequest;
- (void)refreshButtonClicked;
@end
