//
//  MenuViewController.m
//  SlideMenu
//
//  Created by Aryan Gh on 4/24/13.
//  Copyright (c) 2013 Aryan Ghassemi. All rights reserved.
//

#import "LeftMenuViewController.h"
#import "SlideNavigationContorllerAnimatorFade.h"
#import "SlideNavigationContorllerAnimatorSlide.h"
#import "SlideNavigationContorllerAnimatorScale.h"
#import "SlideNavigationContorllerAnimatorScaleAndFade.h"
#import "SlideNavigationContorllerAnimatorSlideAndFade.h"
#import "MainViewController_iphone.h"
#import "CateViewController.h"
#import "ProfileViewController.h"

#import "MyButton.h"

#define Left_Width 264
@implementation LeftMenuViewController

#pragma mark - UIViewController Methods -

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self.slideOutAnimationEnabled = YES;
	
	return [super initWithCoder:aDecoder];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
  self.selectNow = 0;
	self.tableView.frame = CGRectMake(0, 100, Left_Width, [UIScreen mainScreen].bounds.size.height-100);
	self.tableView.separatorColor = [UIColor clearColor];
  self.tableView.separatorStyle = NO;
    //UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"menuLeftbg"]];
  
	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"leftBar"]];
	
	self.view.layer.borderWidth = .6;
	self.view.layer.borderColor = [UIColor lightGrayColor].CGColor;
  
    //添加LOGO
  UIImageView *imageLogo = [[UIImageView alloc] initWithFrame:CGRectMake(63, 40, 138, 44)];
  imageLogo.backgroundColor = [UIColor clearColor];
  imageLogo.image = [UIImage imageNamed:@"image-logo"];
  [self.view addSubview:imageLogo];
}

#pragma mark - UITableView Delegate & Datasrouce -
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return 58.0;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 6;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 20)];
	view.backgroundColor = [UIColor clearColor];
	return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"leftMenuCell"];
  cell.selectionStyle = UITableViewCellSelectionStyleNone;
  for(UIView *view in cell.contentView.subviews)
  {
    [view removeFromSuperview];
  }
    //自定义选择按钮
    MyButton *btn = [MyButton buttonWithType:UIButtonTypeCustom];
    btn.backgroundColor = [UIColor clearColor];
    btn.frame = CGRectMake(0, 0, Left_Width, 58.0);
    [btn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    btn.cellIndex = indexPath;
    [cell.contentView addSubview:btn];
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(24, 16, 27, 27)];
    imgView.backgroundColor = [UIColor clearColor];
    imgView.tag = 100;
    [btn addSubview:imgView];
    
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(60, 16 ,200 , 27)];
    lbl.textAlignment = NSTextAlignmentLeft;
    lbl.font = [UIFont systemFontOfSize:15.0];
    lbl.textColor = [UIColor grayColor];
    lbl.tag = 101;
    [btn addSubview:lbl];
  
	switch (indexPath.row)
	{
    case 0:
    {
      lbl.text = @"首页";
      cell.textLabel.text = @"";
      if (self.selectNow == 0) {
        btn.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"image-select-bg"]];
        imgView.image = [UIImage imageNamed:@"image-main-page-select"];
        lbl.textColor = [UIColor whiteColor];
      }else
      {
        imgView.image = [UIImage imageNamed:@"image-main-page-unselect"];
        
      }
			break;
    }
		case 1:
    {
      lbl.text = @"搜索";
      cell.textLabel.text = @"";
      if (self.selectNow == 1) {
        btn.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"image-select-bg"]];
        imgView.image = [UIImage imageNamed:@"leftbar-serach-select"];
        lbl.textColor = [UIColor whiteColor];
      }else
      {
        imgView.image = [UIImage imageNamed:@"leftbar-serach-unselect"];
        
      }
			break;
    }
		case 2:
    {
      lbl.text = @"分类";
      cell.textLabel.text = @"";
      if (self.selectNow == 2) {
        btn.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"image-select-bg"]];
        imgView.image = [UIImage imageNamed:@"image-cater-select"];
        lbl.textColor = [UIColor whiteColor];
      }else
      {
        imgView.image = [UIImage imageNamed:@"image-cater-unselect"];
      }
			break;
    }
    case 3:
    {
      lbl.text = @"个人中心";
      cell.textLabel.text = @"";
      if (self.selectNow == 3) {
        btn.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"image-select-bg"]];
        imgView.image = [UIImage imageNamed:@"image-person-select"];
        lbl.textColor = [UIColor whiteColor];
      }else
      {
        imgView.image = [UIImage imageNamed:@"image-person-unselect"];
      }
			break;
    }
    case 4:
    {
      lbl.text = @"规则帮助";
      cell.textLabel.text = @"";
      if (self.selectNow == 4) {
        btn.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"image-select-bg"]];
        imgView.image = [UIImage imageNamed:@"image-leftbar-help-select"];
        lbl.textColor = [UIColor whiteColor];
      }else
      {
        imgView.image = [UIImage imageNamed:@"image-leftbar-help-unselect"];
      }
			break;
    }
    case 5:
    {
      lbl.text = @"设置";
      cell.textLabel.text = @"";
      if (self.selectNow == 5) {
        btn.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"image-select-bg"]];
        imgView.image = [UIImage imageNamed:@"image-setting-select"];
        lbl.textColor = [UIColor whiteColor];
      }else
      {
        imgView.image = [UIImage imageNamed:@"image-setting-unselect"];
      }
			break;
    }
	}
	
	cell.backgroundColor = [UIColor clearColor];
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}
- (void)buttonClick:(MyButton *)sender
{
  NSLog(@"111111,%@",sender.cellIndex);
  sender.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"image-select-bg"]];
  UILabel *lbl = (UILabel *)[sender viewWithTag:101];
  lbl.textColor = [UIColor whiteColor];
  
  UIImageView *imgView = (UIImageView *)[sender viewWithTag:100];
  imgView.image = [UIImage imageNamed:@"image-main-page-select"];
  
  UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone"
                                                           bundle: nil];
	
	UIViewController *vc ;
  NSArray *arr = [SlideNavigationController sharedInstance].viewControllers;
	switch (sender.cellIndex.row)
	{
		case 2:
			vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"CateViewController"];
			break;
    case 3:
			vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"ProfileViewController"];
			break;
    case 4:
			vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"RuleHelpViewController"];
			break;
    case 5:
			vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"SettingViewController"];
			break;
	}
