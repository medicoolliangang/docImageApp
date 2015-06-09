//
//  RuleHelpViewController.m
//  docImageApp
//
//  Created by 侯建政 on 11/17/14.
//  Copyright (c) 2014 jianzheng. All rights reserved.
//

#import "RuleHelpViewController.h"
#import "IPhoneSettingsText.h"
#import "Strings.h"
#import "helpViewController.h"

@interface RuleHelpViewController () <UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation RuleHelpViewController

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
  self.title = @"规则和帮助";
  self.view.backgroundColor = [UIColor colorWithRed:239.0/255.0 green:239.0/255.0 blue:244.0/255.0 alpha:1.0];
  
  UIImageView *imageHead = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width-158)/2, 102, 158, 40)];
  imageHead.image = [UIImage imageNamed:@"03_1"];
  imageHead.backgroundColor = [UIColor clearColor];
  [self.view addSubview:imageHead];
  
  self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,180,self.view.frame.size.width,120) style:UITableViewStylePlain];
  self.tableView.dataSource = self;
  self.tableView.delegate = self;
  self.tableView.bounces = NO;
  self.tableView.backgroundColor = [UIColor clearColor];
  self.tableView.contentSize = CGSizeMake(self.view.frame.size.width, 100);
  [self.view addSubview:self.tableView];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
#pragma mark - Table View Datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return 2;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 50.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  NSString *cellReuseIdentifier   = @"SectionTwoCell";
  
  UITableViewCell *cell = nil;
  cell.opaque = NO;
  cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier];
  if (!cell) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifier];
    cell.contentView.backgroundColor = [UIColor clearColor];
    }
  if (indexPath.row == 0) {
    cell.textLabel.text = @"有关规则";
  }else
    cell.textLabel.text = @"使用帮助";
  cell.textLabel.textColor = [UIColor darkGrayColor];
  cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  if (indexPath.row == 0) {
    IPhoneSettingsText* rule = [[IPhoneSettingsText alloc] init];
    rule.type = SETTINGS_RULE;
    [self.navigationController pushViewController:rule animated:YES];
  }else if (indexPath.row == 1)
  {
    helpViewController *helpVC = [[helpViewController alloc] init];
    [self.navigationController pushViewController:helpVC animated:YES];
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
