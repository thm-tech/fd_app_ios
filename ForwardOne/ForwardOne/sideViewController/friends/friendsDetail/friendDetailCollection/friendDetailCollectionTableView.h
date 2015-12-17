//
//  friendDetailCollectionTableView.h
//  ForwardOne
//
//  Created by 杨波 on 15/7/7.
//  Copyright (c) 2015年 杨波. All rights reserved.
//
//cell上面的点击的协议
@protocol YBFriendDetailCollectionDelegate <NSObject>
//需要带上商品的ID参数
-(void)YBFriendDetailColletionCellDidClick:(NSString *)commodityID andShopID:(NSString *)shopID;

@end


#import <UIKit/UIKit.h>

@interface friendDetailCollectionTableView : UIView

@property (nonatomic,weak) id<YBFriendDetailCollectionDelegate>YB_cellDelegate;

@end
