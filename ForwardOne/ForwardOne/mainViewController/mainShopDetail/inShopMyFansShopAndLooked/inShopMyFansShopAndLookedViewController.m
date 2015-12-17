//
//  inShopMyFansShopAndLookedViewController.m
//  ForwardOne
//
//  Created by 杨波 on 15/5/14.
//  Copyright (c) 2015年 杨波. All rights reserved.
//

#import "inShopMyFansShopAndLookedViewController.h"
#import "inShopMyFansShopAndLookedFirstTableView.h"
#import "inShopMyFansShopAndLookedSecondTableView.h"


@interface inShopMyFansShopAndLookedViewController () <UIScrollViewDelegate,YBInShopMyFansShopAndLookedSecondTableViewCellDelegate,YBInShopMyFansShopAndLookedFirstTableViewCellDelegate>
{
    UIScrollView *_scrollView;
   
    UISegmentedControl *_segmentControl;
    
}
@end

@implementation inShopMyFansShopAndLookedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createUINA];
    [self createScrollView];
    // Do any additional setup after loading the view.
}
-(void)createScrollView
{
    _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT-64)];
    _scrollView.contentSize = CGSizeMake(SCREENWIDTH*2, SCREENHEIGHT-64);
    _scrollView.delegate = self;
    _scrollView.bounces = NO;
    _scrollView.pagingEnabled = YES;
    _scrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:_scrollView];
    
    inShopMyFansShopAndLookedFirstTableView *first = [[inShopMyFansShopAndLookedFirstTableView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT-64)];
    first.YB_cellDelegate = self;
   // first.backgroundColor = [UIColor orangeColor];
    [_scrollView addSubview:first];
    
    inShopMyFansShopAndLookedSecondTableView *second = [[inShopMyFansShopAndLookedSecondTableView alloc]initWithFrame:CGRectMake(SCREENWIDTH, 0, SCREENWIDTH, SCREENHEIGHT-64)];
    second.YB_cellDelegate = self;
    [_scrollView addSubview:second];
}
//粉店上面的点击协议
-(void)YBInShopMyFansShopAndLookedSecondTableViewDidSelected:(fansShopDataBaseModel *)model
{
    [self.YB_Delagete YBYBInShopMyFansShopAndLookedTableViewDidClickWithShopName:model.name andShopPic:model.pic andShopID:model.id];
    
    [self.navigationController popViewControllerAnimated:YES];
}

//逛过上面的点击协议
-(void)YBInShopMyFansShopAndLookedFirstTableViewCellDidSelected:(myLookedShopModel *)model
{
    [self.YB_Delagete YBYBInShopMyFansShopAndLookedTableViewDidClickWithShopName:model.name andShopPic:model.shopPic andShopID:model.id];
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)createUINA
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    //创建titleView
    _segmentControl  =[[UISegmentedControl alloc]initWithItems:@[@"逛过",@"粉店"]];
    _segmentControl.selectedSegmentIndex = 0;
    _segmentControl.tintColor = [UIColor whiteColor];
    _segmentControl.frame = CGRectMake(0, 0, SCREENWIDTH*0.5, 30);
    [_segmentControl addTarget:self action:@selector(dealSegmentControl:) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.titleView = _segmentControl;
    
    //导航栏左按钮
    UIButton *imageLeftButton  =[ZCControl createButtonWithFrame:CGRectMake(0, 0, 25, 20) ImageName:@"" Target:self Action:@selector(imageLeftItemBtn) Title:nil];
    [imageLeftButton setImage:[UIImage imageNamed:@"店铺-店铺详情_03"] forState:UIControlStateNormal];
    UIBarButtonItem *imageLeftItem = [[UIBarButtonItem alloc]initWithCustomView:imageLeftButton];
    self.navigationItem.leftBarButtonItem = imageLeftItem;

}
-(void)dealSegmentControl:(UISegmentedControl *)control
{
    if(control.selectedSegmentIndex == 0)
    {
        _scrollView.contentOffset = CGPointMake(0, 0);
    }
    else
    {
        _scrollView.contentOffset = CGPointMake(SCREENWIDTH, 0);
    }
}
-(void)imageLeftItemBtn
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark-(滚动视图的代理)
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    float index = scrollView.contentOffset.x/SCREENWIDTH;
    _segmentControl.selectedSegmentIndex = index;
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
