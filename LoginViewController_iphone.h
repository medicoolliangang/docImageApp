//
//  LoginViewController_iphone.h
//  docImageApp
//
//  Created by 侯建政 on 8/5/14.
//  Copyright (c) 2014 jianzheng. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol LoginViewController_iphoneDelegate <NSObject>

- (void)loadHttpRequest;
@end
@interface LoginViewController_iphone : UIViewController<UITextFieldDelegate, UIAlertViewDelegate>
{
  IBOutlet UIButton* registerBtn;
  IBOutlet UIButton* forgotPasswordBtn;
  IBOutlet UITextField* userText;
  IBOutlet UITextField* userPassword;
  id delegate;
  UIAlertView* alertView;
  
  IBOutlet UIScrollView* _scrollView;
  
  UIActivityIndicatorView* _indicator;
  id viewC;
}
@property (nonatomic, retain) UIViewController* sourceCtr;
@property (nonatomic, retain) IBOutlet UIButton* registerBtn;
@property (nonatomic, retain) IBOutlet UIButton* forgotPasswordBtn;
@property (nonatomic, retain) IBOutlet UITextField* userText;
@property (nonatomic, retain) IBOutlet UITextField* userPassword;
@property (nonatomic, retain) IBOutlet UIScrollView* scrollView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView* indicator;
@property (nonatomic, strong) IBOutlet UIButton* wxButton;

@property (nonatomic, retain) UIAlertView* alertView;
@property (nonatomic, retain) id delegate;
@property (nonatomic, retain) id viewC;

@property (nonatomic, weak) id<LoginViewController_iphoneDelegate> logindelegate;
-(IBAction)login:(id)sender;
-(IBAction)registerNew:(id)sender;
-(IBAction)closeView:(id)sender;

-(IBAction)forgotPassword:(id)sender;

-(void) userLoginFinished:(BOOL)animated;
-(void) userLoginFailed:(UIViewController *)viewController;
-(void) getUserInfo:(NSDictionary *)userInfo;
@end
