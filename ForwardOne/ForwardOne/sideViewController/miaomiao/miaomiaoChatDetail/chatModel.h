//
//  chatModel.h
//  ForwardOne
//
//  Created by 杨波 on 15/5/22.
//  Copyright (c) 2015年 杨波. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface chatModel : NSObject

@property (nonatomic,strong) NSMutableArray *dataSource;
@property (nonatomic) BOOL isGroupChat;

- (void)populateRandomDataSource:(NSArray *)array;

//消息来了 添加一条消息到聊天的tableView上面
-(void)insertOneMessageToTableViewWithDict:(NSDictionary *)dict;

//下拉刷新加载更多的聊天记录
-(void)addMoreChatData:(NSArray *)array;

- (void)addRandomItemsToDataSource:(NSInteger)number;

- (void)addSpecifiedItem:(NSDictionary *)dic;

@end
