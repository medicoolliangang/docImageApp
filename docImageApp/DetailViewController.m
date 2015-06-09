//
//  DetailViewController.m
//  docImageApp
//
//  Created by 侯建政 on 9/3/14.
//  Copyright (c) 2014 jianzheng. All rights reserved.
//

#import "DetailViewController.h"
#import "imdRequest.h"
#import "Strings.h"
#import "ASINetworkQueue.h"
#import "UrlCenter.h"
#import "iosVersionChecker.h"
#import "UIImageExt.h"
#import "THChatInput.h"
#import "ImgScrollView.h"
#import "TapImageView.h"
#import "MyLabel.h"
#import "MyButton.h"
#import "MarkupParser.h"
#import "userLocalData.h"
#import "MBProgressHUD.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "ALAssetsLibrary+CustomPhotoAlbum.h"

#import <ShareSDK/ShareSDK.h>

#define SUPPORT_MAX_HEIGHT 450
#define KEYBOARD_HEIGHT 216
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface DetailViewController ()<UIScrollViewDelegate,UITableViewDelegate,UITableViewDataSource,THChatInputDelegate,TapImageViewDelegate,ImgScrollViewDelegate,UIActionSheetDelegate,MBProgressHUDDelegate>
@property (nonatomic, strong) ASINetworkQueue *networkQueue;    //asi下载队列
@property (nonatomic, strong) NSMutableArray *imagePathArray;//本页面一组图片的地址
@property (nonatomic, assign) float imageMaxHeight;

@property (nonatomic, strong) UIScrollView *bgscrView;
@property (nonatomic, strong) UIScrollView *scrView;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) UITableView *mytreeView;

@property (nonatomic, strong) NSString *descriptions;
@property (nonatomic, strong) NSString *detailuserName;
@property (nonatomic, strong) NSArray *deparmentArray;
@property (nonatomic, strong) NSArray *partArray;

@property (nonatomic, strong) NSMutableArray *parentArray;//讨论区的所有主评论
@property (nonatomic, strong) NSMutableDictionary *childerDic;//讨论区的所有子评论
@property (nonatomic, strong) NSMutableArray *childerIdArray;//讨论区的所有子评论ID

@property (nonatomic, strong) ASIHTTPRequest *request_childeren_discuss;
@property (nonatomic, strong) THChatInput *chatInput;
@property (nonatomic, strong) UITapGestureRecognizer *tapper;//点击
@property (nonatomic, strong) UIPanGestureRecognizer *recognizer;//滑动

@property (nonatomic, strong) UIView *scrollPanel;//显示图片放大缩小的页面
@property (nonatomic, strong) UIView *markView;
@property (nonatomic, strong) UIScrollView *myScrollView;
@property (nonatomic, assign) NSInteger currentIndex;

@property (strong, nonatomic) NSMutableArray *allselectId;  //所有点击展开的父title的id
@property (nonatomic,assign) NSInteger selectIndex; //当前点击展开的父title的row
@property (nonatomic,strong) NSMutableDictionary *selectIndexSet; //记录已经点过的父title位置
@property (nonatomic, strong) NSString *coverPicId;

@property (strong, nonatomic) MarkupParser *parser;
@property (strong, nonatomic) UIButton *favbutton;
@property (assign, nonatomic) BOOL isFav;

@property (strong, nonatomic) MBProgressHUD *myhud;
@property (nonatomic, assign) int cmtCount;
@property (nonatomic, assign) int favCount;

@property (strong, atomic) ALAssetsLibrary* library;
  //ASIHTTP
@property (strong, nonatomic) ASIHTTPRequest *favRequest;
@property (strong, nonatomic) ASIHTTPRequest *upCommentRequest;
@property (strong, nonatomic) ASIHTTPRequest *parentRequest;
@property (strong, nonatomic) ASIHTTPRequest *childRequest;

  //点赞label
@property (strong, nonatomic) UILabel *addlbl;
@property (strong, nonatomic) UILabel *reducelbl;
  //收藏和评论个数
@property (strong, nonatomic) UILabel *favLbl;
@property (strong, nonatomic) UILabel *commentLbl;

@property (assign, nonatomic) BOOL keylock;

@property (strong, nonatomic) MBProgressHUD *imagehud;
@property (strong, nonatomic) UIProgressView *progressView;
@end

@implementation DetailViewController
@synthesize networkQueue;
@synthesize imagePathArray,deparmentArray,partArray,parentArray,childerDic,childerIdArray,allselectId;
@synthesize imageMaxHeight;
@synthesize scrView,pageControl,bgscrView,mytreeView;
@synthesize descriptions,detailuserName;
@synthesize request_childeren_discuss;
@synthesize chatInput;
@synthesize scrollPanel,markView,myScrollView,currentIndex;
@synthesize parser,caseId;
@synthesize favbutton,isFav;
@synthesize myhud;
@synthesize keylock;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)dealloc
{
  self.delegate = nil;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
  self.progressView = [[UIProgressView alloc] init];
  self.view.backgroundColor = [UIColor whiteColor];
  self.library = [[ALAssetsLibrary alloc] init];
    //自定义networkQueue
  networkQueue = [[ASINetworkQueue alloc] init];
  [networkQueue reset];
    //初始化
  imagePathArray = [[NSMutableArray alloc] initWithCapacity:5];
  parentArray = [[NSMutableArray alloc] init];
  childerDic = [[NSMutableDictionary alloc] init];
  childerIdArray = [[NSMutableArray alloc] init];
    
    allselectId = [[NSMutableArray alloc] init];
    self.selectIndexSet = [[NSMutableDictionary alloc] init];
    
  scrollPanel = [[UIView alloc] initWithFrame:self.view.bounds];
  scrollPanel.backgroundColor = [UIColor clearColor];
  scrollPanel.alpha = 0;
  [self.view addSubview:scrollPanel];
  
  markView = [[UIView alloc] initWithFrame:scrollPanel.bounds];
  markView.backgroundColor = [UIColor blackColor];
  markView.alpha = 0.0;
  [scrollPanel addSubview:markView];
  
  myScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
  [scrollPanel addSubview:myScrollView];
  myScrollView.pagingEnabled = YES;
  myScrollView.delegate = self;
  
  parser = [[MarkupParser alloc] init];
  
  self.myhud = [[MBProgressHUD alloc] initWithView:self.view];
  self.myhud.labelText = @"加载中...";
  [self.view addSubview:self.myhud];
  [self.myhud show:YES];
  self.keylock = YES;
//  UIBarButtonItem *aButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"< 返回" style:UIBarButtonItemStyleBordered target:self action:@selector(dismissVC)];
//  self.navigationItem.leftBarButtonItem =aButtonItem;
}
- (void)viewDidUnload
{
  self.library = nil;
  
  [super viewDidUnload];
}
- (void)viewWillDisappear:(BOOL)animated
{
  [networkQueue reset];
  networkQueue = nil;
  self.delegate = nil;
  
  [super viewWillDisappear:animated];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - custom delegate
- (void) tappedWithObject:(id)sender
{
  [self.chatInput resignFirstResponder];
    float widthS = [UIScreen mainScreen].bounds.size.width;
    CGSize contentSize = myScrollView.contentSize;
    contentSize.height = self.view.bounds.size.height;
    contentSize.width = widthS * pageControl.numberOfPages;
    myScrollView.contentSize = contentSize;
    
    [self.view bringSubviewToFront:scrollPanel];
    scrollPanel.alpha = 1.0;
    
    TapImageView *tmpView = sender;
    currentIndex = tmpView.tag - 10;
    
    //转换后的rect
    CGRect convertRect = [[tmpView superview] convertRect:tmpView.frame toView:self.view];
    
    CGPoint contentOffset = myScrollView.contentOffset;
    contentOffset.x = currentIndex*widthS;
    myScrollView.contentOffset = contentOffset;
    
    //添加
    [self addSubImgView];
    
    ImgScrollView *tmpImgScrollView = [[ImgScrollView alloc] initWithFrame:(CGRect){contentOffset,myScrollView.bounds.size}];
    [tmpImgScrollView setContentWithFrame:convertRect];
    [tmpImgScrollView setImage:[UIImage imageWithContentsOfFile:[imagePathArray objectAtIndex:currentIndex]]];
    [myScrollView addSubview:tmpImgScrollView];
    tmpImgScrollView.i_delegate = self;
    
    //[self performSelector:@selector(setOriginFrame:) withObject:tmpImgScrollView afterDelay:0.1];
  [self setOriginFrame:tmpImgScrollView];
}
- (void) addSubImgView
{
  UILongPressGestureRecognizer * longPressGr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressToDo:)];
  longPressGr.minimumPressDuration = 1.0;
  [self.myScrollView addGestureRecognizer:longPressGr];
  
    for (UIView *tmpView in myScrollView.subviews)
    {
        [tmpView removeFromSuperview];
    }
    
    for (int i = 0; i < pageControl.numberOfPages; i ++)
    {
        if (i == currentIndex)
        {
            continue;
        }
        
        TapImageView *tmpView = (TapImageView *)[self.view viewWithTag:10 + i];
      tmpView.autoresizingMask = UIViewAutoresizingNone;
      tmpView.contentMode=UIViewContentModeScaleToFill;
        //转换后的rect
        CGRect convertRect = [[tmpView superview] convertRect:tmpView.frame toView:self.view];
        
        ImgScrollView *tmpImgScrollView = [[ImgScrollView alloc] initWithFrame:(CGRect){i*myScrollView.bounds.size.width,0,myScrollView.bounds.size}];
        [tmpImgScrollView setContentWithFrame:convertRect];
        [tmpImgScrollView setImage:[UIImage imageWithContentsOfFile:[imagePathArray objectAtIndex:i]]];
        [myScrollView addSubview:tmpImgScrollView];
        tmpImgScrollView.i_delegate = self;
        
        [tmpImgScrollView setAnimationRect];
    }
}

