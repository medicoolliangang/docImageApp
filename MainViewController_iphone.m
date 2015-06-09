//
//  MainViewController_iphone.m
//  docImageApp
//
//  Created by 侯建政 on 8/5/14.
//  Copyright (c) 2014 jianzheng. All rights reserved.
//

#import "MainViewController_iphone.h"
#import "PPImageScrollingTableViewCell.h"
#import "ZYQAssetPickerController.h"
#import "UpLoadPictureViewController.h"
#import "LoginViewController_iphone.h"
#import "imdRequest.h"
#import "ASIDownloadCache.h"
#import "ASINetworkQueue.h"
#import "UrlCenter.h"
#import "Strings.h"
#import "iosVersionChecker.h"
#import "userLocalData.h"
#import "UIImageExt.h"
#import "DetailViewController.h"
#import "ImageFlowViewController.h"
#import "MBProgressHUD.h"
#import "UIImage+FixOrientation.h"
#import "WXApi.h"

#define NEW_COUNT 4
#define HOT_COMMENT_COUNT 1000
#define Top_Image_Height 60


@interface MainViewController_iphone ()<PPImageScrollingTableViewCellDelegate,UICollectionViewDataSource, UICollectionViewDelegate,ZYQAssetPickerControllerDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,UISearchBarDelegate,UISearchDisplayDelegate,LoginViewController_iphoneDelegate,UpLoadPictureViewControllerDelegate,DetailViewController_Delegate>
@property (nonatomic, strong) UITableView *myPicturetable;
@property (strong, nonatomic) NSArray *images;
@property (nonatomic, strong) IBOutlet UICollectionView *myCollectionView;

@property (nonatomic, strong) UIView *upLoadView;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UISearchDisplayController *mySearchDisplayController;

@property (nonatomic, strong) NSMutableArray* suggestions;

@property (nonatomic, strong) ASIDownloadCache *imageCache;     //缓存设置
@property (nonatomic, strong) ASINetworkQueue *networkQueue;    //asi下载队列
  //推荐
@property (nonatomic, strong) NSMutableArray *recommencaseIdArray; //已更新的 最新的Id集合
@property (strong, nonatomic) NSMutableArray *collectionImageData; //推荐集合
@property (nonatomic, strong) NSMutableArray *unDownLoadArray;//还没有下载的推荐图片的集合
//最新
@property (nonatomic, strong) NSString *newlastId;//每次更新最新的图片的最后一个ID
@property (nonatomic, strong) NSMutableArray *newcaseIdArray; //已更新的 最新的Id集合
//最火
@property (nonatomic, strong) NSString *hotlastId;//每次更新最新的图片的最后一个ID
@property (nonatomic, strong) NSMutableArray *hotcaseIdArray; //已更新的 最新的Id集合
@property (nonatomic, strong) NSString *hotResource;//最热的哪一天的资源
@property (nonatomic, strong) NSMutableArray *hotPicIdArr;//排名前100的最火的案列封面图片的集合
@property (nonatomic, assign) int hotPage;//刷新到第几页了
//评论最多
@property (nonatomic, strong) NSString *commentlastId;//每次更新最新的图片的最后一个ID
@property (nonatomic, strong) NSString *commentResource;//评论的哪一天的资源
@property (nonatomic, strong) NSMutableArray *commentcaseIdArray; //已更新的 最新的Id集合
@property (nonatomic, strong) NSMutableArray *commentPicIdArr;//排名前100的评论最多的案列封面图片的集合
@property (nonatomic, assign) int commentPage;//刷新到第几页了
  //最新  最火  评论最多
@property(nonatomic, strong) NSMutableArray *contentAllImagePathArray;
@property(nonatomic, strong) NSMutableArray *titleArray;

  //记录推荐滑动的位置
@property (nonatomic, assign) float recommenMoveX;

  //当前滑动的是哪一类
@property (nonatomic, assign) NSString *selectMove;
  //记录搜索的词
@property (nonatomic, strong) NSString *rsearchText;

  //加载
@property (nonatomic, strong) MBProgressHUD *proHud;

  //ASIHTTP
@property (strong, nonatomic) ASIHTTPRequest *discussRequest;
@property (strong, nonatomic) ASIHTTPRequest *detailRequest;

@property (strong, nonatomic) ASIHTTPRequest *checkVersionRequest;
@property (strong, nonatomic) ASIHTTPRequest *searchRequest;
@property (strong, nonatomic) ASIHTTPRequest *newlyRequest;
@property (strong, nonatomic) ASIHTTPRequest *hotRequest;
@property (strong, nonatomic) ASIHTTPRequest *recommenRequest;
@property (strong, nonatomic) ASIHTTPRequest *commentRequest;

@property (strong, nonatomic) ASIHTTPRequest *newloadmanyRequest;
@property (strong, nonatomic) ASIHTTPRequest *hotloadmanyRequest;
@property (strong, nonatomic) ASIHTTPRequest *commentloadmanyRequest;
  //加锁一次滑动只能加载NEW_COUNT张图片
@property (nonatomic, assign) BOOL newLock;
@property (nonatomic, assign) BOOL hotLock;
@property (nonatomic, assign) BOOL commentLock;

  //解决猜你喜欢刷新闪动
@property (nonatomic, strong) NSMutableDictionary *recommenUnImageDic;

  //解决猜你喜欢刷新闪动
@property (nonatomic, strong) UIAlertView *alertNetError;
@end

@implementation MainViewController_iphone
@synthesize myPicturetable;
@synthesize myCollectionView;
@synthesize upLoadView;
@synthesize searchBar,mySearchDisplayController;
@synthesize suggestions;
@synthesize imageCache,networkQueue;
@synthesize newlastId,hotlastId,commentlastId;
@synthesize newcaseIdArray,hotcaseIdArray,commentcaseIdArray,contentAllImagePathArray,titleArray,unDownLoadArray;
@synthesize selectMove,rsearchText;
@synthesize proHud;
@synthesize loginNav;
@synthesize newLock,hotLock,commentLock;
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
  newLock = YES;
  hotLock = YES;
  commentLock = YES;
  UIImageView *imgTitle = [[UIImageView alloc] init];
  imgTitle.backgroundColor = [UIColor clearColor];
  imgTitle.frame = CGRectMake(0, 0, 70, 19);
  [imgTitle setImage:[UIImage imageNamed:@"image-main-title"]];
  self.navigationItem.titleView = imgTitle;
  self.title = @"首页";
  
  self.newlastId = nil;
  newcaseIdArray = [[NSMutableArray alloc] init];
  hotcaseIdArray = [[NSMutableArray alloc] init];
  commentcaseIdArray = [[NSMutableArray alloc] init];
    self.recommencaseIdArray  = [[NSMutableArray alloc] init];
  
  self.recommenUnImageDic = [[NSMutableDictionary alloc] init];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadImageRecommen:) name:@"downloadImageRecommen" object:nil];
    //create title
  float screenWidth = [UIScreen mainScreen].bounds.size.width;
  float screenHeight = [UIScreen mainScreen].bounds.size.height;
  
  self.recommenMoveX = 0;
