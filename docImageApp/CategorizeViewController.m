//
//  CategorizeViewController.m
//  docImageApp
//
//  Created by 侯建政 on 8/11/14.
//  Copyright (c) 2014 jianzheng. All rights reserved.
//

#import "CategorizeViewController.h"
#import "UITableView+ExtendedAnimations.h"
#import "MyButton.h"

@interface CategorizeViewController ()<UITableViewExtendedDelegate,UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) NSMutableArray *headArr;
@property (nonatomic, strong) NSMutableArray *neckArr;
@property (nonatomic, strong) NSMutableArray *thoraxArr;
@property (nonatomic, strong) NSMutableArray *limbsArr;
@property (nonatomic, strong) NSMutableArray *backArr;
@property (nonatomic, strong) NSMutableArray *abdomenAndpeiveisArr;
@property (nonatomic, strong) NSMutableArray *anatomyArr;
@property (nonatomic, strong) NSMutableArray *sectionArr;

@property (nonatomic, strong) UITableView *mySectonTable1;
@property (nonatomic, strong) NSArray *allTable1Data;

@property (nonatomic, strong) UITableView *mySectonTable2;
@property (nonatomic, strong) NSMutableArray *specialtySectionArray;


@property (nonatomic, strong) NSMutableArray *specialtyArray;
@property (nonatomic, strong) NSMutableArray *unSelectArr2;

@property (nonatomic, strong) UISegmentedControl *segmentCtr;
@property (nonatomic, strong) UIBarButtonItem *rightbarButton;
@end

