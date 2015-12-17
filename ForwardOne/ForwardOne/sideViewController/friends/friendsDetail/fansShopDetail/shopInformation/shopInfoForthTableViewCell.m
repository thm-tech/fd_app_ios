//
//  shopInfoForthTableViewCell.m
//  ForwardOne
//
//  Created by 杨波 on 15/5/8.
//  Copyright (c) 2015年 杨波. All rights reserved.
//

#import "shopInfoForthTableViewCell.h"

@implementation shopInfoForthTableViewCell

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
    _myWebView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 10, SCREENWIDTH, SCREENHEIGHT*0.7-10)];
    //_myWebView.backgroundColor = [UIColor whiteColor];
    _myWebView.userInteractionEnabled = YES;
    [self.contentView addSubview:_myWebView];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
