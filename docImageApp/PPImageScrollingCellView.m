//
//  PPImageScrollingCellView.m
//  PPImageScrollingTableViewDemo
//
//  Created by popochess on 13/8/9.
//  Copyright (c) 2013年 popochess. All rights reserved.
//

#import "PPImageScrollingCellView.h"
#import "PPCollectionViewCell.h"
#import "UIImageExt.h"

@interface  PPImageScrollingCellView () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (strong, nonatomic) PPCollectionViewCell *myCollectionViewCell;
@property (strong, nonatomic) UICollectionView *myCollectionView;
@property (strong, nonatomic) NSArray *collectionImageData;
@property (nonatomic) CGFloat imagetitleWidth;
@property (nonatomic) CGFloat imagetitleHeight;
@property (strong, nonatomic) UIColor *imageTilteBackgroundColor;
@property (strong, nonatomic) UIColor *imageTilteTextColor;

@property (assign, nonatomic) NSInteger newCount;
@property (assign, nonatomic) NSInteger hotCount;
@property (assign, nonatomic) NSInteger recommentCount;

@property (nonatomic, strong) NSMutableDictionary *unimageDic;
@end

@implementation PPImageScrollingCellView

- (id)initWithFrame:(CGRect)frame
{
     self = [super initWithFrame:frame];
    
    if (self) {
        // Initialization code

        /* Set flowLayout for CollectionView*/
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flowLayout.itemSize = CGSizeMake(100.0, 120.0);
        flowLayout.sectionInset = UIEdgeInsetsMake(1, 1, 1, 1);
        flowLayout.minimumLineSpacing = 3;

        /* Init and Set CollectionView */
        self.myCollectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:flowLayout];
        self.myCollectionView.delegate = self;
        self.myCollectionView.dataSource = self;
        self.myCollectionView.showsHorizontalScrollIndicator = NO;
      
        [self.myCollectionView registerClass:[PPCollectionViewCell class] forCellWithReuseIdentifier:@"PPCollectionCell"];
        [self addSubview:_myCollectionView];
      
      self.unimageDic = [[NSMutableDictionary alloc] init];
    }
    return self;
}
- (void) setOneImage:(NSString *)imagePath
{
  for (int i = 0; i < _collectionImageData.count; i++) {
    if ([[_collectionImageData objectAtIndex:i] isEqualToString:imagePath]) {
      NSString *key = [NSString stringWithFormat:@"%zd:%d",self.tag,i];
      PPCollectionViewCell *cell = (PPCollectionViewCell *)[self.unimageDic objectForKey:key];
      if ([[NSFileManager defaultManager] fileExistsAtPath:imagePath]) {
        [cell setImage:[UIImage imageWithContentsOfFile:imagePath]];
        [self.unimageDic removeObjectForKey:key];
      }
      return;
    }
  
  }
}
- (void) setImageData:(NSArray*)collectionImageData{

  _collectionImageData = collectionImageData;
  NSInteger count = collectionImageData.count;
    //NSFileManager *fileManger = [NSFileManager defaultManager];
  if (count > 4) {
    NSInteger movecount = 0;
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    switch (self.tag) {
      case 500:
      {
        movecount = count - self.newCount;
        for (int i = 0; i < movecount; i++) {
          [arr addObject:[NSIndexPath indexPathForItem:self.newCount+i inSection:0]];
        }
      }
        break;
      case 501:
      {
        movecount = count - self.hotCount;
        for (int i = 0; i < movecount; i++) {
          [arr addObject:[NSIndexPath indexPathForItem:self.hotCount+i inSection:0]];
        }
      }
        break;
      case 502:
      {
        movecount = count - self.recommentCount;
        for (int i = 0; i < movecount; i++) {
          [arr addObject:[NSIndexPath indexPathForItem:self.recommentCount+i inSection:0]];
        }
      }
        break;
      default:
        break;
    }
    if (arr.count > 0) {
      [self.myCollectionView performBatchUpdates:^{
        [self.myCollectionView insertItemsAtIndexPaths:arr];
      } completion:nil];
    }
  }else
  {
    [self.myCollectionView performBatchUpdates:^{
      [self.myCollectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
      self.myCollectionView.contentOffset = CGPointZero;
          } completion:nil];

  }
  switch (self.tag) {
    case 500:
    {
      self.newCount = collectionImageData.count;
    }
      break;
    case 501:
    {
      self.hotCount = collectionImageData.count;
    }
      break;
    case 502:
    {
      self.recommentCount = collectionImageData.count;
    }
      break;
    default:
      break;
  }

}

- (void) setBackgroundColor:(UIColor*)color{

    self.myCollectionView.backgroundColor = color;
    //[_myCollectionView reloadData];
}

- (void) setImageTitleLabelWitdh:(CGFloat)width withHeight:(CGFloat)height{
    _imagetitleWidth = width;
    _imagetitleHeight = height;
}
- (void) setImageTitleTextColor:(UIColor*)textColor withBackgroundColor:(UIColor*)bgColor{
    
    _imageTilteTextColor = textColor;
    _imageTilteBackgroundColor = bgColor;
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
    PPCollectionViewCell *cell = (PPCollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"PPCollectionCell" forIndexPath:indexPath];
//  if ([cell.contentView subviews]){
//    for (UIImageView *subview in [cell.contentView subviews]) {
//      [subview removeFromSuperview];
//    }
//  }
  for (UIView *subView in cell.contentView.subviews)
  {
    [subView removeFromSuperview];
  }
    NSString *imagePath = [self.collectionImageData objectAtIndex:[indexPath row]];

    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
  if (image) {
        [cell setImage:image];
  }else
  {
    [cell setImage:[UIImage imageNamed:@"default-ruiyituzhi200"]];
      //记录未加载的图片
    NSString *key = [NSString stringWithFormat:@"%zd:%zd",self.tag,indexPath.row];
    [self.unimageDic setObject:cell forKey:key];
  }
  
//    [cell setImageTitleLabelWitdh:_imagetitleWidth withHeight:_imagetitleHeight];
//    [cell setImageTitleTextColor:_imageTilteTextColor withBackgroundColor:_imageTilteBackgroundColor];
    //[cell setTitle:@""];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.delegate collectionView:self didSelectImageItemAtIndexPath:(NSIndexPath*)indexPath];
}
- (void)scrollViewDidScroll:(UIScrollView *)bscrollView
{
//  if (self.refesh) {
//    bscrollView.contentOffset = CGPointZero;
//  }
  bscrollView.tag = self.tag;
  [self.delegate PscrollViewDidScroll:bscrollView];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
