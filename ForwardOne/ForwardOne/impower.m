//
//  impower.m
//  ForwardOne
//
//  Created by 杨波 on 15/7/21.
//  Copyright (c) 2015年 杨波. All rights reserved.
//

#import "impower.h"

static NSMutableDictionary *userInfo;

@implementation impower

-(id)init
{
    self  = [super init];
    if(self != nil)
    {
        
    }
    return self;
}
+(NSDictionary *)getUserInfo:(NSString *)userIdString
{
    NSDictionary *dict = @{@"111":@"222"};
    
    userInfo  = [[NSMutableDictionary alloc]init];
    
    [userInfo setObject:dict forKey:userIdString];
    NSLog(@"*****%@",userInfo);
    return userInfo;
}

@end
