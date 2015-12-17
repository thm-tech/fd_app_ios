//
//  firendDetailThirdTableViewCell.h
//  ForwardOne
//
//  Created by 杨波 on 15/5/7.
//  Copyright (c) 2015年 杨波. All rights reserved.
//
@protocol YBMyFanShopFansButtonDelegate <NSObject>

-(void)YBMyFanShopFansButtonDidClick:(UIButton *)button;

@end


#import <UIKit/UIKit.h>

@interface firendDetailThirdTableViewCell : UITableViewCell

@property (nonatomic,strong) UIImageView *iconImageView;
@property (nonatomic,strong) UILabel *shopNameLabel;
@property (nonatomic,strong) UILabel *activityNewLabel;
@property (nonatomic,strong) UILabel *shopNewLabel;
@property (nonatomic,strong) UIImageView *activityImageView;
@property (nonatomic,strong) UIImageView *shopNewImageView;
@property (nonatomic,strong) UIButton *attenButton;


@property (nonatomic,weak) id<YBMyFanShopFansButtonDelegate> YBCell_delegate;

@end
