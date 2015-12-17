//
//  myCityCollectionViewCell.m
//  ForwardOne
//
//  Created by 杨波 on 15/8/18.
//  Copyright (c) 2015年 杨波. All rights reserved.
//

#import "myCityCollectionViewCell.h"

@implementation myCityCollectionViewCell
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UILabel *label = [ZCControl createLabelWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width*0.22,[UIScreen mainScreen].bounds.size.height*0.06) Font:18 Text:nil];
        label.textAlignment = NSTextAlignmentCenter;
        //  label.backgroundColor = [UIColor orangeColor];
        [self.contentView addSubview:label];
        
        self.contentView.backgroundColor = [UIColor whiteColor];
        
        _label = label;
    }
    return self;
}
@end
