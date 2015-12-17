//
//  friendDetailLookedShopTableView.h
//  ForwardOne
//
//  Created by 杨波 on 15/7/7.
//  Copyright (c) 2015年 杨波. All rights reserved.
//

@protocol YBFriendDetailLookedShopDelegate <NSObject>

-(void)YBFriendDetailLookedShopTableViewCellDidClick:(NSString *)shopIDString andShopName:(NSString *)shopName andShopPic:(NSString *)shopPic;

@end

#import <UIKit/UIKit.h>

@interface friendDetailLookedShopTableView : UIView

@property (nonatomic,weak)id<YBFriendDetailLookedShopDelegate>YB_cellDelegate;

@end
