//
//  otherAppViewController.m
//  docImageApp
//
//  Created by 侯建政 on 11/17/14.
//  Copyright (c) 2014 jianzheng. All rights reserved.
//

#import "otherAppViewController.h"
#import "Strings.h"

@interface otherAppViewController ()
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation otherAppViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
  self.title = @"睿医其它产品";
  self.view.backgroundColor = [UIColor colorWithRed:239.0/255.0 green:239.0/255.0 blue:244.0/255.0 alpha:1.0];
  self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height) style:UITableViewStyleGrouped];
  self.tableView.dataSource = self;
  self.tableView.delegate = self;
  self.tableView.backgroundColor = [UIColor clearColor];
  
//  UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, self.view.frame.size.width, 30)];
//  lbl.text = @"睿医产品";
//  lbl.textAlignment = NSTextAlignmentCenter;
//  lbl.backgroundColor = [UIColor clearColor];
//  self.tableView.tableHeaderView = lbl;
  [self.view addSubview:self.tableView];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Table View Datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return 2;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 60.0;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
  if (section == 0) {
    return @"热门App";
  }else
    return @"在线培训教育类";
  return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  NSString *cellReuseIdentifier   = @"SectionTwoCell";
  
  UITableViewCell *cell = nil;
  cell.opaque = NO;
  cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier];
  if (!cell) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellReuseIdentifier];
    cell.contentView.backgroundColor = [UIColor clearColor];
  }
  if (indexPath.section == 0) {
    if (indexPath.row == 0) {
      cell.imageView.image = [UIImage imageNamed:@"icon50"];
      cell.textLabel.text = @"睿医文献";
      cell.detailTextLabel.text = @"睿医文献是一款同时提供免费中英文医学文献服务的应用";
    }else
    {
      cell.imageView.image = [UIImage imageNamed:@"icon-small-50"];
      cell.textLabel.text = @"睿医资讯";
      cell.detailTextLabel.text = @"免费为中国广大专业医师提供专业、便捷的一站式医学资讯服务";
    }
  }else if (indexPath.section == 1)
  {
    if (indexPath.row == 0) {
      cell.imageView.image = [UIImage imageNamed:@"tiantan"];
      cell.textLabel.text = @"天坛卒中学院";
      cell.detailTextLabel.text = @"快速提升中国卒中规范化诊疗水平，改善患者生活，及其家人的生活";
    }else
    {
      cell.imageView.image = [UIImage imageNamed:@"huopu"];
      cell.textLabel.text = @"霍普金斯疾病学习中心";
      cell.detailTextLabel.text = @"提供糖尿病课程和感染最新相关课程，以提升医者的职业素养和相关技能";
    }
  }
 
  cell.textLabel.textColor = [UIColor darkGrayColor];
  cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  if (indexPath.section == 0) {
    if (indexPath.row == 0) {
      [[UIApplication sharedApplication] openURL:[NSURL URLWithString:APP_RUIYIWENXIAN]];
    }else
    {
      [[UIApplication sharedApplication] openURL:[NSURL URLWithString:APP_RUIYIZIXUN]];
    }
  }else
  {
    if (indexPath.row == 0) {
      [[UIApplication sharedApplication] openURL:[NSURL URLWithString:WEB_TIANTAN]];
    }else
    {
      [[UIApplication sharedApplication] openURL:[NSURL URLWithString:WEB_HUOPU]];
    }
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
