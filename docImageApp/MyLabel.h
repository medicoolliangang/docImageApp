//
//  MyLabel.h
//  docImageApp
//
//  Created by 侯建政 on 9/10/14.
//  Copyright (c) 2014 jianzheng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyLabel : UILabel
{
  float frameXOffset;
  float frameYOffset;
  
  NSAttributedString *attString;
}
@property (retain,nonatomic) NSAttributedString *attString;
@end
