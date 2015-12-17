//
//  myFriendTableViewCell.h
//  ForwardOne
//
//  Created by 杨波 on 15/9/10.
//  Copyright (c) 2015年 杨波. All rights reserved.
//

//cell上面长按的点击协议
@protocol YBFriendLongPressDelegate <NSObject>

-(void)YBFriendLongPressDidPressWithPress:(UILongPressGestureRecognizer *)press;

@end


#import <UIKit/UIKit.h>

@interface myFriendTableViewCell : UITableViewCell

@property (nonatomic,strong) UIImageView *iconImageView;
@property (nonatomic,strong) UILabel *nameLabel;


//添加长按删除好友的手势
@property (nonatomic,strong)UILongPressGestureRecognizer *longPress;

@property (nonatomic,weak)id<YBFriendLongPressDelegate>YB_delegate;

@end
