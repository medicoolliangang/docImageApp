//
//  PPScrollingTableViewCell.m
//  PPImageScrollingTableViewControllerDemo
//
//  Created by popochess on 13/8/10.
//  Copyright (c) 2013年 popochess. All rights reserved.
//

#import "PPImageScrollingTableViewCell.h"
#import "PPImageScrollingCellView.h"
#import "userLocalData.h"

#define kScrollingViewHieght 110
#define kCategoryLabelWidth 200
#define kCategoryLabelHieght 30
#define kStartPointY 0

@interface PPImageScrollingTableViewCell() <PPImageScrollingViewDelegate>

@property (strong,nonatomic) UIColor *categoryTitleColor;
@property(strong, nonatomic) PPImageScrollingCellView *imageScrollingView;
@property (strong, nonatomic) NSString *categoryLabelText;
@property (nonatomic, strong) UIProgressView *progressView;
@end

@implementation PPImageScrollingTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        [self initialize];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self initialize];
}

- (void)initialize
{
    // Set ScrollImageTableCellView
    _imageScrollingView = [[PPImageScrollingCellView alloc] initWithFrame:CGRectMake(0., kCategoryLabelHieght, 320., kScrollingViewHieght)];
    _imageScrollingView.delegate = self;
  
  self.progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(80, kCategoryLabelHieght/2, 235, 1)];
  self.progressView.progressImage = [UIImage imageNamed:@"image-line"];
  [self.contentView addSubview:self.progressView];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshImage:) name:@"ImageDownload" object:nil];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];    
    // Configure the view for the selected state
}

- (void)setImageData:(NSMutableArray*)collectionImageData
{
    [_imageScrollingView setImageData:collectionImageData];
//  NSArray *array = collectionImageData;
//  if (array.count == 1) {
//    
//  }else
//  {
//    _categoryLabelText = [collectionImageData objectForKey:@"category"];
//  }
}

- (void)setCategoryLabelText:(NSString*)text{
    
    if ([self.contentView subviews]){
        for (UIView *subview in [self.contentView subviews]) {
          if ([subview isKindOfClass:[UILabel class]]) {
            [subview removeFromSuperview];
          }
          
        }
    }
    UILabel *categoryTitle = [[UILabel alloc] initWithFrame:CGRectMake(5, kStartPointY, kCategoryLabelWidth, kCategoryLabelHieght)];
    categoryTitle.textAlignment = NSTextAlignmentLeft;
    categoryTitle.text = text;
    categoryTitle.textColor = [UIColor colorWithRed:64.0/255.0 green:111.0/255.0 blue:176.0/255.0 alpha:1.0];
    categoryTitle.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:categoryTitle];

//  UIImageView *categoryLine = [[UIImageView alloc] initWithFrame:CGRectMake(80, kCategoryLabelHieght/2, 235, 1)];
//  categoryLine.backgroundColor = [UIColor clearColor];
//  [categoryLine setImage:[UIImage imageNamed:@"image-line"]];
  
}

- (void) setImageTitleLabelWitdh:(CGFloat)width withHeight:(CGFloat)height {

    [_imageScrollingView setImageTitleLabelWitdh:width withHeight:height];
}

- (void) setImageTitleTextColor:(UIColor *)textColor withBackgroundColor:(UIColor *)bgColor{

    [_imageScrollingView setImageTitleTextColor:textColor withBackgroundColor:bgColor];
}

- (void)setCollectionViewBackgroundColor:(UIColor *)color{
    
    _imageScrollingView.backgroundColor = color;
    _imageScrollingView.tag = self.tag+500;
    [self.contentView addSubview:_imageScrollingView];
}

#pragma mark - PPImageScrollingViewDelegate

- (void)collectionView:(PPImageScrollingCellView *)collectionView didSelectImageItemAtIndexPath:(NSIndexPath*)indexPath {

    [self.delegate scrollingTableViewCell:self didSelectImageAtIndexPath:indexPath atCategoryRowIndex:self.tag];
}
- (void)PscrollViewDidScroll:(UIScrollView *)bscrollView
{
  int number = bscrollView.contentOffset.x/100;
  if (number > 0 ) {
    switch (bscrollView.tag) {
      case 500:
        self.progressView.progress = number/[userLocalData getNewCount];
        break;
      case 501:
        self.progressView.progress = number/([userLocalData getHotCount]-2);
        break;
      case 502:
        self.progressView.progress = number/([userLocalData getCommentCount]-2);
        break;
      default:
        break;
    }
    
  }else
  {
    self.progressView.progress = 0;
  }
  [self.delegate PPscrollViewDidScroll:bscrollView];
}
  //更新图片
- (void)refreshImage:(NSNotification *)notification
{
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
     NSString *imagePath = [notification object];
    dispatch_sync(dispatch_get_main_queue(), ^{
      [_imageScrollingView setOneImage:imagePath];
    });
  });
  
}
-(void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ImageDownload" object:nil];
}
@end