//	if (sender.cellIndex.row == 1) {
//    if (arr.count == 2) {
//      UIViewController *uvc = [arr objectAtIndex:1];
//      if ([uvc isKindOfClass:MainViewController_iphone.class]) {
//        MainViewController_iphone *vac = (MainViewController_iphone *)uvc;
//        [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:uvc
//                                                                 withSlideOutAnimation:self.slideOutAnimationEnabled
//                                                                         andCompletion:^{
//                                                                           [vac showSearch];
//                                                                         }];
//      }else
//      {
//        [[SlideNavigationController sharedInstance] popToRootViewControllerAnimated:NO];
//        MainViewController_iphone *vac = [arr objectAtIndex:0];
//        [vac showSearch];
//      }
//    }else
//    {
//      [[SlideNavigationController sharedInstance] popToRootViewControllerAnimated:NO];
//       MainViewController_iphone *vac = [arr objectAtIndex:0];
//      [vac showSearch];
//    }
//  }else
//  {
    if (sender.cellIndex.row == 0) {
      if (arr.count > 1) {
        for (ProfileViewController *pvc in arr) {
          if ([pvc isKindOfClass:[ProfileViewController class]]) {
            [pvc clearRequest];
          }
        }
      }
    }else if(sender.cellIndex.row == 3)
    {
      for (MainViewController_iphone *mvc in arr) {
        if ([mvc isKindOfClass:[MainViewController_iphone class]]) {
          [mvc clearRequest];
        }
      }
    }

  [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:vc
                                                           withSlideOutAnimation:self.slideOutAnimationEnabled
                                                                   andCompletion:^{
                                                                     MainViewController_iphone *vac = [arr objectAtIndex:0];
                                                                     if (sender.cellIndex.row != 1) {
                                                                       
                                                                       if (sender.cellIndex.row == 0) {
                                                                         vac.clean = nil;
                                                                         [vac hiddenSearch];
                                                                         [vac refreshButtonClicked];
                                                                       }else
                                                                       {
                                                                         [vac hiddenSearch];
                                                                       }
                                                                     }else
                                                                     {
                                                                       [vac showSearch];
                                                                       if (vac.clean.length > 0) {
                                                                         [vac refreshButtonClicked];
                                                                       }
                                                                     }
                                                                   }];
    //}
  self.selectNow = sender.cellIndex.row;
  [self.tableView reloadData];
}
@end
