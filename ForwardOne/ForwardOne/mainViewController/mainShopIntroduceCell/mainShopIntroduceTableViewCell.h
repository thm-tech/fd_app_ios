//
//  mainShopIntroduceTableViewCell.h
//  ForwardOne
//
//  Created by 杨波 on 15/9/29.
//  Copyright (c) 2015年 杨波. All rights reserved.
//
//推荐品牌上面按钮的点击事件代理
@protocol YBMainShopIntroduceDelegate <NSObject>

-(void)YBMainShopIntroduceButtonDidClick:(UIButton *)button;

@end


#import <UIKit/UIKit.h>

@interface mainShopIntroduceTableViewCell : UITableViewCell

@property (nonatomic,strong) UIButton *activityButton1;
@property (nonatomic,strong) UIButton *activityButton2;
@property (nonatomic,strong) UIButton *activityButton3;

@property (nonatomic,weak) id<YBMainShopIntroduceDelegate>YB_delegate;

@end