- (void) setOriginFrame:(ImgScrollView *) sender
{
    self.navigationController.navigationBar.hidden = YES;
    [UIView animateWithDuration:0.4 animations:^{
        [sender setAnimationRect];
        markView.alpha = 1.0;
    }];
}

- (void) tapImageViewTappedWithObject:(id)sender
{
    self.navigationController.navigationBar.hidden = NO;
    ImgScrollView *tmpImgView = sender;
    
    [UIView animateWithDuration:0.5 animations:^{
        markView.alpha = 0;
        [tmpImgView rechangeInitRdct];
    } completion:^(BOOL finished) {
        scrollPanel.alpha = 0;
    }];
    
}

#pragma mark -
#pragma mark - scroll delegate
- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat pageWidth = scrollView.frame.size.width;
    currentIndex = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
}

#pragma mark - UITapGestureRecognizer
- (void)longPressToDo:(UILongPressGestureRecognizer *)gesture
{
  if(gesture.state == UIGestureRecognizerStateBegan)
  {
    UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"分享图片",@"保存相册", nil];
    [action showInView:self.myScrollView];
  }
  
}
//- (void)tappedView:(UITapGestureRecognizer *)TapGesture
//{
//  [self.chatInput resignFirstResponder];
//  [self.tapper removeTarget:self action:@selector(tappedView:)];
//  [self.view removeGestureRecognizer:self.tapper];
//  self.tapper = nil;
//}
- (void)handleSwipeFrom:(UIPanGestureRecognizer *)gesture
{
  [self.chatInput resignFirstResponder];
  [self.recognizer removeTarget:self action:@selector(handleSwipeFrom:)];
  [self.bgscrView removeGestureRecognizer:self.recognizer];
  self.recognizer = nil;
}
- (void)pictureTap:(UITapGestureRecognizer *)TapGesture
{
  
}
#pragma mark - THChatInputDelegate
- (void)chat:(THChatInput*)input sendWasPressed:(NSString*)text
{
  NSLog(@"%@",text);
    //子类回复
  NSDictionary *atDic = input.selectItem;
  NSString *contentText = [text stringByReplacingOccurrencesOfString:@" " withString:@""];
  if (contentText.length > 0) {
    
    [self.chatInput resignFirstResponder];
    NSString *name = [userLocalData getUserName];
    if (input.isFather) {
      NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
      [dic setObject:text forKey:@"content"];
      
      [dic setObject:@"" forKey:@"atname"];
      [dic setObject:@"" forKey:@"atId"];
      [dic setObject:@"" forKey:@"parentId"];
      [dic setObject:self.caseId forKey:@"caseId"];
        
        if (name.length > 0) {
            [dic setObject:name forKey:@"username"];
        }else
        {
          NSString *phoneNumber = [userLocalData getUserPhone];
          if (phoneNumber.length > 0) {
            phoneNumber = [phoneNumber stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"];
          }
            [dic setObject:phoneNumber forKey:@"username"];
        }
      [self postParentDiscuss:dic];
    }else
    {
      NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
      [dic setObject:text forKey:@"content"];
      
      [dic setObject:[atDic objectForKey:@"username"] forKey:@"atname"];
      [dic setObject:[atDic objectForKey:@"userId"] forKey:@"atId"];
      [dic setObject:[atDic objectForKey:@"caseId"] forKey:@"caseId"];
      NSString *ids = [atDic objectForKey:@"parentId"];
      if (ids.length == 0) {
        [dic setObject:[atDic objectForKey:@"id"] forKey:@"parentId"];
      }else
        [dic setObject:ids forKey:@"parentId"];
    
        if (name.length > 0) {
            [dic setObject:name forKey:@"username"];
        }else
        {
          NSString *phoneNumber = [userLocalData getUserPhone];
          if (phoneNumber.length > 0) {
            phoneNumber = [phoneNumber stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"];
          }
        [dic setObject:phoneNumber forKey:@"username"];
        }
      
      [self postDiscuss:dic];
    }
    
    [self.chatInput setText:@""];
  }
  
}
- (void)chatKeyboardWillShow:(THChatInput*)cinput
{
  if (self.keylock) {
    self.keylock = NO;
    self.bgscrView.contentSize = CGSizeMake(self.bgscrView.contentSize.width, self.bgscrView.contentSize.height+292);
  }
}
- (void)chatKeyboardWillHide:(THChatInput*)cinput
{
  if (!self.keylock) {
    self.keylock = YES;
    self.bgscrView.contentSize = CGSizeMake(self.bgscrView.contentSize.width, self.bgscrView.contentSize.height-292);
  }
}
#pragma mark - View Layout
- (void)displayDeatilView:(BOOL)loadImage
{
  [self.myhud hide:YES];
  self.view.backgroundColor = [UIColor whiteColor];
  
  float heightScreen = [UIScreen mainScreen].bounds.size.height;
  float widthScreen = [UIScreen mainScreen].bounds.size.width;
  
  bgscrView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, NavgationHeight, widthScreen, self.view.frame.size.height)];
  bgscrView.backgroundColor=[UIColor whiteColor];
  bgscrView.contentSize = CGSizeMake(widthScreen, heightScreen+100);
  bgscrView.delegate=self;
  [self.view addSubview:bgscrView];
  
  scrView=[[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, widthScreen, heightScreen-NavgationHeight-216-100)];
  scrView.pagingEnabled=YES;
  scrView.backgroundColor=[UIColor whiteColor];
  scrView.delegate=self;
  [bgscrView addSubview:scrView];
  
  chatInput = [[THChatInput alloc] init];
  chatInput.frame = CGRectMake(0,[UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, 44);
  chatInput.delegate = self;
  [self.view insertSubview:chatInput aboveSubview:scrView];
  mytreeView = [[UITableView alloc] init];
  
  mytreeView.delegate = self;
  mytreeView.dataSource = self;
  [mytreeView setBackgroundColor:[UIColor colorWithWhite:0.97 alpha:1.0]];
  
  [bgscrView addSubview:mytreeView];
  
  if (scrView.frame.size.height < imageMaxHeight && imageMaxHeight <= SUPPORT_MAX_HEIGHT) {
    self.scrView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, imageMaxHeight);
    bgscrView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, imageMaxHeight+400);
    
  }else if(imageMaxHeight > SUPPORT_MAX_HEIGHT)
  {
    self.scrView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, SUPPORT_MAX_HEIGHT);
    bgscrView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, SUPPORT_MAX_HEIGHT+KEYBOARD_HEIGHT+240);
    
  }
  pageControl=[[UIPageControl alloc] initWithFrame:CGRectMake(scrView.frame.origin.x, scrView.frame.origin.y+scrView.frame.size.height-20, scrView.frame.size.width, 20)];
  pageControl.pageIndicatorTintColor = [UIColor whiteColor];
  pageControl.currentPageIndicatorTintColor = [UIColor redColor];
  pageControl.hidden = YES;
  [bgscrView addSubview:pageControl];
  
  
    //加载描述文字
   [self displayTextView];
