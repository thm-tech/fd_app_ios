//
//  firendDetailThirdTableViewCell.m
//  ForwardOne
//
//  Created by 杨波 on 15/5/7.
//  Copyright (c) 2015年 杨波. All rights reserved.
//

#import "firendDetailThirdTableViewCell.h"

@implementation firendDetailThirdTableViewCell

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
    _iconImageView = [ZCControl createImageViewWithFrame:CGRectMake(10, SCREENHEIGHT*0.15*0.05, SCREENWIDTH*0.3, SCREENHEIGHT*0.15*0.9) ImageName:@"s"];
    [self.contentView addSubview:_iconImageView];
    
    _shopNameLabel = [ZCControl createLabelWithFrame:CGRectMake(SCREENWIDTH*0.35, SCREENHEIGHT*0.15*0.1, SCREENWIDTH*0.6, SCREENHEIGHT*0.15*0.3) Font:SCREENWIDTH*0.0426 Text:@"Only天鹅湖万达店"];
    _shopNameLabel.textColor = [UIColor colorWithHexStr:@"#333333"];
    //_shopNameLabel.backgroundColor  =[UIColor orangeColor];
    [self.contentView addSubview:_shopNameLabel];
    
    _activityNewLabel = [ZCControl createLabelWithFrame:CGRectMake(SCREENWIDTH*0.43, SCREENHEIGHT*0.15*0.5, SCREENWIDTH*0.25, SCREENHEIGHT*0.15*0.3) Font:SCREENWIDTH*0.0373 Text:@""];
    _activityNewLabel.textColor = [UIColor colorWithHexStr:@"#666666"];
   // _activityNewLabel.backgroundColor = [UIColor orangeColor];
    [self.contentView addSubview:_activityNewLabel];
    
    _shopNewLabel = [ZCControl createLabelWithFrame:CGRectMake(SCREENWIDTH*0.73, SCREENHEIGHT*0.15*0.5, SCREENWIDTH*0.25, SCREENHEIGHT*0.15*0.3) Font:SCREENWIDTH*0.0373 Text:@""];
    //_shopNewLabel.backgroundColor = [UIColor orangeColor];
    _shopNewLabel.textColor = [UIColor colorWithHexStr:@"#666666"];
    [self.contentView addSubview:_shopNewLabel];
    
    _activityImageView = [ZCControl createImageViewWithFrame:CGRectMake(SCREENWIDTH*0.35, SCREENHEIGHT*0.15*0.5, SCREENHEIGHT*0.15*0.3, SCREENHEIGHT*0.15*0.3) ImageName:@""];
    //_activityImageView.backgroundColor = [UIColor redColor];
    [self.contentView addSubview:_activityImageView];
    
    _shopNewImageView = [ZCControl createImageViewWithFrame:CGRectMake(SCREENWIDTH*0.63, SCREENHEIGHT*0.15*0.5, SCREENHEIGHT*0.15*0.3, SCREENHEIGHT*0.15*0.3) ImageName:@""];
    [self.contentView addSubview:_shopNewImageView];
    
    _attenButton = [ZCControl createButtonWithFrame:CGRectMake(SCREENWIDTH*0.8, 0, SCREENWIDTH*0.2, SCREENHEIGHT*0.15*0.4) ImageName:nil Target:self Action:@selector(attenButtonBtn:) Title:nil];
    [_attenButton setImage:[UIImage imageNamed:@"逛过_07"] forState:UIControlStateNormal];
    //_attenButton.backgroundColor = [UIColor orangeColor];
    [self.contentView addSubview:_attenButton];
}
-(void)attenButtonBtn:(UIButton *)button
{
    [self.YBCell_delegate YBMyFanShopFansButtonDidClick:button];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
