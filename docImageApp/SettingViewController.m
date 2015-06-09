//
//  SettingViewController.m
//  docImageApp
//
//  Created by 侯建政 on 10/16/14.
//  Copyright (c) 2014 jianzheng. All rights reserved.
//

#import "SettingViewController.h"
#import "Strings.h"
#import "userLocalData.h"
#import "LoginViewController_iphone.h"
#import "MainViewController_iphone.h"
#import "LeftMenuViewController.h"
#import "IPhoneSettingsFeedback.h"
#import "IPhoneSettingsText.h"
#import "otherAppViewController.h"
#import "UrlCenter.h"

@interface SettingViewController ()<UIActionSheetDelegate>
@property (nonatomic, strong) IBOutlet UITableView *setTableView;
@property (nonatomic, strong) UIActionSheet *exitOut;
@property (nonatomic, assign) BOOL isUpdate;
@end

@implementation SettingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
#pragma mark - SlideNavigationController Methods -

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
	return YES;
}

- (BOOL)slideNavigationControllerShouldDisplayRightMenu
{
	return NO;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"设置";
  
//  UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 120)];
//  UIImageView *logoImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ruiyituzhi"]];
//  logoImg.center = footerView.center;
//  [footerView addSubview:logoImg];
//  self.setTableView.tableFooterView = footerView;
      // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
  return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  switch (section) {
    case 0:
      return 1;
      break;
    case 1:
      return 2;
      break;
    case 2:
      return 2;
      break;
    case 3:
      return 2;
      break;
    case 4:
      return 1;
      break;
    default:
      break;
  }

  return 1;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
  if (section == 0) {
    return @"系统设置";
  }
  return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"suggestItem"];
    cell.backgroundColor = [UIColor whiteColor];
    if (cell == nil) {
      cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"suggestItem"];
    }
  switch (indexPath.section) {
    case 0:
    {
      NSString* support = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/imageFile"];
      NSLog(@"%f",[Strings folderSizeAtPath:support]);
        cell.textLabel.text = [NSString stringWithFormat:@"清除缓存                       %.2f MB",[Strings folderSizeAtPath:support]];
      break;
    }
    case 1:
      if (indexPath.row == 0) {
        cell.textLabel.text = @"建议反馈";
        
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 33, 11, 22, 22)];
        imgView.image = [UIImage imageNamed:@"setting-feedback"];
        [cell.contentView addSubview:imgView];
      }else
      cell.textLabel.text = @"去App Store评分";
      break;
    case 2:
      if (indexPath.row == 0) {
        cell.textLabel.text = @"关于睿医";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
      }else if(indexPath.row == 1)
      {
        cell.textLabel.text = @"免责声明";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
      }
      break;
    case 3:
      if(indexPath.row == 0)
      {
        cell.textLabel.text = @"诚邀体验睿医其它产品";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
      }else
      {
          NSString *version =  [[NSBundle mainBundle].infoDictionary objectForKey:@"CFBundleVersion"];
        NSArray *arr = [SlideNavigationController sharedInstance].viewControllers;
        MainViewController_iphone *vc = [arr objectAtIndex:0];
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
        cell.textLabel.font = [UIFont systemFontOfSize:15.0];
        if ([app_Version compare:vc.serverVersion options:NSNumericSearch]!=NSOrderedAscending) {
          self.isUpdate = NO;
          if (MEETING_URL_ISDEV) {
            cell.textLabel.text = [NSString stringWithFormat:@"版本号 %@",version];
          }else
            cell.textLabel.text = [NSString stringWithFormat:@"QA版本号 %@",version];
        }else
        {
          self.isUpdate = YES;
          if (MEETING_URL_ISDEV) {
            cell.textLabel.text = [NSString stringWithFormat:@"版本号 %@ 点击可更新至 %@",version,vc.serverVersion];
          }else
            cell.textLabel.text = [NSString stringWithFormat:@"QA版本号 %@ 点击可更新至 %@",version,vc.serverVersion];
        }
        
      }
      break;
    case 4:
    {
      cell.textLabel.text = LOGOUT_CONFIRM;
      cell.textLabel.textAlignment = NSTextAlignmentCenter;
      
      UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 33, 9, 21, 23)];
      imgView.image = [UIImage imageNamed:@"seting-open"];
      [cell.contentView addSubview:imgView];
      break;
    }
    default:
      break;
  }
    cell.textLabel.textColor = APPDefaultColor;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.numberOfLines = 1;
    cell.textLabel.opaque = NO;
    cell.textLabel.backgroundColor = [UIColor clearColor];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  switch (indexPath.section) {
    case 1:
    {
      if (indexPath.row == 0) {
        IPhoneSettingsFeedback *feedVC = [[IPhoneSettingsFeedback alloc] init];
        [self.navigationController pushViewController:feedVC animated:YES];
      }else if (indexPath.row == 1)
      {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:RUIYITUZHI_RATE]];
      }
      break;
    }
    case 0:
    {
      [self showAlertViewWithTitle:RUIYI_TITLE andMessage:@"确定清除缓存吗？"];
      break;
    }
    case 2:
    {
      if (indexPath.row == 0) {
        IPhoneSettingsText* aboutUs = [[IPhoneSettingsText alloc] init];
        aboutUs.type = SETTINGS_ABOUTUS;
        [self.navigationController pushViewController:aboutUs animated:YES];
      }else if(indexPath.row == 1)
      {
        IPhoneSettingsText* agreement = [[IPhoneSettingsText alloc]init];
        agreement.type = SETTINGS_AGREEMENT;
        [self.navigationController pushViewController:agreement animated:YES];
      }
      break;
    }
      case 3:
    {
      if (indexPath.row == 0) {
        otherAppViewController *otherVC = [[otherAppViewController alloc] init];
        [self.navigationController pushViewController:otherVC animated:YES];
      }else if(indexPath.row == 1 && self.isUpdate)
      {
        NSArray *arr = [SlideNavigationController sharedInstance].viewControllers;
        MainViewController_iphone *vc = [arr objectAtIndex:0];
          UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:RUIYI_TITLE message:vc.updateMessage delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"前往更新", nil];
          alertView.tag = 100;
          [alertView show];
      }
    break;
    }
    case 4:
    {
      self.exitOut = [[UIActionSheet alloc]initWithTitle:LOGOUT_WARN delegate:self cancelButtonTitle:TEXT_CANCEL destructiveButtonTitle:LOGOUT_CONFIRM otherButtonTitles: nil];
      [self.exitOut showInView:self.view];
      break;
    }
    default:
      break;
  }
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
  if (buttonIndex == 0) {
    [userLocalData saveImdToken:@""];
    [userLocalData saveUserName:@""];
    [userLocalData saveUserPhone:@""];
    [userLocalData savePhotoId:@""];
    [userLocalData savePhotoFilePath:@""];
    [self checkToken];
//    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone"
//                                                             bundle: nil];
//    MainViewController_iphone *vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"MainViewController_iphone"];
//    [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:vc
//                                                             withSlideOutAnimation:NO
//                                                                     andCompletion:^{
//                                                                     }];
//    
//    LeftMenuViewController *leftVC = (LeftMenuViewController *)[SlideNavigationController sharedInstance].leftMenu;
//    leftVC.selectNow = 0;
//    [leftVC.tableView reloadData];
    
    
  }
}
- (void)checkToken
{
    NSArray *arr = [SlideNavigationController sharedInstance].viewControllers;
    MainViewController_iphone *vc = [arr objectAtIndex:0];
  if (vc.loginNav) {
    [self presentViewController:vc.loginNav animated:YES completion:nil];
  }
}
- (void)showAlertViewWithTitle:(NSString *)title andMessage:(NSString *)message{
  UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
  alertView.tag = 1000;
  [alertView show];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
  NSArray *arr = [SlideNavigationController sharedInstance].viewControllers;
  MainViewController_iphone *vc = [arr objectAtIndex:0];
  if (alertView.tag == 1000 && buttonIndex == 1) {
    [Strings clearCache];
     vc.clean = @"clean";
    [self.setTableView reloadData];
  }else if (alertView.tag == 100 && buttonIndex == 1) {
      [[UIApplication sharedApplication] openURL:[NSURL URLWithString:RUIYITUZHI_APPURL]];
  }
}


@end
