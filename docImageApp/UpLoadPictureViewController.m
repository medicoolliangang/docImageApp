//
//  UpLoadPictureViewController.m
//  docImageApp
//
//  Created by 侯建政 on 8/6/14.
//  Copyright (c) 2014 jianzheng. All rights reserved.
//

#import "UpLoadPictureViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "THContactPickerViewController.h"
#import "CategorizeViewController.h"
#import "imdRequest.h"
#import "JSON.h"
#import "UrlCenter.h"
#import "Strings.h"
#import "iosVersionChecker.h"
#import "userLocalData.h"
#import "ZYQAssetPickerController.h"
#import "MBProgressHUD.h"
#import "UIImageExt.h"

#define SUPPORT_MAX_HEIGHT 400
#define KEYBOARD_HEIGHT 216
@interface UpLoadPictureViewController ()<UIScrollViewDelegate,UITextViewDelegate,THContactPickerViewControllerDelegate,CategorizeViewControllerDelegate,UINavigationControllerDelegate,ZYQAssetPickerControllerDelegate>
@property (nonatomic, strong) UIScrollView *bgscrView;
@property (nonatomic, strong) UIScrollView *scrView;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) UIView *myTextView;
@property (nonatomic, strong) UILabel *namelbl;
@property (nonatomic, strong) UITextView *contentView;
@property (nonatomic, strong) UILabel *emaillbl;
@property (nonatomic, strong) UILabel *categorizelbl;

@property (nonatomic, strong) NSString *caseId;
@property (nonatomic, strong) NSMutableArray *imagePathArray;
@property (nonatomic, strong) NSMutableArray *partsArray;
@property (nonatomic, strong) NSMutableArray *departmentArray;
@property (nonatomic, strong) NSMutableArray *tagArray;

@property (nonatomic, strong) NSMutableArray *selectArr;
@property (nonatomic, strong) NSMutableArray *selectArr2;

@property (nonatomic, strong) MBProgressHUD *myhud;

@property (nonatomic, assign) NSInteger canNotEdit;
@property (assign, nonatomic) BOOL keylock;
@end