//  UILabel *lable = [[UILabel alloc] initWithFrame:CGRectMake(0, NavgationHeight,screenWidth, 20)];
//  lable.backgroundColor = [UIColor clearColor];
//  lable.textColor = [UIColor purpleColor];
//  lable.text = @"推荐图片";
//  [self.view addSubview:lable];
  UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
  flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
  flowLayout.itemSize = CGSizeMake(Top_Image_Height, Top_Image_Height);
  flowLayout.sectionInset = UIEdgeInsetsMake(0, 5, 5, 5);
  flowLayout.minimumLineSpacing = 3;
  
    //猜你喜欢
  UIImageView *ImageloveTitle = [[UIImageView alloc] init];
  ImageloveTitle.backgroundColor = [UIColor clearColor];
  ImageloveTitle.frame = CGRectMake(0, NavgationHeight, screenWidth, 24);
  [ImageloveTitle setImage:[UIImage imageNamed:@"image-love-image"]];
  [self.view addSubview:ImageloveTitle];
  
  myCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, NavgationHeight+24, screenWidth, 65) collectionViewLayout:flowLayout];
  myCollectionView.delegate = self;
  myCollectionView.dataSource = self;
  myCollectionView.backgroundColor = [UIColor colorWithRed:248.0/255.0 green:248.0/255.0 blue:248.0/255.0 alpha:1.0];
    //myCollectionView.contentSize = CGSizeMake(5*screenWidth, 80);
  //myCollectionView.pagingEnabled=YES;
  [self.myCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"CollectionViewCell"];
  [self.view addSubview:myCollectionView];
  
    //create Picture tableview
  myPicturetable = [[UITableView alloc] initWithFrame:CGRectMake(0, NavgationHeight+65+24, screenWidth, screenHeight-NavgationHeight-89)];
  myPicturetable.delegate = self;
  myPicturetable.dataSource = self;
  if (screenHeight >= 568) {
    myPicturetable.bounces = NO;
  }
  [self.view addSubview:myPicturetable];
  static NSString *CellIdentifier = @"Cell";
  [self.myPicturetable registerClass:[PPImageScrollingTableViewCell class] forCellReuseIdentifier:CellIdentifier];
    //初始化最新  最火  评论最多的数据
  self.contentAllImagePathArray = [[NSMutableArray alloc] init];
  titleArray = [[NSMutableArray alloc] initWithObjects:@"最新案例",@"最火案例",@"评论最多", nil];
  for (int i = 0; i < 3; i++) {
    NSMutableArray *arr = [[NSMutableArray alloc] init];
//    [arr addObject:@"default"];
//    [arr addObject:@"default"];
//    [arr addObject:@"default"];
    [self.contentAllImagePathArray addObject:arr];
  }
  [myPicturetable reloadData];
  
  self.suggestions = [[NSMutableArray alloc] init];
  for (int i = 0; i < 10; i ++) {
    [self.suggestions addObject:[NSString stringWithFormat:@"h%d",i]];
  }
    //创建rightBar
    //创建rightBar
  UIButton *uploadbutton  = [UIButton buttonWithType:UIButtonTypeCustom];
  uploadbutton.frame = CGRectMake(0, 0, 44, 44);
	[uploadbutton setImage:[UIImage imageNamed:@"image-uploadPhoto"] forState:0];
  [uploadbutton setImageEdgeInsets:UIEdgeInsetsMake(12, 12, 12, 6)];
    // [uploadbutton setTitleColor:[UIColor colorWithRed:64.0/255.0 green:111.0/255.0 blue:176.0/255.0 alpha:1.0] forState:0];
	[uploadbutton addTarget:self action:@selector(uploadPicture) forControlEvents:UIControlEventTouchUpInside];
  
  UIButton *refreshbutton  = [UIButton buttonWithType:UIButtonTypeCustom];
	refreshbutton.frame = CGRectMake(50, 0, 44, 44);
  [refreshbutton setImage:[UIImage imageNamed:@"image-refresh"] forState:0];
  [refreshbutton setImageEdgeInsets:UIEdgeInsetsMake(12, 6, 12, 12)];
    //[refreshbutton setTitleColor:[UIColor colorWithRed:64.0/255.0 green:111.0/255.0 blue:176.0/255.0 alpha:1.0] forState:0];
	[refreshbutton addTarget:self action:@selector(refreshButtonClicked) forControlEvents:UIControlEventTouchUpInside];
  
  UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 88, 44)];
  [rightView addSubview:uploadbutton];
  [rightView addSubview:refreshbutton];
  
	UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithCustomView:rightView];
  self.navigationItem.rightBarButtonItem = rightBarButton;
  
    //创建Upload的控件
  upLoadView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 60)];
  upLoadView.backgroundColor = [UIColor colorWithRed:253/255.0 green:253/255.0 blue:253/255.0 alpha:0.8];
  for (int i = 0; i< 2; i++) {
    UIButton *btn = [UIButton buttonWithType:0];
    btn.layer.borderWidth = 0.25;
    btn.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    btn.frame = CGRectMake(i*(([UIScreen mainScreen].bounds.size.width-2)/2+1), 0, ([UIScreen mainScreen].bounds.size.width-2)/2, 60);
    [btn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
      //[btn setTitle:[NSString stringWithFormat:@"%d",i] forState:0];
    btn.tag = i+100;
    [btn setImageEdgeInsets:UIEdgeInsetsMake(18, 68, 18, 68)];
    switch (i) {
      case 0:
        [btn setImage:[UIImage imageNamed:@"image-picturebutton"] forState:0];
        break;
      case 1:
        [btn setImage:[UIImage imageNamed:@"image-photobutton"] forState:0];
        break;
      default:
        break;
    }
    [upLoadView addSubview:btn];
  }
  [self.view addSubview:upLoadView];
  
  //创建搜索框
  searchBar = [[UISearchBar alloc] init];
  searchBar.delegate = self;
  searchBar.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width,44);
  [self.view addSubview:searchBar];
  searchBar.backgroundColor = [UIColor clearColor];
  
  //[SlideNavigationController sharedInstance].leftBarButtonItem.isEnabled
      //searchBar.barTintColor = [UIColor whiteColor];
  
