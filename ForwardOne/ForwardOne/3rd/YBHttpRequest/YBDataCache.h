//
//  YBDataCache.h
//  NetWorkingDemo
//
//  Created by 杨波 on 15/3/20.
//  Copyright (c) 2015年 杨波. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YBDataCache : NSObject

@property (nonatomic) float invalidInterval;

+(id)sharedInstance;

//作用：保存数据，传入数据和对应url
-(void)saveData:(NSData *)data urlString:(NSString *)urlString;

//作用读取数据，传入url，返回数据
-(NSData *)readDataWithUrlString:(NSString *)urlString;

@end
