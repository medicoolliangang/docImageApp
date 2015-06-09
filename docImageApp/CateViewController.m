//
//  CateViewController.m
//  docImageApp
//
//  Created by 侯建政 on 8/5/14.
//  Copyright (c) 2014 jianzheng. All rights reserved.
//

#import "CateViewController.h"
#import "UITableGridViewCell.h"
#import "UIImageButton.h"
#import "Strings.h"
#import "imdRequest.h"
#import "UrlCenter.h"
#import "iosVersionChecker.h"
#import "ImageFlowViewController.h"
#import "MBProgressHUD.h"

#define kImageWidth  80 //UITableViewCell里面图片的宽度
#define kImageHeight  80 //UITableViewCell里面图片的高度
#define kDepartmentHeight  44
typedef enum {
    Select_Part = 0,
    Select_Department,
} Select_Type;

@interface CateViewController ()
@property (nonatomic, strong) IBOutlet UISegmentedControl *segment;

//part
@property(nonatomic,strong) UITableView *tableView;
@property(nonatomic,strong) NSMutableArray *imagePartArr;
@property(nonatomic,strong) NSArray *anatomyArr;
@property(nonatomic,strong) NSArray *tablePartData;
@property(nonatomic,assign) Select_Type select_type;

//department
@property(nonatomic, strong) NSArray *departmentArr;

@property(nonatomic, strong) NSMutableArray *ImageArrayId;

@property(nonatomic, assign) NSString *selectName;

@property (nonatomic, strong) MBProgressHUD *hud;
  //asiHttp
@property (nonatomic, strong) ASIHTTPRequest *departmentRequest;
@property (nonatomic, strong) ASIHTTPRequest *partRequest;
@end

