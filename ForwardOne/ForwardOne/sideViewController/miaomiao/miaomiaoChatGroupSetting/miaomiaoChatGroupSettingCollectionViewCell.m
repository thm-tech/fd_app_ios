//
//  miaomiaoChatGroupSettingCollectionViewCell.m
//  ForwardOne
//
//  Created by 杨波 on 15/6/2.
//  Copyright (c) 2015年 杨波. All rights reserved.
//

#import "miaomiaoChatGroupSettingCollectionViewCell.h"

@implementation miaomiaoChatGroupSettingCollectionViewCell
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createUI];
    }
    return self;
}

-(void)createUI
{
    _iconImageView = [ZCControl createImageViewWithFrame:CGRectMake(0, 0, (SCREENWIDTH-30)/5, (SCREENWIDTH-30)/5) ImageName:@""];
    _iconImageView.layer.cornerRadius = (SCREENWIDTH-30)/5/2;
    _iconImageView.layer.masksToBounds = YES;
    [self.contentView addSubview:_iconImageView];
    
    _nameLabel = [ZCControl createLabelWithFrame:CGRectMake(0, (SCREENWIDTH-30)/5, (SCREENWIDTH-30)/5, SCREENHEIGHT*0.3*0.4*0.2) Font:14 Text:@""];
    //_nameLabel.backgroundColor = [UIColor orangeColor];
    _nameLabel.adjustsFontSizeToFitWidth = YES;
    _nameLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:_nameLabel];
}

@end
