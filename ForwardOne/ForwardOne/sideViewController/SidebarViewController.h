//
//  SidebarViewController.h
//  LLBlurSidebar
//
//  Created by Lugede on 14/11/20.
//  Copyright (c) 2014年 lugede.cn. All rights reserved.
//
//侧滑菜单上面的点击协议

@protocol YBSideTableViewDelegate <NSObject>

-(void)YBSideTableViewCellDidSelectedWithIndexPath:(NSIndexPath *)indexpath;

-(void)YBSideTableViewHeaderViewDidSelected;

-(void)YBSideTableViewLoginHeaderViewDidSelected;

@end

#import "LLBlurSidebar.h"

@interface SidebarViewController : LLBlurSidebar

@property (nonatomic,weak) id<YBSideTableViewDelegate>YB_delegate;

//菜单上面的选择支持的城市
@property (nonatomic,strong) NSString *cityString;

@end
