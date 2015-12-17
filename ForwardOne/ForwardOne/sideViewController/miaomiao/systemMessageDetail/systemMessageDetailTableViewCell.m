//
//  systemMessageDetailTableViewCell.m
//  ForwardOne
//
//  Created by 杨波 on 15/8/28.
//  Copyright (c) 2015年 杨波. All rights reserved.
//

#import "systemMessageDetailTableViewCell.h"

@implementation systemMessageDetailTableViewCell

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
    _webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT*0.7)];
    [self.contentView addSubview:_webView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
