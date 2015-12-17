//
//  YBHttpRequest.h
//  NetWorkingDemo
//
//  Created by 杨波 on 15/3/20.
//  Copyright (c) 2015年 杨波. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YBHttpRequest : NSObject

//weak修饰的对象指针  当对象释放后指向这个对象的指针自动变成nil
@property (weak,nonatomic) id target;
@property (nonatomic) SEL action;

//表示是否加入缓存功能
@property (nonatomic) BOOL isCache;
@property (nonatomic) NSString *urlString;

//为了存储下载的数据
@property (strong,nonatomic) NSMutableData *downloadData;

//传入下载地址 传入事件的处理方法
-(id)initWithURLString:(NSString *)urlString target:(id)target action:(SEL)action;


@end
