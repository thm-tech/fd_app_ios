//
//  activityDetailViewController.m
//  ForwardOne
//
//  Created by 杨波 on 15/8/11.
//  Copyright (c) 2015年 杨波. All rights reserved.
//

#import "activityDetailViewController.h"

@interface activityDetailViewController ()

@end

@implementation activityDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //创建导航栏
    [self createUINav];
    
    [self createTextUI];
    
    // Do any additional setup after loading the view.
}
-(void)createTextUI
{
    UIView *backView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT*0.7)];
    backView.backgroundColor =[UIColor whiteColor];
    [self.view addSubview:backView];
    //标题、
    UILabel *titleLabel = [ZCControl createLabelWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT*0.7*0.1) Font:SCREENWIDTH*0.053 Text:self.model.title];
    titleLabel.textColor = [UIColor colorWithHexStr:@"#333333"];
    //titleLabel.backgroundColor = [UIColor orangeColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [backView addSubview:titleLabel];
    
//    //活动图片
//    UIImageView *imageView = [ZCControl createImageViewWithFrame:CGRectMake(10, SCREENHEIGHT*0.7*0.1, SCREENWIDTH-20, SCREENHEIGHT*0.7*0.55) ImageName:nil];
//    [imageView sd_setImageWithURL:[NSURL URLWithString:self.model.shopPic]];
//    //imageView.backgroundColor = [UIColor orangeColor];
//    [self.view addSubview:imageView];
//    
//    //活动内容
//    UILabel *contentLabel = [ZCControl createLabelWithFrame:CGRectMake(10, SCREENHEIGHT*0.7*0.65, SCREENWIDTH-20, SCREENHEIGHT*0.7*0.3) Font:SCREENWIDTH*0.048 Text:@"哈哈哈哈哈哈啊哈哈哈哈哈啊哈哈哈哈哈啊啊哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈啊哈哈哈哈哈哈啊哈哈哈哈哈哈啊哈哈哈哈哈哈啊哈哈哈啊啊哈哈哈哈哈啊哈哈哈哈哈啊哈哈啊哈哈哈你"];
//    contentLabel.textColor = [UIColor colorWithHexStr:@"#666666"];
//    //contentLabel.backgroundColor = [UIColor blueColor];
//    [self.view addSubview:contentLabel];
    UIWebView *_webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, SCREENHEIGHT*0.7*0.1, SCREENWIDTH, SCREENHEIGHT*0.7*0.85)];
    _webView.userInteractionEnabled = YES;
    _webView.backgroundColor = [UIColor whiteColor];
    //_webView.scrollView.userInteractionEnabled = NO;
   
    
    //查询宽度
    NSString *finalString = [NSString stringWithFormat:@"<style>p{word-wrap: break-word;word-break: normal;}</style>%@",self.model.content];
    
    NSMutableArray *_widthArray = [[NSMutableArray alloc]init];
    
    NSString *regex = @"width:[0-9]+";
    NSError *error;
    NSRegularExpression *regular = [NSRegularExpression regularExpressionWithPattern:regex options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray *matchs = [regular matchesInString:finalString options:0 range:NSMakeRange(0, finalString.length)];
    for(NSTextCheckingResult *match in matchs)
    {
        NSRange range = [match range];
        NSString *mstr = [finalString substringWithRange:range];
        // NSLog(@"正则表达式匹配的字符串 = %@",mstr);
        NSString *widthValueString = [mstr substringFromIndex:6];
        // NSLog(@"宽度%@",widthValueString);
        [_widthArray addObject:widthValueString];
        
    }
    
    //查询高度
    NSMutableArray *_heightArray = [[NSMutableArray alloc]init];
    
    NSString *heightRegex = @"height:[0-9]+";
    NSRegularExpression *heightRegular = [NSRegularExpression regularExpressionWithPattern:heightRegex options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray *heightMatchs = [heightRegular matchesInString:finalString options:0 range:NSMakeRange(0, finalString.length)];
    NSString *heightValueString = [[NSString alloc]init];
    
    for(NSTextCheckingResult *heightMatch in heightMatchs)
    {
        NSRange range = [heightMatch range];
        NSString *heightString = [finalString substringWithRange:range];
        heightValueString = [heightString substringFromIndex:7];
        [_heightArray addObject:heightValueString];
    }
    
    //判断是否要更改
    for(int i = 0;i<_widthArray.count;i++)
    {
        NSString *deceidedWidthSting = _widthArray[i];
        NSString *deceideHeightSting = _heightArray[i];
        if(deceidedWidthSting.intValue>SCREENWIDTH)
        {
            NSString *finaleDeceideWidthing = [NSString stringWithFormat:@"%f",SCREENWIDTH-15];
            NSString *finaleDeceideHeighing = [NSString stringWithFormat:@"%f",deceideHeightSting.intValue*(SCREENWIDTH/deceidedWidthSting.intValue)];
            //字符串的替换操作
            finalString = [finalString stringByReplacingOccurrencesOfString:deceidedWidthSting withString:finaleDeceideWidthing];
            finalString = [finalString stringByReplacingOccurrencesOfString:deceideHeightSting withString:finaleDeceideHeighing];
        }
        else
        {
            NSString *finaleDeceideWidthing = [NSString stringWithFormat:@"%f",SCREENWIDTH-15];
            finalString = [finalString stringByReplacingOccurrencesOfString:deceidedWidthSting withString:finaleDeceideWidthing];
        }
    }
    //NSLog(@"哈哈哈哈哈哈哈哈%@",finalString);
    
    [_webView loadHTMLString:finalString baseURL:nil];
    [self.view addSubview:_webView];
    //活动日期
    NSString *bt = [self.model.bt substringToIndex:10];
    NSString *et = [self.model.et substringToIndex:10];
    NSString *dateString = [NSString stringWithFormat:@"%@至%@",bt,et];
    NSString *finalaDateString = [NSString stringWithFormat:@"活动时间：%@",dateString];
    UILabel *dateLabel = [ZCControl createLabelWithFrame:CGRectMake(SCREENWIDTH*0.2, SCREENHEIGHT*0.7*0.95, SCREENWIDTH*0.8, SCREENHEIGHT*0.7*0.05) Font:SCREENWIDTH*0.0426 Text:finalaDateString];
    dateLabel.textColor = [UIColor colorWithHexStr:@"#666666"];
    [self.view addSubview:dateLabel];
}

-(void)createUINav
{
    UILabel *titleLabel = [ZCControl createLabelWithFrame:CGRectMake(0, 0, 100, 30) Font:22 Text:@"活动详情"];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = titleLabel;
    
    //导航栏左按钮
    UIButton *leftButton = [ZCControl createButtonWithFrame:CGRectMake(0, 0, 25, 20) ImageName:@"" Target:self Action:@selector(leftButtonBtn:) Title:nil    ];
    [leftButton setImage:[UIImage imageNamed:@"店铺-店铺详情_03"] forState:UIControlStateNormal];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    self.view.backgroundColor = [UIColor colorWithHexStr:@"#eeeeee"];
}
-(void)leftButtonBtn:(UIButton *)button
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
