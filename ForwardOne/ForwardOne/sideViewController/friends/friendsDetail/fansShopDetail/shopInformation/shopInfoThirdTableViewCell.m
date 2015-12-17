//
//  shopInfoThirdTableViewCell.m
//  ForwardOne
//
//  Created by 杨波 on 15/5/8.
//  Copyright (c) 2015年 杨波. All rights reserved.
//

#import "shopInfoThirdTableViewCell.h"

@implementation shopInfoThirdTableViewCell

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
    _titleLabel = [ZCControl createLabelWithFrame:CGRectMake(0,0, SCREENWIDTH, SCREENHEIGHT*0.7*0.1) Font:SCREENWIDTH*0.053 Text:@"一周年纪念活动"];
   // _titleLabel.backgroundColor = [UIColor orangeColor];
    _titleLabel.textColor = [UIColor colorWithHexStr:@"#333333"];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:_titleLabel];
    
//    _iconImageView = [ZCControl createImageViewWithFrame:CGRectMake(10, SCREENHEIGHT*0.7*0.1, SCREENWIDTH-20, SCREENHEIGHT*0.7*0.55) ImageName:nil];
//    _iconImageView.backgroundColor = [UIColor orangeColor];
//    [self.contentView addSubview:_iconImageView];
//    
//    _activityLabel = [ZCControl createLabelWithFrame:CGRectMake(10, SCREENHEIGHT*0.7*0.65, SCREENWIDTH-20, SCREENHEIGHT*0.7*0.3) Font:SCREENWIDTH*0.048 Text:@"活动活动活动活动活动活动活动活动活动活动活动活动活动活动活动活动活动活动活动活动活动活动活动活动活动活动活动活动活动活动活动活动活动活动活动活动活动活动活动活动活动活动活动活动活动活动活动活动活动活动活动活动活动活动"];
//    _activityLabel.textColor = [UIColor colorWithHexStr:@"#66666666666666666666666666666"];
//    //_activityLabel.backgroundColor = [UIColor orangeColor];
//    [self.contentView addSubview:_activityLabel];
    
    _webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, SCREENHEIGHT*0.7*0.1, SCREENWIDTH, SCREENHEIGHT*0.7*0.85)];
    //_webView.backgroundColor = [UIColor whiteColor];
    _webView.userInteractionEnabled = YES;
    [self.contentView addSubview:_webView];
    
    _dateLabel = [ZCControl createLabelWithFrame:CGRectMake(SCREENWIDTH*0.2, SCREENHEIGHT*0.7*0.95, SCREENWIDTH*0.8, SCREENHEIGHT*0.7*0.05) Font:SCREENWIDTH*0.0426 Text:@"活动时间：2015/03/01-2015/03/03"];
    _dateLabel.textAlignment = NSTextAlignmentCenter;
    _dateLabel.textColor = [UIColor colorWithHexStr:@"#666666"];
    //_dateLabel.backgroundColor = [UIColor orangeColor];
    [self.contentView addSubview:_dateLabel];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
