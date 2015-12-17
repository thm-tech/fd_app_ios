//
//  PopoverTableViewCell.m
//  ForwardOne
//
//  Created by 杨波 on 15/5/5.
//  Copyright (c) 2015年 杨波. All rights reserved.
//

#import "PopoverTableViewCell.h"

@implementation PopoverTableViewCell

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
    _iconImageView = [ZCControl createImageViewWithFrame:CGRectMake(10, SCREENWIDTH*0.23*0.1, SCREENWIDTH*0.1375*0.6,SCREENWIDTH*0.1375*0.6 ) ImageName:@""];
    _iconImageView.backgroundColor = [UIColor orangeColor];
    [self.contentView addSubview:_iconImageView];
    
    _titleLabel = [ZCControl createLabelWithFrame:CGRectMake(SCREENWIDTH*0.15, SCREENWIDTH*0.23*0.1, SCREENWIDTH*0.3, SCREENWIDTH*0.23*0.3) Font:SCREENWIDTH*0.048 Text:@""];
    //_titleLabel.backgroundColor = [UIColor orangeColor];
    [self.contentView addSubview:_titleLabel];

    _firstButton = [ZCControl createButtonWithFrame:CGRectMake(10, SCREENWIDTH*0.23*0.6, SCREENWIDTH*0.1, SCREENWIDTH*0.23*0.3) ImageName:@"btn_login_bg_2@2x" Target:self Action:@selector(buttonBtn:) Title:@""];
    _firstButton.tag = 100;
   //[_firstButton setBackgroundColor:[UIColor orangeColor]];
    //[_firstButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    [self.contentView addSubview:_firstButton];
    
    _secondButton = [ZCControl createButtonWithFrame:CGRectMake(SCREENWIDTH*0.1+15, SCREENWIDTH*0.23*0.6, SCREENWIDTH*0.1, SCREENWIDTH*0.23*0.3) ImageName:@"btn_login_bg_2@2x" Target:self Action:@selector(buttonBtn:) Title:@""];
    _secondButton.tag = 200;
    [self.contentView addSubview:_secondButton];
    
    _thirdButton = [ZCControl createButtonWithFrame:CGRectMake(SCREENWIDTH*0.2+20, SCREENWIDTH*0.23*0.6, SCREENWIDTH*0.2, SCREENWIDTH*0.23*0.3) ImageName:@"btn_login_bg_2@2x" Target:self Action:@selector(buttonBtn:) Title:@""];
    _thirdButton.tag = 300;
    [self.contentView addSubview:_thirdButton];
    
}
-(void)buttonBtn:(UIButton *)button
{
    [self.YBCell_delegate YBCellButtonDidClicked:button andTitle:button.titleLabel.text];
}

-(void)firstButtonBtn:(UIButton *)button
{
    
}
-(void)secondButtonBtn:(UIButton *)button
{
    
}
-(void)thirdButtonBtn:(UIButton *)button
{
    
    
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
