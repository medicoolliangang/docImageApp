//
//  WXpwdViewController.m
//  docImageApp
//
//  Created by 侯建政 on 10/14/14.
//  Copyright (c) 2014 jianzheng. All rights reserved.
//

#import "WXpwdViewController.h"
#import "Strings.h"
#import "UrlCenter.h"
#import "imdRequest.h"
#import "JSON.h"
#import "userLocalData.h"
#import "userInfoViewController.h"
#import "iosVersionChecker.h"
#import "MBProgressHUD.h"

@interface WXpwdViewController ()
@property (nonatomic, strong) IBOutlet UITextField *pawTf;
@property (nonatomic, strong) IBOutlet UIButton *registerButton;

@property (nonatomic, strong) MBProgressHUD *proHud;
@end

@implementation WXpwdViewController



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
  self.navigationController.navigationBar.hidden = NO;
//  UIBarButtonItem *aButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleBordered target:self action:@selector(registerIn)];
//  self.navigationItem.rightBarButtonItem =aButtonItem;
//  self.navigationItem.rightBarButtonItem.enabled = NO;
  self.proHud = [[MBProgressHUD alloc] initWithView:self.view];
  [self.view addSubview:self.proHud];
  self.proHud.labelText = @"请稍后...";
  
  self.title = @"手机绑定";
  self.registerButton.enabled = NO;
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChange:) name:UITextFieldTextDidChangeNotification object:nil];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)textChange:(NSNotification *)notification
{
  if (self.pawTf.text.length > 0 ) {
    self.registerButton.enabled = YES;
  }else
    self.registerButton.enabled = NO;
}

- (IBAction)registerIn
{
  if (self.pawTf.text.length < 6) {
    [self showAlertViewWithTitle:RUIYI_TITLE andMessage:REGISTER_PWD_LENGTH];
    return;
  }
  NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
  [dic setObject:self.mobileNumber forKey:PHONE_NUMBER];
  [dic setObject:self.pawTf.text forKey:PASSWORD];
  [dic setObject:self.openid forKey:@"openid"];
  [dic setObject:self.unionid forKey:@"unionid"];
  [self.proHud show:YES];
  [imdRequest postRequest:[UrlCenter urlOfType:WEIXIN_SignUp] delegate:self requestType:@"WXRegister" postData:dic json:NO];
}
- (void)showAlertViewWithTitle:(NSString *)title andMessage:(NSString *)message{
  UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
  [alertView show];
}
#pragma mark - ASIHTTPRequest Delegate
- (void)requestFinished:(ASIHTTPRequest *)request{
  [self.proHud hide:YES];
  NSString *responseString = request.responseString;
  NSString* rType =[[request userInfo] objectForKey:@"requestType"];
  NSLog(@"qqqq%@",request.responseString);
  if ([rType isEqualToString:@"WXRegister"]) {
    NSDictionary* info = nil;
    if (responseString != nil && responseString.length > 0) {
      info =[iosVersionChecker parseJSONObjectFromData:request.responseData];
      if ([[info objectForKey:@"ok"] boolValue]) {
        [userLocalData saveImdToken:[info objectForKey:@"token"]];
        NSDictionary *userInfo = [iosVersionChecker parseJSONObjectFromJSONString:[info objectForKey:@"userInfo"]];
        NSString *userName = [userInfo objectForKey:@"username"];
        NSString *userPhone = [userInfo objectForKey:@"mobile"];
        NSString *portraitId = [userInfo objectForKey:@"portraitId"];
        [userLocalData saveUserName:userName];
        [userLocalData saveUserPhone:userPhone];
        [userLocalData savePhotoId:portraitId];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
    
        [self dismissViewControllerAnimated:YES completion:^{
          if ([self.pwddelegate respondsToSelector:@selector(loadHttpRequest)]) {
            [self.pwddelegate loadHttpRequest];
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

@end
