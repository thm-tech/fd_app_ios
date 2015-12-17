//
//  inShopMyFansShopAndLookedViewController.h
//  ForwardOne
//
//  Created by 杨波 on 15/5/14.
//  Copyright (c) 2015年 杨波. All rights reserved.
//

@protocol YBInShopMyFansShopAndLookedTableViewDelegate <NSObject>

-(void)YBYBInShopMyFansShopAndLookedTableViewDidClickWithShopName:(NSString *)shopName andShopPic:(NSString *)shopPic andShopID:(NSString *)shopID;

@end



#import <UIKit/UIKit.h>

@interface inShopMyFansShopAndLookedViewController : UIViewController

@property (nonatomic,weak)id<YBInShopMyFansShopAndLookedTableViewDelegate> YB_Delagete;

@end
