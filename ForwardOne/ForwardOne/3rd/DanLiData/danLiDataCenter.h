//
//  danLiDataCenter.h
//  ForwardOne
//
//  Created by 杨波 on 15/5/15.
//  Copyright (c) 2015年 杨波. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface danLiDataCenter : NSObject

+(id)sharedInstance;

//菜单栏上面我选择的城市（当前所支持的城市）
@property (copy,nonatomic) NSString *myGetCityString;
@property (copy,nonatomic) NSString *frdIDString;
@end
