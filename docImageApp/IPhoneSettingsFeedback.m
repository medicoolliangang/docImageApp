//
//  IPhoneSettingsFeedback.m
//  imdSearch
//
//  Created by Huajie Wu on 12-1-10.
//  Copyright (c) 2012年 i-md.com. All rights reserved.
//

#import "IPhoneSettingsFeedback.h"
#import "imdRequest.h"
#import "UrlCenter.h"
#import "Strings.h"

@implementation IPhoneSettingsFeedback
@synthesize scrollView, contactField, feedbackTextV, showPlaceHolderInTextView;
@synthesize alertView = _alertView;

@synthesize httpRequest = _httpRequest;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"反馈建议";
        _alertView = [[UIAlertView alloc] initWithTitle:RUIYI_TITLE message:@"" delegate:self cancelButtonTitle:ALERT_CONFIRM otherButtonTitles:nil];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void) dealloc
{
    if (_httpRequest != nil) {
        [_httpRequest clearDelegatesAndCancel];
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
  UIBarButtonItem *aButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"发送" style:UIBarButtonItemStyleBordered target:self action:@selector(postFeedback:)];
  self.navigationItem.rightBarButtonItem =aButtonItem;
    [self setPlaceHolder];
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width, 300)];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - post action.

- (void) popBack:(id) sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) setPlaceHolder
{
    self.feedbackTextV.text = FEEDBACK_PLACEHOLDER;
    self.feedbackTextV.textColor = [UIColor lightGrayColor];
    self.showPlaceHolderInTextView = YES;
}

- (void) postFeedback:(id) sender
{
    if (!feedbackTextV.hasText || [feedbackTextV.text isEqualToString:FEEDBACK_PLACEHOLDER]) {
        feedbackTextV.text = @"";
        [feedbackTextV becomeFirstResponder];
        return;
    }
    
    NSMutableDictionary* data = [[NSMutableDictionary alloc] init];
  if (contactField.text.length > 0) {
    [data setObject:[NSString stringWithFormat:@"%@",contactField.text] forKey:@"emailOrPhone"];
  }else
  [data setObject:@"" forKey:@"emailOrPhone"];
  if (feedbackTextV.text.length > 0) {
    [data setObject:[NSString stringWithFormat:@"%@",feedbackTextV.text] forKey:@"content"];
  }
  NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
  NSString* locationVersion = [infoDict objectForKey:@"CFBundleVersion"];
  [data setObject:[NSString stringWithFormat:@"iPhone-%@,Source:imdpicshow",locationVersion] forKey:@"userAgent"];

  [imdRequest postRequest:[UrlCenter urlOfType:FEEDBACKEMAIL] delegate:self requestType:@"FEEDBACKEMAIL" postData:data json:NO];
}

#pragma mark - Textfield
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //    [self postFeedback:nil];
    [self.feedbackTextV becomeFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    //[self.scrollView setContentOffset:CGPointMake(0, 60) animated:YES];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if (showPlaceHolderInTextView) {
        feedbackTextV.textColor = [UIColor blackColor];
        feedbackTextV.text = @"";
        showPlaceHolderInTextView = NO;
    }
    
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if (feedbackTextV.text.length == 0)
        [self setPlaceHolder];
}

#pragma mark Asy Request

-(void)requestFinished:(ASIHTTPRequest *)request
{
    NSLog(@"%@", [request responseString]);
    [self.alertView setTitle:SETTINGS_FEEDBACK];
    [self.alertView setMessage:FEEDBACK_SUBMIT_MESSAGE];
    
    [self.alertView show];
}

-(void)requestFailed:(ASIHTTPRequest *)request
{
    NSLog(@"%@", [request responseString]);
    [self.alertView show];
}

#pragma mark
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //Do the logout.
    if (buttonIndex == 0 && [alertView.message isEqualToString:FEEDBACK_SUBMIT_MESSAGE]) {
        [self popBack:nil];
    }
}

@end
