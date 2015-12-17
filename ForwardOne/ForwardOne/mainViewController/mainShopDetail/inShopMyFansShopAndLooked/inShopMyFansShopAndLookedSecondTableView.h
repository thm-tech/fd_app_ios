//
//  inShopMyFansShopAndLookedSecondTableView.h
//  ForwardOne
//
//  Created by 杨波 on 15/5/14.
//  Copyright (c) 2015年 杨波. All rights reserved.
//

#import "fansShopDataBaseModel.h"

//自己制定的cell上面的点击协议
@protocol YBInShopMyFansShopAndLookedSecondTableViewCellDelegate <NSObject>

-(void)YBInShopMyFansShopAndLookedSecondTableViewDidSelected:(fansShopDataBaseModel *)model;

@end



#import <UIKit/UIKit.h>

@interface inShopMyFansShopAndLookedSecondTableView : UIView

@property (nonatomic,weak)id<YBInShopMyFansShopAndLookedSecondTableViewCellDelegate>YB_cellDelegate;

@end
