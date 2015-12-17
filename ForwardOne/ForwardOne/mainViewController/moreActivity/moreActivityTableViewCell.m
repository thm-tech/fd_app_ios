//
//  moreActivityTableViewCell.m
//  ForwardOne
//
//  Created by 杨波 on 15/8/11.
//  Copyright (c) 2015年 杨波. All rights reserved.
//

#import "moreActivityTableViewCell.h"

@implementation moreActivityTableViewCell

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
    
    _iconImageView = [ZCControl createImageViewWithFrame:CGRectMake(10, SCREENHEIGHT*0.2*0.1, SCREENHEIGHT*0.2*0.8, SCREENHEIGHT*0.2*0.8) ImageName:nil];
    //_iconImageView.backgroundColor = [UIColor orangeColor];
    [self.contentView addSubview:_iconImageView];
    
    //创建活动名称
    _activityNameLabel = [ZCControl createLabelWithFrame:CGRectMake(SCREENWIDTH*0.35, SCREENHEIGHT*0.2*0.1, SCREENWIDTH*0.6, SCREENHEIGHT*0.05) Font:SCREENWIDTH*0.053 Text:nil];
    _activityNameLabel.textColor = [UIColor colorWithHexStr:@"#333333"];
    //_activityNameLabel.backgroundColor = [UIColor orangeColor];
    [self.contentView addSubview:_activityNameLabel];
    
    _shopNameLabel = [ZCControl createLabelWithFrame:CGRectMake(SCREENWIDTH*0.35, SCREENHEIGHT*0.07, SCREENWIDTH*0.6, SCREENHEIGHT*0.05) Font:SCREENWIDTH*0.048 Text:nil];
     _shopNameLabel.textColor = [UIColor colorWithHexStr:@"#666666"];
    //_shopNameLabel.backgroundColor = [UIColor orangeColor];
    [self.contentView addSubview:_shopNameLabel];
    
    _dateLabel = [ZCControl createLabelWithFrame:CGRectMake(SCREENWIDTH*0.35, SCREENHEIGHT*0.12, SCREENWIDTH*0.6, SCREENHEIGHT*0.05) Font:SCREENWIDTH*0.0426 Text:nil];
    _dateLabel.textColor = [UIColor colorWithHexStr:@"#666666"];
    [self.contentView addSubview:_dateLabel];
    
    
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