@implementation CateViewController
@synthesize hud;
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
    self.title = @"返回";
    [self.navigationController.navigationBar.topItem setTitleView:self.segment];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    //part data
    [self initTablePartData];
   //department data
    [self initTableDepartment];
    
    CGSize mSize = [[UIScreen mainScreen] bounds].size;
    CGFloat screenWidth = mSize.width;
    CGFloat screenHeight = mSize.height;
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight) style:UITableViewStylePlain];
    [self.view addSubview:_tableView];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    
    self.ImageArrayId = [[NSMutableArray alloc] init];
  
  self.select_type = Select_Part;
  
  self.hud = [[MBProgressHUD alloc] initWithView:self.view];
  self.hud.labelText = @"加载中...";
  [self.view addSubview:self.hud];
}
- (void)initTablePartData
{
  self.imagePartArr = [[NSMutableArray alloc] init];
  NSMutableArray *arr = [[NSMutableArray alloc] init];
  for (int i = 0; i < 8 ; i ++) {
    [arr addObject:[NSString stringWithFormat:@"icon_0%d_1",i+1]];
  }
  [self.imagePartArr addObject:[arr copy]];
  [arr removeAllObjects];
  for (int i = 8; i < 12 ; i ++) {
    if (i >= 9) {
      [arr addObject:[NSString stringWithFormat:@"icon_%d_1",i+1]];
    }else
    [arr addObject:[NSString stringWithFormat:@"icon_0%d_1",i+1]];
  }
  [self.imagePartArr addObject:[arr copy]];
  [arr removeAllObjects];
  for (int i = 12; i < 18 ; i ++) {
      [arr addObject:[NSString stringWithFormat:@"icon_%d_1",i+1]];
  }
  [self.imagePartArr addObject:[arr copy]];
  [arr removeAllObjects];
  for (int i = 18; i < 24 ; i ++) {
    [arr addObject:[NSString stringWithFormat:@"icon_%d_1",i+1]];
  }
  [self.imagePartArr addObject:[arr copy]];
  [arr removeAllObjects];
  for (int i = 24; i < 27 ; i ++) {
    [arr addObject:[NSString stringWithFormat:@"icon_%d_1",i+1]];
  }
  [self.imagePartArr addObject:[arr copy]];
  [arr removeAllObjects];
  for (int i = 27; i < 39 ; i ++) {
    [arr addObject:[NSString stringWithFormat:@"icon_%d_1",i+1]];
  }
  [self.imagePartArr addObject:[arr copy]];
  [arr removeAllObjects];
    self.anatomyArr = [[NSArray alloc] initWithObjects:@"头部",@"颈部",@"胸部",@"四肢",@"背部",@"腹部与盆腔",nil];
    self.tablePartData = @[@[@"耳",@"眼",@"面部",@"脑",@"头部",@"口",@"鼻",@"颅骨"],@[@"呼吸道",@"食管",@"颈部",@"血管"],@[@"循环系统",@"心脏",@"肺部",@"纵隔",@"胃",@"胸腔"],@[@"踝部与足部",@"臀部与股部",@"下肢",@"肩部与手臂",@"腕部与手部",@"上肢"],@[@"背部",@"脊柱",@"肌肉骨骼系统"],@[@"腹部",@"主动脉",@"肝、胰及胆道系统",@"肾脏、输尿管、膀胱及肾上腺",@"大肠",@"直肠与肛门",@"生殖器官",@"小肠",@"脾",@"盆腔",@"其他"]];
}
-(void)initTableDepartment
{
  self.departmentArr = @[@{@"indexTitle": @"B",@"data":@[@"病理科"]},
  @{@"indexTitle": @"C",@"data":@[@"传染科",@"产科",]},
  @{@"indexTitle": @"E",@"data":@[@"耳鼻咽喉科",@"儿科"]},
  @{@"indexTitle": @"F",@"data":@[@"妇科",@"风湿免疫科"]},
  @{@"indexTitle": @"G",@"data":@[@"管理科室",@"骨科"]},
  @{@"indexTitle": @"H",@"data":@[@"呼吸内科"]},
  @{@"indexTitle": @"J",@"data":@[@"急诊医学科",@"精神科"]},
  @{@"indexTitle": @"K",@"data":@[@"康复医学科",@"口腔科"]},
  @{@"indexTitle": @"L",@"data":@[@"老年科",@"临床营养科"]},
  @{@"indexTitle": @"M",@"data":@[@"麻醉科",@"民族医学科",@"泌尿外科"]},
  @{@"indexTitle": @"N",@"data":@[@"内分泌科"]},
  @{@"indexTitle": @"P",@"data":@[@"皮肤科",@"普通外科"]},
  @{@"indexTitle": @"Q",@"data":@[@"全科医疗科"]},
  @{@"indexTitle": @"S",@"data":@[@"烧伤整形外科",@"肾脏内科",@"神经内科",@"神经外科"]},
  @{@"indexTitle": @"X",@"data":@[@"心血管外科",@"心血管内科",@"消化内科",@"胸外科",@"血液内科"]},
  @{@"indexTitle": @"Y",@"data":@[@"医学检验科",@"医学影像科",@"眼科",@"药剂科",@"医疗美容科",@"预防保健科",@"运动医学科"]},
  @{@"indexTitle": @"Z",@"data":@[@"重症医学科",@"中西医结合科",@"职业病科",@"肿瘤科",@"中医科"]},
  @{@"indexTitle": @"#",@"data":@[@"其他科室"]}];
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
#pragma mark - UISegmentedControl Methods 
- (IBAction)segmentButtonClick:(id)sender
{
    switch (self.segment.selectedSegmentIndex) {
        case 0:
      {
            self.select_type = Select_Part;
        if (self.departmentRequest) {
          [self.departmentRequest cancel];
          [self.departmentRequest clearDelegatesAndCancel];
          self.departmentRequest = nil;
        }
            break;
      }
        case 1:
      {
        if (self.partRequest) {
          [self.partRequest cancel];
          [self.partRequest clearDelegatesAndCancel];
          self.partRequest = nil;
        }
            self.select_type = Select_Department;
            break;
      }
        default:
            break;
    }
  [self.hud hide:YES];
    [self.tableView reloadData];
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
#pragma mark UITable datasource and delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (self.select_type == Select_Part) {
        return [self.anatomyArr count];
    }else
       return [self.departmentArr count];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.select_type == Select_Part) {
        NSArray *arr = [self.tablePartData objectAtIndex:section];
        if (arr.count%4 == 0) {
            return arr.count/4;
        }else
            return arr.count/4+1;
    }else
    {
      NSArray *arr = [[self.departmentArr objectAtIndex:section] objectForKey:@"data"];
        return arr.count;
    }
}

- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section
{
    if (self.select_type == Select_Part)
    return [self.anatomyArr objectAtIndex:section];
    else
    return [[self.departmentArr objectAtIndex:section] objectForKey:@"indexTitle"];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
  
    //自定义UITableGridViewCell，里面加了个NSArray用于放置里面的3个图片按钮
  
  if (self.select_type == Select_Part) {
    tableView.separatorColor = [UIColor clearColor];
    static NSString *identifier = @"Cell";
    UITableGridViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
      cell = [[UITableGridViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
      //cell.selectedBackgroundView = [[UIView alloc] init];
    }
    for(UIView *view in cell.contentView.subviews)
    {
      [view removeFromSuperview];
    }
    NSArray *arr = [self.tablePartData objectAtIndex:indexPath.section];
    NSArray *arrImage = [self.imagePartArr objectAtIndex:indexPath.section];
    NSInteger count;
   
    if ((arr.count- indexPath.row*4)/4 == 0) {
      count = arr.count- indexPath.row*4;
    }else
    {
      count = 4;
    }
    NSMutableArray *array = [NSMutableArray array];
    
    for (int i=0; i<count; i++) {
        //自定义继续UIButton的UIImageButton 里面只是加了2个row和column属性
      UIImageButton *button = [UIImageButton buttonWithType:UIButtonTypeCustom];
      button.frame = CGRectMake(i*kImageWidth, 0, kImageWidth, kImageHeight);
        //button.center = CGPointMake((1 + i) * 1 + kImageWidth *( 0.5 + i) , 1 + kImageHeight * 0.5);
        //button.column = i;
      [button setValue:[NSNumber numberWithInt:i] forKey:@"column"];
      [button addTarget:self action:@selector(imageItemClick:) forControlEvents:UIControlEventTouchUpInside];
      [button setImage:[UIImage imageNamed:[arrImage objectAtIndex:indexPath.row*4+i]] forState:UIControlStateNormal];
      [cell.contentView addSubview:button];
      [array addObject:button];
    }
    [cell setValue:array forKey:@"buttons"];
      //获取到里面的cell里面的3个图片按钮引用
    NSArray *imageButtons =cell.buttons;
      //设置UIImageButton里面的row属性
    [imageButtons setValue:[NSNumber numberWithInteger:indexPath.row] forKey:@"row"];
    [imageButtons setValue:[NSNumber numberWithInteger:indexPath.section] forKey:@"section"];
    return cell;
  }else
  {
    tableView.separatorColor = [UIColor lightGrayColor];
    static NSString *identifier = @"departmentCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
      cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
      cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    NSArray *arr = [[self.departmentArr objectAtIndex:indexPath.section] objectForKey:@"data"];
    cell.textLabel.text = [arr objectAtIndex:indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:15.0];
    return cell;
  }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.select_type == Select_Part) {
        return kImageHeight;
    }else
        return kDepartmentHeight;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //不让tableviewcell有选中效果
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.select_type == Select_Department) {
      NSArray *arr = [[self.departmentArr objectAtIndex:indexPath.section] objectForKey:@"data"];
        self.selectName = [arr objectAtIndex:indexPath.row];
        NSLog(@".....%@",[Strings getDepartmentString:self.selectName]);
        //按照部门查询
      if (self.departmentRequest) {
        [self.departmentRequest cancel];
        [self.departmentRequest clearDelegatesAndCancel];
        self.departmentRequest = nil;
      }
   [self.hud show:YES];
   self.departmentRequest = [imdRequest getRequest:[NSString stringWithFormat:@"%@/%@/1/10",[UrlCenter urlOfType:GET_SEARCH_DEPARTMENT],[Strings getDepartmentString:self.selectName]] delegate:self requestType:@"GET_SEARCH_DEPARTMENT"];
      
    }
}

