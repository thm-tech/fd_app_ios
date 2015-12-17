//
//  shopInfoSecondTableViewCell.h
//  ForwardOne
//
//  Created by 杨波 on 15/5/8.
//  Copyright (c) 2015年 杨波. All rights reserved.
//
//打电话按钮的点击的实现
@protocol YBPhoneButtonDelegate <NSObject>

-(void)YBPhoneButtonDelegateDidClick:(UIButton *)button;

@end

#import <UIKit/UIKit.h>

@interface shopInfoSecondTableViewCell : UITableViewCell

@property (nonatomic,strong) UIButton *locateImageViewButton;
@property (nonatomic,strong) UIImageView *locateImageView;
@property (nonatomic,strong) UILabel *locateLabel;
@property (nonatomic,strong) UILabel *distanceLabel;
@property (nonatomic,strong) UIImageView *lineImageView;
@property (nonatomic,strong) UIButton *phoneButton;

@property (nonatomic,weak) id<YBPhoneButtonDelegate> YB_PhoneDelegate;

@end
