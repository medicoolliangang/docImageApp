//
//  EmailActiveViewController.m
//  imdSearch
//
//  Created by xiangzhang on 9/26/13.
//  Copyright (c) 2013 i-md.com. All rights reserved.
//

#import "EmailActiveViewController.h"
#import "Strings.h"
#import "imdRequest.h"
#import "UrlCenter.h"
#import "iosVersionChecker.h"

#define REQUESTTAG1     @"1"
#define REQUESTTAG2     @"2"

@interface EmailActiveViewController (){
    ASIHTTPRequest *request;
}

@end

@implementation EmailActiveViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.navigationItem.title = @"激活邮箱";
        self.isActive = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if (![self.originEmailInfo isEqualToString:@""]) {
        self.emailInfo.text = self.originEmailInfo;
    }
    
    [self.sendActiveEmailBtn setBackgroundImage:[[UIImage imageNamed:@"btn-save"] stretchableImageWithLeftCapWidth:30 topCapHeight:15] forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
}

- (void)viewDidUnload {
    [self setTextBgImg:nil];
    [self setEmailInfo:nil];
    [self setSendActiveEmailBtn:nil];
    [super viewDidUnload];
}

#pragma mark - 
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    
    return YES;
}

- (IBAction)dismissView:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)sendActiveEmail:(id)sender {
    if (![self isValidateEmail:self.emailInfo.text]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"您输入的电子邮箱错误，请输入正确的电子邮箱。" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        
        return;
    }
    
    if ([self.originEmailInfo isEqualToString:self.emailInfo.text] && self.isActive) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"您输入的邮箱已被使用，请输入新的邮箱。" delegate:self cancelButtonTitle:@"输入新邮箱" otherButtonTitles:@"取消", nil];
        alertView.tag = 2014052906;
        [alertView show];
        
        return;
    }
    
    
#define CHECK_TYPE @"checktype"
#define CHECK_EMAL @"checkemail"
    request = [imdRequest getRequest:[NSString stringWithFormat:@"%@/%@",[UrlCenter urlOfType:CHECKEMAIL_URL],self.emailInfo.text] delegate:self requestType:CHECK_EMAL];
    request.didFinishSelector = @selector(checkEmailRequestFinish:);
}


#pragma mark - ASIHTTPRequest Delegate
- (void)checkEmailRequestFinish:(ASIHTTPRequest *)request_{
    BOOL checkemail = [[request responseString] boolValue];
    BOOL isOriginEmail = [self.originEmailInfo isEqualToString:self.emailInfo.text];
    if (checkemail || isOriginEmail) {
        if (isOriginEmail) {
          [imdRequest postSearch:[UrlCenter urlOfType:Email_VerifyCode] delegate:self requestType:REQUESTTAG1 postData:self.emailInfo.text];
        }else{
          NSDictionary *postDic = @{@"email":self.emailInfo.text};
          [imdRequest postRequest:[UrlCenter urlOfType:UpdateEmail] delegate:self requestType:REQUESTTAG2 postData:[NSMutableDictionary dictionaryWithDictionary:postDic] json:YES];
        }
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"您输入的帐号已存在，请输入正确的邮箱。" delegate:self cancelButtonTitle:@"重新输入" otherButtonTitles:@"取消", nil];
        alertView.tag = 20131111;
        [alertView show];
    }
}

- (void)requestFinished:(ASIHTTPRequest *)request_{
    NSString *responseStr = [request_ responseString];
    BOOL success = FALSE;
    NSString* rType =[[request userInfo] objectForKey:REQUEST_TYPE];
    if ([rType isEqualToString:REQUESTTAG1]) {
        NSDictionary *jsonDic =[iosVersionChecker parseJSONObjectFromJSONString:responseStr];
         success =[[jsonDic objectForKey:@"validEmailOrMobile"] boolValue];
        
    }else if([rType isEqualToString:REQUESTTAG2]){
        success = [responseStr isEqualToString:@"true"];
    }
    
    if (success) {
        [self showAlertViewWithTitle:@"激活邮件已发送" message: [NSString stringWithFormat:@"请尽快登录%@查收邮件，完成邮箱激活。",self.emailInfo.text] withTag:(int)request_.tag];
    }else{
        [self showAlertViewWithTitle:@"" message:@"激活邮件发送失败，请重试！" withTag:0];
    }
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 20131111){
        if (buttonIndex == 0) {
            self.emailInfo.text = nil;
            [self.emailInfo becomeFirstResponder];
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
        return;
    }else if (alertView.tag == 2014052906 && buttonIndex == 0){
        self.emailInfo.text = nil;
        [self.emailInfo becomeFirstResponder];
    }else if(buttonIndex == 0 && alertView.tag != 0){
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)requestFailed:(ASIHTTPRequest *)requests{
  if ([requests.error code] == ASIRequestTimedOutErrorType) {
    [self showAlertViewWithTitle:RUIYI_TITLE message:REQUEST_TIMEOUT_MESSAGE withTag:0];
  }else
    [self showAlertViewWithTitle:@"睿医" message:@"网络出错-­‐请检查网络设置" withTag:0];
}

-(BOOL)isValidateEmail:(NSString *)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

- (void)showAlertViewWithTitle:(NSString *)title message:(NSString *)message withTag:(int)tag{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    alertView.tag = tag;
    [alertView show];
}
@end