@implementation UpLoadPictureViewController
@synthesize dateImageArr;
@synthesize scrView,pageControl,bgscrView;
@synthesize myTextView,namelbl,contentView,emaillbl,categorizelbl;
@synthesize caseId;
@synthesize imagePathArray;
@synthesize imgHeightMax;
@synthesize partsArray,tagArray,departmentArray;
@synthesize myhud;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
       //创建leftBar
      UIButton *button  = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
      [button setTitle:@"取消" forState:0];
      [button setTitleColor:[UIColor colorWithRed:64.0/255.0 green:111.0/255.0 blue:176.0/255.0 alpha:1.0] forState:0];
      [button addTarget:self action:@selector(dismissVC) forControlEvents:UIControlEventTouchUpInside];
      UIBarButtonItem *leftBar = [[UIBarButtonItem alloc] initWithCustomView:button];
      self.navigationItem.leftBarButtonItem = leftBar;
      
      UIButton *button2  = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
      [button2 setTitle:@"上传" forState:0];
      [button2 setTitleColor:[UIColor colorWithRed:64.0/255.0 green:111.0/255.0 blue:176.0/255.0 alpha:1.0] forState:0];
      [button2 addTarget:self action:@selector(upLoadPicture) forControlEvents:UIControlEventTouchUpInside];
      UIBarButtonItem *rightBar = [[UIBarButtonItem alloc] initWithCustomView:button2];
      self.navigationItem.rightBarButtonItem = rightBar;
      self.navigationItem.title = @"图片分享";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
  self.keylock = YES;
  
  imagePathArray = [[NSMutableArray alloc] init];
  self.view.backgroundColor = [UIColor lightGrayColor];
  
  float heightScreen = [UIScreen mainScreen].bounds.size.height;
  float widthScreen = [UIScreen mainScreen].bounds.size.width;
  
  bgscrView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, widthScreen, self.view.frame.size.height)];
  bgscrView.backgroundColor=[UIColor lightGrayColor];
  bgscrView.contentSize = CGSizeMake(widthScreen, heightScreen+100);
  bgscrView.delegate=self;
  [self.view addSubview:bgscrView];
  
  self.myhud = [[MBProgressHUD alloc] initWithView:self.view];
  [self.view addSubview:self.myhud];
  self.myhud.labelText = @"上传中...";
  
  scrView=[[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, widthScreen, heightScreen-NavgationHeight-216-100)];
  scrView.pagingEnabled=YES;
  scrView.backgroundColor=[UIColor whiteColor];
  scrView.delegate=self;
  [bgscrView addSubview:scrView];
  
  if (scrView.frame.size.height < imgHeightMax && imgHeightMax <= SUPPORT_MAX_HEIGHT) {
    self.scrView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, imgHeightMax);
    bgscrView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, imgHeightMax+100+40);
    [self displayView];
  }else if(imgHeightMax > SUPPORT_MAX_HEIGHT)
  {
    self.scrView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, SUPPORT_MAX_HEIGHT);
    bgscrView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, SUPPORT_MAX_HEIGHT+140);
    [self displayView];
  }else
  {
    bgscrView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, self.scrView.frame.size.height+140);
    [self displayView];
  }
    //从相册来的
  if (dateImageArr.count > 0) {
    [self layoutView];
  }else//从相机拍摄来的
  {
    [scrView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    scrView.contentSize=CGSizeMake(scrView.frame.size.width, scrView.frame.size.height);
    pageControl.numberOfPages=1;
    UIImageView *imgview=[[UIImageView alloc] init];
    imgview.frame = CGRectMake(0, 0, scrView.frame.size.width, scrView.frame.size.height);
    [imgview setImage:self.cameraImage];
    [imagePathArray addObject:self.cameraImagePath];
    [scrView addSubview:imgview];
  }
  partsArray = [[NSMutableArray alloc] init];
  departmentArray = [[NSMutableArray alloc] init];
  tagArray = [[NSMutableArray alloc] init];
  self.selectArr = [[NSMutableArray alloc] init];
  self.selectArr2 = [[NSMutableArray alloc] init];
    //监听键盘
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewChangedText:) name:UITextViewTextDidChangeNotification object:nil];
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
  [contentView scrollRectToVisible:CGRectMake(0, contentView.contentSize.height-1, 1, 1) animated:NO];
  return YES;
}
- (void)viewDidLayoutSubviews
{
  [super viewDidLayoutSubviews];
  [contentView becomeFirstResponder];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)dismissVC
{
  [self dismissViewControllerAnimated:YES completion:^{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
  }];
}
- (void)dismissModalVC:(BOOL)isUpload
{
  [self dismissViewControllerAnimated:YES completion:^{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    if (isUpload) {
      if ([self.delegate respondsToSelector:@selector(loadgetNewResourceRequest)]) {
        [self.delegate loadgetNewResourceRequest];
      }
    }
  }];
}
- (void)layoutView
{
  [scrView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
  
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    scrView.contentSize=CGSizeMake(dateImageArr.count*scrView.frame.size.width, scrView.frame.size.height);
    dispatch_async(dispatch_get_main_queue(), ^{
      pageControl.numberOfPages=dateImageArr.count;
    });
    
    for (int i=0; i<dateImageArr.count; i++) {
      ALAsset *asset=dateImageArr[i];
    
      UIImage *tempImg=[UIImage imageWithCGImage:asset.defaultRepresentation.fullResolutionImage];
      
      UIImageView *imgview=[[UIImageView alloc] init];
      imgview.frame = CGRectMake(i*scrView.frame.size.width, 0, scrView.frame.size.width, scrView.frame.size.height);
      UIImage *newImage;
      if (tempImg.size.height <= 400 && tempImg.size.width <= 320) {
        [imgview setContentScaleFactor:[[UIScreen mainScreen] scale]];
        imgview.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        imgview.contentMode=UIViewContentModeCenter;
        imgview.clipsToBounds=YES;
        newImage = nil;
      }else
      {
        newImage = [tempImg imageByScalingAndCroppingForSize:CGSizeMake(scrView.frame.size.width, scrView.frame.size.height)];
      }
      NSString *path = [Strings saveImage:tempImg WithName:asset.defaultRepresentation.filename];
      [imagePathArray addObject:path];
      dispatch_async(dispatch_get_main_queue(), ^{
        if (newImage == nil) {
          [imgview setImage:tempImg];
        }else
        [imgview setImage:newImage];
        [scrView addSubview:imgview];
      });
    }
      });
}
- (void)displayView
{
    //float heightScreen = [UIScreen mainScreen].bounds.size.height;
  float widthScreen = [UIScreen mainScreen].bounds.size.width;
  pageControl=[[UIPageControl alloc] initWithFrame:CGRectMake(scrView.frame.origin.x, scrView.frame.origin.y+scrView.frame.size.height-20, scrView.frame.size.width, 20)];
  pageControl.pageIndicatorTintColor = [UIColor whiteColor];
  pageControl.currentPageIndicatorTintColor = [UIColor redColor];
  [bgscrView addSubview:pageControl];
  
  
    //功能添加
  UIView *imgView = [[UIView alloc] initWithFrame:CGRectMake(scrView.frame.origin.x, scrView.frame.origin.y+scrView.frame.size.height, widthScreen, 40)];
  imgView.backgroundColor = [UIColor whiteColor];
  [self.bgscrView addSubview:imgView];
  
  UIButton *addbutton =[UIButton buttonWithType:UIButtonTypeCustom];
  addbutton.frame = CGRectMake(10, 5, 80, 40);
  [addbutton setImage:[UIImage imageNamed:@"image-addpicturebutton"] forState:0];
  [addbutton addTarget:self action:@selector(emailButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    //[emailbutton setTitle:@"邮件" forState:0];
  [imgView addSubview:addbutton];
  
  UIButton *catbutton =[UIButton buttonWithType:UIButtonTypeCustom];
  catbutton.frame = CGRectMake(widthScreen-10-80, 5, 80, 40);
  [catbutton setImage:[UIImage imageNamed:@"image-partdepartment"] forState:0];
  [catbutton addTarget:self action:@selector(catButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    //[catbutton setTitle:@"分类" forState:0];
  [imgView addSubview:catbutton];
    // Do any additional setup after loading the view.
  
    //添加发表文字的区域
    [self displayTextView];
  
    //请求服务器new case id
  [self getNewCaseId];
}
#pragma mark - UIScrollView Delegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
  pageControl.currentPage=floor(scrollView.contentOffset.x/scrollView.frame.size.width);
}
#pragma mark - UIButtonClick
- (void)emailButtonClick:(UIButton *)btn
{
//  THContactPickerViewController *thVC = [[THContactPickerViewController alloc] init];
//  thVC.delegate = self;
//  UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:thVC];
//  [self presentViewController:nav animated:YES completion:nil];
  if (self.imagePathArray.count < 5) {
    ZYQAssetPickerController *picker = [[ZYQAssetPickerController alloc] init];
    picker.maximumNumberOfSelection = 5-self.pageControl.numberOfPages;
    picker.assetsFilter = [ALAssetsFilter allPhotos];
    picker.showEmptyGroups=NO;
    picker.delegate = self;
    picker.selectionFilter = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
      if ([[(ALAsset*)evaluatedObject valueForProperty:ALAssetPropertyType] isEqual:ALAssetTypeVideo]) {
        NSTimeInterval duration = [[(ALAsset*)evaluatedObject valueForProperty:ALAssetPropertyDuration] doubleValue];
        return duration >= 5;
      } else {
        return YES;
      }
    }];
    
    [self presentViewController:picker animated:YES completion:NULL];
  }else
  {
    [self showAlertViewWithTitle:RUIYI_TITLE andMessage:@"最多只能上传5张图片!"];
  }
}
- (void)catButtonClick:(UIButton *)btn
{
  CategorizeViewController *catVC = [[CategorizeViewController alloc] init];
  catVC.delegate = self;
  catVC.selectArr = self.selectArr;
  catVC.selectArr2 = self.selectArr2;
  UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:catVC];
  [self presentViewController:nav animated:YES completion:nil];
}
- (void)selectCategorize:(NSMutableArray *)arr departMent:(NSMutableArray *)deparmentArray
{
  imgHeightMax = self.scrView.frame.size.height;
  if (imgHeightMax == SUPPORT_MAX_HEIGHT) {
    imgHeightMax ++;
  }
  self.selectArr = arr;
  self.selectArr2 = deparmentArray;
  [self.departmentArray removeAllObjects];
  [self.partsArray removeAllObjects];
  NSMutableArray *newArr = [[NSMutableArray alloc] init];
  [newArr addObjectsFromArray:arr];
  [newArr addObjectsFromArray:deparmentArray];
  NSString*str;
  if (newArr.count > 1) {
    str =[newArr componentsJoinedByString:@" | "];
  }else
    str = [newArr objectAtIndex:0];
  categorizelbl.text = str;
  CGSize sizecat;
#ifdef __IPHONE_7_0
  sizecat = [str boundingRectWithSize:CGSizeMake(categorizelbl.frame.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:categorizelbl.font} context:nil].size;
#else
 sizecat = [str sizeWithFont:categorizelbl.font constrainedToSize:CGSizeMake(categorizelbl.frame.size.width, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
#endif
  
  
  myTextView.frame = CGRectMake(myTextView.frame.origin.x, myTextView.frame.origin.y, myTextView.frame.size.width, myTextView.frame.size.height+sizecat.height-categorizelbl.frame.size.height);
  bgscrView.contentSize = CGSizeMake(bgscrView.contentSize.width, bgscrView.contentSize.height+sizecat.height-categorizelbl.frame.size.height);
  categorizelbl.frame = CGRectMake(5, categorizelbl.frame.origin.y, categorizelbl.frame.size.width , sizecat.height);
  
  for (int i = 0; i < deparmentArray.count; i++) {
    [self.departmentArray addObject:[Strings getDepartmentString:[deparmentArray objectAtIndex:i]]];
    NSLog(@"%@",self.departmentArray);
  }
  for (int i = 0; i < arr.count; i++) {
    [self.partsArray addObject:[Strings getAnatomyString:[arr objectAtIndex:i]]];
    NSLog(@"%@",self.partsArray);
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
- (void)selectEmailValue:(NSMutableArray *)arr
{
  NSString*str;
  if (arr.count > 1) {
   str =[arr componentsJoinedByString:@" , "];
  }else
    str = [arr objectAtIndex:0];
  emaillbl.text = str;
  CGSize sizeEmail;
#ifdef __IPHONE_7_0
  sizeEmail = [str boundingRectWithSize:CGSizeMake(emaillbl.frame.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:emaillbl.font} context:nil].size;
#else
  sizeEmail = [str sizeWithFont:emaillbl.font constrainedToSize:CGSizeMake(emaillbl.frame.size.width, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
#endif
  emaillbl.frame = CGRectMake(emaillbl.frame.origin.x, emaillbl.frame.origin.y, emaillbl.frame.size.width , sizeEmail.height);
   NSLog(@"dsdsd%@",str);
}
#pragma mark - DIY TextView
- (void)displayTextView
{
  float widthV = [UIScreen mainScreen].bounds.size.width;
  myTextView = [[UIView alloc] initWithFrame:CGRectMake(scrView.frame.origin.x, scrView.frame.origin.y+scrView.frame.size.height+40,widthV, 100)];
  myTextView.backgroundColor = [UIColor whiteColor];
  [self.bgscrView addSubview:myTextView];
  
  NSString *str = [userLocalData getUserName];
  if (str.length == 0) {
    str = [userLocalData getUserPhone];
    if (str.length > 0) {
      str = [str stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"];
    }
  }
//  namelbl = [[UILabel alloc] initWithFrame:CGRectMake(5, 10, 310, 40)];
//  namelbl.font = [UIFont systemFontOfSize:17.0];
//  namelbl.textColor = [UIColor redColor];
//  namelbl.text = [NSString stringWithFormat:@"%@:",str];
//  namelbl.numberOfLines = 2;
//  namelbl.textAlignment = NSTextAlignmentLeft;
//  CGSize size = [str sizeWithFont:namelbl.font constrainedToSize:CGSizeMake(namelbl.frame.size.width, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
//  namelbl.frame = CGRectMake(5, 10, size.width+5, size.height);
//  namelbl.hidden = YES;
  
    //[changestr addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(rangeName.length,MAXFLOAT)];
  
  contentView = [[UITextView alloc] initWithFrame:CGRectMake(5, 0, widthV-10, 70)];
  contentView.text = [NSString stringWithFormat:@"%@: ",str];
  contentView.scrollEnabled = YES;
  contentView.delegate = self;
  contentView.textColor = [UIColor blackColor];
  NSString *newStr = [NSString stringWithFormat:@"%@:%@",str,@" "];
  self.canNotEdit = newStr.length;

    //[myTextView addSubview:namelbl];
  NSRange rangeName = [newStr rangeOfString:str];
  NSRange rangeOther = [newStr rangeOfString:@" "];
  
  NSMutableAttributedString *changestr = [[NSMutableAttributedString alloc] initWithString:newStr];
  [changestr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:64.0/255.0 green:111.0/255.0 blue:176.0/255.0 alpha:1.0] range:rangeName];
  [changestr addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:rangeOther];
  contentView.attributedText = changestr;
  contentView.scrollIndicatorInsets = UIEdgeInsetsZero;
  contentView.font = [UIFont systemFontOfSize:17.0];
  [myTextView addSubview:contentView];
  
  float yHeight = contentView.frame.size.height;
  
  categorizelbl = [[UILabel alloc] init];
  categorizelbl.textColor = [UIColor colorWithRed:0.0/255.0 green:114.0/255.0 blue:252.0/255.0 alpha:1.0];
  categorizelbl.text = @"";
  categorizelbl.numberOfLines = 0;
  categorizelbl.font = [UIFont systemFontOfSize:15.0];
  categorizelbl.textAlignment = NSTextAlignmentLeft;
  CGSize sizecat;
#ifdef __IPHONE_7_0
  sizecat = [str boundingRectWithSize:CGSizeMake(categorizelbl.frame.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:categorizelbl.font} context:nil].size;
#else
  sizecat = [str sizeWithFont:categorizelbl.font constrainedToSize:CGSizeMake(categorizelbl.frame.size.width, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
#endif
  
  categorizelbl.frame = CGRectMake(5, yHeight+10, widthV-10 , sizecat.height);
  [myTextView addSubview:categorizelbl];
  
  yHeight = yHeight + sizecat.height;
  
  emaillbl = [[UILabel alloc] init];
  emaillbl.textColor = [UIColor blackColor];
  emaillbl.text = @"";
  emaillbl.numberOfLines = 0;
  emaillbl.font = [UIFont systemFontOfSize:15.0];
  emaillbl.textAlignment = NSTextAlignmentLeft;
  CGSize sizeEmail;
#ifdef __IPHONE_7_0
  sizeEmail = [str boundingRectWithSize:CGSizeMake(emaillbl.frame.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:emaillbl.font} context:nil].size;
#else
 sizeEmail = [str sizeWithFont:emaillbl.font constrainedToSize:CGSizeMake(emaillbl.frame.size.width, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
#endif
  emaillbl.frame = CGRectMake(5, yHeight, widthV-10 , sizeEmail.height);
  [myTextView addSubview:emaillbl];
}
- (void)textViewDidChange:(UITextView *)textView{
//    //计算文本的高度
//  CGSize constraintSize;
//  constraintSize.width = textView.frame.size.width;
//  constraintSize.height = MAXFLOAT;
//  CGSize sizeFrame =[textView.text sizeWithFont:textView.font
//                              constrainedToSize:constraintSize
//                                  lineBreakMode:NSLineBreakByWordWrapping];
//      //重新调整textView的高度
//  NSLog(@".....%f",sizeFrame.height);
//  textView.frame = CGRectMake(textView.frame.origin.x,textView.frame.origin.y,textView.frame.size.width,sizeFrame.height+5);
}
#pragma mark - HTTP REQUEST
-(void) getNewCaseId
{
  [imdRequest getRequest:[UrlCenter urlOfType:GET_CASE_ID] delegate:self requestType:@"getNewCaseID"];
}
-(void) upLoadPicture
{
  [self.myhud show:YES];
  self.navigationItem.rightBarButtonItem.enabled = NO;
  NSString *str = [userLocalData getUserName];
  if (str.length == 0) {
    str = [userLocalData getUserPhone];
  }
  NSString *content = [self.contentView.text substringFromIndex:str.length+1];
  NSString* description = [content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
  if (description.length == 0) {
    [self.myhud hide:YES];
    self.navigationItem.rightBarButtonItem.enabled = YES;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:RUIYI_TITLE message:@"说点什么..." delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
    alert.tag = 1000;
    [alert show];
    return;
  }
  if (partsArray.count == 0 && departmentArray.count == 0) {
    [self.myhud hide:YES];
    self.navigationItem.rightBarButtonItem.enabled = YES;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:RUIYI_TITLE message:@"请至少添加一个部位或者科室。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alert show];
    return;
  }
  if (self.imagePathArray.count > 0) {
    [imdRequest upLoadPictureRequest:[NSString stringWithFormat:@"%@/%@",[UrlCenter urlOfType:UPLOAD_PICTURE],self.caseId] delegate:self requestType:@"UploadPicture" path:self.imagePathArray imageName:@"image"];
  }
}
- (void) upLoadContents:(NSString *)firstId count:(NSInteger)uploadCount
{
  NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
  
  [dic setObject:self.caseId forKey:@"id"];
  if (partsArray.count > 0) {
    [dic setObject:partsArray forKey:@"parts"];
  }
  if (departmentArray.count > 0) {
    [dic setObject:departmentArray forKey:@"departments"];
  }
  if (tagArray.count > 0) {
    [dic setObject:partsArray forKey:@"tags"];
  }
  [dic setObject:[NSNumber numberWithInteger:uploadCount] forKey:@"picCount"];
  [dic setObject:firstId forKey:@"coverPicId"];
  NSString *str = [userLocalData getUserName];
  if (str.length == 0) {
    str = [userLocalData getUserPhone];
  }
  NSString *content = [self.contentView.text substringFromIndex:str.length+1];
  NSString* description = [content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
  if (description.length > 0) {
    [dic setObject:description forKey:@"description"];
  }
  
 [imdRequest postRequest:[NSString stringWithFormat:@"%@/%@",[UrlCenter urlOfType:UPLOAD_CONTENTS],self.caseId] delegate:self requestType:@"UploadContents" postData:dic json:YES];
}

- (void)requestFinished:(ASIHTTPRequest *)request{
  NSString* responseString = [request responseString];
  NSLog(@"xxxx%@",responseString);
  NSString* rType =[[request userInfo] objectForKey:REQUEST_TYPE];
  NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/imageFile"];
  if ([rType isEqualToString:@"getNewCaseID"]) {
    self.caseId = responseString;
  }else if ([rType isEqualToString:@"UploadPicture"])
  {
    NSArray *arr;
    if (responseString ==(id)[NSNull null] || responseString.length ==0 || [responseString isEqualToString:@"internal server error"])
    {
      arr =nil;
    }
    else
    {
      NSFileManager *fileManager=[NSFileManager defaultManager];
      arr =[iosVersionChecker parseJSONObjectFromJSONString:responseString];
      NSMutableArray *newCaseId = [[NSMutableArray alloc] init];
      for (int i = 0; i < arr.count; i++) {
        NSString *caseIds = [arr objectAtIndex:i];
        NSString *newPath = [NSString stringWithFormat:@"%@/%@",path,caseIds];
        NSString *newsmallPath = [NSString stringWithFormat:@"%@/smallPicture/%@",path,caseIds];
        if (![fileManager fileExistsAtPath:newPath]) {
          [fileManager copyItemAtPath:[self.imagePathArray objectAtIndex:i] toPath:newPath error:nil];
        }
        if (![fileManager fileExistsAtPath:newsmallPath]) {
          [fileManager copyItemAtPath:[self.imagePathArray objectAtIndex:i] toPath:newsmallPath error:nil];
        }
        if (caseIds.length > 0) {
          [newCaseId addObject:caseIds];
        }
      }
      
      if (newCaseId.count > 0) {
        [self upLoadContents:[newCaseId objectAtIndex:0] count:newCaseId.count];
      }
    }
    self.navigationItem.rightBarButtonItem.enabled = YES;
  }else if ([rType isEqualToString:@"UploadContents"])
  {
    NSDictionary* info;
    if (responseString ==(id)[NSNull null] || responseString.length ==0 || [responseString isEqualToString:@"internal server error"])
    {
      info =nil;
    }
    else
    {
      info =[iosVersionChecker parseJSONObjectFromJSONString:responseString];;
    }
    if ([info objectForKey:@"ok"]) {
      [self.myhud hide:YES];
      [self dismissModalVC:YES];
      NSLog(@"上传成功");
      
    }
  }
}

- (void)requestFailed:(ASIHTTPRequest *)requests{
  if ([requests.error code] == ASIRequestTimedOutErrorType) {
    [self showAlertViewWithTitle:RUIYI_TITLE andMessage:REQUEST_TIMEOUT_MESSAGE];
  }else
  {
    [self showAlertViewWithTitle:RUIYI_TITLE andMessage:REQUEST_ERROR];
  }
  [self.myhud hide:YES];
  self.navigationItem.rightBarButtonItem.enabled = YES;
}
- (void)showAlertViewWithTitle:(NSString *)title andMessage:(NSString *)message{
  UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
  [alertView show];
}
#pragma mark - NSNotificationCenter KeyBoard Delegate
- (void)keyboardWillShow:(NSNotification *)notification
{
  NSValue *keyboardBoundsValue = [[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey];
  CGSize kbSize = keyboardBoundsValue.CGRectValue.size;

  if (self.keylock) {
    self.keylock = NO;
    float heightY;
    if (imgHeightMax > SUPPORT_MAX_HEIGHT) {
      heightY = kbSize.height+NavgationHeight+SUPPORT_MAX_HEIGHT+self.myTextView.frame.size.height-[UIScreen mainScreen].bounds.size.height;
    }else if(scrView.frame.size.height == imgHeightMax && imgHeightMax <= SUPPORT_MAX_HEIGHT)
    {
      heightY = kbSize.height+NavgationHeight+imgHeightMax+self.myTextView.frame.size.height-[UIScreen mainScreen].bounds.size.height;
    }else
    {
      heightY = kbSize.height+NavgationHeight+self.scrView.frame.size.height+self.myTextView.frame.size.height-[UIScreen mainScreen].bounds.size.height;
    }
    [self.bgscrView setContentOffset:CGPointMake(0, heightY) animated:NO];
    CGRect f = self.bgscrView.frame;
    f.size.height = self.view.frame.size.height - 252;
    self.bgscrView.frame = f;
      //self.bgscrView.contentSize = CGSizeMake(self.bgscrView.contentSize.width, self.bgscrView.contentSize.height+kbSize.height);
  }
}
- (void)keyboardWillHide:(NSNotification *)notification
{
//  NSValue *keyboardBoundsValue = [[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey];
//  CGSize kbSize = keyboardBoundsValue.CGRectValue.size;

  if (!self.keylock) {
    self.keylock = YES;
    [self.bgscrView setContentOffset:CGPointMake(0, 0) animated:NO];
    CGRect f = self.bgscrView.frame;
    f.size.height = self.view.frame.size.height + 252;
    self.bgscrView.frame = f;
      //self.bgscrView.contentSize = CGSizeMake(self.bgscrView.contentSize.width, self.bgscrView.contentSize.height-kbSize.height);
  }
}
//- (void)keyboardWillShow:(NSNotification *)notification
//{
//  NSValue *keyboardBoundsValue = [[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey];
//  CGSize kbSize = keyboardBoundsValue.CGRectValue.size;
//  float heightY;
//  if (imgHeightMax != -1) {
//    if (imgHeightMax > SUPPORT_MAX_HEIGHT) {
//      heightY = kbSize.height+NavgationHeight+SUPPORT_MAX_HEIGHT+self.myTextView.frame.size.height-[UIScreen mainScreen].bounds.size.height;
//    }else if(scrView.frame.size.height < imgHeightMax && imgHeightMax <= SUPPORT_MAX_HEIGHT)
//    {
//      heightY = kbSize.height+NavgationHeight+imgHeightMax+self.myTextView.frame.size.height-[UIScreen mainScreen].bounds.size.height;
//    }else
//    {
//      heightY = kbSize.height+NavgationHeight+self.scrView.frame.size.height+self.myTextView.frame.size.height-[UIScreen mainScreen].bounds.size.height;
//    }
//     [self.bgscrView setContentOffset:CGPointMake(0, heightY) animated:NO];
//    if (imgHeightMax <= SUPPORT_MAX_HEIGHT) {
//      CGRect f = self.bgscrView.frame;
//      f.size.height = f.size.height-heightY;
//      self.bgscrView.frame = f;
//    }else
//    {
//    }
//    imgHeightMax = -1;
//  }
//}
//- (void)keyboardWillHide:(NSNotification *)notification
//{
//  
//}
- (void)textViewDidChangeSelection:(UITextView *)textView
{
  [textView scrollRangeToVisible:textView.selectedRange];
  NSString *str = [userLocalData getUserName];
  if (str.length == 0) {
    str = [userLocalData getUserPhone];
  }
  NSString *newStr = [NSString stringWithFormat:@"%@:",str];
  if (textView.selectedRange.location < newStr.length) {
    NSRange range;
    range.location = newStr.length;
    range.length = 0;
    textView.selectedRange = range;
  }
  
}
- (void)textViewChangedText:(NSNotification *)notification
{
  [contentView scrollRectToVisible:CGRectMake(0, contentView.contentSize.height-1, 1, 1) animated:NO];
//  CGPoint bottomOffset = CGPointMake(0, contentView.contentSize.height - contentView.bounds.size.height);
//  [contentView setContentOffset:bottomOffset animated:YES];
  if (contentView.text.length >= self.canNotEdit) {
  }else
  {
    NSString *str = [userLocalData getUserName];
    if (str.length == 0) {
      str = [userLocalData getUserPhone];
      if (str.length > 0) {
        str = [str stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"];
      }
    }
    self.contentView.text = [NSString stringWithFormat:@"%@: ",str];
    NSString *newStr = [NSString stringWithFormat:@"%@:%@",str,@" "];
    NSRange rangeName = [newStr rangeOfString:str];
    NSRange rangeOther = [newStr rangeOfString:@" "];
    NSMutableAttributedString *changestr = [[NSMutableAttributedString alloc] initWithString:newStr];
    [changestr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:64.0/255.0 green:111.0/255.0 blue:176.0/255.0 alpha:1.0] range:rangeName];
    [changestr addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:rangeOther];
    contentView.attributedText = changestr;
    contentView.font = [UIFont systemFontOfSize:17.0];
  }
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
  if (alertView.tag == 1000 && buttonIndex == 0) {
    if (!self.contentView.isFirstResponder) {
      [self.contentView becomeFirstResponder];
    }
  }
}
#pragma mark - ZYQAssetPickerController Delegate
-(void)assetPickerController:(ZYQAssetPickerController *)picker didFinishPickingAssets:(NSArray *)assets{
   dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    scrView.contentSize=CGSizeMake((assets.count+imagePathArray.count)*scrView.frame.size.width, scrView.frame.size.height);
    dispatch_async(dispatch_get_main_queue(), ^{
      pageControl.numberOfPages=assets.count+imagePathArray.count;
      scrView.contentOffset = CGPointMake(imagePathArray.count*scrView.frame.size.width,0);
      pageControl.currentPage = imagePathArray.count;

    });
     NSInteger temp = imagePathArray.count;
    for (int i=0; i<assets.count; i++) {
      ALAsset *asset=assets[i];
      UIImageView *imgview=[[UIImageView alloc] init];
      imgview.frame = CGRectMake((i+temp)*scrView.frame.size.width, 0, scrView.frame.size.width, scrView.frame.size.height);
      UIImage *tempImg=[UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage];
      UIImage *newImage;
      if (tempImg.size.height <= 400 && tempImg.size.width <= 320) {
        [imgview setContentScaleFactor:[[UIScreen mainScreen] scale]];
        imgview.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        imgview.contentMode=UIViewContentModeCenter;
        imgview.clipsToBounds=YES;
        newImage = nil;
      }else
      {
        newImage = [tempImg imageByScalingAndCroppingForSize:CGSizeMake(scrView.frame.size.width, scrView.frame.size.height)];
      }
      NSString *path = [Strings saveImage:tempImg WithName:asset.defaultRepresentation.filename];
      [imagePathArray addObject:path];
      dispatch_async(dispatch_get_main_queue(), ^{
        if (newImage == nil) {
          [imgview setImage:tempImg];
        }else
        [imgview setImage:newImage];
        [scrView addSubview:imgview];
      });
    }
  });
}

@end
