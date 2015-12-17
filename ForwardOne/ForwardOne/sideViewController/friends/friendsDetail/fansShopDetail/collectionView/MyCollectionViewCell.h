//
//  MyCollectionViewCell.h
//  AppDevelopment
//
//  Created by 杨波 on 15/1/6.
//  Copyright (c) 2015年 杨波. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyCollectionViewCell : UICollectionViewCell
@property (nonatomic,retain) UILabel *label;
@property (nonatomic,strong) UIImageView *iconImageView;

@property (nonatomic,strong) UIImageView *boomImageView;
@property (nonatomic,strong) UILabel *priceLabel;
@property (nonatomic,strong) UILabel *promoteLabel;
@property (nonatomic,strong) UIImageView *lineIamgeView;
@property (nonatomic,strong) UILabel *goodsNameLabel;


@end
