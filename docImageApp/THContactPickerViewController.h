  //
  //  UpLoadPictureViewController.h
  //  docImageApp
  //
  //  Created by 侯建政 on 8/6/14.
  //  Copyright (c) 2014 jianzheng. All rights reserved.
  //

#import <UIKit/UIKit.h>
#import <AddressBookUI/AddressBookUI.h>
#import "THContactPickerTableViewCell.h"
@protocol THContactPickerViewControllerDelegate <NSObject>
- (void)selectEmailValue:(NSMutableArray *)arr;
@end
@interface THContactPickerViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, ABPersonViewControllerDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *contacts;
@property (nonatomic, strong) NSMutableArray *selectedContacts;
@property (nonatomic, strong) NSArray *filteredContacts;
@property (nonatomic, unsafe_unretained) id<THContactPickerViewControllerDelegate> delegate;
@end
