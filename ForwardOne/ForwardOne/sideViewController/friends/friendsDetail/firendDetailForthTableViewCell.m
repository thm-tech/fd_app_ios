//
//  firendDetailForthTableViewCell.m
//  ForwardOne
//
//  Created by 杨波 on 15/5/7.
//  Copyright (c) 2015年 杨波. All rights reserved.
//

#import "firendDetailForthTableViewCell.h"

@implementation firendDetailForthTableViewCell

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
    _iconImageView = [ZCControl createImageViewWithFrame:CGRectMake(10, SCREENHEIGHT*0.15*0.05, SCREENWIDTH*0.3, SCREENHEIGHT*0.15*0.9) ImageName:@""];
    [self.contentView addSubview:_iconImageView];
    
    _shopNameLabel = [ZCControl createLabelWithFrame:CGRectMake(SCREENWIDTH*0.35, SCREENHEIGHT*0.15*0.1, SCREENWIDTH*0.6, SCREENHEIGHT*0.15*0.3) Font:SCREENWIDTH*0.0426 Text:@""];
    //_shopNameLabel.backgroundColor  =[UIColor orangeColor];
    [self.contentView addSubview:_shopNameLabel];
    
    _dateLabel = [ZCControl createLabelWithFrame:CGRectMake(SCREENWIDTH*0.35, SCREENHEIGHT*0.15*0.5, SCREENWIDTH*0.6, SCREENHEIGHT*0.15*0.3) Font:SCREENWIDTH*0.0373 Text:@""];
    // _activityNewLabel.backgroundColor = [UIColor orangeColor];
    [self.contentView addSubview:_dateLabel];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
