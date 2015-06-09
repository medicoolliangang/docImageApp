//
//  ImageFlowViewController.m
//  docImageApp
//
//  Created by imd on 14-9-13.
//  Copyright (c) 2014年 jianzheng. All rights reserved.
//

#import "ImageFlowViewController.h"
#import "UITableGridViewCell.h"
#import "UIImageButton.h"
#import "DetailViewController.h"
#import "imdRequest.h"
#import "UrlCenter.h"
#import "MJRefresh.h"
#import "Strings.h"
#import "iosVersionChecker.h"
#import "ASIDownloadCache.h"
#import "ASINetworkQueue.h"
#import "UIImageExt.h"
#define kImageWidth  158.5 //UITableViewCell里面图片的宽度
#define kImageHeight  158.5 //UITableViewCell里面图片的高度

@interface ImageFlowViewController ()<UIScrollViewDelegate>
@property(nonatomic,strong) UITableView *tableView;
@property(nonatomic,strong) UIImage *image;
@property(nonatomic,strong) NSArray *anatomyArr;
@property(nonatomic,strong) NSArray *allTable1Data;

@property (nonatomic, strong) ASIDownloadCache *imageCache;     //缓存设置
@property (nonatomic, strong) ASINetworkQueue *networkQueue;    //asi下载队列
@property (nonatomic, strong) NSMutableArray *unDownLoadArray;//还没有下载的推荐图片的集合
@end

@implementation ImageFlowViewController
@synthesize imageIdArr;
@synthesize networkQueue;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewWillDisappear:(BOOL)animated{
  
  if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound){
    [self.networkQueue reset];
  }
  
  [super viewWillDisappear:animated];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
  if (self.warnUploadImageArr == nil) {
    self.warnUploadImageArr = [[NSMutableArray alloc] init];
  }
    //自定义networkQueue
  if (self.networkQueue == nil) {
    self.networkQueue = [[ASINetworkQueue alloc] init];
  }
  [self.networkQueue reset];
    // Do any additional setup after loading the view.
    self.title = self.selectName;
    self.view.backgroundColor = [UIColor whiteColor];
    self.image = [self cutCenterImage:[UIImage imageNamed:@"image-default"]  size:CGSizeMake(kImageWidth , kImageHeight)];
    CGSize mSize = [[UIScreen mainScreen] bounds].size;
    CGFloat screenWidth = mSize.width;
    CGFloat screenHeight = mSize.height;
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight) style:UITableViewStylePlain];
    [self.view addSubview:self.tableView];
    self.tableView.dataSource = self;
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.delegate = self;
    self.tableView.backgroundColor = [UIColor clearColor];
  // 集成刷新控件
  [self setupRefresh];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark UITable datasource and delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (imageIdArr.count%2 == 0) {
        return imageIdArr.count/2;
    }else
    return imageIdArr.count/2 + 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"Cell";
    //自定义UITableGridViewCell，里面加了个NSArray用于放置里面的3个图片按钮
    UITableGridViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableGridViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectedBackgroundView = [[UIView alloc] init];
        NSMutableArray *array = [NSMutableArray array];
        for (int i=0; i<2; i++) {
            //自定义继续UIButton的UIImageButton 里面只是加了2个row和column属性
            UIImageButton *button = [UIImageButton buttonWithType:UIButtonTypeCustom];
            button.bounds = CGRectMake(0, 0, kImageWidth, kImageHeight);
            button.center = CGPointMake((1 + i) * 1 + kImageWidth *( 0.5 + i) , 1 + kImageHeight * 0.5);
            button.tag = 100+i;
            [button setValue:[NSNumber numberWithInt:i] forKey:@"column"];
            [button setBackgroundImage:[UIImage imageNamed:@"default-ruiyituzhi"] forState:0];
            [button addTarget:self action:@selector(imageItemClick:) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:button];
            [array addObject:button];
        }
        [cell setValue:array forKey:@"buttons"];
    }
    UIImageButton *btn1 = (UIImageButton *)[cell viewWithTag:100];
    if (self.imageIdArr.count-1 >= indexPath.row*2 ) {
      btn1.hidden = NO;
        //[btn1 loadImage:];
      [self loadImage:[self.imageIdArr objectAtIndex:indexPath.row*2] button:btn1];
    }else
    {
      btn1.hidden = YES;
    }
    UIImageButton *btn2 = (UIImageButton *)[cell viewWithTag:101];
    if (self.imageIdArr.count-1 >= indexPath.row*2+1 ) {
      btn2.hidden = NO;
       [self loadImage:[self.imageIdArr objectAtIndex:indexPath.row*2+1] button:btn2];
        //[btn2 loadImage:[self.imageIdArr objectAtIndex:indexPath.row*2+1]];
    }else
    {
    btn2.hidden = YES;
    }
    //添加警告图片
  for (int i = 0; i < self.warnUploadImageArr.count; i++) {
    if ([[self.warnUploadImageArr objectAtIndex:i] intValue] == i) {
      if (i%2 == 0) {
        [btn1 setImage:[UIImage imageNamed:@"image-warning"] forState:0];
      }else
      {
        [btn2 setImage:[UIImage imageNamed:@"image-warning"] forState:0];
      }
    }
  }
    //获取到里面的cell里面的3个图片按钮引用
    NSArray *imageButtons =cell.buttons;
    //设置UIImageButton里面的row属性
    [imageButtons setValue:[NSNumber numberWithInteger:indexPath.row] forKey:@"row"];
    [imageButtons setValue:[NSNumber numberWithInteger:indexPath.section] forKey:@"section"];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return kImageHeight + 1;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //不让tableviewcell有选中效果
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)imageItemClick:(UIImageButton *)button{
    NSString *selectId;
    if (button.column == 0) {
        selectId = [self.caseIdArr objectAtIndex:button.row*2];
    }else
    {
        selectId = [self.caseIdArr objectAtIndex:button.row*2+1];
    }
    
    
    DetailViewController *detailVC = [[DetailViewController alloc] init];
    detailVC.caseId = selectId;
    [self.navigationController pushViewController:detailVC animated:YES];
    //  dispatch_async(dispatch_get_global_queue(0, 0), ^{
    //      // 处理耗时操作的代码块...
    [imdRequest getRequest:[NSString stringWithFormat:@"%@/%@",[UrlCenter urlOfType:GET_IMAGE_CASE],selectId] delegate:detailVC requestType:@"getImageDetail"];
    //请求讨论区
    [imdRequest getRequest:[NSString stringWithFormat:@"%@/%@/1/1000",[UrlCenter urlOfType:GET_PARENT_DISCUSS],selectId] delegate:detailVC requestType:@"getDetailParentDiscuss"];
}





