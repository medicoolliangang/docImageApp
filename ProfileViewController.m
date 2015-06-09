//
//  ProfileViewController.m
//  docImageApp
//
//  Created by 侯建政 on 8/5/14.
//  Copyright (c) 2014 jianzheng. All rights reserved.
//

#import "ProfileViewController.h"
#import "userLocalData.h"
#import "UIImageButton.h"
#import "imdRequest.h"
#import "UrlCenter.h"
#import "Strings.h"
#import "iosVersionChecker.h"
#import "ImageFlowViewController.h"
#import "UserBaseInfoViewController.h"
#import "ZYQAssetPickerController.h"
#import "RSKImageCropViewController.h"
#import "MBProgressHUD.h"
#import "UIImageExt.h"
#import <ShareSDK/ShareSDK.h>
#define kImageWidth  107 //UITableViewCell里面图片的宽度
#define kImageHeight  97 //UITableViewCell里面图片的高度
static CGFloat ImageHeight  = 220.0;
static CGFloat ImageWidth  = 320.0;
@interface ProfileViewController ()<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,ZYQAssetPickerControllerDelegate,UINavigationControllerDelegate,RSKImageCropViewControllerDelegate>
@property (nonatomic, strong) UIImageView *imgProfile;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *headView;

@property (nonatomic, strong) UIActionSheet *actionView;
@property (nonatomic, strong) UIButton *photoButton;

@property (nonatomic, strong) ASIHTTPRequest *getPhotoRequest;
@property (nonatomic, strong) ASIHTTPRequest *upLoadPhotoRequest;
@property (nonatomic, strong) ASIHTTPRequest *getEveryCountRequest;

@property (nonatomic, strong) MBProgressHUD *hud;
@end

@implementation ProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
  [self.tableView reloadData];
//    CGRect bounds = self.view.bounds;
//    _tableView.frame = CGRectMake(bounds.origin.x, bounds.origin.y+180, bounds.size.width, bounds.size.height);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
  
    // Do any additional setup after loading the view.
    UIImage *image = [UIImage imageNamed:@"image-person-bg"];
    self.imgProfile = [[UIImageView alloc] initWithImage:image];
    self.imgProfile.frame  = CGRectMake(0, 0, ImageWidth, ImageHeight);
    [self.view addSubview:self.imgProfile];
    self.tableView = [[UITableView alloc] init];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor clearColor];
     _tableView.frame = CGRectMake(0,64,self.view.frame.size.width,self.view.frame.size.height+100);
    
    self.headView = [[UIView alloc] init];
    self.headView.frame = CGRectMake(0, 0, 320, 110);
    self.headView.alpha = 0.1;
    self.headView.backgroundColor = [UIColor orangeColor];
    self.tableView.tableHeaderView = self.headView;
    [self.tableView reloadData];
    
    [self.view addSubview:self.tableView];
  
  for (int i = 0; i < 6; i++) {
    UILabel *lbl = [[UILabel alloc] init];
    lbl.backgroundColor = [UIColor clearColor];
    lbl.text = @"0";
    lbl.textColor = [UIColor grayColor];
    lbl.textAlignment = NSTextAlignmentCenter;
    lbl.tag = 1000+i;
    if (i >= 3 && i<5) {
      lbl.font = [UIFont systemFontOfSize:12.0];
      lbl.text = @"敬请期待";
      lbl.frame = CGRectMake(kImageWidth*(i-3), 270+kImageHeight, kImageWidth, 30);
    }else
      lbl.frame = CGRectMake(kImageWidth*i, 270, kImageWidth, 30);
    [self.tableView addSubview:lbl];
  }
//    [self.view addSubview:self.headView];
    self.title = @"个人中心";
  
  self.actionView = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"选择一张图片", nil];
  self.actionView.actionSheetStyle = UIActionSheetStyleAutomatic;
  [self getPersonUserCount];
  
  self.hud = [[MBProgressHUD alloc] initWithView:self.view];
  self.hud.labelText = @"加载中...";
  [self.view addSubview:self.hud];
  [self.hud show:YES];
}
- (void)updateImg {
    CGFloat yOffset   = _tableView.contentOffset.y;
    NSLog(@"....%f",yOffset);
    if (yOffset > 40) {
        return;
    }
    if (yOffset < 0) {
        
        CGFloat factor = ((ABS(yOffset)+ImageHeight)*ImageWidth)/ImageHeight;
        CGRect f = CGRectMake(-(factor-ImageWidth)/2, 0, factor, ImageHeight+ABS(yOffset));
        self.imgProfile.frame = f;
    } else {
        CGRect f = self.imgProfile.frame;
        f.origin.y = -yOffset;
        self.imgProfile.frame = f;
    }
}

