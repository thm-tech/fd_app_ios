//
//  inShopMyFansShopAndLookedFirstTableView.h
//  ForwardOne
//
//  Created by 杨波 on 15/5/14.
//  Copyright (c) 2015年 杨波. All rights reserved.
//
#import "myLookedShopModel.h"

//自己制定的cell点击的协议
@protocol YBInShopMyFansShopAndLookedFirstTableViewCellDelegate <NSObject>

-(void)YBInShopMyFansShopAndLookedFirstTableViewCellDidSelected:(myLookedShopModel *)model;

@end


#import <UIKit/UIKit.h>

@interface inShopMyFansShopAndLookedFirstTableView : UIView

@property (nonatomic,weak) id<YBInShopMyFansShopAndLookedFirstTableViewCellDelegate>YB_cellDelegate;

@end
