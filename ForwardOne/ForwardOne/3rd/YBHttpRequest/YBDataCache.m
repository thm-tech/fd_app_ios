//
//  YBDataCache.m
//  NetWorkingDemo
//
//  Created by 杨波 on 15/3/20.
//  Copyright (c) 2015年 杨波. All rights reserved.
//

#import "YBDataCache.h"
#import "NSString+Hashing.h"

@implementation YBDataCache
+(id)sharedInstance
{
    static YBDataCache *dc = nil;
    if(dc == nil)
    {
        dc = [[YBDataCache alloc]init];
        
        //设置缓存的有效时间为30分钟
        dc.invalidInterval = 0*60;
    }
    return dc;
}
//作用：保存数据，传入数据和对应url
-(void)saveData:(NSData *)data urlString:(NSString *)urlString
{
   //创建保存缓存文件的文件夹  将数据通过NSFileManager写入文件中
    NSString *path = [NSString stringWithFormat:@"%@/Documents/DataCache",NSHomeDirectory()];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    
    //生成保存缓存文件的文件名
    //使用MD5编码 可以把任意长度的数据编码为固定长度（24，32）的字符串（一串十六进制值）
    //MD5编码特性：不同的具有唯一不同的MD5编码
    NSString *md5String = [urlString MD5Hash];
    NSString *file = [NSString stringWithFormat:@"%@/%@",path,md5String];
    
    //数据写入文件中
    BOOL b = [data writeToFile:file atomically:YES];
    
}

//作用读取数据，传入url，返回数据
-(NSData *)readDataWithUrlString:(NSString *)urlString
{
    //生成文件名
    NSString *file = [NSString stringWithFormat:@"%@/Documents/DataCache/%@",NSHomeDirectory(),[urlString MD5Hash]];
    
    //检查缓存是否过期
    if([[NSFileManager defaultManager] fileExistsAtPath:file] == NO)
    {
        return nil;
    }
    
    //获取当前时间到文件最后修改的时间间隔
    NSTimeInterval interval = [[NSDate date]timeIntervalSinceDate:[self getFileLastModifyTimeWithFileName:file]];
    if(interval > self.invalidInterval)
    {
        //如果失效了 则不使用缓存数据
        return nil;
    }
    
    //读取数据返回
    NSData *data = [[NSData alloc]initWithContentsOfFile:file];
    return data;
    
}
-(NSDate *)getFileLastModifyTimeWithFileName:(NSString *)fileName
{
    NSDictionary *dict = [[NSFileManager defaultManager] attributesOfItemAtPath:fileName error:nil];
    //NSLog(@"dict = %@",dict);
    return dict[@"NSFileModificationDate"];
}

@end
