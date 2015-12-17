//
//  userFeedbackChatModel.h
//  ForwardOne
//
//  Created by 杨波 on 15/7/10.
//  Copyright (c) 2015年 杨波. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface userFeedbackChatModel : NSObject

@property (nonatomic,strong) NSMutableArray *dataSource;
@property (nonatomic) BOOL isGroupChat;

- (void)populateRandomDataSource:(NSArray *)array;

- (void)addRandomItemsToDataSource:(NSInteger)number;

- (void)addSpecifiedItem:(NSDictionary *)dic;

@end
