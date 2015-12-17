//
//  collectionCommodityDetailSecondTableViewCell.m
//  ForwardOne
//
//  Created by 杨波 on 15/5/8.
//  Copyright (c) 2015年 杨波. All rights reserved.
//

#import "collectionCommodityDetailSecondTableViewCell.h"

@implementation collectionCommodityDetailSecondTableViewCell

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
    _colorLabel = [ZCControl createLabelWithFrame:CGRectMake(10, SCREENHEIGHT*0.2*0.1, SCREENWIDTH*0.15, SCREENHEIGHT*0.2*0.2) Font:SCREENWIDTH*0.048 Text:@"颜色："];
    //_colorLabel.backgroundColor = [UIColor orangeColor];
    [self.contentView addSubview:_colorLabel];
    
    _colorDetailLabel = [ZCControl createLabelWithFrame:CGRectMake(SCREENWIDTH*0.15+10, SCREENHEIGHT*0.2*0.1, SCREENWIDTH*0.5, SCREENHEIGHT*0.2*0.2) Font:SCREENWIDTH*0.0487 Text:@"白色"];
    [self.contentView addSubview:_colorDetailLabel];
    
    _sizeLabel = [ZCControl createLabelWithFrame:CGRectMake(10, SCREENHEIGHT*0.2*0.3, SCREENWIDTH*0.15, SCREENHEIGHT*0.2*0.2) Font:SCREENWIDTH*0.048 Text:@"尺码："];
    //_sizeLabel.backgroundColor = [UIColor orangeColor];
    [self.contentView addSubview:_sizeLabel];
    
    _sizeDetailLabel = [ZCControl createLabelWithFrame:CGRectMake(SCREENWIDTH*0.15+10, SCREENHEIGHT*0.2*0.3, SCREENWIDTH*0.5, SCREENHEIGHT*0.2*0.2) Font:SCREENWIDTH*0.048 Text:@"XXL"];
    [self.contentView addSubview:_sizeDetailLabel];
    
    _designLabel = [ZCControl createLabelWithFrame:CGRectMake(10, SCREENHEIGHT*0.2*0.5, SCREENWIDTH*0.15, SCREENHEIGHT*0.2*0.2) Font:SCREENWIDTH*0.048 Text:@"款式："];
    [self.contentView addSubview:_designLabel];
    
    _designDetailLabel = [ZCControl createLabelWithFrame:CGRectMake(SCREENWIDTH*0.15+10, SCREENHEIGHT*0.2*0.5, SCREENWIDTH*0.5, SCREENHEIGHT*0.2*0.2)  Font:SCREENWIDTH*0.048 Text:@"瘦身"];
    [self.contentView addSubview:_designDetailLabel];
    
    _styleLabel = [ZCControl createLabelWithFrame:CGRectMake(10, SCREENHEIGHT*0.2*0.7, SCREENWIDTH*0.15, SCREENHEIGHT*0.2*0.2) Font:SCREENWIDTH*0.048 Text:@"风格："];
    [self.contentView addSubview:_styleLabel];
    
    _styleDetailLabel = [ZCControl createLabelWithFrame:CGRectMake(SCREENWIDTH*0.15+10, SCREENHEIGHT*0.2*0.7, SCREENWIDTH*0.5, SCREENHEIGHT*0.2*0.2) Font:SCREENWIDTH*0.048 Text:@"商务"];
    [self.contentView addSubview:_styleDetailLabel];
    
}
    

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
