//
//  friendDetailFansShopTableView.h
//  ForwardOne
//
//  Created by 杨波 on 15/7/7.
//  Copyright (c) 2015年 杨波. All rights reserved.
//

@protocol YBFriendDetailFansShopDelegate <NSObject>

-(void)YBFriendDetailFansShopTableViewCellDidClick:(NSString *)shopIDString ansShopName:(NSString *)shopName andShopPic:(NSString *)shopPic;

@end

#import <UIKit/UIKit.h>

@interface friendDetailFansShopTableView : UIView

@property (nonatomic,weak)id<YBFriendDetailFansShopDelegate>YB_cellDelegate;

@end
