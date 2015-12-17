//
//  PopoverFirstTableViewCell.m
//  ForwardOne
//
//  Created by 杨波 on 15/5/5.
//  Copyright (c) 2015年 杨波. All rights reserved.
//

#import "PopoverFirstTableViewCell.h"

@implementation PopoverFirstTableViewCell

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
    _iconImageView = [ZCControl createImageViewWithFrame:CGRectMake(10, SCREENWIDTH*0.1375*0.2, SCREENWIDTH*0.1375*0.6, SCREENWIDTH*0.1375*0.6) ImageName:@"nil"];
    _iconImageView.backgroundColor = [UIColor orangeColor];
    [self.contentView addSubview:_iconImageView];
    
    _titleLabel = [ZCControl createLabelWithFrame:CGRectMake(SCREENWIDTH*0.15, SCREENWIDTH*0.1375*0.2, SCREENWIDTH*0.3, SCREENWIDTH*0.1375*0.6) Font:SCREENWIDTH*0.048 Text:@""];
    //_titleLabel.backgroundColor = [UIColor orangeColor];
    [self.contentView addSubview:_titleLabel];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