//  mySearchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
//
//  [self setMySearchDisplayController:mySearchDisplayController];
//  [mySearchDisplayController setDelegate:self];
//  [mySearchDisplayController setSearchResultsDataSource:self];
//  [mySearchDisplayController setSearchResultsDelegate:self];
//  [[searchBar.subviews objectAtIndex:0]removeFromSuperview];
//  for (UIView *subview in searchBar.subviews)
//  {
//    if ([subview isKindOfClass:NSClassFromString(@"UISearchBarBackground")])
//    {
//      [subview removeFromSuperview];
//      break;  
//    }  
//  }
  //引导页面
  BOOL firstLogined = [Strings getFirstOpenInCurrentVersion];
  if (!firstLogined) {
    [Strings setFirstOpenInCurrentVersion:YES];
    [self showHelp];
      //更换微信登陆   取消原来TOKEN  需要重新绑定
    if ([WXApi isWXAppInstalled])
      [userLocalData saveImdToken:nil];
    }else
    {
      [self isLoginIn];
    }
}
- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
    //[self loadgetNewResourceRequest];
  if (self.detailRequest) {
    [self.detailRequest cancel];
    [self.detailRequest clearDelegatesAndCancel];
  }
  if (self.discussRequest) {
  [self.discussRequest cancel];
  [self.discussRequest clearDelegatesAndCancel];
  }
}
- (void)viewWillDisappear:(BOOL)animated
{
    [self hiddenSearch];
    [self.searchBar resignFirstResponder];
    if (self.upLoadView.frame.origin.y > 0) {
        [UIView animateWithDuration:0.3 animations:^{
            upLoadView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 60);
        } completion:nil];
    }
}
- (void)checkVersion
{
    //检查当前版本
  self.checkVersionRequest = [imdRequest getRequest:[UrlCenter urlOfType:GET_SERVER_VERSION] delegate:self requestType:@"GET_SERVER_VERSION"];
}
- (void)showSearch
{
 self.upLoadView.hidden = YES;
  self.searchBar.hidden = NO;
    [self.searchBar becomeFirstResponder];
  NSLog(@"show Search");
    if (self.upLoadView.frame.origin.y > 0) {
        [UIView animateWithDuration:0.3 animations:^{
            upLoadView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 60);
        } completion:nil];
    }
    [UIView animateWithDuration:0.53 animations:^{
      searchBar.frame = CGRectMake(0, NavgationHeight, [UIScreen mainScreen].bounds.size.width, 44);
    } completion:nil];
}
- (void)hiddenSearch
{
    self.upLoadView.hidden = NO;
    self.searchBar.hidden = YES;
    self.searchBar.text = @"";
    [self.searchBar resignFirstResponder];
        [UIView animateWithDuration:0.3 animations:^{
            searchBar.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44);
        } completion:nil];
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
#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  if (tableView == self.searchDisplayController.searchResultsTableView) {
    return self.suggestions.count;
  }else
  return [self.contentAllImagePathArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *CellIdentifier = @"Cell";
  if (tableView == self.searchDisplayController.searchResultsTableView) {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"suggestItem"];
    
    if (cell == nil) {
      cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"suggestItem"];
      cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = [NSString stringWithFormat:@"%@", [self.suggestions objectAtIndex:indexPath.row]];
    cell.textLabel.numberOfLines = 1;
    cell.textLabel.opaque = NO;
    cell.textLabel.backgroundColor = [UIColor clearColor];
    return cell;
  }else
  {
  NSMutableArray *cellData = [self.contentAllImagePathArray objectAtIndex:[indexPath section]];
  PPImageScrollingTableViewCell *customCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
  [customCell setBackgroundColor:[UIColor whiteColor]];
  [customCell setDelegate:self];
    if ([selectMove isEqualToString:@"downLoadNewImage"] && indexPath.section == 0) {
      [customCell setImageData:cellData];
    }else if([selectMove isEqualToString:@"downLoadHotImage"] && indexPath.section == 1)
    {
    [customCell setImageData:cellData];
    }else if([selectMove isEqualToString:@"downLoadCommentImage"] && indexPath.section == 2)
    {
    [customCell setImageData:cellData];
    }else if([selectMove isEqualToString:@"ALL"])
    {
      [customCell setImageData:cellData];
    }
  [customCell setCategoryLabelText:[titleArray objectAtIndex:[indexPath section]]];
  [customCell setTag:[indexPath section]];
  [customCell setImageTitleTextColor:[UIColor whiteColor] withBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.7]];
  [customCell setImageTitleLabelWitdh:30 withHeight:20];
  [customCell setCollectionViewBackgroundColor:[UIColor whiteColor]];
    [customCell setSelectionStyle:UITableViewCellSelectionStyleNone];
  tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    return customCell;
  }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (tableView == self.searchDisplayController.searchResultsTableView) {
    return 40;
  }else
  return 138;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //不让tableviewcell有选中效果
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self hiddenSearch];
}
#pragma mark - PPImageScrollingTableViewCellDelegate

- (void)scrollingTableViewCell:(PPImageScrollingTableViewCell *)scrollingTableViewCell didSelectImageAtIndexPath:(NSIndexPath*)indexPathOfImage atCategoryRowIndex:(NSInteger)categoryRowIndex
{
  NSString *caseId ;
  switch (categoryRowIndex) {
    case 0:
      caseId = [self.newcaseIdArray objectAtIndex:indexPathOfImage.row];
      break;
    case 1:
      caseId = [self.hotcaseIdArray objectAtIndex:indexPathOfImage.row];
      break;
    case 2:
      caseId = [self.commentcaseIdArray objectAtIndex:indexPathOfImage.row];
      break;
    default:
      break;
  }
  NSLog(@"xxx%@",caseId);
    [self goToDetail:caseId indexPath:indexPathOfImage];
//    [request didFinishSelector:];
//  });
}
#pragma mark - UICollectionViewDataSource methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
  return [self.collectionImageData count];
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString * CellIdentifier = @"CollectionViewCell";
   UICollectionViewCell*cell=[collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
  cell.backgroundColor = [UIColor whiteColor];
  for(UIImageView *imgView in cell.contentView.subviews)
  {
    [imgView removeFromSuperview];
  }
//  UIImageView *imgView = (UIImageView *)[cell.contentView viewWithTag:100+indexPath.row];
//  if (imgView == nil) {
    UIImageView *imgView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, Top_Image_Height, Top_Image_Height)];
    imgView.tag = 100+indexPath.row;
    imgView.backgroundColor = [UIColor clearColor];
  UIImage *zipImage;
  if (self.collectionImageData.count > 0) {
    zipImage = [UIImage imageWithContentsOfFile:[self.collectionImageData objectAtIndex:indexPath.row]];
  }else
    zipImage = nil;
  
      //imgView.image =[zipImage imageByScalingAndCroppingForSize:CGSizeMake(Top_Image_Height*2, Top_Image_Height*2)];
  if (zipImage == nil) {
    imgView.layer.cornerRadius = 8.0;
    imgView.layer.masksToBounds = YES;
    imgView.image = [UIImage imageNamed:@"default-ruiyituzhi"];
    [cell.contentView addSubview:imgView];
    [self.recommenUnImageDic setObject:imgView forKey:[NSString stringWithFormat:@"%zd",indexPath.row]];
  }else
  {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
      imgView.layer.cornerRadius = 8.0;
      imgView.layer.masksToBounds = YES;
      UIImage *newImage =[zipImage imageByScalingAndCroppingForSize:CGSizeMake(Top_Image_Height*2, Top_Image_Height*2)];
      dispatch_async(dispatch_get_main_queue(), ^{
        imgView.image = newImage;
        [cell.contentView addSubview:imgView];
      });
    
      });
  }
    return cell;
  
    // UIImage *zipImage = [UIImage imageWithContentsOfFile:[self.collectionImageData objectAtIndex:indexPath.row]];
  //[zipImage imageByScalingAndCroppingForSize:CGSizeMake(Top_Image_Height*2, Top_Image_Height*2)];
  
 
