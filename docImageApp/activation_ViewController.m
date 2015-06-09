//
//  activation ViewController.m
//  docImageApp
//
//  Created by 侯建政 on 10/13/14.
//  Copyright (c) 2014 jianzheng. All rights reserved.
//

#import "activation_ViewController.h"
#import "Strings.h"
#import "UrlCenter.h"
#import "imdRequest.h"
#import "JSON.h"
#import "userLocalData.h"
#import "userInfoViewController.h"
#import "iosVersionChecker.h"
#import "WXpwdViewController.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"

#define NEXT_STEP 20140831
@interface activation_ViewController ()<WXpwdViewControllerDelegate>
{
  ASIHTTPRequest *request;
}
@property (nonatomic, strong) IBOutlet UITextField *phoneTF;
@property (nonatomic, strong) IBOutlet UITextField *codeTF;
@property (nonatomic, strong) IBOutlet UIButton *checkButton;
@property (nonatomic, strong) IBOutlet UIButton *postCodeButton;
@property (nonatomic, strong) IBOutlet UILabel *numberLbl;

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) int timeCount;

@property (nonatomic, strong) MBProgressHUD *proHud;
@end

@implementation activation_ViewController

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
  [super viewWillDisappear:animated];
  [self.timer invalidate];
  self.timer = nil;
}
- (void)viewWillAppear:(BOOL)animated
{
  self.postCodeButton.enabled = YES;
  [self.postCodeButton setTitle:@"获取验证码" forState:0];
  self.numberLbl.hidden = YES;
  if (self.timer == nil) {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(remainTimer) userInfo:nil repeats:YES];
    self.timeCount = 60;
    [self.timer setFireDate:[NSDate distantFuture]];
  }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
  self.navigationController.navigationBar.hidden = NO;
  self.checkButton.enabled = NO;
  self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(remainTimer) userInfo:nil repeats:YES];
  self.timeCount = 60;
  [self.timer setFireDate:[NSDate distantFuture]];
