//
//  firendDetailSecondTableViewCell.h
//  ForwardOne
//
//  Created by 杨波 on 15/5/7.
//  Copyright (c) 2015年 杨波. All rights reserved.
//

//收藏和分享的按钮的协议
@protocol YBMyCollectionGoodsButtonDelegate <NSObject>

-(void)YBMyCollectionGoodsButtonDidClick:(UIButton *)button;

@end

#import <UIKit/UIKit.h>

@interface firendDetailSecondTableViewCell : UITableViewCell

@property (nonatomic,strong) UIImageView *iconImageView;
@property (nonatomic,strong) UILabel *describtionLabel;
@property (nonatomic,strong) UILabel *originalPriceLabel;
@property (nonatomic,strong) UILabel *discounLabel;
@property (nonatomic,strong) UIImageView *lineImageView;
@property (nonatomic,strong) UIImageView *discountImageView;

//收藏的按钮
@property (nonatomic,strong) UIButton *collectionButton;

//分享的按钮
@property (nonatomic,strong) UIButton *sharedButton;

@property (nonatomic,weak) id<YBMyCollectionGoodsButtonDelegate>YB_buttonDelegate;

@end