//  UILabel *lblText = [[UILabel alloc] initWithFrame:CGRectMake(0, scrView.frame.origin.y+scrView.frame.size.height, widthScreen, 100)];
//  lblText.font = [UIFont systemFontOfSize:17.0];
//  lblText.textColor = [UIColor blackColor];
//  lblText.backgroundColor = [UIColor whiteColor];
//  CGSize sizecat = [description sizeWithFont:lblText.font constrainedToSize:CGSizeMake(lblText.frame.size.width, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
//
//  lblText.frame = CGRectMake(0, lblText.frame.origin.y, widthScreen,sizecat.height);
//  lblText.text = description;
//  [bgscrView addSubview:lblText];
    //加载图片
  if (loadImage) {
    [self loadImageView];
  }else
  {
  [self loadDeafultImageView];
  }
}
- (void)addButton:(float)heightY
{
  float widthScreen = [UIScreen mainScreen].bounds.size.width;
    //功能添加
  UIView *imgView = [[UIView alloc] initWithFrame:CGRectMake(scrView.frame.origin.x, heightY, widthScreen, 40)];
  imgView.backgroundColor = [UIColor colorWithRed:247.0/255.0 green:247.0/255.0 blue:247.0/255.0 alpha:1.0];
  imgView.layer.borderWidth = 1;
  imgView.layer.borderColor = [[UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1.0] CGColor];
  [self.bgscrView addSubview:imgView];
    //收藏
  favbutton =[UIButton buttonWithType:UIButtonTypeCustom];
    if (isFav) {
        [self.favbutton setImage:[UIImage imageNamed:@"toolbar_fav_press"] forState:0];
    }else
        [favbutton setImage:[UIImage imageNamed:@"toolbar_fav_default"] forState:0];
  
  [favbutton setImageEdgeInsets:UIEdgeInsetsMake(11, 11, 11, 11)];
  favbutton.frame = CGRectMake(60, 0, 40, 40);
  [favbutton addTarget:self action:@selector(favButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    //[emailbutton setTitle:@"邮件" forState:0];
  [imgView addSubview:favbutton];
  
  self.favLbl = [[UILabel alloc] initWithFrame:CGRectMake(94, 5, 50, 30)];
  self.favLbl.backgroundColor = [UIColor clearColor];
  self.favLbl.text = [NSString stringWithFormat:@"%d",self.favCount];
  self.favLbl.textColor = [UIColor colorWithRed:64.0/255.0 green:111.0/255.0 blue:176.0/255.0 alpha:1.0];
  self.favLbl.font = [UIFont systemFontOfSize:17.0];
  [imgView addSubview:self.favLbl];
    //回复 主评论
  UIButton *commentbutton =[UIButton buttonWithType:UIButtonTypeCustom];
  [commentbutton setImage:[UIImage imageNamed:@"detail-comment-unselect"] forState:UIControlStateNormal];
  [commentbutton setImage:[UIImage imageNamed:@"detail-comment-select"] forState:UIControlStateHighlighted];
  [commentbutton setImageEdgeInsets:UIEdgeInsetsMake(11, 11, 11, 11)];
  commentbutton.frame = CGRectMake(0, 0, 40, 40);
  [commentbutton addTarget:self action:@selector(commentButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    //[catbutton setTitle:@"分类" forState:0];
  [imgView addSubview:commentbutton];
  
    //分享
  UIButton *sharebutton =[UIButton buttonWithType:UIButtonTypeCustom];
  sharebutton.hidden = YES;
  [sharebutton setImage:[UIImage imageNamed:@"image-myshare"] forState:UIControlStateNormal];
  [sharebutton setImageEdgeInsets:UIEdgeInsetsMake(11, 11, 11, 11)];
  sharebutton.frame = CGRectMake(260, 0, 40, 40);
  [sharebutton addTarget:self action:@selector(shareButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    //[catbutton setTitle:@"分类" forState:0];
  [imgView addSubview:sharebutton];
  
  self.commentLbl = [[UILabel alloc] initWithFrame:CGRectMake(34, 5, 50, 30)];
  self.commentLbl.backgroundColor = [UIColor clearColor];
  self.commentLbl.text = [NSString stringWithFormat:@"%d",self.cmtCount];
  self.commentLbl.textColor = [UIColor colorWithRed:64.0/255.0 green:111.0/255.0 blue:176.0/255.0 alpha:1.0];
  self.commentLbl.font = [UIFont systemFontOfSize:17.0];
  [imgView addSubview:self.commentLbl];
  
  self.mytreeView.frame = CGRectMake(0, heightY+40, widthScreen, 330);
  
  if (scrView.frame.size.height < imageMaxHeight && imageMaxHeight <= SUPPORT_MAX_HEIGHT) {
    self.scrView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, imageMaxHeight);
  }else if(imageMaxHeight > SUPPORT_MAX_HEIGHT)
  {
    self.scrView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, SUPPORT_MAX_HEIGHT);
  }
  bgscrView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, heightY+40+330+NavgationHeight);
}
- (void)displayTextView
{
  float widthScreen = [UIScreen mainScreen].bounds.size.width;
    self.title = detailuserName;
//  UILabel *namelbl = [[UILabel alloc] init];
//  namelbl.textColor = [UIColor redColor];
//  namelbl.text = [NSString stringWithFormat:@"%@:",detailuserName];
//  namelbl.numberOfLines = 0;
//  namelbl.textAlignment = NSTextAlignmentLeft;
//  namelbl.backgroundColor = [UIColor whiteColor];
//  CGSize size = [[NSString stringWithFormat:@"%@:",detailuserName] sizeWithFont:namelbl.font constrainedToSize:CGSizeMake(namelbl.frame.size.width, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
//  namelbl.frame = CGRectMake(0, scrView.frame.origin.y+scrView.frame.size.height, size.width , 20);
//  [bgscrView addSubview:namelbl];
//  
//  UILabel *lblText = [[UILabel alloc] initWithFrame:CGRectMake(namelbl.frame.size.width-2, scrView.frame.origin.y+scrView.frame.size.height, widthScreen, 100)];
//  lblText.numberOfLines = 0;
//  lblText.font = [UIFont systemFontOfSize:17.0];
//  lblText.textColor = [UIColor blackColor];
//  lblText.backgroundColor = [UIColor whiteColor];
//  CGSize sizecat = [description sizeWithFont:lblText.font constrainedToSize:CGSizeMake(lblText.frame.size.width, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
//  lblText.frame = CGRectMake(namelbl.frame.size.width,scrView.frame.origin.y+scrView.frame.size.height,widthScreen -size.width,sizecat.height);
//  lblText.text = description;
//  [bgscrView addSubview:lblText];
  UILabel *lablText = [[UILabel alloc] initWithFrame:CGRectMake(5, scrView.frame.origin.y+scrView.frame.size.height+10, widthScreen-10, 100)];
//  lablText.layer.borderColor = [UIColor lightGrayColor].CGColor;
//  lablText.layer.borderWidth = 0.5;
//  lablText.layer.cornerRadius = 5.0;
  lablText.numberOfLines = 0;
  lablText.font = [UIFont systemFontOfSize:17.0];
  lablText.textAlignment = NSTextAlignmentLeft;
  NSString *str = [NSString stringWithFormat:@"%@:%@",detailuserName,descriptions];

  NSRange rangeName = [str rangeOfString:detailuserName];
  
  NSMutableAttributedString *changestr = [[NSMutableAttributedString alloc] initWithString:str];
  [changestr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:64.0/255.0 green:111.0/255.0 blue:176.0/255.0 alpha:1.0] range:rangeName];
 
  CGSize sizecat;
#ifdef __IPHONE_7_0
  sizecat = [str boundingRectWithSize:CGSizeMake(lablText.frame.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17.0]} context:nil].size;
#else
  sizecat = [str sizeWithFont:[UIFont systemFontOfSize:17.0] constrainedToSize:CGSizeMake(lablText.frame.size.width, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
#endif
  

  lablText.attributedText = changestr;
  lablText.frame = CGRectMake(5,scrView.frame.origin.y+scrView.frame.size.height+10,widthScreen-10,sizecat.height);
  [bgscrView addSubview:lablText];
  
  float yHeight = lablText.frame.origin.y+lablText.frame.size.height+10;
  
  UILabel *departlbl = [[UILabel alloc] initWithFrame:CGRectMake(5, yHeight, widthScreen-10 , 50)];
  departlbl.backgroundColor = [UIColor whiteColor];
  departlbl.textColor = [UIColor colorWithRed:0.0/255.0 green:114.0/255.0 blue:252.0/255.0 alpha:1.0];
  departlbl.text = [self getArratString:deparmentArray part:partArray];
  departlbl.numberOfLines = 10;
  departlbl.font = [UIFont systemFontOfSize:15.0];
  departlbl.textAlignment = NSTextAlignmentLeft;
  CGSize sizeDep ;
#ifdef __IPHONE_7_0
  sizeDep = [departlbl.text boundingRectWithSize:CGSizeMake(departlbl.frame.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:departlbl.font} context:nil].size;
#else
  sizeDep = = [departlbl.text sizeWithFont:departlbl.font constrainedToSize:CGSizeMake(departlbl.frame.size.width, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
#endif
  departlbl.frame = CGRectMake(5, yHeight, widthScreen-10 , sizeDep.height);
  [bgscrView addSubview:departlbl];
    //功能按钮
  [self addButton:yHeight+sizeDep.height];
}
- (NSString *)getArratString:(NSArray *)arr part:(NSArray *)arr2
{
  NSString*str;
  NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:arr.count+arr2.count];
  for (int i = 0; i< arr2.count; i++) {
    [tempArray addObject:[Strings getAnatomyStringCN:[arr2 objectAtIndex:i]]];
  }
  for (int i = 0; i< arr.count; i++) {
    [tempArray addObject:[Strings getDepartmentStringCN:[arr objectAtIndex:i]]];
  }
    if (tempArray.count > 1) {
      str =[tempArray componentsJoinedByString:@" | "];
    }else if(tempArray.count == 1)
    {
      str = [tempArray objectAtIndex:0];
    }else
      return nil;
   return str;
}
- (void)loadDeafultImageView
{
  [scrView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
  
  NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/imageFile/smallPicture"];
  NSString *filePath = [path stringByAppendingPathComponent:self.coverPicId];
  pageControl.numberOfPages=1;
  UIImageView *imgview=[[UIImageView alloc] init];
  imgview.frame = CGRectMake(0, 0, scrView.frame.size.width, scrView.frame.size.height);
  UIImage *tempImg=[UIImage imageWithContentsOfFile:filePath];
  [imgview setContentScaleFactor:[[UIScreen mainScreen] scale]];
  imgview.autoresizingMask = UIViewAutoresizingFlexibleHeight;
  imgview.contentMode=UIViewContentModeCenter;
  imgview.clipsToBounds=YES;
  [imgview setImage:tempImg];
  [scrView addSubview:imgview];
  
  self.imagehud = [MBProgressHUD showHUDAddedTo:imgview animated:YES];
  self.imagehud.progress = 0.0;
  self.imagehud.mode = MBProgressHUDModeDeterminate;
  self.imagehud.color = [UIColor colorWithRed:64.0/255.0 green:111.0/255.0 blue:176.0/255.0 alpha:0.5];
  self.imagehud.delegate = self;
  self.imagehud.labelText = @"图片加载中";
    // [self.imagehud showWhileExecuting:@selector(myProgressTask) onTarget:self withObject:nil animated:YES];
}
- (void)hudWasHidden:(MBProgressHUD *)hud {
    // Remove HUD from screen when the HUD was hidded
  [self.imagehud removeFromSuperview];
  self.imagehud = nil;
}
- (void)loadImageView
{
  [scrView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
  
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    scrView.contentSize=CGSizeMake(imagePathArray.count*scrView.frame.size.width, scrView.frame.size.height);
    dispatch_async(dispatch_get_main_queue(), ^{
      pageControl.numberOfPages=imagePathArray.count;
      if (pageControl.numberOfPages > 1) {
        pageControl.hidden = NO;
      }
    });
    
    for (int i=0; i<imagePathArray.count; i++) {
      TapImageView *imgview=[[TapImageView alloc] init];
      imgview.frame = CGRectMake(i*scrView.frame.size.width, 0, scrView.frame.size.width, scrView.frame.size.height);
      UIImage *tempImg=[UIImage imageWithContentsOfFile:[imagePathArray objectAtIndex:i]];
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
        imgview.t_delegate = self;
        imgview.tag = 10 + i;
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
#pragma mark - UIScrollView Delegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    pageControl.currentPage=floor(scrollView.contentOffset.x/scrollView.frame.size.width);;
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
  NSLog(@".....");
}
#pragma mark - HTTP REQUEST
- (void)requestFinished:(ASIHTTPRequest *)request{
  NSString* responseString = [request responseString];
  NSLog(@"xxxx%@",responseString);
  NSString* rType =[[request userInfo] objectForKey:REQUEST_TYPE];
  NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/imageFile/"];
  if ([rType isEqualToString:@"getImageDetail"])
  {
    NSDictionary *info;
    if (responseString ==(id)[NSNull null] || responseString.length ==0 || [responseString isEqualToString:@"internal server error"])
    {
      info =nil;
    }
    else
    {
      info = [iosVersionChecker parseJSONObjectFromJSONString:responseString];
      NSArray *arr = [info objectForKey:@"picIds"];
      detailuserName = [info objectForKey:@"username"];
      
      descriptions = [info objectForKey:@"description"] ;
      deparmentArray = [info objectForKey:@"departments"];
      partArray = [info objectForKey:@"parts"];
      self.isFav = [[info objectForKey:@"fav"] boolValue];
      self.cmtCount = [[info objectForKey:@"cmtCount"] intValue];
      self.favCount = [[info objectForKey:@"favCount"] intValue];
      self.coverPicId = [info objectForKey:@"coverPicId"];
      if (arr.count > 6) {
        return;
      }else
      {
        [self displayDeatilView:NO];
          //下载图片
        for (int i = 0; i < arr.count; i++) {
          NSString *imagePath = [path stringByAppendingPathComponent:[arr objectAtIndex:i]];
          [imagePathArray addObject:imagePath];
          [self downLoadImage:[arr objectAtIndex:i] reType:[NSString stringWithFormat:@"%zd:%d",arr.count-1,i]];
        }
      }
    }
  }else if ([rType isEqualToString:@"getDetailParentDiscuss"])
  {
    NSDictionary *info;
    if (responseString ==(id)[NSNull null] || responseString.length ==0 || [responseString isEqualToString:@"internal server error"])
    {
      info =nil;
    }
    else
    {
      info = [iosVersionChecker parseJSONObjectFromJSONString:responseString];
      self.parentArray = [NSMutableArray arrayWithArray:[info objectForKey:@"comment"]];
      if (self.parentArray.count > 0) {
        [self.mytreeView reloadData];
      }
    }
  }else if ([rType isEqualToString:@"getChildernDiscuss"])
  {
    NSArray *info;
    if (responseString ==(id)[NSNull null] || responseString.length ==0 || [responseString isEqualToString:@"internal server error"])
    {
      info =nil;
    }
    else
    {
      NSString *parentId = [request.url lastPathComponent];
      [allselectId addObject:parentId];
      info = [iosVersionChecker parseJSONObjectFromJSONString:responseString];
      NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(self.selectIndex+1,info.count)];
      
        //      for (NSDictionary *dic in info) {
        //        [self.parentArray insertObject:dic atIndex:self.selectIndex+1];
        //      }
      [self.parentArray insertObjects:info atIndexes:indexes];
      NSMutableArray *cellIndexPaths = [[NSMutableArray alloc] initWithCapacity:info.count];
      for(int i = 0 ; i<info.count; i++) {
        [cellIndexPaths addObject:[NSIndexPath indexPathForRow:self.selectIndex+i+1 inSection:0]];
      }
      [self.selectIndexSet setObject:[NSNumber numberWithInteger:info.count] forKey:parentId];
      [self.mytreeView insertRowsAtIndexPaths:cellIndexPaths withRowAnimation:UITableViewRowAnimationTop];
      [self.mytreeView reloadData];
        //[self.childerArray removeAllObjects];
        // NSMutableArray *arr = [NSMutableArray arrayWithArray:info];
      
    }
  }else if ([rType isEqualToString:@"creatNewChildrenDiscuss" ])
  {
    NSDictionary *info;
    if (responseString ==(id)[NSNull null] || responseString.length ==0 || [responseString isEqualToString:@"internal server error"])
    {
      info =nil;
    }
    else
    {
      info = [iosVersionChecker parseJSONObjectFromJSONString:responseString];
      
      if ([info objectForKey:@"ok"]) {
        self.commentLbl.text = [NSString stringWithFormat:@"%d",[self.commentLbl.text intValue]+1];
        
        NSString *ids  = [[info objectForKey:@"comment"] objectForKey:@"parentId"];
          //未展开
        if (![self isSelectId:ids]) {
          [self requestChilderenDisscuss:ids];
        }else//已展开
        {
          int tempInt = [[self.selectIndexSet objectForKey:ids] intValue];
          [self.selectIndexSet setObject:[NSNumber numberWithInt:tempInt+1] forKey:ids];
          [self.parentArray insertObject:[info objectForKey:@"comment"] atIndex:self.selectIndex+1+tempInt];
          
          [self.mytreeView reloadData];
          [self.mytreeView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectIndex+1+tempInt inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
        }
      }
    }
  }else if ([rType isEqualToString:@"creatNewParentDiscuss"])
  {
    NSDictionary *info;
    if (responseString ==(id)[NSNull null] || responseString.length ==0 || [responseString isEqualToString:@"internal server error"])
    {
      info =nil;
    }
    else
    {
      info = [iosVersionChecker parseJSONObjectFromJSONString:responseString];
      if ([info objectForKey:@"ok"]) {
        self.commentLbl.text = [NSString stringWithFormat:@"%d",[self.commentLbl.text intValue]+1];
        
        [self.parentArray addObject:[info objectForKey:@"comment"]];
        [self.mytreeView reloadData];
        [self.mytreeView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.parentArray.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
      }
    }
  }else if([rType isEqualToString:@"ADD_FAV"])
  {
    NSDictionary *info;
    if (responseString ==(id)[NSNull null] || responseString.length ==0 || [responseString isEqualToString:@"internal server error"])
    {
      info =nil;
    }
    else
    {
      info = [iosVersionChecker parseJSONObjectFromJSONString:responseString];
      if ([info objectForKey:@"ok"]) {
        if (isFav) {
          self.isFav = NO;
          [favbutton setImage:[UIImage imageNamed:@"toolbar_fav_default"] forState:0];
          self.favLbl.text = [NSString stringWithFormat:@"%d",[self.favLbl.text intValue]-1];
          [self showAlertViewWithTitle:RUIYI_TITLE andMessage:@"取消收藏成功！"];
        }else
        {
          [self.favbutton setImage:[UIImage imageNamed:@"toolbar_fav_press"] forState:0];
          self.isFav = YES;
          self.favLbl.text = [NSString stringWithFormat:@"%d",[self.favLbl.text intValue]+1];
          [self showAlertViewWithTitle:RUIYI_TITLE andMessage:@"收藏成功！"];
        }
        
      }
    }
  }else
  {
    NSArray *arr = [rType componentsSeparatedByString:@"::"];
    if (arr.count == 2) {
      if ([[arr objectAtIndex:0] isEqualToString:@"upDownDiscuss"]) {
        NSDictionary *info;
        if (responseString ==(id)[NSNull null] || responseString.length ==0 || [responseString isEqualToString:@"internal server error"])
        {
          info =nil;
        }
        else
        {
          info = [iosVersionChecker parseJSONObjectFromJSONString:responseString];
          if ([[info objectForKey:@"ok"] intValue] == 1) {
            NSString *single = [request.url lastPathComponent];
            if ([single isEqualToString:@"+"]) {
              self.addlbl.text = [NSString stringWithFormat:@"%d",[self.addlbl.text intValue]+1];
              NSDictionary *dic = [self.parentArray objectAtIndex:[[arr objectAtIndex:1] intValue]];
              NSArray *arrKey = [dic allKeys];
              NSMutableDictionary *newDic = [[NSMutableDictionary alloc] initWithCapacity:arr.count];
              for (int i = 0; i < arrKey.count; i++) {
                [newDic setObject:[dic objectForKey:[arrKey objectAtIndex:i]] forKey:[arrKey objectAtIndex:i]];
              }
              [newDic setObject:[NSNumber numberWithInt:[self.addlbl.text intValue]] forKey:@"upCount"];
              [self.parentArray replaceObjectAtIndex:[[arr objectAtIndex:1] intValue] withObject:newDic];
            }else
            {
              self.reducelbl.text = [NSString stringWithFormat:@"%d",[self.reducelbl.text intValue]+1];
              NSDictionary *dic = [self.parentArray objectAtIndex:[[arr objectAtIndex:1] intValue]];
              NSArray *arrKey = [dic allKeys];
              NSMutableDictionary *newDic = [[NSMutableDictionary alloc] initWithCapacity:arr.count];
              for (int i = 0; i < arrKey.count; i++) {
                [newDic setObject:[dic objectForKey:[arrKey objectAtIndex:i]] forKey:[arrKey objectAtIndex:i]];
              }
              [newDic setObject:[NSNumber numberWithInt:[self.reducelbl.text intValue]] forKey:@"downCount"];
              [self.parentArray replaceObjectAtIndex:[[arr objectAtIndex:1] intValue] withObject:newDic];
            }
          }else
          {
            [self showAlertViewWithTitle:RUIYI_TITLE andMessage:@"该评论已经被您评价过了。"];
          }
        }
        
      }
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
}
- (void)showAlertViewWithTitle:(NSString *)title andMessage:(NSString *)message{
  UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
  [alertView show];
}
- (void)downLoadImage:(NSString *)name reType:(NSString *)type
{
  NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/imageFile/"];
  
  NSString *filePath = [path stringByAppendingPathComponent:name];
  if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
    UIImage *image = [UIImage imageWithContentsOfFile:filePath];
    if (image.size.height > imageMaxHeight) {
      imageMaxHeight = image.size.height;
    }
    if (type.length > 0) {
      NSArray *arr = [type componentsSeparatedByString:@":"];
      if (arr.count == 2) {
        if ([[arr objectAtIndex:0] intValue] == [[arr objectAtIndex:1] intValue]) {
          if ([[arr objectAtIndex:0] intValue] == 0 && networkQueue.requestsCount > 0) {
            [self showAllPicture:NO];
          }else
          {
            [self showAllPicture:YES];
          }
        }
      }
    }
  }else
  {
    
    [networkQueue setRequestDidFinishSelector:@selector(imageDownloadComplete:)];//队列加载完成时调用的方法
    [networkQueue setRequestDidFailSelector:@selector(imageFetchFailed:)];//队列加载出错时调用的方法
    [networkQueue setQueueDidFinishSelector:@selector(allDownloadCompleteFinish:)];//队列全部结束
    [networkQueue setDelegate:self];
    [networkQueue setDownloadProgressDelegate:self.progressView];
    [networkQueue addOperation:[imdRequest downLoadPictureRequest:[NSString stringWithFormat:@"%@/%@",[UrlCenter urlOfType:DOWNLOAD_IMAGE],name] requestType:type]];
    [networkQueue go];
  }
}
- (void)imageDownloadComplete:(ASIHTTPRequest*)request//加载完成时
{
  self.imagehud.progress = self.progressView.progress;
  
  //下载出错删除错误文件
  NSFileManager *fileManager = [NSFileManager defaultManager];
  NSString *downloadpath = [request downloadDestinationPath];
  
  if (request.responseStatusCode > 400) {
    if ([fileManager fileExistsAtPath:downloadpath]) {
      [fileManager removeItemAtPath:downloadpath error:nil];
    }
  }
    //判断缩略图目录是否存在封面图片，存在不存储，不存在就存储
  NSString *name = [[request url] lastPathComponent];
  if ([name isEqualToString:self.coverPicId]) {
    NSString *documentpath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/imageFile/smallPicture/"];
    NSString *filePath = [documentpath stringByAppendingPathComponent:name];
    if (![fileManager fileExistsAtPath:filePath]) {
      [fileManager copyItemAtPath:downloadpath toPath:filePath error:nil];
    }
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(refreshSelectImage:)]) {
      [self.delegate refreshSelectImage:self.index];
    }
  }
  UIImage *image = [UIImage imageWithContentsOfFile:[request downloadDestinationPath]];
  if (image) {
    if (image.size.height > imageMaxHeight) {
      imageMaxHeight = image.size.height;
    }
  }
}
- (void)imageFetchFailed:(ASIHTTPRequest *)request//加载失败时
{
  NSLog(@"Failed to download images");
}
- (void)allDownloadCompleteFinish:(ASIHTTPRequest *)request
{
  if (imagePathArray.count == 1) {
    [self showAllPicture:NO];
  }else
  {
    [self showAllPicture:YES];
  }
}
- (void)requestChilderenDisscuss:(NSString *)parentid
{
  if (request_childeren_discuss != nil) {
    [request_childeren_discuss cancel];
  }
  request_childeren_discuss = [imdRequest getRequest:[NSString stringWithFormat:@"%@/%@",[UrlCenter urlOfType:GET_CHIRLD_DISCUSS],parentid] delegate:self requestType:@"getChildernDiscuss"];
}
- (void)postDiscuss:(NSMutableDictionary *)dic
{
  if (self.childRequest != nil) {
    [self.childRequest cancel];
  }
  self.childRequest = [imdRequest postRequest:[UrlCenter urlOfType:POST_DISCUSS] delegate:self requestType:@"creatNewChildrenDiscuss" postData:dic json:YES];
}
- (void)postParentDiscuss:(NSMutableDictionary *)dic
{
  if (self.parentRequest != nil) {
    [self.parentRequest cancel];
  }
  self.parentRequest = [imdRequest postRequest:[UrlCenter urlOfType:POST_DISCUSS] delegate:self requestType:@"creatNewParentDiscuss" postData:dic json:YES];
}

- (void)upDownDiscuss:(NSString *)idD upOrdown:(NSString *)operate selectIndex:(NSInteger)index
{
  if (self.upCommentRequest != nil) {
    [self.upCommentRequest cancel];
  }
  self.upCommentRequest = [imdRequest getRequest:[NSString stringWithFormat:@"%@/%@/%@",[UrlCenter urlOfType:UPDOWN_DISCUSS],idD,operate] delegate:self requestType:[NSString stringWithFormat: @"upDownDiscuss::%zd",index]];
}
#pragma mark - UIBUTTON CLICK
- (void)favButtonClick:(id)sender
{
  if (self.favRequest != nil) {
    [self.favRequest cancel];
  }
    //添加，取消 收藏
   self.favRequest = [imdRequest getRequest:[NSString stringWithFormat:@"%@/%@",[UrlCenter urlOfType:ADD_FAV],self.caseId] delegate:self requestType:@"ADD_FAV"];
//    //查看收藏状态
    //  [imdRequest getRequest:[NSString stringWithFormat:@"%@/%@",[UrlCenter urlOfType:IS_FAV],self.title] delegate:self requestType:@"GET_FAV_LIST"];

}
- (void)shareButtonClick:(UIView *)sender
{
  if (imagePathArray.count == 0) {
    return;
  }
  NSString *imagePath;
  NSArray *shareList;
  if (sender.tag == 1000) {
    imagePath = [imagePathArray objectAtIndex:currentIndex];
   shareList  = [ShareSDK getShareListWithType:ShareTypeSinaWeibo,ShareTypeTencentWeibo,ShareTypeWeixiSession,ShareTypeWeixiTimeline,ShareTypeWeixiFav,ShareTypeQQSpace,ShareTypeQQ,ShareTypeCopy, nil];
  }else
  {
    shareList  = [ShareSDK getShareListWithType:ShareTypeSinaWeibo,ShareTypeTencentWeibo,ShareTypeWeixiSession,ShareTypeWeixiTimeline,ShareTypeWeixiFav,ShareTypeQQSpace,ShareTypeQQ,ShareTypeSMS,ShareTypeMail,ShareTypeCopy, nil];
   imagePath = [imagePathArray objectAtIndex:0];
  }
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
    UIImage *image = [Strings imageWithSourceImage:[UIImage imageWithContentsOfFile:imagePath] WaterMask:[UIImage imageNamed:@"image-imd.png"]];
    dispatch_async(dispatch_get_main_queue(), ^{
        //构造分享内容
      id<ISSContent> publishContent = [ShareSDK content:[NSString  stringWithFormat:@"%@\n下载地址:%@",descriptions,APP_TUIJIAN_URL]
                                         defaultContent:@""
                                                  image:[ShareSDK jpegImageWithImage:image quality:0.5]
                                                  title:@"我分享了一张“睿医图志”的照片，快来围观！"
                                                    url:APP_TUIJIAN_URL
                                            description:[NSString  stringWithFormat:@"%@\n下载地址:%@",descriptions,APP_TUIJIAN_URL]
                                              mediaType:SSPublishContentMediaTypeNews];
        //短信分享
       [publishContent addSMSUnitWithContent:[NSString stringWithFormat:@"%@\n下载地址:%@",TUIJIAN,APP_TUIJIAN_URL]];
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
                                  sharehud.labelText = @"分享成功";
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
                                    sharehud.labelText = @"分享失败";
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
                                    sharehud.labelText = @"分享中。。";
                                  }
                                  [sharehud show:YES];
                                  [sharehud hide:YES afterDelay:2];
                                }
                              }];
    });
  });
  
}
- (void)commentButtonClick:(id)sender
{
  if (self.chatInput.textView.isFirstResponder) {
    [self.chatInput resignFirstResponder];
  }else
  {
  self.chatInput.isFather = YES;
  if (self.parentArray.count> 0) {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.parentArray count]-1 inSection:0];
    CGRect frame = [mytreeView rectForRowAtIndexPath:indexPath];
      //底层view向上移动
    [self.bgscrView setContentOffset:CGPointMake(0,self.mytreeView.frame.origin.y+292+64-[UIScreen mainScreen].bounds.size.height+frame.size.height+frame.origin.y)];
    [self.mytreeView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
  }else
  {
      //底层view向上移动
    [self.bgscrView setContentOffset:CGPointMake(0,self.mytreeView.frame.origin.y+292+64-[UIScreen mainScreen].bounds.size.height)];
  }
    [self.chatInput beganEditing];
//    self.tapper = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedView:)];
//    [self.view addGestureRecognizer:self.tapper];
  }
}
#pragma mark - UITableView Delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   return self.parentArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  
  NSDictionary *cellInfo = [self.parentArray objectAtIndex:indexPath.row];
  NSString *parentId = [cellInfo objectForKey:@"parentId"];
  NSString *userName = [cellInfo objectForKey:@"username"];
  NSString *content = [cellInfo objectForKey:@"content"];
  NSString *atName = [cellInfo objectForKey:@"atname"];
  NSString *userContent;
  if (parentId.length > 0) {
    if (atName.length > 0) {
      if ([userName isEqualToString:atName]) {
        userContent = [NSString stringWithFormat:@"%@:%@",atName,content];
      }else
        userContent = [NSString stringWithFormat:@"%@ 回复 %@:%@",userName,atName,content];
    }else
    {
      userContent = [NSString stringWithFormat:@"%@:%@",userName,content];
    }
    CGSize size;
#ifdef __IPHONE_7_0
    size = [userContent boundingRectWithSize:CGSizeMake(290.0, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15.0]} context:nil].size;
