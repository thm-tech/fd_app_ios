//
//  newFeatureViewController.m
//  ForwardOne
//
//  Created by 杨波 on 15/10/26.
//  Copyright (c) 2015年 杨波. All rights reserved.
//

#import "newFeatureViewController.h"

#import "ViewController.h"

@interface newFeatureViewController () <UIScrollViewDelegate>
{
    UIScrollView *_scrollView;
    UIImageView *_imageView;
}
@end

@implementation newFeatureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //创建scrollView
    [self createScrollView];
    
    //滚动视图上面添加图片
    [self addImage];
    
    // Do any additional setup after loading the view.
}
//滚动视图上面添加图片
-(void)addImage
{
    double w = SCREENWIDTH;
    double h = SCREENHEIGHT;
    
    for(int i = 1;i<=3;i++)
    {
        double x = SCREENWIDTH*(i-1);
        double y = 0;
        
        _imageView = [[UIImageView alloc]initWithFrame:CGRectMake(x, y, w, h)];
        _imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"app_guide%d.jpg",i]];
        _imageView.userInteractionEnabled = YES;
        [_scrollView addSubview:_imageView];
        
        //最后一张上面添加跳转按钮
        if(i == 3)
        {
            UIButton *button = [ZCControl createButtonWithFrame:CGRectMake(0, SCREENHEIGHT*0.8, SCREENWIDTH, SCREENHEIGHT*0.2) ImageName:nil Target:self Action:@selector(buttonBtn:) Title:@"立即体验"];
           
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [_imageView addSubview:button];
        }
    }
}

//立即体验按钮的点击的事件
-(void)buttonBtn:(UIButton *)button
{
    //不是第一次使用
    ViewController *rvc = [[ViewController alloc]init];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:rvc];
    [self presentViewController:nav animated:YES completion:nil];
}


//创建scrollView
-(void)createScrollView
{
    _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT)];
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.contentSize = CGSizeMake(SCREENWIDTH*3, SCREENHEIGHT);
    _scrollView.pagingEnabled = YES;
    _scrollView.bounces = NO;
    _scrollView.delegate = self;
    
    //打开用户交互属性
    _scrollView.userInteractionEnabled = YES;
    [self.view addSubview:_scrollView];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
