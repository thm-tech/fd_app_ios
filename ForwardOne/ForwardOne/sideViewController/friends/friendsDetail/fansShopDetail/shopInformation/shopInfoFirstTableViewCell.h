//
//  shopInfoFirstTableViewCell.h
//  ForwardOne
//
//  Created by 杨波 on 15/5/8.
//  Copyright (c) 2015年 杨波. All rights reserved.
//

//商店详情上面关注商店的点击按钮
@protocol YBShopAttentionButtonDelegate <NSObject>

-(void)YBShopAttentionButtonDidClick:(UIButton *)button;

@end



#import <UIKit/UIKit.h>

@interface shopInfoFirstTableViewCell : UITableViewCell


@property (nonatomic,strong) UILabel *workTimeLabel;
@property (nonatomic,strong) UIImageView *lineImagView;
@property (nonatomic,strong) UIButton *attentionButton;
@property (nonatomic,strong) UILabel *attentionLabel;
@property (nonatomic,strong) UILabel *onLinePeopleLabel;


@property (nonatomic,weak) id<YBShopAttentionButtonDelegate>YB_delegate;

@end
