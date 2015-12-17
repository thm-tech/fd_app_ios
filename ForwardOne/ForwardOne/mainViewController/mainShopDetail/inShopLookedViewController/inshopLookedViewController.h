//
//  inshopLookedViewController.h
//  ForwardOne
//
//  Created by 杨波 on 15/9/30.
//  Copyright (c) 2015年 杨波. All rights reserved.
//

@protocol YBInshopLookedDelegate <NSObject>

-(void)YBInshopLookedTableViewCellDidClickWithShopName:(NSString *)shopName andShopPic:(NSString *)shopPic andShopID:(NSString *)shopID;

@end

#import <UIKit/UIKit.h>

@interface inshopLookedViewController : UIViewController

@property (nonatomic,weak) id<YBInshopLookedDelegate>YB_delegate;

//从上个界面传过来的商店ID用于当前界面退出商店
@property (nonatomic,copy) NSString *shopIDString;


@end
