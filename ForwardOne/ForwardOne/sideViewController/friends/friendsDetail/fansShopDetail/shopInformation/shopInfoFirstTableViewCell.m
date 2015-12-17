//
//  shopInfoFirstTableViewCell.m
//  ForwardOne
//
//  Created by 杨波 on 15/5/8.
//  Copyright (c) 2015年 杨波. All rights reserved.
//

#import "shopInfoFirstTableViewCell.h"

@implementation shopInfoFirstTableViewCell

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
    _workTimeLabel = [ZCControl createLabelWithFrame:CGRectMake(10, 0, SCREENWIDTH*0.5, SCREENHEIGHT*0.08) Font:SCREENWIDTH*0.0426 Text:@""];
    //_workTimeLabel.backgroundColor = [UIColor orangeColor];
    _workTimeLabel.textColor = [UIColor colorWithHexStr:@"#666666"];
    [self.contentView addSubview:_workTimeLabel];
    
    _lineImagView = [ZCControl createImageViewWithFrame:CGRectMake(SCREENWIDTH*0.5, 0, 0.5, SCREENHEIGHT*0.08) ImageName:nil];
    _lineImagView.backgroundColor = [UIColor colorWithHexStr:@"#666666"];
    [self.contentView addSubview:_lineImagView];
    
    _onLinePeopleLabel = [ZCControl createLabelWithFrame:CGRectMake(SCREENWIDTH*0.52, 0, SCREENWIDTH*0.3, SCREENHEIGHT*0.08) Font:SCREENWIDTH*0.0426 Text:@""];
    _onLinePeopleLabel.textColor = [UIColor colorWithHexStr:@"#666666"];
   // _onLinePeopleLabel.backgroundColor = [UIColor orangeColor];
    [self.contentView addSubview:_onLinePeopleLabel];
    
    _attentionButton = [ZCControl createButtonWithFrame:CGRectMake(SCREENWIDTH*0.8, 0, SCREENWIDTH*0.2, SCREENHEIGHT*0.08) ImageName:@"" Target:self Action:@selector(shopAttentionButtonBtn:) Title:@""];
    [_attentionButton setImage:[UIImage imageNamed:@"店铺-店铺详情_07-04"] forState:UIControlStateNormal];
    [_attentionButton setTitleColor:[UIColor colorWithHexStr:@"#ff7e7e"] forState:UIControlStateNormal];
    [self.contentView addSubview:_attentionButton];
    
    _attentionLabel = [ZCControl createLabelWithFrame:CGRectMake(SCREENWIDTH*0.94, 0, SCREENWIDTH*0.06, SCREENHEIGHT*0.08) Font:SCREENWIDTH*0.0426 Text:nil];
    _attentionLabel.textColor = [UIColor colorWithHexStr:@"#ff7e7e"];
    [self.contentView addSubview:_attentionLabel];
}
-(void)shopAttentionButtonBtn:(UIButton *)button
{
    
    [self.YB_delegate YBShopAttentionButtonDidClick:button];
    
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
