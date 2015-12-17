//
//  SlideDeleteCell.h
//  RHSlideDeleteTableViewCell
//
//  Created by london on 14-2-21.
//  Copyright (c) 2014年 Robin_Huang. All rights reserved.
//
@protocol YBMiaoMiaoCellButtonDelegate <NSObject>

-(void)YBMiaoMiaoCellButtonDidClick:(UIButton *)button;

@end


#import <UIKit/UIKit.h>

@class SlideDeleteCell;
@protocol  SlideDeleteCellDelegate<NSObject>

-(void)slideToDeleteCell:(SlideDeleteCell *)slideDeleteCell;

@end

@interface SlideDeleteCell : UITableViewCell<UIGestureRecognizerDelegate>
{
}

@property(assign, nonatomic)id<SlideDeleteCellDelegate>delegate;

@property (nonatomic,strong)UIImageView *iconImageView;
@property (nonatomic,strong)UILabel *nameLabel;
@property (nonatomic,strong)UILabel *messageLabel;
@property (nonatomic,strong)UIImageView *pointImageView;
@property (nonatomic,strong)UIButton *refuseButton;
@property (nonatomic,strong)UIButton *receiveButton;

@property (nonatomic,weak) id<YBMiaoMiaoCellButtonDelegate> YB_cellDelegate;


@end
