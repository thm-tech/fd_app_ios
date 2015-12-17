//
//  fansShopDetailViewController.h
//  ForwardOne
//
//  Created by 杨波 on 15/5/8.
//  Copyright (c) 2015年 杨波. All rights reserved.
//
@protocol YBFansShopDetailDelegate <NSObject>

-(void)YBFansShopDetailClickWithShopName:(NSString *)shopName andShopPic:(NSString *)shopPic andShopID:(NSString *)shopID;
-(void)YBFansShopGnameDelegate:(NSString *)gname andGroupName:(NSString *)groupName;

@end


#import <UIKit/UIKit.h>
@interface fansShopDetailViewController : UIViewController

//用来接收传递过来的数组
@property (nonatomic,copy) NSMutableArray *dataArray;
@property (nonatomic,copy) NSString *shopNamestrting;
@property (nonatomic,copy) NSString *shopIDString;
@property (nonatomic,copy) NSString *groupNameString;
@property (nonatomic,copy) NSString *shopPic;
@property (nonatomic,copy) NSString *gnameString;



@property (nonatomic,weak) id<YBFansShopDetailDelegate>YB_delegate;

@end
