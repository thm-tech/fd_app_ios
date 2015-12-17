//
//  YBHttpRequest.m
//  NetWorkingDemo
//
//  Created by 杨波 on 15/3/20.
//  Copyright (c) 2015年 杨波. All rights reserved.
//

#import "YBHttpRequest.h"

#import "YBDataCache.h"
#import "AFNetworking.h"
#import "UIKit+AFNetworking.h"

//消除performSelector的警告
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

@implementation YBHttpRequest


-(id)initWithURLString:(NSString *)urlString target:(id)target action:(SEL)action
{
    if(self = [super init])
    {
        //默认开启缓存功能
        self.isCache = YES;
        _urlString = urlString;
        _target = target;
        _action = action;
        _downloadData = [[NSMutableData alloc]init];
        
        //下载之前检查数据是否存在 如果存在直接读取
        NSData *data = [[YBDataCache sharedInstance] readDataWithUrlString:_urlString];
        //如果缓存存在 则不下载 直接返回
        if(data != nil)
        {
            [_downloadData appendData:data];
            
            //延时0.1秒后返回
            [self.target performSelector:self.action withObject:self afterDelay:0.1];
        }
        else
        {
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            manager.responseSerializer = [AFHTTPResponseSerializer serializer];
            [manager GET:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                [_downloadData appendData:responseObject];
                
                //数据下载完成后保存数据
                if(self.isCache)
                {
                    //保存数据
                    [[YBDataCache sharedInstance] saveData:_downloadData urlString:self.urlString];
                }
                //执行回调的方法  通知界面数据下载完成
                if([_target respondsToSelector:_action])
                {
                    //执行传入的方法
                    [_target performSelector:_action withObject:self];
                    
                }
                
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                
                NSLog(@"error = %@",error);
                
            }];
        }
    }
    return self;
}

@end
