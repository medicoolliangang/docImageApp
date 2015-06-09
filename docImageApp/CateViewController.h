//
//  CateViewController.h
//  docImageApp
//
//  Created by 侯建政 on 8/5/14.
//  Copyright (c) 2014 jianzheng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlideNavigationController.h"
@interface CateViewController : UIViewController<SlideNavigationControllerDelegate,UITableViewDataSource,UITableViewDelegate>
-(void)clearRequest;
@end