#else
    size = [userContent sizeWithFont:[UIFont systemFontOfSize:15.0] constrainedToSize:CGSizeMake(290.0, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
#endif
    return size.height+12;
  }else
  {
  userContent = [NSString stringWithFormat:@"%@:%@",userName,content];
    CGSize size;
#ifdef __IPHONE_7_0
    size = [userContent boundingRectWithSize:CGSizeMake(280.0, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15.0]} context:nil].size;
#else
   size = [userContent sizeWithFont:[UIFont systemFontOfSize:15.0] constrainedToSize:CGSizeMake(280.0, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
#endif
    return size.height+36;
  }
  return 40;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
      
    }
  for(UIView *view in cell.contentView.subviews)
  {
    [view removeFromSuperview];
  }
  
    //text button
  UILabel *lblText = [[UILabel alloc] initWithFrame:CGRectMake(30, 6, 280, 40)];
  lblText.numberOfLines = 0;
  lblText.tag = 100;
  lblText.backgroundColor = [UIColor clearColor];
  lblText.font = [UIFont systemFontOfSize:15.0];
  lblText.textColor = [UIColor darkGrayColor];
  [cell.contentView addSubview:lblText];
  
    //点赞 button
  MyButton *addButton = [MyButton buttonWithType:UIButtonTypeCustom];
  [addButton setImage:[UIImage imageNamed:@"detail-upbutton"] forState:0];
  addButton.frame = CGRectMake(20, 20, 70, 40);
  [addButton setImageEdgeInsets:UIEdgeInsetsMake(5, 0 , 0, 0)];
  addButton.tag = 101;
  addButton.backgroundColor = [UIColor clearColor];
  [addButton addTarget:self action:@selector(upButtonClick:) forControlEvents:UIControlEventTouchUpInside];
  [cell.contentView addSubview:addButton];
  
    //被赞的次数
  UILabel *addLable = [[UILabel alloc] initWithFrame:CGRectMake(35, 14, 25, 18)];
  addLable.tag = 104;
  addLable.font = [UIFont systemFontOfSize:12.0];
  addLable.textColor = [UIColor colorWithRed:64.0/255.0 green:111.0/255.0 blue:176.0/255.0 alpha:1.0];
  addLable.textAlignment = NSTextAlignmentCenter;
  [addButton addSubview:addLable];
    //踩 button
  MyButton *reduceButton = [MyButton buttonWithType:UIButtonTypeCustom];
  [reduceButton setImage:[UIImage imageNamed:@"detail-downbutton"] forState:0];
  
  reduceButton.frame = CGRectMake(90, 20, 70, 40);
  reduceButton.tag = 102;
  reduceButton.backgroundColor = [UIColor clearColor];
  [reduceButton setImageEdgeInsets:UIEdgeInsetsMake(5, 0 , 0, 0)];
  [reduceButton addTarget:self action:@selector(downButtonClick:) forControlEvents:UIControlEventTouchUpInside];
  [cell.contentView addSubview:reduceButton];
  
    //被踩的次数
  UILabel *reduceLable = [[UILabel alloc] initWithFrame:CGRectMake(35, 14, 25, 18)];
  reduceLable.font = [UIFont systemFontOfSize:12.0];
  reduceLable.tag = 105;
  reduceLable.textColor = [UIColor grayColor];
  reduceLable.textAlignment = NSTextAlignmentCenter;
  [reduceButton addSubview:reduceLable];
  
  UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(260, 50, 60, 20)];
  lbl.backgroundColor = [UIColor clearColor];
  lbl.text = @"回复";
  lbl.textColor = [UIColor grayColor];
  lbl.font = [UIFont boldSystemFontOfSize:15.0];
  [cell.contentView addSubview:lbl];
    //展开 关闭 button
  MyButton *developButton = [MyButton buttonWithType:UIButtonTypeCustom];
  [developButton setImage:[UIImage imageNamed:@"comment-close"] forState:0];
  developButton.frame = CGRectMake(0, 0, 40, 60);
  [developButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0 , 30, 12)];
  developButton.tag = 103;
  developButton.hidden = YES;
  developButton.backgroundColor = [UIColor clearColor];
  [developButton addTarget:self action:@selector(developButtonClick:) forControlEvents:UIControlEventTouchUpInside];
  [cell.contentView addSubview:developButton];
  
    NSString *parentId = [[self.parentArray objectAtIndex:indexPath.row] objectForKey:@"parentId"];
    NSString *ids = [[self.parentArray objectAtIndex:indexPath.row] objectForKey:@"id"];
    MyButton *btn = (MyButton *)[cell.contentView viewWithTag:101];
    btn.cellIndex = indexPath;
    
    MyButton *btn2 = (MyButton *)[cell.contentView viewWithTag:102];
    btn2.cellIndex = indexPath;
    
    UILabel *textLbl = (UILabel *)[cell.contentView viewWithTag:100];
    
    MyButton *btn3 = (MyButton *)[cell.contentView viewWithTag:103];
    btn3.cellIndex = indexPath;
    
    
    if ([self isSelectId:ids]) {
        [btn3 setImage:[UIImage imageNamed:@"comment-close"] forState:0];
    }else
        [btn3 setImage:[UIImage imageNamed:@"comment-open"] forState:0];
  
  NSString *userName = [[self.parentArray objectAtIndex:indexPath.row] objectForKey:@"username"];
  NSString *content = [[self.parentArray objectAtIndex:indexPath.row] objectForKey:@"content"];
  NSString *atName = [[self.parentArray objectAtIndex:indexPath.row] objectForKey:@"atname"];
  int subcount = [[[self.parentArray objectAtIndex:indexPath.row] objectForKey:@"subCount"] intValue];
  addLable.text = [NSString stringWithFormat:@"%d",[[[self.parentArray objectAtIndex:indexPath.row] objectForKey:@"upCount"] intValue]];
  reduceLable.text = [NSString stringWithFormat:@"%d",[[[self.parentArray objectAtIndex:indexPath.row] objectForKey:@"downCount"] intValue]];
  NSString *userContent;
     //children
    if (parentId.length > 0) {
      textLbl.frame = CGRectMake(30, textLbl.frame.origin.y, 290, textLbl.frame.size.height);
      lbl.hidden = YES;
        btn.hidden = YES;
        btn2.hidden = YES;
        btn3.hidden = YES;
      cell.contentView.backgroundColor = [UIColor colorWithRed:242.0/255.0 green:242.0/255.0 blue:242.0/255.0 alpha:1.0];
      NSRange rangeName;
      if (atName.length > 0) {
        if ([userName isEqualToString:atName]) {
          userContent = [NSString stringWithFormat:@"%@:%@",atName,content];
          rangeName = [userContent rangeOfString:atName];
        }else
        {
          userContent = [NSString stringWithFormat:@"%@ 回复 %@:%@",userName,atName,content];
          rangeName = [userContent rangeOfString:[NSString stringWithFormat:@"%@ 回复 %@:",userName,atName]];
        }
      }else
      {
        userContent = [NSString stringWithFormat:@"%@:%@",userName,content];
        rangeName = [userContent rangeOfString:userName];
      }
      NSMutableAttributedString *changestr = [[NSMutableAttributedString alloc] initWithString:userContent];
      [changestr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:64.0/255.0 green:111.0/255.0 blue:176.0/255.0 alpha:1.0] range:rangeName];
      
      CGSize sizecat;
