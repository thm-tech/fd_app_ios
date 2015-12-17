//
//  myCityViewController.h
//  ForwardOne
//
//  Created by 杨波 on 15/5/9.
//  Copyright (c) 2015年 杨波. All rights reserved.
//
@protocol YBCollectionViewDelegate <NSObject>

-(void)YBCollectionViewDidClickWithTitle:(NSString *)title;

@end


#import <UIKit/UIKit.h>

@interface myCityViewController : UIViewController
@property (nonatomic,weak)id<YBCollectionViewDelegate>YB_CollectionViewDelegate;

@end
