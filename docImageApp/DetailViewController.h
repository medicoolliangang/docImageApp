//
//  DetailViewController.h
//  docImageApp
//
//  Created by 侯建政 on 9/3/14.
//  Copyright (c) 2014 jianzheng. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol DetailViewController_Delegate <NSObject>

- (void)refreshSelectImage:(NSIndexPath *)index;
@end
@interface DetailViewController : UIViewController
@property (strong, nonatomic) NSString *caseId;
@property (strong, nonatomic) NSIndexPath *index;
@property (weak, nonatomic) id<DetailViewController_Delegate> delegate;
@end
