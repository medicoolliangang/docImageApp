//
//  RegisterViewController.m
//  docImageApp
//
//  Created by 侯建政 on 8/28/14.
//  Copyright (c) 2014 jianzheng. All rights reserved.
//

#import "RegisterViewController.h"
#import "Strings.h"
#import "UrlCenter.h"
#import "imdRequest.h"
#import "JSON.h"
#import "userLocalData.h"
#import "userInfoViewController.h"
#import "iosVersionChecker.h"
#import "VerifyCheckcodeViewController.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"

#define NEXT_STEP 20140831
@interface RegisterViewController ()
{
  ASIHTTPRequest *request;
}
@property (nonatomic, strong) IBOutlet UITextField *phoneTF;
@property (nonatomic, strong) IBOutlet UITextField *passTF;
@property (nonatomic, strong) IBOutlet UIButton *registerButton;
@property (nonatomic, strong) MBProgressHUD *proHud;
@end

@implementation RegisterViewController
@synthesize proHud;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewWillDisappear:(BOOL)animated
{
  if (request) {
    [request clearDelegatesAndCancel];
    request = nil;
  }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
  self.navigationController.navigationBar.hidden = NO;
  
  proHud = [[MBProgressHUD alloc] initWithView:self.view];
  [self.view addSubview:proHud];
  proHud.labelText = @"请稍后...";
//  UIBarButtonItem *aButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"注册" style:UIBarButtonItemStyleBordered target:self action:@selector(registerIn)];
//  self.navigationItem.rightBarButtonItem =aButtonItem;
//  self.navigationItem.rightBarButtonItem.enabled = NO;
  self.registerButton.enabled = NO;
  self.title = @"手机注册";
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChange:) name:UITextFieldTextDidChangeNotification object:nil];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
}
- (IBAction)registerIn
{
  if (![Strings phoneNumberJudge:self.phoneTF.text]) {
    [self showAlertViewWithTitle:RUIYI_TITLE andMessage:REGISTER_MOBILE_MESSAGE];
    return;
  }
  if (self.passTF.text.length < 6) {
    [self showAlertViewWithTitle:RUIYI_TITLE andMessage:REGISTER_PWD_LENGTH];
    return;
  }
  [self clickVerifyInfo];
}
- (void)showAlertViewWithTitle:(NSString *)title andMessage:(NSString *)message{
  UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
  [alertView show];
}

- (void)textChange:(NSNotification *)notification
{
  if (self.phoneTF.text.length > 0 && self.passTF.text.length > 0) {
    self.registerButton.enabled = YES;
  }else
    self.registerButton.enabled = NO;
}
- (void)clickVerifyInfo{
  [self.proHud show:YES];
  NSString *accountInfo = self.phoneTF.text;
  
  if (![Strings phoneNumberJudge:accountInfo]) {
    [self showAlertViewWithTitle:@"提醒" andMessage:@"您输入的手机号码错误，请输入正确的手机号码。"];
    return;
  }
  if (request) {
    [request clearDelegatesAndCancel];
    request = nil;
  }
  request = [imdRequest getRequest:[NSString stringWithFormat:@"%@/%@",[UrlCenter urlOfType:CHECKMOBILE_URL],accountInfo] delegate:self requestType:nil];
  request.didFinishSelector = @selector(checkMobileInfoRequestFinished:);
  request.didFailSelector = @selector(checkFailed:);
}
- (void)checkMobileInfoRequestFinished:(ASIHTTPRequest *)request_{
  BOOL checked = [[request_ responseString] boolValue];
  [self.proHud hide:YES];
  if ((!checked)) {
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"手机号码已被注册" message:@"您输入的手机号码已被注册，请输入新手机号码。" delegate:self cancelButtonTitle:@"输入新手机号" otherButtonTitles:@"取消", nil];
    alertView.tag = 2013102401;
    [alertView show];
  }else{
    AppDelegate *delegateApp = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    VerifyCheckcodeViewController *checkCode = [[VerifyCheckcodeViewController alloc] init];
    checkCode.passNumber = self.passTF.text;
    checkCode.phoneNumber = self.phoneTF.text;
    checkCode.codedelegate = delegateApp.mainVC;
    [checkCode postCode];
    [self.navigationController pushViewController:checkCode animated:YES];
  }
}
- (void)checkFailed:(ASIHTTPRequest *)request_
{
  [self.proHud hide:YES];
  if ([request_.error code] == ASIRequestTimedOutErrorType) {
    [self showAlertViewWithTitle:RUIYI_TITLE andMessage:REQUEST_TIMEOUT_MESSAGE];
  }else
  {
    [self showAlertViewWithTitle:RUIYI_TITLE andMessage:REQUEST_ERROR];
  }
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
  if (alertView.tag == 2013102401 && buttonIndex == 0) {
    self.phoneTF.text = @"";
    [self.phoneTF becomeFirstResponder];
  }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
