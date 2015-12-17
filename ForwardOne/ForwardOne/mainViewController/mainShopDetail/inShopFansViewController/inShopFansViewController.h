//
//  inShopFansViewController.h
//  ForwardOne
//
//  Created by 杨波 on 15/9/30.
//  Copyright (c) 2015年 杨波. All rights reserved.
//
@protocol YBInshopFansDelegate <NSObject>

-(void)YBInshopFansTableViewCellDidClickWithShopName:(NSString *)shopName andShopPic:(NSString *)shopPic andShopID:(NSString *)shopID;

@end

#import <UIKit/UIKit.h>

@interface inShopFansViewController : UIViewController

@property (nonatomic,weak)id<YBInshopFansDelegate>YB_delegate;

@property (nonatomic,copy) NSString *shopIDString;

@end
