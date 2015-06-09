//
//  helpViewController.m
//  docImageApp
//
//  Created by 侯建政 on 11/17/14.
//  Copyright (c) 2014 jianzheng. All rights reserved.
//

#import "helpViewController.h"

@interface helpViewController ()

@end

@implementation helpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  self.title = @"使用帮助";
  self.view.backgroundColor = [UIColor colorWithRed:239.0/255.0 green:239.0/255.0 blue:244.0/255.0 alpha:1.0];
  UIScrollView *scrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
  scrollview.scrollEnabled = YES;
  scrollview.contentSize = CGSizeMake(320, 1186);
  UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 1186)];
  imageview.image = [UIImage imageNamed:@"07_1"];
  [scrollview addSubview:imageview];
  [self.view addSubview:scrollview];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
