//
//  myFriendTableViewCell.m
//  ForwardOne
//
//  Created by 杨波 on 15/9/10.
//  Copyright (c) 2015年 杨波. All rights reserved.
//

#import "myFriendTableViewCell.h"

@implementation myFriendTableViewCell

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
    _iconImageView = [ZCControl createImageViewWithFrame:CGRectMake(10, 5, SCREENHEIGHT*0.1-10, SCREENHEIGHT*0.1-10) ImageName:nil];
    //_iconImageView.backgroundColor = [UIColor orangeColor];
    [self.contentView addSubview:_iconImageView];
    
    _nameLabel = [ZCControl createLabelWithFrame:CGRectMake(SCREENHEIGHT*0.15, 0, SCREENWIDTH*0.3, SCREENHEIGHT*0.1) Font:SCREENWIDTH*0.048 Text:nil];
    _nameLabel.backgroundColor = [UIColor orangeColor];
    [self.contentView addSubview:_nameLabel];
    
    _longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressDidPress:)];
    [self.contentView addGestureRecognizer:_longPress];
    
}

//长按的点击
-(void)longPressDidPress:(UILongPressGestureRecognizer *)longPress
{
    [self.YB_delegate YBFriendLongPressDidPressWithPress:longPress];
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
