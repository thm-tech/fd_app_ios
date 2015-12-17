//
//  addFirendsViewController.h
//  ForwardOne
//
//  Created by 杨波 on 15/5/7.
//  Copyright (c) 2015年 杨波. All rights reserved.
//
@protocol YBAddFriendChatChangeGnameDelegate <NSObject>

-(void)YBAddFriendChatChangGnameWith:(NSString *)gname andGroupName:(NSString *)groupName;

@end


#import <UIKit/UIKit.h>
#import <AddressBookUI/AddressBookUI.h>

@interface addFirendsViewController : UIViewController <ABPeoplePickerNavigationControllerDelegate>

@property (copy,nonatomic) NSString *invitationLabelString;
@property (copy,nonatomic) NSString *gnameString;

@property (nonatomic,weak) id<YBAddFriendChatChangeGnameDelegate> YB_delegate;

@end
