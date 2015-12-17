//
//  mainShopIntroduceTableViewCell.m
//  ForwardOne
//
//  Created by 杨波 on 15/9/29.
//  Copyright (c) 2015年 杨波. All rights reserved.
//

#import "mainShopIntroduceTableViewCell.h"

@implementation mainShopIntroduceTableViewCell

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
    _activityButton1 = [ZCControl createButtonWithFrame:CGRectMake(10, 10, (SCREENWIDTH-40)/3, SCREENHEIGHT*0.2-20) ImageName:@"s" Target:self Action:@selector(activityButtonBtn:) Title:nil];
    _activityButton1.tag = 101;
    [self.contentView addSubview:_activityButton1];
    
    _activityButton2 = [ZCControl createButtonWithFrame:CGRectMake((SCREENWIDTH-40)/3+20, 10, (SCREENWIDTH-40)/3, SCREENHEIGHT*0.2-20) ImageName:@"s" Target:self Action:@selector(activityButtonBtn:) Title:nil];
    _activityButton2.tag = 102;
    [self.contentView addSubview:_activityButton2];
    
    _activityButton3 = [ZCControl createButtonWithFrame:CGRectMake(SCREENWIDTH-10-(SCREENWIDTH-40)/3, 10,(SCREENWIDTH-40)/3 , SCREENHEIGHT*0.2-20) ImageName:@"s" Target:self Action:@selector(activityButtonBtn:) Title:nil];
    _activityButton3.tag = 103;
    [self.contentView addSubview:_activityButton3];
}
-(void)activityButtonBtn:(UIButton *)button
{
    [self.YB_delegate YBMainShopIntroduceButtonDidClick:button];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
