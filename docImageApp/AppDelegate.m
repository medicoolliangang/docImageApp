//
//  AppDelegate.m
//  docImageApp
//
//  Created by 侯建政 on 8/5/14.
//  Copyright (c) 2014 jianzheng. All rights reserved.
//

#import "AppDelegate.h"
#import "SlideNavigationContorllerAnimatorScaleAndFade.h"
#import "WXApiObject.h"
#import "imdRequest.h"
#import "UrlCenter.h"
#import "iosVersionChecker.h"
#import "RegisterViewController.h"
#import "userLocalData.h"
#import "LoginViewController_iphone.h"
#import "Strings.h"

#import <ShareSDK/ShareSDK.h>
#import "WeiboApi.h"
#import <TencentOpenAPI/QQApi.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/TencentOAuth.h>
#define WEIXIN_APPID @"wx64ec26e28b8d2e91"
#define WEIXIN_APPSECRET @"22326d12abdc91119844a82ff741e08f"
@implementation AppDelegate
@synthesize mainVC;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  [NSThread sleepForTimeInterval:2.0];
  
  UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle: nil];
	
	LeftMenuViewController *leftMenu = (LeftMenuViewController*)[mainStoryboard instantiateViewControllerWithIdentifier: @"LeftMenuViewController"];
  
  [SlideNavigationController sharedInstance].leftMenu = leftMenu;
  [SlideNavigationController sharedInstance].menuRevealAnimator = [[SlideNavigationContorllerAnimatorScaleAndFade alloc] initWithMaximumFadeAlpha:.8 fadeColor:[UIColor blackColor] andMinimumScale:.8];
  [SlideNavigationController sharedInstance].portraitSlideOffset = [UIScreen mainScreen].bounds.size.width - 264.0;
  [SlideNavigationController sharedInstance].rightMenu.view.hidden = YES;
  
  NSDictionary * dict= [NSDictionary dictionaryWithObjectsAndKeys:NavigationColor,UITextAttributeTextColor,[UIFont systemFontOfSize:17],UITextAttributeFont, nil];
  [SlideNavigationController sharedInstance].navigationBar.titleTextAttributes = dict;
  
  UIButton *button  = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
	[button setImage:[UIImage imageNamed:@"image-menu"] forState:UIControlStateNormal];
	[button addTarget:[SlideNavigationController sharedInstance] action:@selector(toggleLeftMenu) forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
	[SlideNavigationController sharedInstance].leftBarButtonItem = leftBarButtonItem;
    // Override point for customization after application launch.
  
  NSArray *arrVC = [SlideNavigationController sharedInstance].viewControllers;
  mainVC = [arrVC objectAtIndex:0];
  [mainVC checkVersion];
//    //向微信注册
    //  [WXApi registerApp:WEIXIN_APPID withDescription:@"demo 2.0"];
  
  [[UIApplication sharedApplication] cancelAllLocalNotifications];
  
  /**
   注册SDK应用，此应用请到http://www.sharesdk.cn中进行注册申请。
   此方法必须在启动时调用，否则会限制SDK的使用。
   **/
  [ShareSDK registerApp:@"47f0c721c1d6"];
  [self initializePlat];
    //[self performSelector:@selector(testLog) withObject:nil afterDelay:3];
    return YES;
}
-(void)onResp:(SendAuthResp *)resp
{
  NSString *urlpath;
  @try {
    urlpath = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code",WEIXIN_APPID,WEIXIN_APPSECRET,resp.code];
  }
  @catch (NSException *exception) {
    NSLog(@"exception");
    return;
  }
  @finally {
    if (urlpath.length > 0) {
       [imdRequest getRequest:urlpath delegate:self requestType:@"get_access_token"];
    }
  }
}
-(void)getUserFromWeiXin:(NSString *)urlpath
{
  [imdRequest getRequest:urlpath delegate:self requestType:@"get_info"];
}
-(void) onReq:(BaseReq*)req
{
  NSLog(@".....%d",req.type);
}
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
  NSArray *array = [[url absoluteString] componentsSeparatedByString:@":"];
  if (array.count > 0) {
    if ([[array objectAtIndex:0] isEqualToString:WEIXIN_APPID]) {
        //登录
      return  [WXApi handleOpenURL:url delegate:self];
    }

  }
    //分享
  return [ShareSDK handleOpenURL:url
                      wxDelegate:self];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
  NSArray *array = [[url absoluteString] componentsSeparatedByString:@":"];
  if (array.count >= 2) {
    if ([[array objectAtIndex:0] isEqualToString:WEIXIN_APPID]) {
      if ([[array objectAtIndex:1] isEqualToString:@"//platformId=wechat"]) {
          //分享
        return [ShareSDK handleOpenURL:url
                     sourceApplication:sourceApplication
                            annotation:annotation
                            wxDelegate:self];
      }else
      {
        //登录
      BOOL isSuc = [WXApi handleOpenURL:url delegate:self];
      NSLog(@"url %@ isSuc %d",url,isSuc == YES ? 1 : 0);
      
      return  isSuc;
      }
    }
    
  }
    //分享
  return [ShareSDK handleOpenURL:url
               sourceApplication:sourceApplication
                      annotation:annotation
                      wxDelegate:self];
}
- (void)requestFinished:(ASIHTTPRequest *)request{
  NSString* responseString = [request responseString];
  NSLog(@"xxxx%@",responseString);
  NSString* rType =[[request userInfo] objectForKey:@"requestType"];
  if ([rType isEqualToString:@"get_access_token"])
  {
    NSDictionary *info;
    if (responseString ==(id)[NSNull null] || responseString.length ==0 || [responseString isEqualToString:@"internal server error"])
    {
      info =nil;
    }
    else
    {
      info = [iosVersionChecker parseJSONObjectFromJSONString:responseString];
      NSString *token = [info objectForKey:@"access_token"];
      NSString *urlpath = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/userinfo?access_token=%@&openid=%@",token,WEIXIN_APPID];
      [self getUserFromWeiXin:urlpath];
    }
  }else if ([rType isEqualToString:@"get_info"])
  {
    NSDictionary *info;
    if (responseString ==(id)[NSNull null] || responseString.length ==0 || [responseString isEqualToString:@"internal server error"])
    {
      info =nil;
    }
    else
    {
      info = [iosVersionChecker parseJSONObjectFromData:request.responseData];
      [imdRequest postRequest:[UrlCenter urlOfType:WEIXIN_POSTDATA] delegate:self requestType:@"POSTDATA" postData:[NSMutableDictionary dictionaryWithDictionary:info] json:YES];
//      RegisterViewController *regVC = [[RegisterViewController alloc] initWithNibName:@"RegisterViewController" bundle:nil];
//      [mainVC.loginNav pushViewController:regVC animated:YES];
    }
  }else if ([rType isEqualToString:@"POSTDATA"])
  {
    NSDictionary *info;
    if (responseString ==(id)[NSNull null] || responseString.length ==0 || [responseString isEqualToString:@"internal server error"])
    {
      info =nil;
    }
    else
    {
      info = [iosVersionChecker parseJSONObjectFromData:request.responseData];
      if ([[info objectForKey:@"ok"] boolValue]) {
          //已绑定微信直接登录成功
        NSString *imdToken = [info objectForKey:@"token"];
        if (imdToken.length > 0) {
          [userLocalData saveImdToken:imdToken];
          LoginViewController_iphone *loginVC = [[mainVC.loginNav viewControllers] objectAtIndex:0];
          [loginVC getUserInfo:[iosVersionChecker parseJSONObjectFromJSONString:[info objectForKey:@"userInfo"]]];
        }
      }else
      {
        activation_ViewController *actVC = [[activation_ViewController alloc] initWithNibName:@"activation_ViewController" bundle:nil];
        actVC.openid = [info objectForKey:@"openid"];
        actVC.unionid = [info objectForKey:@"unionid"];
        actVC.activedelegate = mainVC;
        [mainVC.loginNav pushViewController:actVC animated:YES];
      }
    }
  }
}
-(void)requestFailed:(ASIHTTPRequest*)request
{
  
  NSLog(@"request failed.");
  
  NSError *error = [request error];
  NSLog(@"error %@",error);
}
- (void)applicationWillResignActive:(UIApplication *)application
{
  // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
  // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
  // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
  // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
  // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
  // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
  // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
- (void)initializePlat
{
  /***
   连接新浪微博开放平台应用以使用相关功能，此应用需要引用SinaWeiboConnection.framework
   http://open.weibo.com上注册新浪微博开放平台应用，并将相关信息填写到以下字段
   **/
  [ShareSDK connectSinaWeiboWithAppKey:@"4069024032"
                             appSecret:@"c6716d8d1579144bf65ef66ea187e237"
                           redirectUri:@"http://www.i-md.com"];
  /**
   连接腾讯微博开放平台应用以使用相关功能，此应用需要引用TencentWeiboConnection.framework
   http://dev.t.qq.com上注册腾讯微博开放平台应用，并将相关信息填写到以下字段
   
   如果需要实现SSO，需要导入libWeiboSDK.a，并引入WBApi.h，将WBApi类型传入接口
   **/
  [ShareSDK connectTencentWeiboWithAppKey:@"801463158"
                                appSecret:@"f317814194abcbde52cfd44c81b50985"
                              redirectUri:@"http://www.i-md.com"
                                 wbApiCls:[WeiboApi class]];
  
    //连接短信分享
  [ShareSDK connectSMS];
  
  
  /**
   连接QQ空间应用以使用相关功能，此应用需要引用QZoneConnection.framework
   http://connect.qq.com/intro/login/上申请加入QQ登录，并将相关信息填写到以下字段
   
   如果需要实现SSO，需要导入TencentOpenAPI.framework,并引入QQApiInterface.h和TencentOAuth.h，将QQApiInterface和TencentOAuth的类型传入接口
   **/
  [ShareSDK connectQZoneWithAppKey:@"1103561133"
                         appSecret:@"CoAZJK87IOzWxfZv"
                 qqApiInterfaceCls:[QQApiInterface class]
                   tencentOAuthCls:[TencentOAuth class]];
  
  /**
   连接QQ应用以使用相关功能，此应用需要引用QQConnection.framework和QQApi.framework库
   http://mobile.qq.com/api/上注册应用，并将相关信息填写到以下字段
   **/
    //旧版中申请的AppId（如：QQxxxxxx类型），可以通过下面方法进行初始化
    //    [ShareSDK connectQQWithAppId:@"QQ075BCD15" qqApiCls:[QQApi class]];
  
  [ShareSDK connectQQWithQZoneAppKey:@"1103561133"
                   qqApiInterfaceCls:[QQApiInterface class]
                     tencentOAuthCls:[TencentOAuth class]];
  
  /**
   连接微信应用以使用相关功能，此应用需要引用WeChatConnection.framework和微信官方SDK
   http://open.weixin.qq.com上注册应用，并将相关信息填写以下字段
   **/
  [ShareSDK connectWeChatWithAppId:WEIXIN_APPID wechatCls:[WXApi class]];
  
    //连接邮件
  [ShareSDK connectMail];
  
    //连接拷贝
  [ShareSDK connectCopy];
}

@end