//  [cell.contentView addSubview:imgView];
//  return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self hiddenSearch];
    NSString *caseid = [self.recommencaseIdArray objectAtIndex:indexPath.row];
    [self goToDetail:caseid indexPath:indexPath];
}
#pragma mark - UISearchBarDelegate methods
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBars {
    if ([searchBars.text stringByReplacingOccurrencesOfString:@" " withString:@""].length > 0) {
      [self.proHud show:YES];
      [self doSearch:searchBars.text];
    }
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
  
}
- (void)doSearch:(NSString *)str
{
  if (self.searchRequest) {
    [self.searchRequest cancel];
  }
   //TEST 搜索关键词
 self.searchRequest = [imdRequest postSearch:[NSString stringWithFormat:@"%@/1/10",[UrlCenter urlOfType:SEARCH_STRING]] delegate:self requestType:@"SEARCH_STRING" postData:str];
  self.rsearchText = nil;
  self.rsearchText = str;
}
- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
  //[self showSearch];
}
#pragma mark - UISearchDisplayDelegate methods
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
  return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
  return NO;
}
- (void) searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
  [UIView animateWithDuration:0.3 animations:^{
    searchBar.frame = CGRectMake(0, 20, [UIScreen mainScreen].bounds.size.width, 60);
  } completion:nil];
}

- (void) searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
{

}


#pragma mark - UpLoadPicture methods
- (void)refreshButtonClicked
{
  [self.proHud show:YES];
  self.recommenMoveX = 0;
  self.myCollectionView.contentOffset = CGPointZero;
  self.newlastId = nil;
  [newcaseIdArray removeAllObjects];
  [hotcaseIdArray removeAllObjects];
  [commentcaseIdArray removeAllObjects];
  [self.recommencaseIdArray removeAllObjects];
  [self.contentAllImagePathArray removeAllObjects];
  
  for (int i = 0; i < 3; i++) {
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    [self.contentAllImagePathArray addObject:arr];
  }
  self.searchBar.hidden = YES;
  self.upLoadView.hidden = NO;
    //create Animation
  if (self.upLoadView.frame.origin.y > 0) {
    [UIView animateWithDuration:0.3 animations:^{
      upLoadView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 60);
    } completion:nil];
  }
  [self hiddenSearch];
  [self loadHttpRequest];
}
- (void)uploadPicture
{
    self.searchBar.hidden = YES;
    self.upLoadView.hidden = NO;
    //create Animation
  if (self.upLoadView.frame.origin.y > 0) {
    [UIView animateWithDuration:0.3 animations:^{
      upLoadView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 60);
    } completion:nil];
  }else
  {
  [UIView animateWithDuration:0.53 animations:^{
    upLoadView.frame = CGRectMake(0, NavgationHeight, [UIScreen mainScreen].bounds.size.width, 60);
  } completion:nil];
  }
}
- (void)buttonClick:(UIButton *)btn
{
  self.upLoadView.hidden = NO;
  self.searchBar.hidden = YES;
  switch (btn.tag) {
    case 100:
      [self loadlocalPicture];
      break;
    case 101:
      [self performSelector:@selector(loadPhotoCamera) withObject:nil afterDelay:0.3];
      break;
    default:
      break;
  }
}
- (void)loadlocalPicture
{
  ZYQAssetPickerController *picker = [[ZYQAssetPickerController alloc] init];
  NSDictionary * dict= [NSDictionary dictionaryWithObjectsAndKeys:NavigationColor,NSForegroundColorAttributeName,[UIFont systemFontOfSize:17],NSFontAttributeName, nil];
  picker.navigationBar.titleTextAttributes = dict;
  picker.maximumNumberOfSelection = 10;
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
  picker.allowsEditing = NO;//设置可编辑
  picker.sourceType = sourceType;
  [self presentViewController:picker animated:YES completion:nil];//进入照相界面
   }
}
#pragma mark Camera View Delegate Methods
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
  MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:picker.view];
	[picker.view addSubview:hud];
	hud.labelText = @"处理中...";
  [hud show:YES];
  UIImage *imagex = [info objectForKey:UIImagePickerControllerOriginalImage];
  UIImage *image = [imagex fixOrientation];
//  
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      
    UIImage *newImage = [image imageByScalingFitSize:CGSizeMake([UIScreen mainScreen].bounds.size.width*1.5, [UIScreen mainScreen].bounds.size.height*1.5)];
    NSString *name = [self stringFromDate:[NSDate date]];
    NSString *path = [Strings saveImage:newImage WithName:name];
     dispatch_sync(dispatch_get_main_queue(), ^{
       [picker dismissViewControllerAnimated:NO completion:nil];
       
       UpLoadPictureViewController *uploadVC = [[UpLoadPictureViewController alloc] init];
       uploadVC.delegate = self;
       uploadVC.dateImageArr = nil;
       uploadVC.imgHeightMax = image.size.height;
       uploadVC.cameraImagePath = path;
       uploadVC.cameraImage = [UIImage imageWithContentsOfFile:path];
      UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:uploadVC];
       NSDictionary * dict= [NSDictionary dictionaryWithObjectsAndKeys:NavigationColor,NSForegroundColorAttributeName,[UIFont systemFontOfSize:17],NSFontAttributeName, nil];
       nav.navigationBar.titleTextAttributes = dict;
       [hud removeFromSuperview];
      [self presentViewController:nav animated:YES completion:nil];
     });
     });
 
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
  [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - ZYQAssetPickerController Delegate
-(void)assetPickerController:(ZYQAssetPickerController *)picker didFinishPickingAssets:(NSArray *)assets{
  NSLog(@"%@",assets);
  float oldheight = 0.0;
  for (int i=0; i<assets.count; i++) {
    ALAsset *asset=assets[i];
    UIImage *tempImg=[UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage];
    if (tempImg.size.height > oldheight) {
      oldheight = tempImg.size.height;
    }
  }
  if (assets.count > 0) {
    UpLoadPictureViewController *uploadVC = [[UpLoadPictureViewController alloc] init];
    uploadVC.delegate = self;
    uploadVC.dateImageArr = assets;
    uploadVC.imgHeightMax = oldheight;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:uploadVC];
    NSDictionary * dict= [NSDictionary dictionaryWithObjectsAndKeys:NavigationColor,NSForegroundColorAttributeName,[UIFont systemFontOfSize:17],NSFontAttributeName, nil];
    nav.navigationBar.titleTextAttributes = dict;
    [self presentViewController:nav animated:NO completion:nil];
  }
}
#pragma mark - HTTP REQUEST
- (void)loadgetNewResourceRequest
{
    //自定义networkQueue
  if (networkQueue == nil) {
    networkQueue = [[ASINetworkQueue alloc] init];
  }
  [networkQueue reset];
    //获取最新的图片
  if (self.newlyRequest) {
    [self.newlyRequest cancel];
  }
 self.newlyRequest = [imdRequest getRequest:[NSString stringWithFormat:@"%@//%d",[UrlCenter urlOfType:GET_NEW_CASE_INFO],NEW_COUNT] delegate:self requestType:@"getNewResource"];
}

