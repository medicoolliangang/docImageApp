//
//  ImageFlowViewController.h
//  docImageApp
//
//  Created by imd on 14-9-13.
//  Copyright (c) 2014年 jianzheng. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface ImageFlowViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) NSMutableArray *imageIdArr;
@property (nonatomic, strong) NSMutableArray *caseIdArr;
@property (nonatomic, assign) NSString *imageType;
@property (nonatomic, assign) NSString *selectName;

@property (nonatomic, strong) NSMutableArray *warnUploadImageArr;//上传图片中的警告
@end
