//
//  aboutMiaomiaoXiongViewController.m
//  ForwardOne
//
//  Created by 杨波 on 15/5/9.
//  Copyright (c) 2015年 杨波. All rights reserved.
//

#import "aboutMiaomiaoXiongViewController.h"

@interface aboutMiaomiaoXiongViewController ()

@end

@implementation aboutMiaomiaoXiongViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createUINA];
    
    [self createTextUI];
    // Do any additional setup after loading the view.
}

-(void)createTextUI
{
    UIImageView *iconImageView = [ZCControl createImageViewWithFrame:CGRectMake(SCREENWIDTH*0.3, SCREENHEIGHT*0.05, SCREENWIDTH*0.4, SCREENWIDTH*0.4) ImageName:@"logo"];
    [self.view addSubview:iconImageView];
    
    UILabel *productNameLabel = [ZCControl createLabelWithFrame:CGRectMake(SCREENWIDTH*0.3, SCREENHEIGHT*0.3, SCREENWIDTH*0.4, SCREENHEIGHT*0.05) Font:SCREENWIDTH*0.053 Text:@"喵喵熊1.0"];
    //productNameLabel.backgroundColor = [UIColor orangeColor];
    productNameLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:productNameLabel];
    
    UILabel *companyLabel = [ZCControl createLabelWithFrame:CGRectMake(0, SCREENHEIGHT*0.7, SCREENWIDTH, SCREENHEIGHT*0.05) Font:SCREENWIDTH*0.053 Text:@"北京银瀑技术有限公司"];
    companyLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:companyLabel];
    
    UILabel *companyLabel2 = [ZCControl createLabelWithFrame:CGRectMake(0, SCREENHEIGHT*0.75, SCREENWIDTH, SCREENHEIGHT*0.05) Font:SCREENWIDTH*0.048 Text:@"Copyright 2015-2016 impower"];
    companyLabel2.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:companyLabel2];
    
    UILabel *companyLabel3 = [ZCControl createLabelWithFrame:CGRectMake(0, SCREENHEIGHT*0.8, SCREENWIDTH, SCREENHEIGHT*0.05) Font:SCREENWIDTH*0.048 Text:@"All rights Reserved"];
    companyLabel3.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:companyLabel3];
    
}

-(void)createUINA
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    UILabel *titleLabel = [ZCControl createLabelWithFrame:CGRectMake(0, 0, 100, 30) Font:22 Text:@"关于喵喵熊"];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = titleLabel;
    
    //导航栏左按钮
    UIButton *imageLeftButton  =[ZCControl createButtonWithFrame:CGRectMake(0, 0, 25, 20) ImageName:@"" Target:self Action:@selector(imageLeftItemBtn) Title:nil];
    [imageLeftButton setImage:[UIImage imageNamed:@"店铺-店铺详情_03"] forState:UIControlStateNormal];
    UIBarButtonItem *imageLeftItem = [[UIBarButtonItem alloc]initWithCustomView:imageLeftButton];
    self.navigationItem.leftBarButtonItem = imageLeftItem;
}
-(void)imageLeftItemBtn
{
    [self.navigationController popViewControllerAnimated:YES];
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