- (void)loadHttpRequest
{
  self.collectionImageData =  [[NSMutableArray alloc] initWithCapacity:20];
  unDownLoadArray = [[NSMutableArray alloc] initWithCapacity:20];
    //自定义缓存
  imageCache = [[ASIDownloadCache alloc] init];
    //设置缓存路径
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *documentDirectory = [paths objectAtIndex:0];
  [self.imageCache setStoragePath:[documentDirectory stringByAppendingPathComponent:@"resource"]];
  [self.imageCache setDefaultCachePolicy:ASIOnlyLoadIfNotCachedCachePolicy];
    //自定义networkQueue
  if (networkQueue == nil) {
    networkQueue = [[ASINetworkQueue alloc] init];
  }
  
  [networkQueue reset];
  
  if (self.newlyRequest) {
    [self.newlyRequest cancel];
    [self.newlyRequest clearDelegatesAndCancel];
  }
  if (self.recommenRequest) {
    [self.recommenRequest cancel];
    [self.recommenRequest clearDelegatesAndCancel];
  }
  if (self.hotRequest) {
    [self.hotRequest cancel];
    [self.hotRequest clearDelegatesAndCancel];
  }
  if (self.commentRequest) {
    [self.commentRequest cancel];
    [self.commentRequest clearDelegatesAndCancel];
  }
    //获取最新的图片
  self.newlyRequest = [imdRequest getRequest:[NSString stringWithFormat:@"%@//%d",[UrlCenter urlOfType:GET_NEW_CASE_INFO],NEW_COUNT] delegate:self requestType:@"getNewResource"];
      //获取推荐的图片
  self.recommenRequest = [imdRequest getRequest:[NSString stringWithFormat:@"%@/%d",[UrlCenter urlOfType:GET_RECOMMEN_CASE_INFO],20] delegate:self requestType:@"getRecommenResource"];
    //获取最火的图片
  self.hotRequest = [imdRequest getRequest:[NSString stringWithFormat:@"%@//view//%d",[UrlCenter urlOfType:GET_HOT_CASE_INFO],HOT_COMMENT_COUNT] delegate:self requestType:@"getHotResource"];
    //获取评论最多的图片
  self.commentRequest = [imdRequest getRequest:[NSString stringWithFormat:@"%@//comment//%d",[UrlCenter urlOfType:GET_COMMENT_CASE_INFO],HOT_COMMENT_COUNT] delegate:self requestType:@"getCommentResource"];
}
- (void)loadManyRecommenImageRequest
{
  NSMutableArray *arr = [unDownLoadArray copy];
  if (unDownLoadArray.count > 5) {
    for (int i = 0; i < 5; i++) {
      [self downLoadImage:[arr objectAtIndex:i] reType:@"downLoadRecommenImage"];
    }
  }else
  {
    for (int i = 0; i < unDownLoadArray.count; i++) {
      [self downLoadImage:[unDownLoadArray objectAtIndex:i] reType:@"downLoadRecommenImage"];
    }
  }
}
- (void)loadManyNewImageRequest
{
  NSString *lastId = [self.newcaseIdArray lastObject];
  if (![lastId isEqualToString:newlastId]) {
    newlastId = lastId;
   self.newloadmanyRequest = [imdRequest getRequest:[NSString stringWithFormat:@"%@/%@/%d",[UrlCenter urlOfType:GET_NEW_CASE_INFO],lastId,NEW_COUNT] delegate:self requestType:@"getNewResource"];
  }
  
}
- (void)loadManyHotImageRequest
{
  NSString *lastId;
  if (self.hotPicIdArr.count > 0) {
   lastId = [self.hotPicIdArr objectAtIndex:self.hotPage*NEW_COUNT];

    if (![lastId isEqualToString:hotlastId]) {
      hotlastId = lastId;
      self.selectMove = @"downLoadHotImage";
        //接着滑动的时候下载最火的后面的图片
      for (int i = 0; i < NEW_COUNT; i++) {
        if (self.hotPage*NEW_COUNT+i >= self.hotPicIdArr.count) {
          return;
        }
        [self downLoadImage:[self.hotPicIdArr objectAtIndex:self.hotPage*NEW_COUNT+i] reType:@"downLoadHotImage"];
      }
      hotLock = YES;
      self.hotPage++;
    }
  }
  
}

- (void)loadManyCommentImageRequest
{
  NSString *lastId;
  if (self.commentPicIdArr.count > 0) {
    lastId = [self.commentPicIdArr objectAtIndex:self.commentPage*NEW_COUNT];
    
    if (![lastId isEqualToString:commentlastId]) {
      commentlastId = lastId;
      self.selectMove = @"downLoadCommentImage";
        //接着滑动的时候下载最火的后面的图片
      for (int i = 0; i < NEW_COUNT; i++) {
        if (self.commentPage*NEW_COUNT+i >= self.commentPicIdArr.count) {
          return;
        }
        [self downLoadImage:[self.commentPicIdArr objectAtIndex:self.commentPage*NEW_COUNT+i] reType:@"downLoadHotImage"];
      }
      commentLock = YES;
      self.commentPage++;
    }
  }
}

