//
//  shopInfoSecondTableViewCell.m
//  ForwardOne
//
//  Created by 杨波 on 15/5/8.
//  Copyright (c) 2015年 杨波. All rights reserved.
//

#import "shopInfoSecondTableViewCell.h"

@implementation shopInfoSecondTableViewCell

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
//    _locateImageView = [ZCControl createImageViewWithFrame:CGRectMake(10, SCREENHEIGHT*0.08*0.3, SCREENWIDTH*0.04, SCREENHEIGHT*0.08*0.4) ImageName:@"店铺-店铺详情_07-06"];
//    //_locateImageView.backgroundColor = [UIColor orangeColor];
//    [self.contentView addSubview:_locateImageView];
    
    _locateImageViewButton = [ZCControl createButtonWithFrame:CGRectMake(0, 0, SCREENWIDTH*0.09, SCREENHEIGHT*0.08) ImageName:@"" Target:self Action:@selector(phoneButtonBtn:) Title:nil];
    //_locateImageViewButton.backgroundColor = [UIColor orangeColor];
    _locateImageViewButton.tag = 501;
    [_locateImageViewButton setImage:[UIImage imageNamed:@"店铺-店铺详情_07-06"] forState:UIControlStateNormal];
    [self.contentView addSubview:_locateImageViewButton];
    
    _locateLabel = [ZCControl createLabelWithFrame:CGRectMake(SCREENWIDTH*0.1,0, SCREENWIDTH*0.6, SCREENHEIGHT*0.08) Font:SCREENWIDTH*0.0426 Text:@""];
    _locateLabel.textColor = [UIColor colorWithHexStr:@"#666666"];
    _locateLabel.adjustsFontSizeToFitWidth = YES;
  // _locateLabel.backgroundColor = [UIColor orangeColor];
    [self.contentView addSubview:_locateLabel];
    
    _distanceLabel = [ZCControl createLabelWithFrame:CGRectMake(SCREENWIDTH*0.7, SCREENHEIGHT*0.08*0.3, SCREENWIDTH*0.2, SCREENHEIGHT*0.08*0.4) Font:SCREENWIDTH*0.0426 Text:@""];
    _distanceLabel.textColor = [UIColor colorWithHexStr:@"#666666"];
    //_distanceLabel.backgroundColor = [UIColor orangeColor];
    [self.contentView addSubview:_distanceLabel];
    
    _lineImageView = [ZCControl createImageViewWithFrame:CGRectMake(SCREENWIDTH*0.85, SCREENHEIGHT*0.08*0.2, 0.5, SCREENHEIGHT*0.08*0.6) ImageName:nil];
    _lineImageView.backgroundColor = [UIColor colorWithHexStr:@"666666"];
    [self.contentView addSubview:_lineImageView];
    
    _phoneButton = [ZCControl createButtonWithFrame:CGRectMake(SCREENWIDTH*0.85, 0, SCREENWIDTH*0.15, SCREENHEIGHT*0.08) ImageName:@"" Target:self Action:@selector(phoneButtonBtn:) Title:nil];
    _phoneButton.tag = 502;
    [_phoneButton setImage:[UIImage imageNamed:@"店铺-店铺详情_14"] forState:UIControlStateNormal];
    //[_phoneButton setBackgroundColor:[UIColor orangeColor]];
    [self.contentView addSubview:_phoneButton];
    
    
}
-(void)phoneButtonBtn:(UIButton *)button
{
    [self.YB_PhoneDelegate YBPhoneButtonDelegateDidClick:button];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