#ifdef __IPHONE_7_0
      sizecat = [userContent boundingRectWithSize:CGSizeMake(textLbl.frame.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15.0]} context:nil].size;
#else
      sizecat =  = [userContent sizeWithFont:[UIFont systemFontOfSize:15.0] constrainedToSize:CGSizeMake(textLbl.frame.size.width, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
#endif
      textLbl.frame = CGRectMake(30, textLbl.frame.origin.y, 290, sizecat.height);
      textLbl.attributedText = changestr;
    }else  //father
    {
      if (subcount > 0) {
        btn3.hidden = NO;
      }else
      {
        int tempInt = [[self.selectIndexSet objectForKey:ids] intValue];
        if (tempInt > 0) {
          btn3.hidden = NO;
        }else
          btn3.hidden = YES;
      }
        btn.hidden = NO;
        btn2.hidden = NO;
      lbl.hidden = NO;
        //UIColor
      userContent = [NSString stringWithFormat:@"%@:%@",userName,content];
      NSRange rangeName = [userContent rangeOfString:userName];
      NSMutableAttributedString *changestr = [[NSMutableAttributedString alloc] initWithString:userContent];
      [changestr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:64.0/255.0 green:111.0/255.0 blue:176.0/255.0 alpha:1.0] range:rangeName];
      textLbl.attributedText = changestr;
      cell.contentView.backgroundColor = UIColorFromRGB(0xF7F7F7);
      
      CGSize size;
#ifdef __IPHONE_7_0
      size = [userContent boundingRectWithSize:CGSizeMake(280.0, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15.0]} context:nil].size;
