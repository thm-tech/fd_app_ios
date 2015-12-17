//
//  firendDetailSecondTableViewCell.m
//  ForwardOne
//
//  Created by 杨波 on 15/5/7.
//  Copyright (c) 2015年 杨波. All rights reserved.
//

#import "firendDetailSecondTableViewCell.h"

@implementation firendDetailSecondTableViewCell

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
    _iconImageView = [ZCControl createImageViewWithFrame:CGRectMake(10, SCREENHEIGHT*0.15*0.05, SCREENWIDTH*0.25, SCREENHEIGHT*0.15*0.9) ImageName:@""];
    [self.contentView addSubview:_iconImageView];
    
    _describtionLabel = [ZCControl createLabelWithFrame:CGRectMake(SCREENWIDTH*0.3, SCREENHEIGHT*0.15*0.02, SCREENWIDTH*0.65, SCREENHEIGHT*0.15*0.38) Font:SCREENWIDTH*0.0426 Text:@""];
    _describtionLabel.textColor = [UIColor colorWithHexStr:@"#333333"];
    //_describtionLabel.backgroundColor = [UIColor orangeColor];
    [self.contentView addSubview:_describtionLabel];
    
    _originalPriceLabel = [ZCControl createLabelWithFrame:CGRectMake(SCREENWIDTH*0.35, SCREENHEIGHT*0.15*0.4, SCREENWIDTH*0.4, SCREENHEIGHT*0.15*0.2) Font:SCREENWIDTH*0.0373 Text:@""];
    _originalPriceLabel.textColor = [UIColor colorWithHexStr:@"#999999"];
    //_originalPriceLabel.backgroundColor = [UIColor orangeColor];
    [self.contentView addSubview:_originalPriceLabel];
    
    _discounLabel = [ZCControl createLabelWithFrame:CGRectMake(SCREENWIDTH*0.35, SCREENHEIGHT*0.15*0.6, SCREENWIDTH*0.5, SCREENHEIGHT*0.15*0.4 ) Font:SCREENWIDTH*0.048 Text:@""];
    //_discounLabel.backgroundColor = [UIColor orangeColor];
    _discounLabel.textColor = [UIColor colorWithHexStr:@"#FF3030"];
    [self.contentView addSubview:_discounLabel];
    
    _lineImageView = [ZCControl createImageViewWithFrame:CGRectMake(SCREENWIDTH*0.34, SCREENHEIGHT*0.15*0.5, SCREENWIDTH*0.15, 1) ImageName:nil];
    _lineImageView.backgroundColor = [UIColor colorWithHexStr:@"#999999"];
    [self.contentView addSubview:_lineImageView];
    
    _discountImageView = [ZCControl createImageViewWithFrame:CGRectMake(SCREENWIDTH*0.6, SCREENHEIGHT*0.15*0.7, SCREENWIDTH*0.05, SCREENHEIGHT*0.15*0.2) ImageName:@""];
    //_discountImageView.backgroundColor = [UIColor orangeColor];
    [self.contentView addSubview:_discountImageView];
    
    _collectionButton = [ZCControl createButtonWithFrame:CGRectMake(SCREENWIDTH*0.75, SCREENHEIGHT*0.15*0.6, SCREENWIDTH*0.15, SCREENHEIGHT*0.15*0.4) ImageName:nil Target:self Action:@selector(buttonDidClick:) Title:nil];
    _collectionButton.tag = 201;
    [_collectionButton setImage:[UIImage imageNamed:@"收藏_03-02"] forState:UIControlStateNormal];
    //_collectionButton.backgroundColor = [UIColor orangeColor];
    [self.contentView addSubview:_collectionButton];
    
    _sharedButton = [ZCControl createButtonWithFrame:CGRectMake(SCREENWIDTH*0.85, SCREENHEIGHT*0.15*0.6, SCREENWIDTH*0.15, SCREENHEIGHT*0.15*0.4) ImageName:nil Target:self Action:@selector(buttonDidClick:) Title:nil];
    _sharedButton.tag = 202;
    [_sharedButton setImage:[UIImage imageNamed:@"收藏_03-03"] forState:UIControlStateNormal];
    //[self.contentView addSubview:_sharedButton];
}

-(void)buttonDidClick:(UIButton *)button
{
    [self.YB_buttonDelegate YBMyCollectionGoodsButtonDidClick:button];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
// Configure the view for the selected state
}

@end
