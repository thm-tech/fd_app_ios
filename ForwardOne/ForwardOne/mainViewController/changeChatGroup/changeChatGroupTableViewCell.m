//
//  changeChatGroupTableViewCell.m
//  ForwardOne
//
//  Created by 杨波 on 15/5/26.
//  Copyright (c) 2015年 杨波. All rights reserved.
//

#import "changeChatGroupTableViewCell.h"

@implementation changeChatGroupTableViewCell

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
    _iconImageView = [ZCControl createImageViewWithFrame:CGRectMake(10, SCREENHEIGHT*0.15*0.1, SCREENHEIGHT*0.15*0.8, SCREENHEIGHT*0.15*0.8) ImageName:@""];
    _iconImageView.layer.cornerRadius = SCREENHEIGHT*0.15*0.8/2;
    _iconImageView.layer.masksToBounds = YES;
    [self.contentView addSubview:_iconImageView];
    
    _nameLabel = [ZCControl createLabelWithFrame:CGRectMake(SCREENWIDTH*0.3, SCREENHEIGHT*0.15*0.1, SCREENWIDTH*0.6, SCREENHEIGHT*0.15*0.3) Font:SCREENWIDTH*0.048 Text:nil];
    // _nameLabel.backgroundColor = [UIColor orangeColor];
    [self.contentView addSubview:_nameLabel];
    
    _messageLabel = [ZCControl createLabelWithFrame:CGRectMake(SCREENWIDTH*0.3, SCREENHEIGHT*0.15*0.4, SCREENWIDTH*0.65, SCREENHEIGHT*0.15*0.5) Font:SCREENWIDTH*0.0426 Text:nil];
    _messageLabel.textColor = [UIColor grayColor];
    //_messageLabel.backgroundColor = [UIColor orangeColor];
    [self.contentView addSubview:_messageLabel];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