#pragma mark - Table View Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self updateImg];
}

#pragma mark - Table View Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
	
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row ==  0) {
        return 90.0;
    }else
        return kImageHeight+1;
	
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellReuseIdentifier   = @"SectionTwoCell";
    
    UITableViewCell *cell = nil;
    
    cell.opaque = NO;
    cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier];
   

    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifier];
        cell.contentView.backgroundColor = [UIColor clearColor];
        if(indexPath.row == 0)
        cell.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.1];
    }
    for(UIView *view in cell.contentView.subviews)
    {
        [view removeFromSuperview];
    }
    if (indexPath.row == 0) {
        //if (self.photoButton == nil) {
        self.photoButton = [UIButton buttonWithType:0];
        self.photoButton.layer.cornerRadius = 8.0;
        self.photoButton.layer.masksToBounds = YES;
        NSString *path = [userLocalData getPhotoFilePath];
        NSString *photoid =[userLocalData getPhotoId];
        if (photoid.length > 0) {
          NSString *newPath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/PhotoImage/%@",photoid]];
          if ([[path lastPathComponent] isEqualToString:[userLocalData getPhotoId]]) {
            if ([[NSFileManager defaultManager] fileExistsAtPath:newPath]) {
              [self.photoButton setImage:[UIImage imageWithContentsOfFile:newPath] forState:0];
            }else
            {
            [self.photoButton setImage:[UIImage imageNamed:@"icon_head_1"] forState:0];
            [self getPhotoRequest:[userLocalData getPhotoId]];
            }
          }else
          {
            [self.photoButton setImage:[UIImage imageNamed:@"icon_head_1"] forState:0];
            [self getPhotoRequest:[userLocalData getPhotoId]];
          }
        }else
        {
            [self.photoButton setImage:[UIImage imageNamed:@"icon_head_1"] forState:0];
        }
        self.photoButton.frame = CGRectMake(15, 5, 80, 80);
        [self.photoButton addTarget:self action:@selector(changeheadPortrait:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:self.photoButton];
        //}
        UILabel *namelbl = [[UILabel alloc] initWithFrame:CGRectMake(2*self.photoButton.frame.origin.x + self.photoButton.frame.size.width, 0, 320- (2*self.photoButton.frame.origin.x + self.photoButton.frame.size.width), 40)];
        namelbl.textColor = [UIColor whiteColor];
        namelbl.font = [UIFont systemFontOfSize:15.0];
        NSString *userName = [userLocalData getUserName];
        CGSize size = [userName sizeWithFont:namelbl.font constrainedToSize:CGSizeMake(namelbl.frame.size.width, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
        CGRect f= namelbl.frame;
        f.size.width = size.width;
        namelbl.frame = f;
        namelbl.text = userName;
        [cell.contentView addSubview:namelbl];
        
        UIView *bgView = [[UIView alloc] init];
        bgView.frame = CGRectMake(0, 46, 320, 44);
        bgView.backgroundColor = [UIColor colorWithRed:248.0/255.0 green:248.0/255.0 blue:248.0/255.0 alpha:1.0];
        UIButton *editButton = [UIButton buttonWithType:0];
       [editButton setBackgroundImage:[UIImage imageNamed:@"image-editor-userinfo"] forState:0];
        [editButton addTarget:self action:@selector(getUserInfo) forControlEvents:UIControlEventTouchUpInside];
        editButton.frame = CGRectMake(namelbl.frame.origin.x, 5, 76, 26);
        [bgView addSubview:editButton];
        [cell.contentView insertSubview:bgView belowSubview:self.photoButton];
    }else
    {
        for (int i=0; i<3; i++) {
            //自定义继续UIButton的UIImageButton 里面只是加了2个row和column属性
            UIImageButton *button = [UIImageButton buttonWithType:0];
            button.bounds = CGRectMake(0, 0, kImageWidth, kImageHeight);
            button.center = CGPointMake(kImageWidth *( 0.5 + i) , kImageHeight * 0.5);
            button.column = i;
            button.row = (int)indexPath.row;
            [button addTarget:self action:@selector(imageItemClick:) forControlEvents:UIControlEventTouchUpInside];
            //[button.layer setMasksToBounds:YES];
//          CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//          
//          CGColorRef colorref = CGColorCreate(colorSpace,(CGFloat[]){ 223.0/255.0, 223.0/255.0, 223.0/255.0, 1 });
//          
//          [button.layer setBorderColor:colorref];//边框颜色
//          
//          [button.layer setBorderWidth:1.0];   //边框宽度
          switch (indexPath.row) {
            case 1:
            {
              switch (i) {
                case 0:
                  button.enabled = YES;
                  [button setImage:[UIImage imageNamed:@"image-myuploads"] forState:0];
                  [button setImage:[UIImage imageNamed:@"image-myuploads-select"] forState:UIControlStateHighlighted];
                  break;
                case 1:
                  button.enabled = YES;
                  [button setImage:[UIImage imageNamed:@"image-myfav-default"] forState:0];
                  [button setImage:[UIImage imageNamed:@"image-myfav-select"] forState:UIControlStateHighlighted];
                  break;
                case 2:
                  button.enabled = YES;
                  [button setImage:[UIImage imageNamed:@"image-mydiscuss-default"] forState:0];
                  [button setImage:[UIImage imageNamed:@"image-mydiscuss-select"] forState:UIControlStateHighlighted];
                  break;
                default:
                  break;
              }
              break;
            }
            case 2:
            {
              switch (i) {
                case 0:
                  button.enabled = NO;
                  [button setImage:[UIImage imageNamed:@"image-myobserver-default"] forState:0];
                  [button setImage:[UIImage imageNamed:@"image-myobserver-select"] forState:UIControlStateHighlighted];
                  break;
                case 1:
                  button.enabled = NO;
                  [button setImage:[UIImage imageNamed:@"image-myshare-default"] forState:0];
                  [button setImage:[UIImage imageNamed:@"image-myshare-select"] forState:UIControlStateHighlighted];
                  break;
                case 2:
                  button.enabled = YES;
                  [button setImage:[UIImage imageNamed:@"image-sharefriends-default"] forState:0];
                  [button setImage:[UIImage imageNamed:@"image-sharefriends-select"] forState:UIControlStateHighlighted];
                  break;
                default:
                  break;
              }
              break;
            }
            default:
              break;
          }
            [cell.contentView addSubview:button];
        }
    }
    cell.textLabel.backgroundColor = [UIColor clearColor];
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
    return cell;
}
#pragma mark - UIBUTTON CLICK
- (void)getUserInfo
{
  UserBaseInfoViewController *userVC = [[UserBaseInfoViewController alloc] init];
  [self.navigationController pushViewController:userVC animated:YES];
}
- (void)imageItemClick:(UIImageButton *)sender
{
    NSLog(@"%d...%d",sender.row,sender.column);
    //Fav List
  UILabel *lbl = (UILabel *)[self.tableView viewWithTag:1000+sender.column];
    if (sender.row == 1 && sender.column == 1) {
            //获取收藏的记录
      if ([lbl.text isEqualToString:@"0"]) {
        [self showAlertViewWithTitle:RUIYI_TITLE andMessage:@"我的收藏空空的，先收藏一点东西吧..."];
      }else
      {
        [self.hud show:YES];
         [imdRequest getRequest:[NSString stringWithFormat:@"%@/1/10",[UrlCenter urlOfType:GET_FAV_LIST]] delegate:self requestType:@"GET_FAV_LIST"];
      }
    }else if (sender.row == 1 && sender.column == 0)
    {
        //获取上传的记录
      if ([lbl.text isEqualToString:@"0"]) {
        [self showAlertViewWithTitle:RUIYI_TITLE andMessage:@"我的上传空空的，先上传一点东西吧..."];
      }else
      {
        [self.hud show:YES];
        [imdRequest getRequest:[NSString stringWithFormat:@"%@/1/10",[UrlCenter urlOfType:GET_PERSON_SELF_CASE]] delegate:self requestType:@"GET_PERSON_SELF_CASE"];
      }
    }else if (sender.row == 1 && sender.column == 2)
    {
        //获取讨论的记录
      if ([lbl.text isEqualToString:@"0"]) {
        [self showAlertViewWithTitle:RUIYI_TITLE andMessage:@"我的讨论空空的，先讨论一点东西吧..."];
      }else
      {
        [self.hud show:YES];
       [imdRequest getRequest:[NSString stringWithFormat:@"%@/1/10",[UrlCenter urlOfType:GET_PERSON_SELF_COMMENT]] delegate:self requestType:@"GET_PERSON_SELF_COMMENT"];
      }
    }else if (sender.row == 2 && sender.column == 2)
    {
        //朋友分享
      [self shareFriend:sender];
    }
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
#pragma mark - HTTP REQUEST
- (void)getPersonUserCount
{
  if (self.getEveryCountRequest) {
    [self.getEveryCountRequest cancel];
  }
 self.getEveryCountRequest = [imdRequest getRequest:[UrlCenter urlOfType:GET_PERSON_COUNT] delegate:self requestType:@"GET_PERSON_COUNT"];
}
- (void)getPhotoRequest:(NSString *)idp
{
  if (self.getPhotoRequest) {
    [self.getPhotoRequest cancel];
  }
  self.getPhotoRequest = [imdRequest downLoadPhotoRequest:[NSString stringWithFormat:@"%@/%@",[UrlCenter urlOfType:GET_PERSON_PHOTO],idp] delegate:self requestType:@"GetPhoto"];
}
- (void)postPersonPhoto:(NSString *)path
{
  NSMutableArray *arr = [[NSMutableArray alloc] initWithCapacity:1];
  [arr addObject:path];
  if (self.upLoadPhotoRequest) {
    [self.upLoadPhotoRequest cancel];
  }
  self.upLoadPhotoRequest = [imdRequest upLoadPictureRequest:[UrlCenter urlOfType:POST_PERSON_PHOTO] delegate:self requestType:@"UpLoadPhoto" path:arr imageName:@"portrait"];
}
- (void)requestFinished:(ASIHTTPRequest *)request{
    NSString* responseString = [request responseString];
    NSLog(@"xxxx%@",responseString);
  [self.hud hide:YES];
    NSString* rType =[[request userInfo] objectForKey:REQUEST_TYPE];
    if ([rType isEqualToString:@"GET_FAV_LIST"])
    {
        NSArray *info;
        if (responseString ==(id)[NSNull null] || responseString.length ==0 || [responseString isEqualToString:@"internal server error"])
        {
            info =nil;
        }
        else
        {
            info = [iosVersionChecker parseJSONObjectFromJSONString:responseString];
            NSMutableArray *caseIdArr = [[NSMutableArray alloc] init];
            NSMutableArray *ImageArrayId = [[NSMutableArray alloc] init];
            for (int i = 0; i < info.count; i++) {
                NSDictionary *dic = [info objectAtIndex:i];
                NSString *picId = [[dic objectForKey:@"caze"] objectForKey:@"coverPicId"];
              if (picId == nil) {
                continue;
              }
                NSString *caseId = [dic objectForKey:@"caseId"];
                [ImageArrayId addObject:picId];
                [caseIdArr addObject:caseId];
            }
            ImageFlowViewController *waterVC = [[ImageFlowViewController alloc] init];
            waterVC.imageIdArr = ImageArrayId;
            waterVC.caseIdArr = caseIdArr;
            waterVC.imageType = rType;
            waterVC.selectName = @"我的收藏";
            [self.navigationController pushViewController:waterVC animated:YES];
        }
    }else if([rType isEqualToString:@"UpLoadPhoto"])
    {
      if (responseString.length == 24) {
       [self showAlertViewWithTitle:RUIYI_TITLE andMessage:@"头像上传成功"];
        [userLocalData savePhotoId:responseString];
        [self.photoButton setImage:[UIImage imageWithContentsOfFile:[userLocalData getPhotoFilePath]] forState:0];
      }else
       [self showAlertViewWithTitle:RUIYI_TITLE andMessage:@"头像上传失败"];
      
    }else if([rType isEqualToString:@"GetPhoto"])
    {
      if (request.responseStatusCode == 200) {
       
        NSString* fullPathToFile = request.downloadDestinationPath;
        [userLocalData savePhotoFilePath:fullPathToFile];
        [userLocalData savePhotoId:[request.url lastPathComponent]];
        [self.photoButton setImage:[UIImage imageWithContentsOfFile:fullPathToFile] forState:0];
      }else
      {
      [self.photoButton setImage:[UIImage imageNamed:@"icon_head_1"] forState:0];
      }
    }else if([rType isEqualToString:@"GET_PERSON_COUNT"])
    {
      NSDictionary *info;
      if (responseString ==(id)[NSNull null] || responseString.length ==0 || [responseString isEqualToString:@"internal server error"])
      {
        info =nil;
      }
      else
      {
        info = [iosVersionChecker parseJSONObjectFromJSONString:responseString];
        NSArray *arr = [NSArray arrayWithObjects:[info objectForKey:@"caseCount"],[info objectForKey:@"favCount"],[info objectForKey:@"commentCount"], nil];
        for (int i = 0; i < 3; i++) {
          UILabel *lbl = (UILabel *)[self.tableView viewWithTag:1000+i];
          lbl.text = [NSString stringWithFormat:@"%d",[[arr objectAtIndex:i] intValue]];
        }
      }
    }else if([rType isEqualToString:@"GET_PERSON_SELF_CASE"] || [rType isEqualToString:@"GET_PERSON_SELF_COMMENT"])
    {
      NSDictionary *info;
      if (responseString ==(id)[NSNull null] || responseString.length ==0 || [responseString isEqualToString:@"internal server error"])
      {
        info =nil;
      }
      else
      {
        info = [iosVersionChecker parseJSONObjectFromJSONString:responseString];
        NSArray *arr = [info objectForKey:@"cases"];
        NSMutableArray *caseIdArr = [[NSMutableArray alloc] init];
        NSMutableArray *ImageArrayId = [[NSMutableArray alloc] init];
        
        NSMutableArray *statusArr = [[NSMutableArray alloc] init];
        if ([rType isEqualToString:@"GET_PERSON_SELF_CASE"]) {
          for (int i = 0; i < arr.count; i++) {
            NSDictionary *dic = [arr objectAtIndex:i];
            NSString *picId = [dic objectForKey:@"coverPicId"];
            NSString *caseId = [dic objectForKey:@"id"];
            
            NSString *status = [dic objectForKey:@"status"];
            if ([status isEqualToString:@"Warning"]) {
              [statusArr addObject:[NSNumber numberWithInt:i]];
              [ImageArrayId addObject:picId];
              [caseIdArr addObject:caseId];
            }else if([status isEqualToString:@"Forbidden"])
            {
              
            }else
            {
              [ImageArrayId addObject:picId];
              [caseIdArr addObject:caseId];
            }
          }

        }else
        {
          for (int i = 0; i < arr.count; i++) {
            NSDictionary *dic = [arr objectAtIndex:i];
            NSString *picId = [dic objectForKey:@"coverPicId"];
            NSString *caseId = [dic objectForKey:@"id"];
            [ImageArrayId addObject:picId];
            [caseIdArr addObject:caseId];
          }

        }
        ImageFlowViewController *waterVC = [[ImageFlowViewController alloc] init];
        waterVC.imageIdArr = ImageArrayId;
        waterVC.caseIdArr = caseIdArr;
        waterVC.imageType = rType;
        
        
        if ([rType isEqualToString:@"GET_PERSON_SELF_CASE"]) {
          waterVC.selectName = @"我的上传";
          waterVC.warnUploadImageArr = statusArr;
        }else
          waterVC.selectName = @"我的讨论";
        [self.navigationController pushViewController:waterVC animated:YES];
      }
    }
}
- (void)requestFailed:(ASIHTTPRequest *)requests{
  [self.hud hide:YES];
  if ([requests.error code] == ASIRequestTimedOutErrorType) {
        [self showAlertViewWithTitle:RUIYI_TITLE andMessage:REQUEST_TIMEOUT_MESSAGE];
    }else
    {
        [self showAlertViewWithTitle:RUIYI_TITLE andMessage:REQUEST_ERROR];
    }
}
- (void)showAlertViewWithTitle:(NSString *)title andMessage:(NSString *)message{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alertView show];
}
#pragma mark - BUTTON CLICK
- (void)changeheadPortrait:(id)sender
{
  [self.actionView showInView:self.view];
}
#pragma mark - UIActionSheet
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
  [self.actionView dismissWithClickedButtonIndex:buttonIndex animated:NO];
  if (buttonIndex == 0) {
    [self performSelector:@selector(loadPhotoCamera) withObject:nil afterDelay:0.3];
  }else if(buttonIndex == 1)
  {
    [self loadlocalPicture];
  }
}
- (void)loadlocalPicture
{
  ZYQAssetPickerController *picker = [[ZYQAssetPickerController alloc] init];
  picker.maximumNumberOfSelection = 1;
  picker.assetsFilter = [ALAssetsFilter allPhotos];
  picker.showEmptyGroups=NO;
  picker.delegate=self;
  picker.selectionFilter = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
    if ([[(ALAsset*)evaluatedObject valueForProperty:ALAssetPropertyType] isEqual:ALAssetTypeVideo]) {
      NSTimeInterval duration = [[(ALAsset*)evaluatedObject valueForProperty:ALAssetPropertyDuration] doubleValue];
      return duration >= 5;
    } else {
      return YES;
    }
  }];
  
  [self presentViewController:picker animated:YES completion:NULL];
}
- (void)loadPhotoCamera
{
  UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    //    if (![UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
    //        sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    //    }
    //sourceType = UIImagePickerControllerSourceTypeCamera; //照相机
    //sourceType = UIImagePickerControllerSourceTypePhotoLibrary; //图片库
    //sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum; //保存的相片
  if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
  {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];//初始化
    picker.delegate = self;
    picker.allowsEditing = YES;//设置可编辑
    picker.sourceType = sourceType;
    [self presentViewController:picker animated:YES completion:nil];//进入照相界面
  }
}
#pragma mark Camera View Delegate Methods
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
  UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
  
  MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:picker.view];
  [picker.view addSubview:hud];
  hud.labelText = @"处理中...";
  [hud show:YES];
  
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    UIImage *newImage = [image imageByScalingAndCroppingForSize:CGSizeMake(160, 160)];
    dispatch_sync(dispatch_get_main_queue(), ^{
      [picker dismissViewControllerAnimated:YES completion:^{
      [self savePhotoImage:newImage];
      [hud removeFromSuperview];
      }];
      
    });
  });
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
  [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - ZYQAssetPickerController Delegate
-(void)assetPickerController:(ZYQAssetPickerController *)picker didFinishPickingAssets:(NSArray *)assets{
  NSLog(@"%@",assets);
  if (assets.count > 0) {
    ALAsset *asset=assets[0];
    UIImage *tempImg=[UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage];
    if (assets.count > 0) {
      RSKImageCropViewController *imageCropVC = [[RSKImageCropViewController alloc] initWithImage:tempImg cropMode:RSKImageCropModeSquare];
      imageCropVC.delegate = self;
      [self.navigationController pushViewController:imageCropVC animated:YES];
    }
  }else
  {
    [self showAlertViewWithTitle:RUIYI_TITLE andMessage:@"请选择图片。"];
  }
}
#pragma mark - RSKImageCropViewControllerDelegate

- (void)imageCropViewControllerDidCancelCrop:(RSKImageCropViewController *)controller
{
  [self.navigationController popViewControllerAnimated:YES];
}

- (void)imageCropViewController:(RSKImageCropViewController *)controller didCropImage:(UIImage *)croppedImage
{
  [self.photoButton setImage:croppedImage forState:UIControlStateNormal];
  [self savePhotoImage:croppedImage];
  [self.navigationController popViewControllerAnimated:YES];
}
- (void)savePhotoImage:(UIImage *)image
{
  if (image) {
    NSData *imageData;
    if (UIImagePNGRepresentation(image)) {
        //返回为png图像。
      imageData = UIImagePNGRepresentation(image);
    }else {
        //返回为JPEG图像。
      imageData = UIImageJPEGRepresentation(image, 1.0);
    }
    NSString *paths = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/"];
    
    NSString* documentsDirectory = [NSString stringWithFormat:@"%@/PhotoImage",paths];
    if (![[NSFileManager defaultManager] fileExistsAtPath:documentsDirectory]) {
      [[NSFileManager defaultManager] createDirectoryAtPath:documentsDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString  *photoId = [userLocalData getPhotoId];
    NSString* fullPathToFile;
    if (photoId.length > 0) {
      fullPathToFile = [documentsDirectory stringByAppendingPathComponent:photoId];
    }else
      fullPathToFile = [documentsDirectory stringByAppendingPathComponent:@"myPhoto"];
    
    NSArray *nameAry=[fullPathToFile componentsSeparatedByString:@"/"];
    NSLog(@"===fullPathToFile===%@",fullPathToFile);
    NSLog(@"===FileName===%@",[nameAry objectAtIndex:[nameAry count]-1]);
    
    [imageData writeToFile:fullPathToFile atomically:NO];
    [userLocalData savePhotoFilePath:fullPathToFile];
    [self postPersonPhoto:fullPathToFile];
  }
}
- (void)shareFriend:(id)sender
{
   NSArray *shareList  = [ShareSDK getShareListWithType:ShareTypeSinaWeibo,ShareTypeTencentWeibo,ShareTypeWeixiSession,ShareTypeWeixiTimeline,ShareTypeWeixiFav,ShareTypeQQSpace,ShareTypeQQ,ShareTypeSMS,ShareTypeMail,ShareTypeCopy, nil];
   UIImage *image = [UIImage imageNamed:@"logo-image120"];
        //构造分享内容
      id<ISSContent> publishContent = [ShareSDK content:[NSString stringWithFormat:@"%@下载地址:%@",TUIJIAN,APP_TUIJIAN_URL]
                                         defaultContent:@""
                                                  image:[ShareSDK pngImageWithImage:image]
                                                  title:@"睿医图志-医学图片"
                                                    url:APP_TUIJIAN_URL
                                            description:[NSString stringWithFormat:@"%@下载地址:%@",TUIJIAN,APP_TUIJIAN_URL]
                                              mediaType:SSPublishContentMediaTypeNews];
        //短信分享
      [publishContent addSMSUnitWithContent:[NSString stringWithFormat:@"%@下载地址:%@",TUIJIAN,APP_TUIJIAN_URL]];
        //创建弹出菜单容器
      id<ISSContainer> container = [ShareSDK container];
      [container setIPadContainerWithView:sender arrowDirect:UIPopoverArrowDirectionUp];
      
      
      MBProgressHUD *sharehud = [[MBProgressHUD alloc] initWithView:self.view];
      [self.view addSubview:sharehud];
      sharehud.mode = MBProgressHUDModeCustomView;
        //弹出分享菜单
      [ShareSDK showShareActionSheet:container
                           shareList:shareList
                             content:publishContent
                       statusBarTips:NO
                         authOptions:nil
                        shareOptions:nil
                              result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                
                                if (state == SSResponseStateSuccess)
                                {
                                  NSLog(NSLocalizedString(@"TEXT_ShARE_SUC", @"分享成功"));
                                  sharehud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
                                  if (type == ShareTypeCopy) {
                                    sharehud.labelText = @"图片拷贝成功";
                                  }else
                                  {
                                    sharehud.labelText = @"推荐发送成功";
                                  }
                                  [sharehud show:YES];
                                  [sharehud hide:YES afterDelay:2];
                                }
                                else if (state == SSResponseStateFail)
                                {
                                  NSLog(NSLocalizedString(@"TEXT_ShARE_FAI", @"分享失败,错误码:%d,错误描述:%@"), [error errorCode], [error errorDescription]);
                                  if (type == ShareTypeCopy) {
                                    sharehud.labelText = @"图片拷贝失败";
                                  }else
                                  {
                                    sharehud.labelText = @"推荐发送失败";
                                  }
                                  [sharehud show:YES];
                                  [sharehud hide:YES afterDelay:2];
                                }else if (state == SSResponseStateBegan)
                                {
                                  if (type == ShareTypeSMS) {
                                    sharehud.labelText = @"信息准备中。。";
                                  }else if (type == ShareTypeMail)
                                  {
                                    sharehud.labelText = @"邮件准备中。。";
                                  }
                                  else
                                  {
                                    sharehud.labelText = @"推荐中。。";
                                  }
                                  [sharehud show:YES];
                                  [sharehud hide:YES afterDelay:2];
                                }
                              }];

}
-(void)clearRequest
{
  if (self.getEveryCountRequest) {
    [self.getEveryCountRequest cancel];
    [self.getEveryCountRequest clearDelegatesAndCancel];
    self.getEveryCountRequest = nil;
  }
  if (self.getPhotoRequest) {
    [self.getPhotoRequest cancel];
    [self.getPhotoRequest clearDelegatesAndCancel];
    self.getPhotoRequest = nil;
  }
  if (self.upLoadPhotoRequest) {
    [self.upLoadPhotoRequest cancel];
    [self.upLoadPhotoRequest clearDelegatesAndCancel];
    self.upLoadPhotoRequest = nil;
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
