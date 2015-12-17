//
//  myCollectionCommodityViewController.h
//  ForwardOne
//
//  Created by 杨波 on 15/5/9.
//  Copyright (c) 2015年 杨波. All rights reserved.
//
@protocol YBMyCollectionChatChangeGnameDelegate <NSObject>

-(void)YBMyCollectionChatChangeGnameWithGname:(NSString *)gname andGroupName:(NSString *)groupName;

@end


#import <UIKit/UIKit.h>

@interface myCollectionCommodityViewController : UIViewController

@property (copy,nonatomic) NSString *invitationLabelString;
@property (copy,nonatomic) NSString *gnameString;
@property (nonatomic,weak) id<YBMyCollectionChatChangeGnameDelegate>YB_delegate;


@end
