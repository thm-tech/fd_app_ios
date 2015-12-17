//
//  twoDimensionalCodeViewController.m
//  ForwardOne
//
//  Created by 杨波 on 15/5/4.
//  Copyright (c) 2015年 杨波. All rights reserved.
//

#import "twoDimensionalCodeViewController.h"
#import "QRCodeGenerator.h"


@interface twoDimensionalCodeViewController ()

@end

@implementation twoDimensionalCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createNav];
    
    [self createTwoDimensionalCode];
    
    // Do any additional setup after loading the view.
}
-(void)createTwoDimensionalCode
{
    UIImageView *imageView = [ZCControl createImageViewWithFrame:CGRectMake(SCREENWIDTH*0.1, SCREENHEIGHT*0.05, SCREENWIDTH*0.8, SCREENHEIGHT*0.4) ImageName:@""];
    imageView.backgroundColor = [UIColor whiteColor];
    
    UIImage *image = [QRCodeGenerator qrImageForString:self.qcodeString imageSize:400];
    imageView.image = image;
    [self.view addSubview:imageView];
}


-(void)createNav
{
    self.view.backgroundColor = [UIColor whiteColor];
    UILabel *titleLabel = [ZCControl createLabelWithFrame:CGRectMake(0, 0, 100, 30) Font:22 Text:@"我的二维码"];
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
