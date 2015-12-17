//
//  addressTableViewCell.h
//  ForwardOne
//
//  Created by 杨波 on 15/7/6.
//  Copyright (c) 2015年 杨波. All rights reserved.
//
//设置默认地址的协议
@protocol YBSettingAdressDelegate <NSObject>

-(void)YBSettingButtonDidClick:(UIButton *)button;

@end

#import <UIKit/UIKit.h>

@interface addressTableViewCell : UITableViewCell

@property (nonatomic,strong) UILabel *nameLabel;
@property (nonatomic,strong) UILabel *phoneLabel;
@property (nonatomic,strong) UILabel *addressLabel;
@property (nonatomic,strong) UIButton *settingButton;

@property (nonatomic,weak) id<YBSettingAdressDelegate>YB_SettingButtonDelegate;

@end
