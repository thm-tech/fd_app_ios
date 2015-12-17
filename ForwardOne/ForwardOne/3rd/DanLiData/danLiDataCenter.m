//
//  danLiDataCenter.m
//  ForwardOne
//
//  Created by 杨波 on 15/5/15.
//  Copyright (c) 2015年 杨波. All rights reserved.
//

#import "danLiDataCenter.h"

@implementation danLiDataCenter

+(id)sharedInstance
{
    static danLiDataCenter *dc = nil;
    if(dc == nil)
    {
        dc = [[[self class] alloc] init];
    }
    return dc;
}
    

@end
