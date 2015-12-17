//
//  mainShopTableViewCell.h
//  ForwardOne
//
//  Created by 杨波 on 15/9/28.
//  Copyright (c) 2015年 杨波. All rights reserved.
//
//发送商店的按钮的点击的协议
@protocol mainShopSendShopDelegate <NSObject>

-(void)YBMainShopSendShopButtonDidClick:(UIButton *)button;

@end


#import <UIKit/UIKit.h>

@interface mainShopTableViewCell : UITableViewCell

@property (nonatomic,strong) UILabel *shopNameLabel;
@property (nonatomic,strong) UIImageView *attentionImageView;
@property (nonatomic,strong) UILabel *attentionCountLabel;
@property (nonatomic,strong) UIImageView *onLineImageView;
@property (nonatomic,strong) UILabel *onLineCountLabel;
@property (nonatomic,strong) UIButton *sendShopButton;
@property (nonatomic,strong) UIImageView *goodsImageView1;
@property (nonatomic,strong) UIImageView *goodsImageView2;
@property (nonatomic,strong) UIImageView *discountImageView1;
@property (nonatomic,strong) UILabel *orignalPriceLabel1;
@property (nonatomic,strong) UILabel *discountPriceLabel1;
@property (nonatomic,strong) UIImageView *discountImageView2;
@property (nonatomic,strong) UILabel *orignalPriceLabel2;
@property (nonatomic,strong) UILabel *discountPriceLabel2;
@property (nonatomic,strong) UIImageView *bttomImageView1;
@property (nonatomic,strong) UIImageView *bttomImageView2;
@property (nonatomic,strong) UIButton *attentionButton;


@property (nonatomic,strong) UILabel *goodsNameLabel1;
@property (nonatomic,strong) UILabel *goodsNamelable2;


@property (nonatomic,weak) id<mainShopSendShopDelegate>YB_delagete;

@end