#else
     size = [userContent sizeWithFont:[UIFont systemFontOfSize:15.0] constrainedToSize:CGSizeMake(280.0, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
#endif
      textLbl.frame = CGRectMake(30, textLbl.frame.origin.y, 280, size.height);
      btn.frame = CGRectMake(btn.frame.origin.x, size.height, btn.frame.size.width ,btn.frame.size.height);
      btn2.frame = CGRectMake(btn2.frame.origin.x, size.height, btn2.frame.size.width ,btn2.frame.size.height);
      lbl.frame = CGRectMake(lbl.frame.origin.x, size.height+10, lbl.frame.size.width ,lbl.frame.size.height);
    }
  
    //    NSInteger level = [self.mytreeView levelForCellForItem:item];
    //    NSString *title;
    //    NSString *countText;
    //    NSString *userName = [dataObject.dic objectForKey:@"username"];
    //    NSString *content = [dataObject.dic objectForKey:@"content"];
    //    NSString *atName = [dataObject.dic objectForKey:@"atname"];
    //    NSString *userContent;
    //
    //    if (level > 0 && atName.length > 0) {
    //        userContent = [NSString stringWithFormat:@"<font color=\"orange\">%@<font color=\"black\"> 回复 <font color=\"orange\">%@<font color=\"black\">:%@",userName,atName,content];
    //    }else
    //    {
    //        userContent = [NSString stringWithFormat:@"<font color=\"orange\">%@<font color=\"black\">:%@",userName,content];
    //    }
    //    title = [NSString localizedStringWithFormat:@"%@", userContent];
    
  
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  self.chatInput.isFather = NO;
  if (self.chatInput.textView.isFirstResponder) {
    [self.chatInput.textView resignFirstResponder];
  }else
  {
    
    self.chatInput.selectItem = [self.parentArray objectAtIndex:indexPath.row];
    
    NSString *parentId = [[self.parentArray objectAtIndex:indexPath.row] objectForKey:@"parentId"];
    if (parentId.length > 0) {
      for (int i = 0; i< self.parentArray.count;i++) {
        NSDictionary *dic = [self.parentArray objectAtIndex:i];
        if ([[dic objectForKey:@"id"] isEqualToString:parentId]) {
          self.selectIndex = i;
          break;
        }
      }
    }else
    {
      self.selectIndex = indexPath.row;
    }
   CGRect frame = [mytreeView rectForRowAtIndexPath:indexPath];
      //底层view向上移动
    [self.bgscrView setContentOffset:CGPointMake(0,self.mytreeView.frame.origin.y+292+64-[UIScreen mainScreen].bounds.size.height+frame.size.height+frame.origin.y)];
    
    [self.mytreeView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    [self.chatInput beganEditing];
//    self.tapper = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedView:)];
//    [self.view addGestureRecognizer:self.tapper];
//    self.recognizer =  [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFrom:)];
////    [self.recognizer setDirection:UISwipeGestureRecognizerDirectionRight|UISwipeGestureRecognizerDirectionLeft|UISwipeGestureRecognizerDirectionUp|UISwipeGestureRecognizerDirectionDown];
//    [self.bgscrView addGestureRecognizer:self.recognizer];
  }
}
- (void)developButtonClick:(MyButton *)btn
{
    NSString *ids = [[self.parentArray objectAtIndex:btn.cellIndex.row] objectForKey:@"id"];
    if (![self isSelectId:ids]) {
        self.selectIndex = btn.cellIndex.row;
        [self requestChilderenDisscuss:ids];
    }else
    {
        [allselectId removeObject:ids];
        int count = [[self.selectIndexSet objectForKey:ids] intValue];
      NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(btn.cellIndex.row+1,count)];
      
      NSMutableArray *cellIndexPaths = [[NSMutableArray alloc] initWithCapacity:count];
      for(int i = 0 ; i<count; i++) {
        [cellIndexPaths addObject:[NSIndexPath indexPathForRow:btn.cellIndex.row+i+1 inSection:0]];
      }
        [self.parentArray removeObjectsAtIndexes:indexes];
        [self.mytreeView deleteRowsAtIndexPaths:cellIndexPaths withRowAnimation:UITableViewRowAnimationFade];
        // [self.mytreeView reloadRowsAtIndexPaths:@[btn.cellIndex] withRowAnimation:UITableViewRowAnimationTop];
      [self.mytreeView reloadData];
    }
   
}
- (BOOL)isSelectId:(NSString *)idT
{
    BOOL temp = NO;
    for (NSString *ids in allselectId) {
        if ([ids isEqualToString:idT]) {
            return YES;
        }
    }
    return temp;
}
#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
  if (buttonIndex == 1) {
    UIImage *oldimage = [UIImage imageWithContentsOfFile:[imagePathArray objectAtIndex:currentIndex]];
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.myScrollView];
    [self.myScrollView addSubview:hud];
    hud.labelText = @"保存中...";
    [hud show:YES];
      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
      UIImage *image = [Strings imageWithSourceImage:oldimage WaterMask:[UIImage imageNamed:@"image-imd.png"]];
       dispatch_async(dispatch_get_main_queue(), ^{
        [self.library saveImage:image toAlbum:@"睿医图志" withCompletionBlock:^(NSError *error) {
          if (error!=nil) {
            hud.labelText = @"图片保存失败";
            [hud show:YES];
            [hud hide:YES afterDelay:2];
          }else
          {
            hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
            hud.mode = MBProgressHUDModeCustomView;
            hud.labelText = @"图片已保存";
            [hud show:YES];
            [hud hide:YES afterDelay:2];
          }
        }];
      });
      });
  }else if(buttonIndex == 0)
  {
    actionSheet.tag = 1000;
    [self shareButtonClick:actionSheet];
  }
}
-(void)upButtonClick:(MyButton *)sender
{
  sender.enabled = NO;
  if (self.addlbl) {
    self.addlbl = nil;
  }
  self.addlbl = (UILabel *)[sender viewWithTag:104];
  NSString *upid = [[self.parentArray objectAtIndex:sender.cellIndex.row] objectForKey:@"id"];
  [self upDownDiscuss:upid upOrdown:@"+" selectIndex:sender.cellIndex.row];
}
-(void)downButtonClick:(MyButton *)sender
{
  sender.enabled = NO;
  if (self.reducelbl) {
    self.reducelbl = nil;
  }
  self.reducelbl = (UILabel *)[sender viewWithTag:105];
  NSString *upid = [[self.parentArray objectAtIndex:sender.cellIndex.row] objectForKey:@"id"];
  [self upDownDiscuss:upid upOrdown:@"-" selectIndex:sender.cellIndex.row];
}
- (void)showAllPicture:(BOOL)more
{
  NSLog(@"111111xx%d",more);
  if (more) {
    [self displayDeatilView:YES];
  }else
  {
    [self.imagehud showAnimated:YES whileExecutingBlock:^{
      [self myTask];
    } completionBlock:^{
      [self.imagehud removeFromSuperview];
      [self displayDeatilView:YES];
    }];
  }
}
- (void)myTask
{
  self.imagehud.progress = 0.0;
  float progress = 0.0f;
  while (progress < 1.0f)
  {
    progress += 0.01f;
    self.imagehud.progress = progress;
    usleep(10000);
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
