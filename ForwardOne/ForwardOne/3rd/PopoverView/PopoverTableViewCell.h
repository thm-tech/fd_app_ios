//
//  PopoverTableViewCell.h
//  ForwardOne
//
//  Created by 杨波 on 15/5/5.
//  Copyright (c) 2015年 杨波. All rights reserved.
//
//cell上面按钮的点击自制定的协议
@protocol YBCellDelegate <NSObject>

-(void)YBCellButtonDidClicked:(UIButton *)button andTitle:(NSString *)title;

@end


#import <UIKit/UIKit.h>

@interface PopoverTableViewCell : UITableViewCell

//定制cell上面的属性
@property (nonatomic,strong) UIImageView *iconImageView;
@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,strong) UIButton *firstButton;
@property (nonatomic,strong) UIButton *secondButton;
@property (nonatomic,strong) UIButton *thirdButton;

@property (nonatomic,weak) id<YBCellDelegate>YBCell_delegate;

@end
