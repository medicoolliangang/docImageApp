//
//  VerifyCheckcodeViewController.m
//  docImageApp
//
//  Created by 侯建政 on 11/18/14.
//  Copyright (c) 2014 jianzheng. All rights reserved.
//

#import "VerifyCheckcodeViewController.h"
#import "Strings.h"
#import "imdRequest.h"
#import "UrlCenter.h"
#import "iosVersionChecker.h"
#import "userLocalData.h"
#import "MBProgressHUD.h"

@interface VerifyCheckcodeViewController ()
@property (nonatomic, strong) IBOutlet UILabel *textLbl;
@property (nonatomic, strong) IBOutlet UILabel *numberLbl;
@property (nonatomic, strong) IBOutlet UIButton *checkButton;
@property (nonatomic, strong) IBOutlet UIButton *postCodeButton;
@property (nonatomic, strong) IBOutlet UITextField *verifyTF;

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) int timeCount;

@property (nonatomic, strong) ASIHTTPRequest *requestRegister;
@property (nonatomic, strong) ASIHTTPRequest *requestPostcode;

@property (nonatomic, strong) MBProgressHUD *proHud;
@end

@implementation VerifyCheckcodeViewController

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
  
  if (self.requestPostcode) {
    [self.requestPostcode clearDelegatesAndCancel];
    self.requestPostcode = nil;
  }
  if (self.requestRegister) {
    [self.requestRegister clearDelegatesAndCancel];
    self.requestRegister = nil;
  }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
  self.title = @"手机激活";
  self.textLbl.text = [NSString stringWithFormat:@"已发送验证码到\n+86 %@ 验证后完成注册",self.phoneNumber];
  self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(remainTimer) userInfo:nil repeats:YES];
  self.timeCount = 60;
  
  self.proHud = [[MBProgressHUD alloc] initWithView:self.view];
  [self.view addSubview:self.proHud];
  self.proHud.labelText = @"请稍后...";
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
- (IBAction)checkCode:(id)sender
{
  if (self.verifyTF.text.length != 6) {
    [self showAlertViewWithTitle:RUIYI_TITLE andMessage:REGISTER_CODE_MESSAGE];
    return;
  }
  
  NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
  [dic setObject:self.phoneNumber forKey:PHONE_NUMBER];
  [dic setObject:self.passNumber forKey:PASSWORD];
  [dic setObject:self.verifyTF.text forKey:CODE_Available];
  [self.proHud show:YES];
  if (self.requestRegister) {
    [self.requestRegister clearDelegatesAndCancel];
    self.requestRegister = nil;
  }
  self.requestRegister = [imdRequest postRequest:[UrlCenter urlOfType:REGISTER_URL] delegate:self requestType:@"Register" postData:dic json:NO];
}
- (void)showAlertViewWithTitle:(NSString *)title andMessage:(NSString *)message{
  UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
  [alertView show];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
  if (alertView.tag == 20141117 && buttonIndex == 0) {
    self.verifyTF.text = @"";
  }
}
#pragma mark - ASIHTTPRequest Delegate
- (void)requestFinished:(ASIHTTPRequest *)request_{
  NSString *responseString = request_.responseString;
  NSString* rType =[[request_ userInfo] objectForKey:@"requestType"];
  NSLog(@"qqqq%@",request_.responseString);
  [self.proHud hide:YES];
  if ([request_.responseString isEqualToString:@"codeverifyerror"]) {
    
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:RUIYI_TITLE message:@"您输入的验证码错误，请输入正确验证码。" delegate:self cancelButtonTitle:@"重新输入" otherButtonTitles:nil];
    alert.tag = 20141117;
    [alert show];
  }else if ([rType isEqualToString:@"checkCodeRequestFinish"])
  {
    NSDictionary* dic = nil;
    if (responseString != nil && responseString.length > 0) {
      dic =[iosVersionChecker parseJSONObjectFromData:request_.responseData];
    }
    BOOL validInfo = [[dic objectForKey:@"validEmailOrMobile"] boolValue];
    if (validInfo){
      [self.timer setFireDate:[NSDate distantPast]];
      self.timeCount = 60;
        //[self showAlertViewWithTitle:@"提示" andMessage:@"验证码发送成功，请在6分钟内激活。"];
    }else{
      [self showAlertViewWithTitle:@"错误提示" andMessage:@"验证码发送失败，请重试！"];
    }
  }else if([rType isEqualToString:@"Register"])
  {
    NSDictionary* dic = nil;
    if (responseString != nil && responseString.length > 0) {
      dic =[iosVersionChecker parseJSONObjectFromData:request_.responseData];
      if ([dic objectForKey:REGISTER_SUCCESS]) {
        [userLocalData saveImdToken:[dic objectForKey:REGISTER_TOKEN]];
        NSDictionary *userInfo = [iosVersionChecker parseJSONObjectFromJSONString:[dic objectForKey:@"userInfo"]];
        NSString *userName = [userInfo objectForKey:@"username"];
        NSString *userPhone = [userInfo objectForKey:@"mobile"];
        NSString *portraitId = [userInfo objectForKey:@"portraitId"];
        [userLocalData saveUserName:userName];
        [userLocalData saveUserPhone:userPhone];
        [userLocalData savePhotoId:portraitId];
        
        [self dismissViewControllerAnimated:YES completion:^{
          if ([self.codedelegate respondsToSelector:@selector(loadHttpRequest)]) {
            [self.codedelegate loadHttpRequest];
            [self.navigationController popToRootViewControllerAnimated:NO];
          }
        }];
      }
    }
  }
}

- (void)requestFailed:(ASIHTTPRequest *)requests{
  [self.proHud hide:YES];
  if ([requests.error code] == ASIRequestTimedOutErrorType) {
    [self showAlertViewWithTitle:RUIYI_TITLE andMessage:REQUEST_TIMEOUT_MESSAGE];
  }else
  {
    [self showAlertViewWithTitle:RUIYI_TITLE andMessage:REQUEST_ERROR];
  }
}
- (IBAction)postCode
{
  if (self.requestPostcode) {
    [self.requestPostcode clearDelegatesAndCancel];
    self.requestPostcode = nil;
  }
  [self.proHud show:YES];
  self.requestPostcode = [imdRequest postRequest:[NSString stringWithFormat:@"%@/%@",[UrlCenter urlOfType:Mobile_VerifyCode],self.phoneNumber] delegate:self requestType:@"checkCodeRequestFinish" postData:nil json:NO];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
