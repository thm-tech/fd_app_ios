//
//  YBSearchTableViewCell.m
//  ForwardOne
//
//  Created by 杨波 on 15/11/17.
//  Copyright (c) 2015年 杨波. All rights reserved.
//

#import "YBSearchTableViewCell.h"

@implementation YBSearchTableViewCell

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
    _iconImageView = [ZCControl createImageViewWithFrame:CGRectMake(10, 0, SCREENWIDTH*0.2, SCREENHEIGHT*0.1) ImageName:nil];
    [self.contentView addSubview:_iconImageView];
    
    _shopNameLabel = [ZCControl createLabelWithFrame:CGRectMake(SCREENWIDTH*0.27, 0, SCREENWIDTH*0.6, SCREENHEIGHT*0.1) Font:SCREENWIDTH*0.048 Text:nil];
    [self.contentView addSubview:_shopNameLabel];
    
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