//  UIBarButtonItem *aButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"下一步" style:UIBarButtonItemStyleBordered target:self action:@selector(registerIn)];
//  self.navigationItem.rightBarButtonItem =aButtonItem;
//  self.navigationItem.rightBarButtonItem.enabled = NO;
  self.title = @"手机绑定";
  
  self.proHud = [[MBProgressHUD alloc] initWithView:self.view];
  [self.view addSubview:self.proHud];
  self.proHud.labelText = @"请稍后...";
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChange:) name:UITextFieldTextDidChangeNotification object:nil];
    // Do any additional setup after loading the view from its nib.
}
- (void)remainTimer
{
  [self.postCodeButton setTitle:@"" forState:0];
  self.postCodeButton.enabled = NO;
  
  self.numberLbl.hidden = NO;
  self.numberLbl.text = [NSString stringWithFormat:@"%d秒后重试",--self.timeCount];
  if (self.timeCount == 0) {
    self.numberLbl.hidden = YES;
    [self.timer setFireDate:[NSDate distantFuture]];
    self.timeCount = 60;
    self.postCodeButton.enabled = YES;
    [self.postCodeButton setTitle:@"重新获取" forState:0];
  }
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
  if (self.codeTF.text.length != 6) {
    [self showAlertViewWithTitle:RUIYI_TITLE andMessage:REGISTER_CODE_MESSAGE];
    return;
  }
  
  NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
  [dic setObject:self.phoneTF.text forKey:PHONE_NUMBER];
  [dic setObject:self.codeTF.text forKey:CODE_Available];
  [self.proHud show:YES];
  [imdRequest getRequest:[NSString stringWithFormat:@"%@/%@/%@/%@/%@",[UrlCenter urlOfType:WEIXIN_BIND],self.phoneTF.text,self.codeTF.text,self.openid,self.unionid] delegate:self requestType:@"WEIXIN_BIND"];
}
- (IBAction)clickVerifyInfoBtn:(id)sender {
  NSString *accountInfo = self.phoneTF.text;
  
  if (![Strings phoneNumberJudge:accountInfo]) {
    [self showAlertViewWithTitle:@"提醒" andMessage:@"您输入的手机号码错误，请输入正确的手机号码。"];
    return;
  }
  [self.proHud show:YES];
  request = [imdRequest postRequest:[NSString stringWithFormat:@"%@/%@",[UrlCenter urlOfType:Mobile_VerifyCode],self.phoneTF.text] delegate:self requestType:@"" postData:nil json:NO];
  request.didFinishSelector = @selector(checkCodeRequestFinish:);
  request.didFailSelector = @selector(checkFailed:);
}
- (void)checkCodeRequestFinish:(ASIHTTPRequest *)request_
{
  NSString* responseString = [request_ responseString];
  NSDictionary* dic = nil;
  if (responseString != nil && responseString.length > 0) {
    dic =[responseString JSONValue];
  }
  [self.proHud hide:YES];
  BOOL validInfo = [[dic objectForKey:@"validEmailOrMobile"] boolValue];
  if (validInfo){
    [self showAlertViewWithTitle:@"提示" andMessage:@"验证码发送成功，请在6分钟内激活。"];
    [self.timer setFireDate:[NSDate distantPast]];
    self.timeCount = 60;
  }else{
    [self showAlertViewWithTitle:@"错误提示" andMessage:@"验证码发送失败，请重试！"];
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
#pragma mark - ASIHTTPRequest Delegate
- (void)requestFinished:(ASIHTTPRequest *)request_{
  [self.proHud hide:YES];
  NSString *responseString = request_.responseString;
  NSString* rType =[[request_ userInfo] objectForKey:@"requestType"];
  NSLog(@"qqqq%@",request_.responseString);
  if ([responseString isEqualToString:@"codeverifyerror"]) {
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:RUIYI_TITLE message:@"您输入的验证码错误，请输入正确验证码。" delegate:self cancelButtonTitle:@"重新输入" otherButtonTitles:nil];
    [alert show];
  }else if([rType isEqualToString:@"WEIXIN_BIND"])
  {
    NSDictionary* info = nil;
    if (responseString != nil && responseString.length > 0) {
      info =[iosVersionChecker parseJSONObjectFromData:request_.responseData];
      if ([[info objectForKey:@"ok"] boolValue]) {
        [userLocalData saveImdToken:[info objectForKey:@"token"]];
        NSDictionary *userInfo = [iosVersionChecker parseJSONObjectFromJSONString:[info objectForKey:@"userInfo"]];
        NSString *userName = [userInfo objectForKey:@"username"];
        NSString *userPhone = [userInfo objectForKey:@"mobile"];
        NSString *portraitId = [userInfo objectForKey:@"portraitId"];
        [userLocalData saveUserName:userName];
        [userLocalData saveUserPhone:userPhone];
        [userLocalData savePhotoId:portraitId];
    
        [self dismissViewControllerAnimated:YES completion:^{
          if ([self.activedelegate respondsToSelector:@selector(loadHttpRequest)]) {
            [self.activedelegate loadHttpRequest];
            [self.navigationController popToRootViewControllerAnimated:NO];
          }
        }];
      }else
      {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
        AppDelegate *delegateApp = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        WXpwdViewController *pwdVC = [[WXpwdViewController alloc] init];
        pwdVC.openid = self.openid;
        pwdVC.unionid = self.unionid;
        pwdVC.mobileNumber = self.phoneTF.text;
        pwdVC.pwddelegate = delegateApp.mainVC;
        [self.navigationController pushViewController:pwdVC animated:YES];
      }
    }
  }
}

- (void)requestFailed:(ASIHTTPRequest *)requests{
  if ([requests.error code] == ASIRequestTimedOutErrorType) {
    [self showAlertViewWithTitle:RUIYI_TITLE andMessage:REQUEST_TIMEOUT_MESSAGE];
  }else
  {
    [self showAlertViewWithTitle:RUIYI_TITLE andMessage:REQUEST_ERROR];
  }
}
- (void)textChange:(NSNotification *)notification
{
  if (self.phoneTF.text.length > 0 && self.codeTF.text.length > 0) {
    self.checkButton.enabled = YES;
  }else
    self.checkButton.enabled = NO;
}
- (void)showAlertViewWithTitle:(NSString *)title andMessage:(NSString *)message{
  UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
  [alertView show];
}

@end