-(void)imageItemClick:(UIImageButton *)button{
    self.selectName = [[self.tablePartData objectAtIndex:button.section] objectAtIndex:button.column+4*button.row];
    NSLog(@".....%@",[Strings getAnatomyString:self.selectName]);
    
    //按照部位查询
  if (self.partRequest) {
    [self.partRequest cancel];
    [self.partRequest clearDelegatesAndCancel];
    self.partRequest = nil;
  }
  [self.hud show:YES];
   self.partRequest = [imdRequest getRequest:[NSString stringWithFormat:@"%@/%@/1/10",[UrlCenter urlOfType:GET_SEARCH_PART],[Strings getAnatomyString:self.selectName]] delegate:self requestType:@"GET_SEARCH_PART"];
}
#pragma mark - HTTP REQUEST
- (void)requestFinished:(ASIHTTPRequest *)request{
    NSString* responseString = [request responseString];
    NSLog(@"xxxx%@",responseString);
    NSString* rType =[[request userInfo] objectForKey:REQUEST_TYPE];
  [self.hud hide:YES];
    if ([rType isEqualToString:@"GET_SEARCH_PART"])
    {
        NSArray *info;
        if (responseString ==(id)[NSNull null] || responseString.length ==0 || [responseString isEqualToString:@"internal server error"])
        {
            info =nil;
        }
        else
        {
            info = [iosVersionChecker parseJSONObjectFromJSONString:responseString];
            [self.ImageArrayId removeAllObjects];
            NSMutableArray *caseIdArr = [[NSMutableArray alloc] init];
            for (int i = 0; i < info.count; i++) {
                NSDictionary *dic = [info objectAtIndex:i];
                NSString *picId = [dic objectForKey:@"coverPicId"];
                NSString *caseId = [dic objectForKey:@"id"];
                [self.ImageArrayId addObject:picId];
                [caseIdArr addObject:caseId];
            }
          if (self.ImageArrayId.count > 0) {
            ImageFlowViewController *waterVC = [[ImageFlowViewController alloc] init];
            waterVC.imageIdArr = self.ImageArrayId;
            waterVC.caseIdArr = caseIdArr;
            waterVC.imageType = @"GET_SEARCH_PART";
            waterVC.selectName = self.selectName;
            [self.navigationController pushViewController:waterVC animated:YES];
          }else
          {
            [self showAlertViewWithTitle:RUIYI_TITLE andMessage:@"抱歉，没有查找到相关内容。"];
          }
        }
    }else if ([rType isEqualToString:@"GET_SEARCH_DEPARTMENT"])
    {
        NSArray *info;
        if (responseString ==(id)[NSNull null] || responseString.length ==0 || [responseString isEqualToString:@"internal server error"])
        {
            info =nil;
        }
        else
        {
            info = [iosVersionChecker parseJSONObjectFromJSONString:responseString];
            [self.ImageArrayId removeAllObjects];
            NSMutableArray *caseIdArr = [[NSMutableArray alloc] init];
            for (int i = 0; i < info.count; i++) {
                NSDictionary *dic = [info objectAtIndex:i];
                NSString *picId = [dic objectForKey:@"coverPicId"];
                [self.ImageArrayId addObject:picId];
                NSString *caseId = [dic objectForKey:@"id"];
                [caseIdArr addObject:caseId];
            }
          if (self.ImageArrayId.count > 0) {
            ImageFlowViewController *waterVC = [[ImageFlowViewController alloc] init];
            waterVC.imageIdArr = self.ImageArrayId;
            waterVC.caseIdArr = caseIdArr;
            waterVC.selectName = self.selectName;
            waterVC.imageType = @"GET_SEARCH_DEPARTMENT";
            [self.navigationController pushViewController:waterVC animated:YES];
          }else
          {
            [self showAlertViewWithTitle:RUIYI_TITLE andMessage:@"抱歉，没有查找到相关内容。"];
          }
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
-(void)clearRequest
{

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