#pragma mark 根据size截取图片中间矩形区域的图片 这里的size是正方形
-(UIImage *)cutCenterImage:(UIImage *)image size:(CGSize)size{
    CGSize imageSize = image.size;
    CGRect rect;
    //根据图片的大小计算出图片中间矩形区域的位置与大小
    if (imageSize.width > imageSize.height) {
        float leftMargin = (imageSize.width - imageSize.height) * 0.5;
        rect = CGRectMake(leftMargin, 0, imageSize.height, imageSize.height);
    }else{
        float topMargin = (imageSize.height - imageSize.width) * 0.5;
        rect = CGRectMake(0, topMargin, imageSize.width, imageSize.width);
    }
    
    CGImageRef imageRef = image.CGImage;
    //截取中间区域矩形图片
    CGImageRef imageRefRect = CGImageCreateWithImageInRect(imageRef, rect);
    
    UIImage *tmp = [[UIImage alloc] initWithCGImage:imageRefRect];
    CGImageRelease(imageRefRect);
    
    UIGraphicsBeginImageContext(size);
    CGRect rectDraw = CGRectMake(0, 0, size.width, size.height);
    [tmp drawInRect:rectDraw];
    // 从当前context中创建一个改变大小后的图片
    tmp = UIGraphicsGetImageFromCurrentImageContext();
    
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    
    return tmp;
}
/**
 *  集成刷新控件
 */
- (void)setupRefresh
{
    // 1.下拉刷新(进入刷新状态就会调用self的headerRereshing)
  [self.tableView addHeaderWithTarget:self action:@selector(headerRereshing)];
    //[self.tableView headerBeginRefreshing];
  if (self.imageIdArr.count == 10) {
      // 2.上拉加载更多(进入刷新状态就会调用self的footerRereshing)
    [self.tableView addFooterWithTarget:self action:@selector(footerRereshing)];
    
    self.tableView.footerPullToRefreshText = @"上拉可以加载更多数据了";
    self.tableView.footerReleaseToRefreshText = @"松开马上加载更多数据了";
    self.tableView.footerRefreshingText = @"睿医为您努力加载中...";
  }
  
    // 设置文字(也可以不设置,默认的文字在MJRefreshConst中修改)
  self.tableView.headerPullToRefreshText = @"下拉可以刷新了";
  self.tableView.headerReleaseToRefreshText = @"松开马上刷新了";
  self.tableView.headerRefreshingText = @"睿医为您努力加载中...";
}
#pragma mark 开始进入刷新状态
- (void)headerRereshing
{
  [self.tableView headerEndRefreshing];
}

