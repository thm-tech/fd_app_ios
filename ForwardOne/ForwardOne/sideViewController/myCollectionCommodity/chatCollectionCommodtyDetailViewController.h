//
//  chatCollectionCommodtyDetailViewController.h
//  ForwardOne
//
//  Created by 杨波 on 15/12/2.
//  Copyright © 2015年 杨波. All rights reserved.
//
@protocol chatCollectionDetailChatChangeGnameDelegate <NSObject>

-(void)YBchatCollectionDetailChatChangeGnameWithGname:(NSString *)gname andGroupName:(NSString *)groupName;

@end



#import <UIKit/UIKit.h>

@interface chatCollectionCommodtyDetailViewController : UIViewController

//传递过来的goodsID
@property (copy,nonatomic) NSString *goodsIDString;
@property (copy,nonatomic) NSString *shopIDString;

@property (copy,nonatomic) NSString *invitationLabelString;
@property (copy,nonatomic) NSString *gnameString;

@property (nonatomic,weak) id<chatCollectionDetailChatChangeGnameDelegate>YB_delegate;

@end
