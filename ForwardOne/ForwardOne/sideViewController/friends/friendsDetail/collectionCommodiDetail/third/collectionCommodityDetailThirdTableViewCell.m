//
//  collectionCommodityDetailThirdTableViewCell.m
//  ForwardOne
//
//  Created by 杨波 on 15/5/8.
//  Copyright (c) 2015年 杨波. All rights reserved.
//

#import "collectionCommodityDetailThirdTableViewCell.h"

@implementation collectionCommodityDetailThirdTableViewCell

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
    _iconImageView1 = [ZCControl createImageViewWithFrame:CGRectMake(10, SCREENHEIGHT*0.4*0.05, SCREENWIDTH-20, SCREENHEIGHT*0.4*0.9) ImageName:nil];
    [self.contentView addSubview:_iconImageView1];
}
    

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
