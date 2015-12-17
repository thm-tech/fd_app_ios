//
//  mainShopTableViewCell.m
//  ForwardOne
//
//  Created by 杨波 on 15/9/28.
//  Copyright (c) 2015年 杨波. All rights reserved.
//

#import "mainShopTableViewCell.h"

@implementation mainShopTableViewCell

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
    _shopNameLabel = [ZCControl createLabelWithFrame:CGRectMake(10, 10, SCREENWIDTH*0.5, SCREENHEIGHT*0.4*0.1) Font:SCREENWIDTH*0.0426 Text:@""];
    _shopNameLabel.textColor = [UIColor colorWithHexStr:@"#333333"];
    _shopNameLabel.adjustsFontSizeToFitWidth = NO;
    [self.contentView addSubview:_shopNameLabel];
    
//    _attentionImageView = [ZCControl createImageViewWithFrame:CGRectMake(SCREENWIDTH*0.55, SCREENHEIGHT*0.4*0.06, SCREENWIDTH*0.04,SCREENWIDTH*0.04) ImageName:@"收藏"];
//   // _attentionImageView.backgroundColor = [UIColor orangeColor];
//    [self.contentView addSubview:_attentionImageView];
//
    _attentionCountLabel = [ZCControl createLabelWithFrame:CGRectMake(SCREENWIDTH*0.6, 10, SCREENWIDTH*0.1, SCREENHEIGHT*0.4*0.1) Font:SCREENWIDTH*0.0426 Text:@""];
    _attentionCountLabel.textColor = [UIColor colorWithHexStr:@"#999999"];
    //_attentionCountLabel.backgroundColor = [UIColor orangeColor];
    [self.contentView addSubview:_attentionCountLabel];
    
    _attentionButton = [ZCControl createButtonWithFrame:CGRectMake(SCREENWIDTH*0.5, 10, SCREENWIDTH*0.14, SCREENHEIGHT*0.4*0.15-10) ImageName:nil Target:self Action:@selector(sendShopButtonBtn:) Title:nil];
    _attentionButton.tag = 101;
    //_attentionButton.backgroundColor = [UIColor orangeColor];
    [_attentionButton setImage:[UIImage imageNamed:@"收藏"] forState:UIControlStateNormal];
    [self.contentView addSubview:_attentionButton];
    
    _onLineImageView = [ZCControl createImageViewWithFrame:CGRectMake(SCREENWIDTH*0.73, SCREENHEIGHT*0.4*0.06, SCREENWIDTH*0.04,SCREENWIDTH*0.04) ImageName:@"人数"];
    [self.contentView addSubview:_onLineImageView];
    
    _onLineCountLabel = [ZCControl createLabelWithFrame:CGRectMake(SCREENWIDTH*0.78, 10, SCREENWIDTH*0.1, SCREENHEIGHT*0.4*0.1) Font:SCREENWIDTH*0.0426 Text:@""];
    //_onLineCountLabel.backgroundColor = [UIColor orangeColor];
    _onLineCountLabel.textColor = [UIColor colorWithHexStr:@"#999999"];
    [self.contentView addSubview:_onLineCountLabel];
    
    _sendShopButton = [ZCControl createButtonWithFrame:CGRectMake(SCREENWIDTH*0.85, 10, SCREENWIDTH*0.15, SCREENHEIGHT*0.4*0.1) ImageName:@"" Target:self Action:@selector(sendShopButtonBtn:) Title:nil];
    _sendShopButton.tag = 102;
    [_sendShopButton setImage:[UIImage imageNamed:@"发送"] forState:UIControlStateNormal];
    //_sendShopButton.backgroundColor = [UIColor orangeColor];
    [self.contentView addSubview:_sendShopButton];

    _goodsImageView1 = [ZCControl createImageViewWithFrame:CGRectMake(10, SCREENHEIGHT*0.45*0.15, (SCREENWIDTH-30)/2, SCREENHEIGHT*0.45*0.75) ImageName:@""];
   
    [self.contentView addSubview:_goodsImageView1];

    _goodsImageView2 = [ZCControl createImageViewWithFrame:CGRectMake((SCREENWIDTH-30)/2+20, SCREENHEIGHT*0.45*0.15, (SCREENWIDTH-30)/2, SCREENHEIGHT*0.45*0.75) ImageName:@""];
    [self.contentView addSubview:_goodsImageView2];
    
    
    _goodsNameLabel1 = [ZCControl createLabelWithFrame:CGRectMake(10, SCREENHEIGHT*0.45*0.9, (SCREENWIDTH-30)/2, SCREENHEIGHT*0.45*0.1) Font:SCREENWIDTH*0.0426 Text:@""];
    _goodsNameLabel1.textColor = [UIColor colorWithHexStr:@"#999999"];
    //_goodsNameLabel1.backgroundColor = [UIColor orangeColor];
    [self.contentView addSubview:_goodsNameLabel1];
    
    _goodsNamelable2 = [ZCControl createLabelWithFrame:CGRectMake((SCREENWIDTH-30)/2+20, SCREENHEIGHT*0.45*0.9, (SCREENWIDTH-30)/2, SCREENHEIGHT*0.45*0.1) Font:SCREENWIDTH*0.0426 Text:@""];
    _goodsNamelable2.textColor = [UIColor colorWithHexStr:@"#999999"];
    //_goodsNamelable2.backgroundColor = [UIColor orangeColor];
    [self.contentView addSubview:_goodsNamelable2];
    
    
    
    
    
    
    _bttomImageView1 = [ZCControl createImageViewWithFrame:CGRectMake(10, SCREENHEIGHT*0.4*0.9-10, (SCREENWIDTH-30)/2, SCREENHEIGHT*0.4*0.1) ImageName:nil];
    _bttomImageView1.backgroundColor = [[UIColor whiteColor]colorWithAlphaComponent:0.4];
    [self.contentView addSubview:_bttomImageView1];
    
    _bttomImageView2 = [ZCControl createImageViewWithFrame:CGRectMake((SCREENWIDTH-30)/2+20, SCREENHEIGHT*0.4*0.9-10, (SCREENWIDTH-30)/2, SCREENHEIGHT*0.4*0.1) ImageName:nil];
    _bttomImageView2.backgroundColor = [[UIColor whiteColor]colorWithAlphaComponent:0.4];
    [self.contentView addSubview:_bttomImageView2];
    
    _orignalPriceLabel1 = [ZCControl createLabelWithFrame:CGRectMake(20, SCREENHEIGHT*0.4*0.9-10, SCREENWIDTH*0.2, SCREENHEIGHT*0.4*0.1) Font:SCREENWIDTH*0.0426 Text:@""];
    //_orignalPriceLabel1.backgroundColor = [UIColor orangeColor];
    //_orignalPriceLabel1.adjustsFontSizeToFitWidth = NO;
    _orignalPriceLabel1.textColor = [UIColor colorWithHexStr:@"#999999"];
    [self.contentView addSubview:_orignalPriceLabel1];
    
    _discountImageView1 = [ZCControl createImageViewWithFrame:CGRectMake(10, SCREENHEIGHT*0.4*0.9-10+SCREENHEIGHT*0.4*0.1*0.5, SCREENWIDTH*0.15, 0.5) ImageName:nil];
    _discountImageView1.backgroundColor = [UIColor colorWithHexStr:@"#999999"];
    [self.contentView addSubview:_discountImageView1];
    
    _discountPriceLabel1 = [ZCControl createLabelWithFrame:CGRectMake(SCREENWIDTH*0.25, SCREENHEIGHT*0.4*0.9-10, SCREENWIDTH*0.2, SCREENHEIGHT*0.4*0.1) Font:SCREENWIDTH*0.053 Text:@""];
    //_discountPriceLabel1.backgroundColor = [UIColor orangeColor];
    _discountPriceLabel1.textColor = [UIColor colorWithHexStr:@"#ff0000"];
    [self.contentView addSubview:_discountPriceLabel1];
    
    _orignalPriceLabel2 = [ZCControl createLabelWithFrame:CGRectMake((SCREENWIDTH-30)/2+20+10, SCREENHEIGHT*0.4*0.9-10, SCREENWIDTH*0.2, SCREENHEIGHT*0.4*0.1) Font:SCREENWIDTH*0.0426 Text:@""];
    //_orignalPriceLabel2.backgroundColor = [UIColor orangeColor];
    _orignalPriceLabel2.textColor = [UIColor colorWithHexStr:@"#999999"];
    [self.contentView addSubview:_orignalPriceLabel2];
    
    _discountImageView2 = [ZCControl createImageViewWithFrame:CGRectMake((SCREENWIDTH-30)/2+20, SCREENHEIGHT*0.4*0.9-10+SCREENHEIGHT*0.4*0.1*0.5, SCREENWIDTH*0.15, 0.5) ImageName:nil];
    _discountImageView2.backgroundColor = [UIColor colorWithHexStr:@"#999999"];
    [self.contentView addSubview:_discountImageView2];
    
    _discountPriceLabel2 = [ZCControl createLabelWithFrame:CGRectMake(SCREENWIDTH*0.75, SCREENHEIGHT*0.4*0.9-10, SCREENWIDTH*0.2, SCREENHEIGHT*0.4*0.1) Font:SCREENWIDTH*0.053 Text:@""];
    //_discountPriceLabel2.backgroundColor = [UIColor orangeColor];
    _discountPriceLabel2.textColor = [UIColor colorWithHexStr:@"#ff0000"];
    [self.contentView addSubview:_discountPriceLabel2];

    
}
-(void)sendShopButtonBtn:(UIButton *)button
{
    
    [self.YB_delagete YBMainShopSendShopButtonDidClick:button];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