- (void)footerRereshing
{
    int page =(int)self.imageIdArr.count/10 + 1;
    if ([self.imageType isEqualToString:@"GET_FAV_LIST"]) {
      [imdRequest getRequest:[NSString stringWithFormat:@"%@/%d/10",[UrlCenter urlOfType:GET_FAV_LIST],page] delegate:self requestType:@"GET_FAV_LIST"];
    }else if([self.imageType isEqualToString:@"GET_SEARCH_PART"])
    {
    [imdRequest getRequest:[NSString stringWithFormat:@"%@/%@/%d/10",[UrlCenter urlOfType:GET_SEARCH_PART],[Strings getAnatomyString:self.selectName],page] delegate:self requestType:@"GET_SEARCH_PART"];
    }else if([self.imageType isEqualToString:@"GET_SEARCH_DEPARTMENT"])
    {
    [imdRequest getRequest:[NSString stringWithFormat:@"%@/%@/%d/10",[UrlCenter urlOfType:GET_SEARCH_DEPARTMENT],[Strings getDepartmentString:self.selectName],page] delegate:self requestType:@"GET_SEARCH_DEPARTMENT"];
    }else if([self.imageType isEqualToString:@"SEARCH_STRING"])
    {
      [imdRequest postSearch:[NSString stringWithFormat:@"%@/%d/10",[UrlCenter urlOfType:SEARCH_STRING],page] delegate:self requestType:@"SEARCH_STRING" postData:self.selectName];
    }else if([self.imageType isEqualToString:@"GET_PERSON_SELF_CASE"])
    {
      [imdRequest getRequest:[NSString stringWithFormat:@"%@/%d/10",[UrlCenter urlOfType:GET_PERSON_SELF_CASE],page] delegate:self requestType:@"GET_PERSON_SELF_CASE"];
    }else if([self.imageType isEqualToString:@"GET_PERSON_SELF_COMMENT"])
    {
      [imdRequest getRequest:[NSString stringWithFormat:@"%@/%d/10",[UrlCenter urlOfType:GET_PERSON_SELF_COMMENT],page] delegate:self requestType:@"GET_PERSON_SELF_COMMENT"];
    }
  
}
#pragma mark - HTTP REQUEST
- (void)requestFinished:(ASIHTTPRequest *)request{
  NSString* responseString = [request responseString];
  NSLog(@"xxxx%@",responseString);
    NSString* rType =[[request userInfo] objectForKey:REQUEST_TYPE];
  if ([rType isEqualToString:@"GET_FAV_LIST"]) {
    NSArray *info;
    if (responseString ==(id)[NSNull null] || responseString.length ==0 || [responseString isEqualToString:@"internal server error"])
    {
      info =nil;
    }
    else
    {
      info = [iosVersionChecker parseJSONObjectFromJSONString:responseString];
      if (info.count == 0) {
        [self.tableView footerEndRefreshing];
        [self.tableView removeFooter];
        return;
      }else
      {
        for (int i = 0; i < info.count; i++) {
          NSDictionary *dic = [info objectAtIndex:i];
          NSString *picId = [[dic objectForKey:@"caze"] objectForKey:@"coverPicId"];
          NSString *caseId = [dic objectForKey:@"caseId"];
          [self.imageIdArr addObject:picId];
          [self.caseIdArr addObject:caseId];
        }
          //调用endRefreshing可以结束刷新状态
        [self.tableView reloadData];
        [self.tableView footerEndRefreshing];
      }
    }
  }else if ([rType isEqualToString:@"GET_PERSON_SELF_CASE"])
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
      if (arr.count == 0) {
        [self.tableView footerEndRefreshing];
        [self.tableView removeFooter];
        return;
      }else
      {
        for (int i = 0; i < arr.count; i++) {
          NSDictionary *dic = [arr objectAtIndex:i];
          NSString *picId = [dic objectForKey:@"coverPicId"];
          NSString *caseId = [dic objectForKey:@"id"];
          
          NSString *status = [dic objectForKey:@"status"];
            if ([status isEqualToString:@"Warning"]) {
            [self.warnUploadImageArr addObject:[NSNumber numberWithInt:i+self.imageIdArr.count]];
            [self.imageIdArr addObject:picId];
            [self.caseIdArr addObject:caseId];
          }else if([status isEqualToString:@"Forbidden"])
          {
            
          }else
          {
            [self.imageIdArr addObject:picId];
            [self.caseIdArr addObject:caseId];
          }
          
        }
          //调用endRefreshing可以结束刷新状态
        [self.tableView reloadData];
        [self.tableView footerEndRefreshing];
      }
    }
  }else if ([rType isEqualToString:@"GET_PERSON_SELF_COMMENT"])
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
      if (arr.count == 0) {
        [self.tableView footerEndRefreshing];
        [self.tableView removeFooter];
        return;
      }else
      {
        for (int i = 0; i < arr.count; i++) {
          NSDictionary *dic = [arr objectAtIndex:i];
          NSString *picId = [dic objectForKey:@"coverPicId"];
          NSString *caseId = [dic objectForKey:@"id"];
          [self.imageIdArr addObject:picId];
          [self.caseIdArr addObject:caseId];
        }
          //调用endRefreshing可以结束刷新状态
        [self.tableView reloadData];
        [self.tableView footerEndRefreshing];
      }
    }
  }else
  {
    NSArray *info;
    if (responseString ==(id)[NSNull null] || responseString.length ==0 || [responseString isEqualToString:@"internal server error"])
    {
      info =nil;
    }
    else
    {
      info = [iosVersionChecker parseJSONObjectFromJSONString:responseString];
      if (info.count == 0) {
        [self.tableView footerEndRefreshing];
        [self.tableView removeFooter];
        return;
      }else
      {
        for (int i = 0; i < info.count; i++) {
          NSDictionary *dic = [info objectAtIndex:i];
          NSString *picId = [dic objectForKey:@"coverPicId"];
          NSString *caseId = [dic objectForKey:@"id"];
          [self.imageIdArr addObject:picId];
          [self.caseIdArr addObject:caseId];
        }
          //调用endRefreshing可以结束刷新状态
        [self.tableView reloadData];
        [self.tableView footerEndRefreshing];
      }
    }
  
  }
  
  
  
  if (self.imageIdArr.count%10 == 0) {
    
  }else
  {
    [self.tableView removeFooter];
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
  UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
  [alertView show];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
//  if (buttonIndex == 0 && [alertView.message isEqualToString:@"抱歉，没有查找到相关内容。"]) {
//    [self.navigationController popToRootViewControllerAnimated:YES];
//  }
}
- (void) loadImage:(NSString*)name button:(UIImageButton *)btn{
  dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
  dispatch_async(queue, ^{
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/imageFile/"];
    
    NSString *filePath = [path stringByAppendingPathComponent:name];
    UIImage *image;
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
      CGSize size = CGSizeMake(btn.frame.size.width, btn.frame.size.height);
      image = [[UIImage imageWithContentsOfFile:filePath] imageByScalingAndCroppingForSize:size];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
      if (image)
        [btn setBackgroundImage:image forState:0];
      else
      {
        [networkQueue setRequestDidFinishSelector:@selector(imageDownloadComplete:)];//队列加载完成时调用的方法
        [networkQueue setRequestDidFailSelector:@selector(imageFetchFailed:)];//队列加载出错时调用的方法
        [networkQueue setDelegate:self];
        [networkQueue addOperation:[imdRequest downLoadPictureRequest:[NSString stringWithFormat:@"%@/%@",[UrlCenter urlOfType:DOWNLOAD_IMAGE],name] requestType:btn]];
        [networkQueue go];
      }
    });
  });
  
}
#pragma mark-
#pragma mark- downLoadImage
- (void)imageDownloadComplete:(ASIHTTPRequest*)request//加载完成时
{
  UIImage *image = [UIImage imageWithContentsOfFile:[request downloadDestinationPath]];
  UIImageButton *btn = [request.userInfo objectForKey:@"requestType"];
  if (image) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      UIImage *zipImage =[image imageByScalingAndCroppingForSize:CGSizeMake(btn.frame.size.width, btn.frame.size.height)];
      dispatch_async(dispatch_get_main_queue(), ^{
        [btn setBackgroundImage:zipImage forState:0];
      });
      
    });
    
  }
}
- (void)imageFetchFailed:(ASIHTTPRequest *)request//加载失败时
{
  NSLog(@"Failed to download images");
}

@end