@implementation CategorizeViewController
@synthesize anatomyArr,headArr,neckArr,thoraxArr,limbsArr,backArr,abdomenAndpeiveisArr,sectionArr,selectArr;
@synthesize mySectonTable1,mySectonTable2;
@synthesize specialtySectionArray,selectArr2,specialtyArray,unSelectArr2;
@synthesize segmentCtr;
@synthesize rightbarButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)dissView
{
  [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)viewDidDisappear:(BOOL)animated
{
  [super viewDidDisappear:animated];
}
- (void)viewDidLoad
{
  [super viewDidLoad];
  rightbarButton = [[UIBarButtonItem alloc] initWithTitle:@"选择" style:UIBarButtonItemStyleDone target:self action:@selector(done)];
 rightbarButton.enabled = FALSE;
  
  UIBarButtonItem *leftbarButton = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(dissView)];
  self.navigationItem.rightBarButtonItem = rightbarButton;
  self.navigationItem.leftBarButtonItem = leftbarButton;
  NSArray *segmentedArray = [[NSArray alloc]initWithObjects:@"解剖部位",@"专业科室",nil];
  segmentCtr = [[UISegmentedControl alloc] initWithItems:segmentedArray];
  segmentCtr.frame = CGRectMake(0, 7, 100, 30);
  segmentCtr.selectedSegmentIndex = 0;
  [segmentCtr addTarget:self action:@selector(selectSegment:) forControlEvents:UIControlEventValueChanged];
  self.navigationItem.titleView = segmentCtr;
  if (selectArr == nil) {
    selectArr = [[NSMutableArray alloc] init];
  }
  if (selectArr2 == nil) {
    selectArr2 = [[NSMutableArray alloc] init];
  }
  [self reloadTable1Data];
  [self reloadTable2Data];
  [self displayView];
    // Do any additional setup after loading the view.
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)reloadTable1Data
{
  anatomyArr = [[NSMutableArray alloc] initWithObjects:@"已选择",@"头部",@"颈部",@"胸部",@"四肢",@"背部",@"腹部与盆腔", nil];
  headArr = [[NSMutableArray alloc] initWithObjects:@"脑",@"耳",@"眼",@"面部",@"头部",@"口",@"鼻",@"颅骨", nil];
  neckArr = [[NSMutableArray alloc] initWithObjects:@"呼吸道",@"食管",@"颈部",@"血管", nil];
  thoraxArr = [[NSMutableArray alloc] initWithObjects:@"循环系统",@"心脏",@"肺部",@"纵隔",@"胃",@"胸腔", nil];
  limbsArr = [[NSMutableArray alloc] initWithObjects:@"踝部与足部",@"臀部与股部",@"下肢",@"肩部与手臂",@"上肢",@"腕部与手部", nil];
  backArr = [[NSMutableArray alloc] initWithObjects:@"背部",@"肌肉骨骼系统",@"脊柱", nil];
  abdomenAndpeiveisArr = [[NSMutableArray alloc] initWithObjects:@"腹部",@"主动脉",@"肾脏、输尿管、膀胱及肾上腺",@"大肠",@"肝、胰及胆道系统",@"盆腔",@"直肠与肛门",@"生殖器官",@"小肠",@"脾",@"其他", nil];
  if (selectArr.count > 0) {
    for (NSString *str in selectArr) {
      for (int i = 0; i < headArr.count; i++) {
        if ([str isEqualToString:[headArr objectAtIndex:i]]) {
          [headArr removeObjectAtIndex:i];
        }
      }
      for (int i = 0; i < neckArr.count; i++) {
        if ([str isEqualToString:[neckArr objectAtIndex:i]]) {
          [neckArr removeObjectAtIndex:i];
        }
      }
      for (int i = 0; i < thoraxArr.count; i++) {
        if ([str isEqualToString:[thoraxArr objectAtIndex:i]]) {
          [thoraxArr removeObjectAtIndex:i];
        }
      }
      for (int i = 0; i < limbsArr.count; i++) {
        if ([str isEqualToString:[limbsArr objectAtIndex:i]]) {
          [limbsArr removeObjectAtIndex:i];
        }
      }
      for (int i = 0; i < backArr.count; i++) {
        if ([str isEqualToString:[backArr objectAtIndex:i]]) {
          [backArr removeObjectAtIndex:i];
        }
      }
      for (int i = 0; i < abdomenAndpeiveisArr.count; i++) {
        if ([str isEqualToString:[abdomenAndpeiveisArr objectAtIndex:i]]) {
          [abdomenAndpeiveisArr removeObjectAtIndex:i];
        }
      }
    }
    
  }
  
  sectionArr = [[NSMutableArray alloc] initWithObjects:selectArr,headArr,neckArr,thoraxArr,limbsArr,backArr,abdomenAndpeiveisArr, nil];
  self.allTable1Data = @[@[@"脑",@"耳",@"眼",@"面部",@"头部",@"口",@"鼻",@"颅骨"],@[@"呼吸道",@"食管",@"颈部",@"血管"],@[@"循环系统",@"心脏",@"肺部",@"纵隔",@"胃",@"胸腔"],@[@"踝部与足部",@"臀部与股部",@"下肢",@"肩部与手臂",@"上肢",@"腕部与手部"],@[@"背部",@"肌肉骨骼系统",@"脊柱"],@[@"腹部",@"主动脉",@"肾脏、输尿管、膀胱及肾上腺",@"大肠",@"肝、胰及胆道系统",@"盆腔",@"直肠与肛门",@"生殖器官",@"小肠",@"脾",@"其他"]];
}
- (void)reloadTable2Data
{
  specialtySectionArray = [[NSMutableArray alloc] initWithObjects:@"已选择",@"未选择", nil];
  unSelectArr2 = [[NSMutableArray alloc] initWithObjects:@"麻醉科",@"烧伤整形外科",@"心血管外科",@"心血管内科",@"重症医学科",@"中西医结合科",@"皮肤科",@"急诊医学科",@"内分泌科",@"消化内科",@"全科医疗科",@"普通外科",@"老年科",@"妇科",@"血液内科",@"传染科",@"医学检验科",@"管理科室",@"医学影像科",@"民族医学科",@"肾脏内科",@"神经内科",@"神经外科",@"临床营养科",@"产科",@"职业病科",@"肿瘤科",@"眼科",@"骨科",@"泌尿外科",@"耳鼻咽喉科",@"病理科",@"儿科",@"药剂科",@"医疗美容科",@"预防保健科",@"精神科",@"康复医学科",@"呼吸内科",@"风湿免疫科",@"运动医学科",@"口腔科",@"胸外科",@"中医科",@"其他科室",nil];
  for (NSString *str in selectArr2) {
    for (int i = 0; i < unSelectArr2.count; i++) {
      if ([str isEqualToString:[unSelectArr2 objectAtIndex:i]]) {
        [unSelectArr2 removeObjectAtIndex:i];
      }
    }
  }
  self.specialtyArray = [[NSMutableArray alloc] initWithObjects:selectArr2,unSelectArr2,nil];
}
- (void)displayView
{
  float heightV = [UIScreen mainScreen].bounds.size.height;
  float widthV = [UIScreen mainScreen].bounds.size.width;
  mySectonTable1 = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, widthV, heightV)];
  [self.view addSubview:mySectonTable1];
  mySectonTable1.delegate = self;
  mySectonTable1.dataSource = self;
  mySectonTable1.tag = 1000;
  [mySectonTable1 reloadData];
  
  mySectonTable2 = [[UITableView alloc] initWithFrame:CGRectMake(0, NavgationHeight, widthV, heightV-NavgationHeight)];
  [self.view addSubview:mySectonTable2];
  mySectonTable2.delegate = self;
  mySectonTable2.dataSource = self;
  mySectonTable2.tag = 1001;
  mySectonTable2.hidden = YES;
  [mySectonTable2 reloadData];
}
#pragma mark - UITableView Delegate and Datasource functions
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  NSInteger sectionNumber = 0;
  if (tableView == self.mySectonTable1) {
    sectionNumber = [anatomyArr count];
  }else
    sectionNumber = [self.specialtySectionArray count];
  
  return sectionNumber;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  NSMutableArray *sectionArray;
  if (tableView == self.mySectonTable1) {
   sectionArray = [self.sectionArr objectAtIndex:section];
  }else
	 sectionArray = [self.specialtyArray objectAtIndex:section];
  return [sectionArray count];
}
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//  if (section == 0) {
//    return 0;
//  }
//  return 23;
//}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
  UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(10.0, 0.0, 300.0, 44.0)];
  customView.backgroundColor = [UIColor grayColor];
  
  UILabel * headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
  headerLabel.backgroundColor = [UIColor clearColor];
  headerLabel.opaque = NO;
  headerLabel.textColor = [UIColor whiteColor];
  headerLabel.highlightedTextColor = [UIColor whiteColor];
  headerLabel.font = [UIFont boldSystemFontOfSize:15];
  headerLabel.frame = CGRectMake(13, 2, 300.0, 20);
  if (tableView == self.mySectonTable1) {
    headerLabel.text = [self.anatomyArr objectAtIndex:section];
  }else
    headerLabel.text = [self.specialtySectionArray objectAtIndex:section];
  [customView addSubview:headerLabel];
  return customView;
}
- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section
{
  NSString *str;
  if (aTableView == self.mySectonTable1) {
    str = [self.anatomyArr objectAtIndex:section];
  }else
    str = [self.specialtySectionArray objectAtIndex:section];
  return str;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  static NSString *CellIdentifier = @"Cell";
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  cell.backgroundColor = [UIColor clearColor];
  if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
      //add button
    MyButton *addButton = [MyButton buttonWithType:UIButtonTypeContactAdd];
    addButton.frame = CGRectMake(270, 7, 30, 30);
    addButton.tag = 101;
    addButton.backgroundColor = [UIColor clearColor];
    [addButton addTarget:self action:@selector(addButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [cell.contentView addSubview:addButton];
    
    //reduce button
    MyButton *reduceButton = [MyButton buttonWithType:UIButtonTypeCustom];
    [reduceButton setImage:[UIImage imageNamed:@"image_reduce"] forState:0];
    [reduceButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 11, 16)];
    reduceButton.frame = CGRectMake(270, 7, 44, 44);
    reduceButton.tag = 102;
    [reduceButton addTarget:self action:@selector(reduceButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [cell.contentView addSubview:reduceButton];
    
    cell.contentView.backgroundColor = [UIColor clearColor];
  }
  
  MyButton *btn = (MyButton *)[cell.contentView viewWithTag:101];
  btn.cellIndex = indexPath;
  
  MyButton *btn2 = (MyButton *)[cell.contentView viewWithTag:102];
  btn2.cellIndex = indexPath;
  
  if (indexPath.section == 0) {
    cell.contentView.backgroundColor = [UIColor lightGrayColor];
    btn.hidden = YES;
    btn2.hidden = NO;
  }else
  {
    cell.contentView.backgroundColor = [UIColor clearColor];
    btn.hidden = NO;
    btn2.hidden = YES;
  }
  NSMutableArray *sectionArray;
  if (tableView == self.mySectonTable1) {
    sectionArray = [self.sectionArr objectAtIndex:indexPath.section];
  }else
	  sectionArray = [self.specialtyArray objectAtIndex:indexPath.section];
	
	cell.textLabel.text = [sectionArray objectAtIndex:indexPath.row];
    //btn2.cellString = [sectionArray objectAtIndex:indexPath.row];
  btn2.cellString = [sectionArray objectAtIndex:indexPath.row];
  cell.textLabel.font = [UIFont systemFontOfSize:15.0];
    //cell.selectionStyle = UITableViewCellSelectionStyleGray;
  return cell;
}
- (void)reloadMyTableView1
{
  [self.mySectonTable1 reloadData];
  NSInteger A = self.selectArr2.count + self.selectArr.count;
  if (A > 0) {
    rightbarButton.enabled = YES;
  }else
    rightbarButton.enabled = NO;
}
- (void)reloadMyTableView2
{
  [self.mySectonTable2 reloadData];
  NSInteger A = self.selectArr2.count + self.selectArr.count;
  if (A > 0) {
    rightbarButton.enabled = YES;
  }else
    rightbarButton.enabled = NO;
}
- (void)tableView:(UITableView *)tableView
         moveCell:(UITableViewCell *)cell
    fromIndexPath:(NSIndexPath *)fromIndexPath
      toIndexPath:(NSIndexPath *)toIndexPath {
  NSMutableArray *sectionArray1;
  NSMutableArray *sectionArray2;
  if (tableView == self.mySectonTable1) {
    sectionArray1 = [self.sectionArr objectAtIndex:fromIndexPath.section];
    sectionArray2 = [self.sectionArr objectAtIndex:toIndexPath.section];
  }else
  {
	sectionArray1 = [self.specialtyArray objectAtIndex:fromIndexPath.section];
	sectionArray2 = [self.specialtyArray objectAtIndex:toIndexPath.section];
	}
	NSString *stringToMove = [sectionArray1 objectAtIndex:fromIndexPath.row];
	[sectionArray1 removeObjectAtIndex:fromIndexPath.row];
	[sectionArray2 insertObject:stringToMove atIndex:toIndexPath.row];
}

- (void)tableView:(UITableView *)tableView
     exchangeCell:(UITableViewCell *)cell1 atIndexPath:(NSIndexPath *)indexPath1
         withCell:(UITableViewCell *)cell2 atIndexPath:(NSIndexPath *)indexPath2 {
	NSMutableArray *sectionArray1;
	NSMutableArray *sectionArray2;
	if (tableView == self.mySectonTable1) {
    sectionArray1 = [self.sectionArr objectAtIndex:indexPath1.section];
    sectionArray2 = [self.sectionArr objectAtIndex:indexPath2.section];
  }else
  {
    sectionArray1 = [self.specialtyArray objectAtIndex:indexPath1.section];
    sectionArray2 = [self.specialtyArray objectAtIndex:indexPath2.section];
	}
	NSString *string1 = [sectionArray1 objectAtIndex:indexPath1.row];
	NSString *string2 = [sectionArray2 objectAtIndex:indexPath2.row];
	
	[sectionArray1 replaceObjectAtIndex:indexPath1.row withObject:string2];
	[sectionArray2 replaceObjectAtIndex:indexPath2.row withObject:string1];
	
	cell1.textLabel.text = string2;
	cell2.textLabel.text = string1;
}

- (void)tableView:(UITableView *)tableView transitionDeletedCellForRowAtIndexPath:(NSIndexPath *)indexPath {
  NSMutableArray *sectionArray;
  if (tableView == self.mySectonTable1) {
    sectionArray = [self.sectionArr objectAtIndex:indexPath.section];
  }else
	 sectionArray = [self.specialtyArray objectAtIndex:indexPath.section];
	[sectionArray removeObjectAtIndex:indexPath.row];
}

- (void)tableView:(UITableView *)tableView transitionInsertedCellForRowAtIndexPath:(NSIndexPath *)indexPath {
  NSMutableArray *sectionArray;
  if (tableView == self.mySectonTable1) {
    sectionArray = [self.sectionArr objectAtIndex:indexPath.section];
  }else
	sectionArray = [self.specialtyArray objectAtIndex:indexPath.section];
	[sectionArray insertObject:@"TRANSITION CELL" atIndex:indexPath.row];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  
}
- (void)done
{
  NSMutableArray *mutArr = [[NSMutableArray alloc] init];
  NSMutableArray *depArr = [[NSMutableArray alloc] init];
  for (int i = 0; i < selectArr.count; i++) {
    [mutArr addObject:[selectArr objectAtIndex:i]];
  }
  for (int i = 0; i < selectArr2.count; i++) {
    [depArr addObject:[selectArr2 objectAtIndex:i]];
  }
  [self.delegate selectCategorize:mutArr departMent:depArr];
  [self dissView];
  NSLog(@"%@",mutArr);
}
-(void)addButtonClick:(MyButton *)btn
{
  NSLog(@"%@",btn.cellIndex);
  NSIndexPath *index = [NSIndexPath indexPathForRow:0 inSection:0];
  if (segmentCtr.selectedSegmentIndex == 0) {
    [self.mySectonTable1 moveMyRowAtIndexPath:btn.cellIndex toIndexPath:index];
  }else
    [self.mySectonTable2 moveMyRowAtIndexPath:btn.cellIndex toIndexPath:index];
}
-(void)reduceButtonClick:(MyButton *)btn
{
  NSLog(@"%@",btn.cellIndex);
  
  if (segmentCtr.selectedSegmentIndex == 0) {
  NSIndexPath *index = [NSIndexPath indexPathForRow:0 inSection:[self searchSection:btn.cellString]];
	[self.mySectonTable1 moveMyRowAtIndexPath:btn.cellIndex toIndexPath:index];
  }else
  {
    NSIndexPath *index = [NSIndexPath indexPathForRow:0 inSection:1];
    [self.mySectonTable2 moveMyRowAtIndexPath:btn.cellIndex toIndexPath:index];
  }
}
- (NSInteger)searchSection:(NSString *)str
{
  int tempInt = 0;
  for (int i = 1; i<=[self.allTable1Data count]; i++) {
    NSArray *arr = [self.allTable1Data objectAtIndex:i-1];
    for (int j = 0; j < arr.count;j++ ) {
      if ([[arr objectAtIndex:j] isEqualToString:str]) {
        tempInt = i;
        break;
      }
    }
  }
  return tempInt;
}
-(void)selectSegment:(id)sender
{
  UISegmentedControl *segment = (UISegmentedControl *)sender;
    //NSLog(@"%d",segment.selectedSegmentIndex);
  switch (segment.selectedSegmentIndex) {
    case 0:
      mySectonTable1.hidden = NO;
      mySectonTable2.hidden = YES;
      break;
    case 1:
      mySectonTable1.hidden = YES;
      mySectonTable2.hidden = NO;
      break;
    default:
      break;
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