- (void)requestFinished:(ASIHTTPRequest *)request{
  NSString* responseString = [request responseString];
  NSLog(@"xxxx%@",responseString);
  NSString* rType =[[request userInfo] objectForKey:REQUEST_TYPE];
  [self.proHud hide:YES];
  NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/imageFile/smallPicture/"];
  if (request.responseStatusCode != 200 ) {
    [self showAlertViewWithTitle:RUIYI_TITLE andMessage:[NSString stringWithFormat:@"internal server error %d",request.responseStatusCode]];
    return;
  }
  if ([rType isEqualToString:@"getNewResource"])
  {
    NSDictionary *info;
    if (responseString ==(id)[NSNull null] || responseString.length ==0 || [responseString isEqualToString:@"internal server error"])
    {
      info =nil;
    }
    else
    {
      info = [iosVersionChecker parseJSONObjectFromJSONString:responseString];
      if (info == nil) {
        [self showAlertViewWithTitle:RUIYI_TITLE andMessage:@"服务器错误，请重试。"];
      }
      newLock = YES;
      NSArray *caseArray = [info objectForKey:@"cases"];
      NSInteger count = [[info objectForKey:@"count"] integerValue];
        //NSString *sourceTime = [info objectForKey:@"source"];
        //判断是否重新获取
      NSMutableArray *arr;
      if ([request.url isEqual:[NSURL URLWithString:[NSString stringWithFormat:@"%@//%d",[UrlCenter urlOfType:GET_NEW_CASE_INFO],NEW_COUNT]]]) {
        arr = [[NSMutableArray alloc] init];
        self.selectMove = @"ALL";
        [self.newcaseIdArray removeAllObjects];
        [userLocalData saveNewCount:count];
      }else
      {
        arr = [self.contentAllImagePathArray objectAtIndex:0];
        self.selectMove = @"downLoadNewImage";
      }
      for (int i = 0; i <[caseArray count]; i++) {
        NSDictionary *dic = [caseArray objectAtIndex:i];
        NSString *coverPicId = [dic objectForKey:@"coverPicId"];
        NSString *newId = [dic objectForKey:@"id"];
        if (newId.length > 0) {
          [self.newcaseIdArray addObject:newId];
        }
        NSString *filePath = [path stringByAppendingPathComponent:coverPicId];
        [arr addObject:filePath];
        

        if (coverPicId.length > 0) {
          [self downLoadImage:coverPicId reType:@"downLoadNewImage"];
        }
      }
      [self.contentAllImagePathArray replaceObjectAtIndex:0 withObject:arr];
      
        [self.myPicturetable reloadData];
//      NSIndexPath *index = [NSIndexPath indexPathForRow:0 inSection:0];
//     
//      [self.myPicturetable reloadRowsAtIndexPaths:@[index] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
  }else if([rType isEqualToString:@"getHotResource"])
  {
    NSDictionary *info;
    if (responseString ==(id)[NSNull null] || responseString.length ==0 || [responseString isEqualToString:@"internal server error"])
    {
      info =nil;
    }
    else
    {
      info = [iosVersionChecker parseJSONObjectFromJSONString:responseString];
      if (info == nil) {
        [self showAlertViewWithTitle:RUIYI_TITLE andMessage:@"服务器错误，请重试。"];
      }
      hotLock = YES;
      NSArray *caseArray = [info objectForKey:@"cases"];
      self.hotResource = [info objectForKey:@"source"];
      NSInteger count = [[info objectForKey:@"count"] integerValue];
      NSMutableArray *arr = [self.contentAllImagePathArray objectAtIndex:1];
        //添加最火封面集合
      self.hotPage = 0;
      if (self.hotPicIdArr) {
        [self.hotPicIdArr removeAllObjects];
      }else
      {
        self.hotPicIdArr = [[NSMutableArray alloc] init];
      }
      
      if (arr.count == 0) {
        self.selectMove = @"ALL";
        [userLocalData saveHotCount:count];
      }else
        self.selectMove = @"downLoadHotImage";
      for (int i = 0; i <[caseArray count]; i++) {
        NSDictionary *dic = [caseArray objectAtIndex:i];
        NSString *coverPicId = [dic objectForKey:@"coverPicId"];
        NSString *newId = [dic objectForKey:@"id"];
        if (newId.length > 0) {
          [self.hotcaseIdArray addObject:newId];
        }
        if (coverPicId.length > 0) {
          NSString *filePath = [path stringByAppendingPathComponent:coverPicId];
          [arr addObject:filePath];
          [self.hotPicIdArr addObject:coverPicId];
        }
      }
        //先下载主页面的最火的 NEW_COUNT 张图片
      for (int i = 0; i < NEW_COUNT; i++) {
        [self downLoadImage:[self.hotPicIdArr objectAtIndex:i] reType:@"downLoadHotImage"];
      }
      self.hotPage++;
      hotlastId = [self.hotPicIdArr objectAtIndex:NEW_COUNT-1];
      [self.contentAllImagePathArray replaceObjectAtIndex:1 withObject:arr];
      [self.myPicturetable reloadData];
    }
  }else if([rType isEqualToString:@"getCommentResource"])
  {
    NSDictionary *info;
    if (responseString ==(id)[NSNull null] || responseString.length ==0 || [responseString isEqualToString:@"internal server error"])
    {
      info =nil;
    }
    else
    {
      info = [iosVersionChecker parseJSONObjectFromJSONString:responseString];
      if (info == nil) {
        [self showAlertViewWithTitle:RUIYI_TITLE andMessage:@"服务器错误，请重试。"];
      }
      commentLock = YES;
      NSArray *caseArray = [info objectForKey:@"cases"];
      self.commentResource = [info objectForKey:@"source"];
      NSInteger count = [[info objectForKey:@"count"] integerValue];
      NSMutableArray *arr = [self.contentAllImagePathArray objectAtIndex:2];
      
        //添加最火封面集合
      self.commentPage = 0;
      if (self.commentPicIdArr) {
        [self.commentPicIdArr removeAllObjects];
      }else
      {
        self.commentPicIdArr = [[NSMutableArray alloc] init];
      }
      if (arr.count == 0) {
        [userLocalData saveCommentCount:count];
        self.selectMove = @"ALL";
      }else
        self.selectMove = @"downLoadCommentImage";
      for (int i = 0; i <[caseArray count]; i++) {
        NSDictionary *dic = [caseArray objectAtIndex:i];
        NSString *coverPicId = [dic objectForKey:@"coverPicId"];
        NSString *newId = [dic objectForKey:@"id"];
        if (newId.length > 0) {
          [self.commentcaseIdArray addObject:newId];
        }
       
        if (coverPicId.length > 0) {
            // [self downLoadImage:coverPicId reType:@"downLoadCommentImage"];
          NSString *filePath = [path stringByAppendingPathComponent:coverPicId];
          [arr addObject:filePath];
          [self.commentPicIdArr addObject:coverPicId];
        }
      }
        //先下载主页面的评论做多的 NEW_COUNT 张图片
      for (int i = 0; i < NEW_COUNT; i++) {
        [self downLoadImage:[self.commentPicIdArr objectAtIndex:i] reType:@"downLoadHotImage"];
      }
      self.commentPage++;
      commentlastId = [self.commentPicIdArr objectAtIndex:NEW_COUNT-1];
      [self.contentAllImagePathArray replaceObjectAtIndex:2 withObject:arr];
     [self.myPicturetable reloadData];
    }
  }else if([rType isEqualToString:@"getRecommenResource"])
  {
    NSDictionary *info;
    if (responseString ==(id)[NSNull null] || responseString.length ==0 || [responseString isEqualToString:@"internal server error"])
    {
      info =nil;
    }
    else
    {
      info = [iosVersionChecker parseJSONObjectFromJSONString:responseString];
      if (info == nil) {
        [self showAlertViewWithTitle:RUIYI_TITLE andMessage:@"服务器错误，请重试。"];
      }
      NSArray *caseArray = [info objectForKey:@"cases"];
        //self.hotResource = [info objectForKey:@"source"];
      for (int i = 0; i <[caseArray count]; i++) {
        NSDictionary *dic = [caseArray objectAtIndex:i];
        NSString *coverPicId = [dic objectForKey:@"coverPicId"];
        NSString *newId = [dic objectForKey:@"id"];
        if (newId.length > 0) {
          [self.recommencaseIdArray addObject:newId];
        }
        NSString *filePath = [path stringByAppendingPathComponent:coverPicId];
        [self.collectionImageData addObject:filePath];
        [unDownLoadArray addObject:coverPicId];
      }
      [self.myCollectionView reloadData];
      NSMutableArray *arr = [unDownLoadArray copy];
      if (unDownLoadArray.count > 5) {
        for (int i = 0; i < 5; i++) {
          [self downLoadImage:[arr objectAtIndex:i] reType:@"downLoadRecommenImage"];
        }
      }else
      {
        for (int i = 0; i < unDownLoadArray.count; i++) {
          [self downLoadImage:[unDownLoadArray objectAtIndex:i] reType:@"downLoadRecommenImage"];
        }
      }
    }
  }else if ([rType isEqualToString:@"SEARCH_STRING"])
  {
      NSArray *info;
      if (responseString ==(id)[NSNull null] || responseString.length ==0 || [responseString isEqualToString:@"internal server error"])
      {
          info =nil;
      }
      else
      {
          info = [iosVersionChecker parseJSONObjectFromJSONString:responseString];
        if (info == nil) {
          [self showAlertViewWithTitle:RUIYI_TITLE andMessage:@"服务器错误，请重试。"];
        }
         NSMutableArray *ImageArrayId = [[NSMutableArray alloc] init];
          NSMutableArray *caseIdArr = [[NSMutableArray alloc] init];
          for (int i = 0; i < info.count; i++) {
              NSDictionary *dic = [info objectAtIndex:i];
              NSString *picId = [dic objectForKey:@"coverPicId"];
              [ImageArrayId addObject:picId];
              NSString *caseId = [dic objectForKey:@"id"];
              [caseIdArr addObject:caseId];
          }
        if (ImageArrayId.count > 0) {
          ImageFlowViewController *waterVC = [[ImageFlowViewController alloc] init];
          waterVC.imageIdArr = ImageArrayId;
          waterVC.caseIdArr = caseIdArr;
          waterVC.imageType = @"SEARCH_STRING";
          waterVC.selectName = self.rsearchText;
          [self.navigationController pushViewController:waterVC animated:YES];
        }else
        {
          [self showAlertViewWithTitle:RUIYI_TITLE andMessage:@"抱歉，没有查找到相关内容。"];
        }
      }
  }else if([rType isEqualToString:@"GET_SERVER_VERSION"])
  {
    NSArray *info;
    if (responseString ==(id)[NSNull null] || responseString.length ==0 || [responseString isEqualToString:@"internal server error"])
    {
      info =nil;
    }
    else
    {
      info = [iosVersionChecker parseJSONObjectFromJSONString:responseString];
      if (info == nil) {
        [self showAlertViewWithTitle:RUIYI_TITLE andMessage:@"服务器错误，请重试。"];
      }
      for (NSDictionary *dic in info) {
        if ([[dic objectForKey:@"device"] isEqualToString:@"iphone"]) {
          NSString *serverVersion = [dic objectForKey:@"version"];
          self.serverVersion = serverVersion;
          NSLog(@"%@",[UIDevice currentDevice].systemVersion);
          NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
          NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
          if ([app_Version compare:serverVersion options:NSNumericSearch]!=NSOrderedAscending) {
            NSLog(@"已是最新版本。");
          }else
          {
            NSString *message = [dic objectForKey:@"description"];
            self.updateMessage = message;
            self.updateUrl = [dic objectForKey:@"url"];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:RUIYI_TITLE message:message delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"前往更新", nil];
            alertView.tag = 100;
            [alertView show];
          }
        }
      }
    }
  }
}

