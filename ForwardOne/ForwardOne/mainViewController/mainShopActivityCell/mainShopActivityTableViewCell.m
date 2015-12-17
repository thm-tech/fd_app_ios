//
//  mainShopActivityTableViewCell.m
//  ForwardOne
//
//  Created by 杨波 on 15/9/29.
//  Copyright (c) 2015年 杨波. All rights reserved.
//

#import "mainShopActivityTableViewCell.h"
#import "DIImageView.h"

@implementation mainShopActivityTableViewCell

- (void)awakeFromNib {
    // Initialization code
}
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self)
    {
        [self createUI];
    }
    return self;
}

-(void)createUI
{
    _iconImageView = [[DIImageView alloc]initWithFrame:CGRectMake(10, 0, SCREENWIDTH-20, SCREENHEIGHT*0.3-10)];
    _iconImageView.image = [UIImage imageNamed:@""];
    [self.contentView addSubview:_iconImageView];

    _activityNameLabel = [ZCControl createLabelWithFrame:CGRectMake(20, SCREENHEIGHT*0.3*0.68, SCREENWIDTH*0.8, SCREENHEIGHT*0.05) Font:SCREENWIDTH*0.048 Text:@""];
    _activityNameLabel.textColor = [UIColor whiteColor];
    [self.contentView addSubview:_activityNameLabel];
    
    _shopImageView = [ZCControl createImageViewWithFrame:CGRectMake(20, SCREENHEIGHT*0.3*0.83, 20, 20) ImageName:@"店铺"];
    [self.contentView addSubview:_shopImageView];
    
    _shopNameLabel = [ZCControl createLabelWithFrame:CGRectMake(45, SCREENHEIGHT*0.3*0.8, SCREENWIDTH*0.8, SCREENHEIGHT*0.05) Font:SCREENWIDTH*0.0426 Text:@""];
    _shopNameLabel.textColor = [[UIColor whiteColor]colorWithAlphaComponent:0.5];
    [self.contentView addSubview:_shopNameLabel];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
