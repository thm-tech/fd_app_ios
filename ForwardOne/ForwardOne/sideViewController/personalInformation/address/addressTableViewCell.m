//
//  addressTableViewCell.m
//  ForwardOne
//
//  Created by 杨波 on 15/7/6.
//  Copyright (c) 2015年 杨波. All rights reserved.
//

#import "addressTableViewCell.h"

@implementation addressTableViewCell

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
    _nameLabel = [ZCControl createLabelWithFrame:CGRectMake(10, SCREENHEIGHT*0.15*0.05, SCREENWIDTH*0.3, SCREENHEIGHT*0.15*0.3) Font:SCREENWIDTH*0.048 Text:@"小小小小小鸟"];
    _nameLabel.textColor = [UIColor colorWithHexStr:@"#333333"];
    //_nameLabel.backgroundColor = [UIColor orangeColor];
    [self.contentView addSubview:_nameLabel];
    
    _phoneLabel = [ZCControl createLabelWithFrame:CGRectMake(SCREENWIDTH*0.4, SCREENHEIGHT*0.15*0.05, SCREENWIDTH*0.35, SCREENHEIGHT*0.15*0.3) Font:SCREENWIDTH*0.048 Text:@"18156832958"];
    _phoneLabel.textColor = [UIColor colorWithHexStr:@"#333333"];
   // _phoneLabel.backgroundColor = [UIColor orangeColor];
    [self.contentView addSubview:_phoneLabel];
    
    _settingButton = [ZCControl createButtonWithFrame:CGRectMake(SCREENWIDTH*0.75, SCREENHEIGHT*0.15*0.05, SCREENWIDTH*0.2, SCREENHEIGHT*0.15*0.3) ImageName:nil Target:self Action:@selector(setttingButtonBtn:) Title:@"设为默认"];
    //_settingButton.backgroundColor = [UIColor orangeColor];
    [_settingButton setTitleColor:[UIColor colorWithHexStr:@"#48d58b"] forState:UIControlStateNormal];
    [self.contentView addSubview:_settingButton];
    
    _addressLabel = [ZCControl createLabelWithFrame:CGRectMake(10, SCREENHEIGHT*0.15*0.35, SCREENWIDTH-20, SCREENHEIGHT*0.15*0.6) Font:16 Text:@"安徽省合肥市蜀山区黄山路与肥西路交口兴科大厦1601"];
    _addressLabel.textColor = [UIColor colorWithHexStr:@"#666666"];
    [self.contentView addSubview:_addressLabel];
    
}
-(void)setttingButtonBtn:(UIButton *)button
{
    [self.YB_SettingButtonDelegate YBSettingButtonDidClick:button];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
