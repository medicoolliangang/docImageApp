//
//  LoginViewController_iphone.m
//  docImageApp
//
//  Created by 侯建政 on 8/5/14.
//  Copyright (c) 2014 jianzheng. All rights reserved.
//

#import "LoginViewController_iphone.h"
#import "Strings.h"
#import "imdRequest.h"
#import "UrlCenter.h"
#import "iosVersionChecker.h"
#import "userLocalData.h"
#import "FindPWDAccountInfoViewController.h"
#import "RegisterViewController.h"
#import "WXApi.h"
#define ALERTVIEWTAG1 2013102201
#define ALERTVIEWTAG2 2013102202
#define ALERTVIEWTAG3 2013102203
@interface LoginViewController_iphone ()<WXApiDelegate,UIApplicationDelegate>
@property (assign, nonatomic) BOOL isInputAccount;
@property (strong, nonatomic) UITapGestureRecognizer *taper;
@end

@implementation LoginViewController_iphone

@synthesize registerBtn, forgotPasswordBtn, userText, userPassword;
@synthesize alertView;
@synthesize delegate;
@synthesize sourceCtr;
@synthesize scrollView = _scrollView;
@synthesize indicator = _indicator;
@synthesize viewC;
@synthesize taper;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        alertView = [[UIAlertView alloc]initWithTitle:LOGIN_ALERT_TITLE message:LOGIN_ALERT_MESSAGE delegate:self cancelButtonTitle:ALERT_CONFIRM otherButtonTitles:nil];
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBAction
-(IBAction)login:(id)sender
{
  if  ([self.userText.text isEqualToString:@""]) {
    [self.userText becomeFirstResponder];
    return;
  }
  if  ([self.userPassword.text isEqualToString:@""]) {
    [self.userPassword becomeFirstResponder];
    return;
  }
  if (![Strings validEmail:self.userText.text] && ![Strings phoneNumberJudge:self.userText.text]) {
    [alertView setMessage:REGISTER_EMAIL_FORMAT];
    [alertView show];
    [self.userText becomeFirstResponder];
    return;
  }
    //temp code,login anyway
  [self loginHttpRequest];
}
-(void)loginHttpRequest
{
  NSString *name = [self.userText.text lowercaseString];
  NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithCapacity:2];
  [dic setObject:name forKey:@"id"];
  [dic setObject:self.userPassword.text forKey:@"password"];
  [imdRequest postRequest:[UrlCenter urlOfType:LOGIN_URL] delegate:self requestType:@"LoginIn" postData:dic json:NO];
}
//-(IBAction)closeView:(id)sender
//{
//  self.userPassword.text = nil;
//  [self dismissViewControllerAnimated:YES completion:nil];
//}
-(void)getUserInfo:(NSDictionary *)userInfo
{
  NSString *userName = [userInfo objectForKey:@"username"];
  NSString *userPhone = [userInfo objectForKey:@"mobile"];
  NSString *portraitId = [userInfo objectForKey:@"portraitId"];
  if (userName.length == 0) {
    userName = [userPhone stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"];
  }
  [userLocalData saveUserName:userName];
  [userLocalData saveUserPhone:userPhone];
  [userLocalData savePhotoId:portraitId];
  [self dismissViewControllerAnimated:YES completion:^{
    if ([self.logindelegate respondsToSelector:@selector(loadHttpRequest)]) {
      [self.logindelegate loadHttpRequest];
    }
  }];
}
-(void)dealloc
{
  [self.taper removeTarget:self action:@selector(tappedView:)];
  [self.view removeGestureRecognizer:self.taper];
  self.taper = nil;
  
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}
- (void)loadHttpRequest
{
  if ([self.logindelegate respondsToSelector:@selector(loadHttpRequest)]) {
    [self.logindelegate loadHttpRequest];
  }
}
-(void)requestFinished:(ASIHTTPRequest*)request
{
  NSLog(@"request finished %@", [request responseString]);
  
  NSString* responseString = [request responseString];
  NSString* rType =[[request userInfo] objectForKey:@"requestType"];
  
  
  if([rType isEqualToString:@"LoginIn"]){
    NSDictionary* info;
    if (responseString ==(id)[NSNull null] || responseString.length ==0 || [responseString isEqualToString:@"internal server error"])
    {
      info =nil;
    }
    else
    {
      info = [iosVersionChecker parseJSONObjectFromData:request.responseData];
      NSLog(@"responseString %@",responseString);
      if (request.responseStatusCode == 200 && [[info objectForKey:@"ok"] boolValue]) {
        NSString *token = [info objectForKey:@"token"];
        [userLocalData saveImdToken:token];
        NSDictionary *userInfo = [iosVersionChecker parseJSONObjectFromJSONString:[info objectForKey:@"userInfo"]];
        [self getUserInfo:userInfo];
        //[self dismissViewControllerAnimated:YES completion:nil];
      }else if (request.responseStatusCode == 200 && [responseString isEqualToString:@"useridOrpassworderr"])
      {
        UIAlertView *alertView2 = [[UIAlertView alloc] initWithTitle:@"帐号或密码错误" message:@"请输入正确帐号和密码。如果忘记密码，请选择“找回密码”。" delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil];
          [alertView2 show];
      }
        // [self testClient];
      
    }
  }
}

-(void)requestFailed:(ASIHTTPRequest*)request
{
  
  NSLog(@"request failed.");
  
  NSError *error = [request error];
  NSLog(@"error %@",error);
  
  NSString* rType =[[request userInfo] objectForKey:@"requestType"];
  
  if([rType isEqualToString:@"LoginIn"]){
    NSLog(@"LoginIn error");
  }
}

-(IBAction)registerNew:(id)sender
{
  RegisterViewController *regVC = [[RegisterViewController alloc] initWithNibName:@"RegisterViewController" bundle:nil];
  [self.navigationController pushViewController:regVC animated:YES];
}

-(IBAction)forgotPassword:(id)sender{
  self.userPassword.text = nil;
  
  FindPWDAccountInfoViewController *viewController = [[FindPWDAccountInfoViewController alloc] init];
  viewController.type = ViewTypeFindPWD;
  viewController.userAccount = self.isInputAccount ? self.userText.text : @"";
  [self.navigationController pushViewController:viewController animated:YES];
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.title = @"登录";
  if ([WXApi isWXAppInstalled]) {
    self.wxButton.hidden = NO;
  }else
    self.wxButton.hidden = YES;
    // Do any additional setup after loading the view from its nib.
  userPassword.secureTextEntry = YES;
  userPassword.delegate = self;
  
    //监听键盘
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
//  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(findUserPasswordShow:) name:@"FindUserPassword" object:nil];
//  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearUserInfoDeal:) name:@"modifyMobileSuccess" object:nil];
  self.taper = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedView:)];
  [self.view addGestureRecognizer:self.taper];
}
#pragma mark - UITapGestureRecognizer
- (void)tappedView:(UITapGestureRecognizer *)TapGesture
{
  [self.userPassword resignFirstResponder];
  [self.userText resignFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  self.navigationController.navigationBar.hidden = YES;
  if (iPhone5) {
    self.scrollView.frame = CGRectMake(0, -20, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
  }
  
  [self.scrollView setContentSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-64)];
}

- (void)viewDidUnload
{
  [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewDidDisappear:(BOOL)animated
{
  [super viewDidDisappear:animated];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
  return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
- (void)keyboardWillShow:(NSNotification *)notification
{
  if (self.scrollView.frame.origin.y  == -20) {
    CGRect f = self.scrollView.frame;
    f.origin.y = f.origin.y-50;
    [UIView animateWithDuration:0.7 animations:^{
      self.scrollView.frame = f;
    } completion:nil];
  }
}
- (void)keyboardWillHide:(NSNotification *)notification
{
  if (self.scrollView.frame.origin.y  < -20) {
    CGRect f = self.scrollView.frame;
    f.origin.y = f.origin.y+50;
    [UIView animateWithDuration:1.0 animations:^{
      self.scrollView.frame = f;
    } completion:nil];
  }
}

#pragma mark - UITextField Delegate
- (void)textFieldDidEndEditing:(UITextField *)textField{
  if (textField == self.userText && self.userText.text && ![self.userText.text isEqualToString:@""]) {
    if (![Strings validEmail:self.userText.text] && ![Strings phoneNumberJudge:self.userText.text]) {
      UIAlertView *alertView3 = [[UIAlertView alloc] initWithTitle:LOGIN_ALERT_TITLE message:REGISTER_EMAIL_FORMAT delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
      [alertView3 setTag:ALERTVIEWTAG3];
      [alertView3 show];
      return;
    }
  }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
  if (textField == userText) {
    [self.userPassword becomeFirstResponder];
  }else if (textField == userPassword){
    [self login:nil];
  }
  
  return YES;
}
//
//- (void)findUserPasswordShow:(NSNotification *)notification{
//  self.userPassword.text = Nil;
//  
//  NSString *account = [notification object];
//  
//  FindPWDAccountInfoViewController *viewController = [[FindPWDAccountInfoViewController alloc] init];
//  viewController.type = ViewTypeFindPWD;
//  viewController.userAccount = account;
//  [self.navigationController pushViewController:viewController animated:YES];
//  [viewController release];
//}
//
//- (void)userLoginInfoDeal:(NSNotification *)notification{
//  NSString *result = [notification object];
//  [self.indicator stopAnimating];
//  
//  if ([result isEqualToString:@"AccountNotExist"]) {
//    UIAlertView *alertView1 = [[UIAlertView alloc] initWithTitle:@"帐号不存在" message:[NSString stringWithFormat:@"未在系统中找到%@帐号，请输入正确帐号或注册新帐号。",self.userText.text] delegate:self cancelButtonTitle:@"注册新帐号" otherButtonTitles:@"重新输入帐号", nil];
//    [alertView1 setTag:ALERTVIEWTAG1];
//    [alertView1 show];
//    
//  }else if ([result isEqualToString:@"WrongPassword"]){
//    UIAlertView *alertView2 = [[UIAlertView alloc] initWithTitle:@"密码错误" message:@"请输入正确密码。忘记密码，请选择“找回密码”。" delegate:self cancelButtonTitle:@"找回密码" otherButtonTitles:@"重新输入密码", nil];
//    [alertView2 setTag:ALERTVIEWTAG2];
//    [alertView2 show];
//  }else {
//    UIAlertView *alertView3 = [[UIAlertView alloc] initWithTitle:@"登录失败" message:@"请输入注册用的手机或邮箱" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//    [alertView3 setTag:ALERTVIEWTAG3];
//    [alertView3 show];
//  }
//}
-(IBAction)wexinLogin:(id)sender
{
  
    //构造SendAuthReq结构体
  SendAuthReq* req =[[SendAuthReq alloc ] init ];
  req.scope = @"snsapi_userinfo" ;
  req.state = @"wechat_sdk_demo" ;
    //第三方向微信终端发送一个SendAuthReq消息结构
  [WXApi sendReq:req];
}
//- (void)clearUserInfoDeal:(NSNotification *)notification{
//  [self.userText setText:nil];
//  [self.userPassword setText:nil];
//}
//
//-(void) userLoginFinished:(BOOL)animated
//{
//  [self.indicator stopAnimating];
//  [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound];
//  if ([self.title isEqualToString:MYFAVORITE_CN]) {
//    imdSearchAppDelegate_iPhone *appDelegate = (imdSearchAppDelegate_iPhone *)[[UIApplication sharedApplication] delegate];
//    appDelegate.myTabBarController.selectedIndex = 1;
//    UINavigationController* favsNav = [appDelegate.myTabBarController.viewControllers objectAtIndex:1];
//    [[favsNav.viewControllers objectAtIndex:0] sync];
//    [[favsNav.viewControllers objectAtIndex:0] refresh];
//  }
//  if ([self.title isEqualToString:SEARCHMGR_CN]){
//    imdSearchAppDelegate_iPhone *appDelegate = (imdSearchAppDelegate_iPhone *)[[UIApplication sharedApplication] delegate];
//    appDelegate.myTabBarController.selectedIndex = 2;
//    
//  }
//  NSMutableArray *mut = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:Alert_Count] ];
//  if ([mut count]) {
//    BOOL isExitName = NO;
//    for (int i = 0; i<[mut count]; i++) {
//      if ([[[mut objectAtIndex:i] objectForKey:SAVED_USER] isEqualToString:[UserManager userName]]) {
//        isExitName = NO;
//        [UIApplication sharedApplication].applicationIconBadgeNumber = [[[mut objectAtIndex:i] objectForKey:Array_ID] count];
//        break;
//      }else {
//        isExitName = YES;
//      }
//    }
//    if (isExitName) {
//      NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
//      [dic setObject:[UserManager userName] forKey:SAVED_USER];
//      NSMutableArray *mut2 = [[NSMutableArray alloc]init];
//      [dic setObject:mut2 forKey:Array_ID];
//      [mut addObject:dic];
//      [[NSUserDefaults standardUserDefaults] setObject:mut forKey:Alert_Count];
//      [[NSUserDefaults standardUserDefaults] synchronize];
//    }
//  }else {
//    NSMutableArray *mut = [[[NSMutableArray alloc]init] autorelease];
//    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
//    [dic setObject:[UserManager userName] forKey:SAVED_USER];
//    NSMutableArray *mut2 = [[[NSMutableArray alloc]init] autorelease];
//    [dic setObject:mut2 forKey:Array_ID];
//    [mut addObject:dic];
//    [[NSUserDefaults standardUserDefaults] setObject:mut forKey:Alert_Count];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//  }
//  self.userPassword.text = nil;
//  NSString *name = [UserManager userName];
//  NSString *fNamne = [[NSUserDefaults standardUserDefaults] objectForKey:name];
//  if (fNamne.length == 0) {
//    [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:name];
//  }
//  
//  [self dismissModalViewControllerAnimated:animated];
//  
//}
//
//-(void) userLoginFailed:(UIViewController *)viewController
//{
//  [self.indicator stopAnimating];
//  
//  self.viewC = viewController;
//}
//
//-(void) requestFailed:(ASIHTTPRequest *)request
//{
//  [self.indicator stopAnimating];
//  
//  UIAlertView* networkAlert = [[UIAlertView alloc] initWithTitle:REQUEST_FAILED_TITLE message:REQUEST_FAILED_MESSAGE delegate:self cancelButtonTitle:REQUEST_FAILED_CANCEL otherButtonTitles:nil];
//  [networkAlert show];
//  [networkAlert release];
//}
//
//- (void)alertView:(UIAlertView *)alertView_ clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//  if ([alertView_.message isEqualToString:@"登录失败请重新登录"]&&buttonIndex == 0) {
//    imdSearchAppDelegate *appDelegate = (imdSearchAppDelegate *)[[UIApplication sharedApplication] delegate];
//    [appDelegate showLoginView:self.viewC title:IMD_CN];
//  }
//  
//  if (alertView_.tag == ALERTVIEWTAG1 && buttonIndex == 0) {
//    
//    [self registerNew:nil];
//    
//  }else if((alertView_.tag == ALERTVIEWTAG1 && buttonIndex == 1) || alertView_.tag == ALERTVIEWTAG3){
//    self.userText.text = nil;
//    self.userPassword.text = nil;
//    [self.userText becomeFirstResponder];
//    
//  }else if (alertView_.tag == ALERTVIEWTAG2 && buttonIndex == 0 ){
//    self.isInputAccount = YES;
//    [self forgotPassword:nil];
//  }else if (alertView_.tag == ALERTVIEWTAG2 && buttonIndex == 1){
//    self.userPassword.text = nil;
//    [self.userPassword becomeFirstResponder];
//  }
//}

@end
