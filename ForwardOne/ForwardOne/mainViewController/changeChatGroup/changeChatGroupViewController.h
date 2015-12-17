//
//  changeChatGroupViewController.h
//  ForwardOne
//
//  Created by 杨波 on 15/5/26.
//  Copyright (c) 2015年 杨波. All rights reserved.
//
//进行反向传值gname的代理
@protocol YBChangeGroupNameDelegate <NSObject>

-(void)YBChangeGroupGNameWith:(NSString *)gname andGroupName:(NSString *)groupName;
-(void)YBchangeGroupTableViewReloadData2;

@end


#import <UIKit/UIKit.h>

@interface changeChatGroupViewController : UIViewController

@property (nonatomic,weak) id<YBChangeGroupNameDelegate>YB_ChangeGroupGnameDelegate;

@end
