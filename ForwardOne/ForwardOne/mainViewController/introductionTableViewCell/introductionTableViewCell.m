//
//  introductionTableViewCell.m
//  ForwardOne
//
//  Created by 杨波 on 15/5/27.
//  Copyright (c) 2015年 杨波. All rights reserved.
//

#import "introductionTableViewCell.h"

@implementation introductionTableViewCell

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
//    _iconImageView = [ZCControl createImageViewWithFrame:CGRectMake(5, 5, SCREENHEIGHT*0.22-10, SCREENWIDTH*0.8-10) ImageName:@""];
//    //_iconImageView = [ZCControl createImageViewWithFrame:CGRectMake(5, 5, SCREENWIDTH*0.8-10, SCREENHEIGHT*0.22-10) ImageName:@""];
//    _iconImageView.backgroundColor = [UIColor orangeColor];
//    //_iconImageView.transform = CGAffineTransformMakeRotation(M_PI/-2);
//    [self.contentView addSubview:_iconImageView];
    
    
   
    
    //_shopNameLabel = [ZCControl createLabelWithFrame:CGRectMake(70, 50, 110, 30) Font:18 Text:@"NI万达店"];
    _shopNameLabel = [ZCControl createLabelWithFrame:CGRectMake(SCREENHEIGHT*0.10494753,SCREENWIDTH*0.133333 , SCREENHEIGHT*0.1649, SCREENWIDTH*0.08) Font:SCREENWIDTH*0.048 Text:@"NI万达店哈哈哈哈"];
    //_shopNameLabel.backgroundColor = [UIColor orangeColor];
     _shopNameLabel.transform = CGAffineTransformMakeRotation(90 * M_PI/180.0);
    [self.contentView addSubview:_shopNameLabel];
    
    //_activityNameLabel = [ZCControl createLabelWithFrame:CGRectMake(10,70, 150, 30) Font:18 Text:@"一周年庆典活动"];
    _activityNameLabel = [ZCControl createLabelWithFrame:CGRectMake(SCREENHEIGHT*0.0149925,SCREENWIDTH*0.1866667, SCREENHEIGHT*0.22488756,SCREENWIDTH*0.08 ) Font:SCREENWIDTH*0.048 Text:@"一周年庆典活动"];
    //_activityNameLabel.backgroundColor = [UIColor orangeColor];
    _activityNameLabel.transform = CGAffineTransformMakeRotation(90 * M_PI/180.0);
    _activityNameLabel.textColor = [UIColor orangeColor];
    [self.contentView addSubview:_activityNameLabel];
    
    //_datelLabel = [ZCControl createLabelWithFrame:CGRectMake(-30, 70, 160, 30) Font:14 Text:@"2015/03/01-2015/08/01"];
    _datelLabel = [ZCControl createLabelWithFrame:CGRectMake(-SCREENHEIGHT*0.044977, SCREENWIDTH*0.1866667, SCREENHEIGHT*0.23988, SCREENWIDTH*0.08) Font:SCREENWIDTH*0.0373333 Text:@"2015/03/01-2015/08/01"];
    _datelLabel.textColor = [UIColor grayColor];
    //_datelLabel.backgroundColor = [UIColor orangeColor];
    _datelLabel.transform = CGAffineTransformMakeRotation(90 * M_PI/180.0);
    [self.contentView addSubview:_datelLabel];
    
    _iconImageView = [ZCControl createImageViewWithFrame:CGRectMake(SCREENHEIGHT*0.0149925, SCREENWIDTH*0.4266667, SCREENWIDTH*0.34666667, SCREENWIDTH*0.34666667) ImageName:@"s"];
    _iconImageView.transform = CGAffineTransformMakeRotation(90 * M_PI/180.0);
    [self.contentView addSubview:_iconImageView];
    
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