- (void)requestFailed:(ASIHTTPRequest *)requests{
  [self.proHud hide:YES];
  NSString* rType =[[requests userInfo] objectForKey:REQUEST_TYPE];
  if ([rType isEqualToString:@"getNewResource"])
  {
    newlastId = nil;
    newLock = YES;
  }else if ([rType isEqualToString:@"getHotResource"])
  {
    hotLock = YES;
  }else if ([rType isEqualToString:@"getCommentResource"])
  {
    commentLock = YES;
  }

  if ([requests.error code] == ASIRequestTimedOutErrorType) {
    if (!self.alertNetError) {
      self.alertNetError = [[UIAlertView alloc] initWithTitle:RUIYI_TITLE message:REQUEST_TIMEOUT_MESSAGE delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    }
    if (self.alertNetError.isVisible) {
      
    }else
    {
      [self.alertNetError show];
    }
  }else if ([rType isEqualToString:@"GET_SERVER_VERSION"] && requests.responseStatusCode == 401)
  {
     NSString *token = [userLocalData getImdToken];
    if (token == nil || token.length == 0) {
      
    }else
    {
    [userLocalData saveImdToken:@""];
    [self isLoginIn];
    }
  }
  else
  {
    if (!self.alertNetError) {
      self.alertNetError = [[UIAlertView alloc] initWithTitle:RUIYI_TITLE message:REQUEST_ERROR delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    }
    if (self.alertNetError.isVisible) {
      
    }else
    {
      [self.alertNetError show];
    }
  }
}
- (void)showAlertViewWithTitle:(NSString *)title andMessage:(NSString *)message{
  UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
  [alertView show];
}
- (void)downLoadImage:(NSString *)name reType:(NSString *)type
{
  NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/imageFile/smallPicture/"];
  
  NSString *filePath = [path stringByAppendingPathComponent:name];
  if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
    if ([type isEqualToString:@"downLoadRecommenImage"]) {
      [unDownLoadArray removeObject:name];
      [self.myCollectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
    }
  }else
  {
    [unDownLoadArray removeObject:name];
    [networkQueue setRequestDidFinishSelector:@selector(imageDownloadComplete:)];//队列加载完成时调用的方法
    [networkQueue setRequestDidFailSelector:@selector(imageFetchFailed:)];//队列加载出错时调用的方法
    [networkQueue setDelegate:self];
    [networkQueue addOperation:[imdRequest downLoadsmallPictureRequest:[NSString stringWithFormat:@"%@/%@",[UrlCenter urlOfType:GET_SMALL_PICTURE],name] requestType:type]];
    [networkQueue go];
  }
}
- (void)imageDownloadComplete:(ASIHTTPRequest*)request//加载完成时
{
  if (request.responseStatusCode > 400) {
    NSFileManager *file = [NSFileManager defaultManager];
    NSString *path = [request downloadDestinationPath];
    if ([file fileExistsAtPath:path]) {
      [file removeItemAtPath:path error:nil];
    }
  }
  NSString* rType =[[request userInfo] objectForKey:REQUEST_TYPE];
  UIImage *image = [UIImage imageWithContentsOfFile:[request downloadDestinationPath]];
  if (image) {
    if ([rType isEqualToString:@"downLoadRecommenImage"]) {
          [[NSNotificationCenter defaultCenter] postNotificationName:@"downloadImageRecommen" object:[request downloadDestinationPath]];
    }else
    {
      [self.myPicturetable reloadData];
       //下载完成通知更新图片
      [[NSNotificationCenter defaultCenter] postNotificationName:@"ImageDownload" object:[request downloadDestinationPath]];
    }
  }
}

- (void)imageFetchFailed:(ASIHTTPRequest *)request//加载失败时
{
  NSLog(@"Failed to download images");
    //  if (!failed) {
    //    if ([[request error] domain] != NetworkRequestErrorDomain || [[request error] code] != ASIRequestCancelledErrorType) {
    //      UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"Download failed" message:@"Failed to download images" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
    //      [alertView show];
    //    }
    //    failed = YES;
    //  }
}
- (void)goToDetail:(NSString *)caseId indexPath:(NSIndexPath *)index
{
    DetailViewController *detailVC = [[DetailViewController alloc] init];
    detailVC.caseId = caseId;
  
    detailVC.delegate = self;
    detailVC.index = index;
    [self.navigationController pushViewController:detailVC animated:YES];
    //  dispatch_async(dispatch_get_global_queue(0, 0), ^{
    //      // 处理耗时操作的代码块...
  if (self.detailRequest != nil) {
    [self.detailRequest cancel];
  }
    self.detailRequest = [imdRequest getRequest:[NSString stringWithFormat:@"%@/%@",[UrlCenter urlOfType:GET_IMAGE_CASE],caseId] delegate:detailVC requestType:@"getImageDetail"];
    //请求讨论区
  if (self.discussRequest != nil) {
    [self.discussRequest cancel];
  }
    self.discussRequest = [imdRequest getRequest:[NSString stringWithFormat:@"%@/%@/1/1000",[UrlCenter urlOfType:GET_PARENT_DISCUSS],caseId] delegate:detailVC requestType:@"getDetailParentDiscuss"];
}
#pragma mark - UIScrollView methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
  if (scrollView == myCollectionView) {
    if (scrollView.contentOffset.x > self.recommenMoveX) {
      self.recommenMoveX = scrollView.contentOffset.x;
      [self loadManyRecommenImageRequest];
    }
  }
  
}
- (void)PPscrollViewDidScroll:(UIScrollView *)bscrollView
{
  float width = [UIScreen mainScreen].bounds.size.width;
  if (bscrollView.tag == 500) {
    if (bscrollView.contentOffset.x+width+80 > bscrollView.contentSize.width && newLock) {
      newLock = NO;
      [self loadManyNewImageRequest];
    }
  }else if(bscrollView.tag == 501)
  {
      if (bscrollView.contentOffset.x + width > self.hotPage * width && hotLock) {
        hotLock = NO;
        [self loadManyHotImageRequest];
      }
  }else if(bscrollView.tag == 502)
  {
    if (bscrollView.contentOffset.x + width > self.commentPage * width && commentLock) {
      commentLock = NO;
      [self loadManyCommentImageRequest];
    }
  }
}

//-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
//  
//  if(scrollView==myCollectionView){
//    
//    CGPoint offset = myCollectionView.contentOffset;
//     int currentPage = offset.x / (self.view.bounds.size.width); //计算当前的页码
//    [myCollectionView setContentOffset:CGPointMake(self.view.bounds.size.width * (currentPage),myCollectionView.contentOffset.y) animated:YES]; //设置scrollview的显示为当前滑动到的页面
//  }
//}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (NSString *)stringFromDate:(NSDate *)date{
  
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
  [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
  NSString *destDateString = [dateFormatter stringFromDate:date];
  return destDateString;
}
#pragma mark - DetailViewController_Delegate
- (void)refreshSelectImage:(NSIndexPath *)index
{
  [self.myPicturetable reloadData];
  [self.myCollectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
  if (alertView.tag == 100 && buttonIndex == 1) {
    if (self.updateUrl.length > 0) {
      [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.updateUrl]];
    }
  }
}

-(void) showHelp
{
  BOOL isIphone5 = iPhone5;
  EAIntroPage *page1 = [EAIntroPage page];
  page1.bgImage = [UIImage imageNamed:isIphone5 ? @"help-001" : @"help001"];
  
  EAIntroPage *page2 = [EAIntroPage page];
  page2.bgImage = [UIImage imageNamed:isIphone5 ?@"help-002": @"help002"];
  
  EAIntroPage *page3 = [EAIntroPage page];
  page3.bgImage = [UIImage imageNamed:isIphone5 ?@"help-003@2x.jpg": @"help003@2x.jpg"];
  
  EAIntroView *intro = [[EAIntroView alloc] initWithFrame:self.view.bounds andPages:@[page1,page2,page3]];
  
  [intro setDelegate:self];
  [intro showInView:self.navigationController.view animateDuration:1.0];
}
- (void)introDidFinish:(EAIntroView *)introView
{
  NSLog(@"finish");
  [self isLoginIn];
}
- (void)isLoginIn
{
  proHud = [[MBProgressHUD alloc] initWithView:self.view];
  [self.view addSubview:proHud];
  proHud.labelText = @"加载中...";
    // Do any additional setup after loading the view.
  UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone"
                                                           bundle: nil];
  LoginViewController_iphone *loginvc = [mainStoryboard instantiateViewControllerWithIdentifier:@"LoginViewController_iphone"];
  loginvc.logindelegate = self;
  loginNav = [[UINavigationController alloc] initWithRootViewController:loginvc];
  NSString *token = [userLocalData getImdToken];
  if (token == nil | token.length == 0) {
    [self presentViewController:loginNav animated:NO completion:nil];
  }else
  {
    [proHud show:YES];
    [self loadHttpRequest];
  }

}
- (void)downloadImageRecommen:(NSNotification *)nofication
{
  NSString *imagePath = nofication.object;
  for (int i = 0; i < self.collectionImageData.count; i++) {
    if ([[self.collectionImageData objectAtIndex:i] isEqualToString:imagePath]) {
      NSString *key = [NSString stringWithFormat:@"%d",i];
      UIImageView *imageView = (UIImageView *)[self.recommenUnImageDic objectForKey:key];
      if ([[NSFileManager defaultManager] fileExistsAtPath:imagePath]) {
        [imageView setImage:[UIImage imageWithContentsOfFile:imagePath]];
        [self.recommenUnImageDic removeObjectForKey:key];
      }
      return;
    }
    
  }
}
-(void)clearRequest
{
  if (networkQueue) {
    [networkQueue reset];
    networkQueue = nil;
  }
  if (self.searchRequest) {
    [self.searchRequest cancel];
    [self.searchRequest clearDelegatesAndCancel];
    self.searchRequest = nil;
  }
  if (self.checkVersionRequest) {
    [self.checkVersionRequest cancel];
    [self.checkVersionRequest clearDelegatesAndCancel];
    self.checkVersionRequest = nil;
  }
  if (self.newlyRequest ) {
    [self.newlyRequest cancel];
    [self.newlyRequest clearDelegatesAndCancel];
    self.newlyRequest = nil;
  }
  if (self.commentRequest) {
    [self.commentRequest cancel];
    [self.commentRequest clearDelegatesAndCancel];
    self.commentRequest = nil;
  }
  if (self.recommenRequest) {
    [self.recommenRequest cancel];
    [self.recommenRequest clearDelegatesAndCancel];
    self.recommenRequest = nil;
  }
  if (self.hotRequest) {
    [self.hotRequest cancel];
    [self.hotRequest clearDelegatesAndCancel];
    self.hotRequest = nil;
  }
  if (self.detailRequest) {
    [self.detailRequest cancel];
    [self.detailRequest clearDelegatesAndCancel];
    self.detailRequest = nil;
  }
  if (self.discussRequest) {
    [self.discussRequest cancel];
    [self.discussRequest clearDelegatesAndCancel];
    self.discussRequest = nil;
  }
  if (self.newloadmanyRequest) {
    [self.newloadmanyRequest cancel];
    [self.newloadmanyRequest clearDelegatesAndCancel];
    self.newloadmanyRequest = nil;
  }
  if (self.commentloadmanyRequest) {
    [self.commentloadmanyRequest cancel];
    [self.commentloadmanyRequest clearDelegatesAndCancel];
    self.commentloadmanyRequest = nil;
  }
  if (self.hotloadmanyRequest) {
    [self.hotloadmanyRequest cancel];
    [self.hotloadmanyRequest clearDelegatesAndCancel];
    self.hotloadmanyRequest = nil;
  }
}
@end
