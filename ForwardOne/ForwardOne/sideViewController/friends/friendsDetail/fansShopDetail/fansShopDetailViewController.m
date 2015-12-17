//
//  fansShopDetailViewController.m
//  ForwardOne
//
//  Created by 杨波 on 15/5/8.
//  Copyright (c) 2015年 杨波. All rights reserved.
//

#import "fansShopDetailViewController.h"
#import "shopInformationViewController.h"
#import "inShopMyFansShopAndLookedViewController.h"
#import "MyCollectionViewCell.h"
#import "MyCollectionHeaderView.h"
#import "MycollectionFooterView.h"

#import "collectionCommodityDetailViewController.h"

#import "shakeAndShakeViewController.h"
#import "invivateFriendsShoppingViewController.h"
#import "changeChatGroupViewController.h"

#import "inShopActivityViewController.h"
#import "inShopFansViewController.h"
#import "inshopLookedViewController.h"

#import "mainShopDetailViewController.h"

#import "myAppDataBase.h"

//数据类
#import "mainShopDetailCommodityModel.h"

//退出商店的URL
#define EXISTSHOPURL @"http://%@/user/shop/exit?sid=%d"

//进店URl
#define VISITSHOPURL @"http://%@/user/shop/enter?sid=%d"

//店内商品URL
#define SHOPDETAILCOMMODITYURL @"http://%@/user/goods?sid=%d&offset=%d&count=%d"

@interface fansShopDetailViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UIActionSheetDelegate,YBInshopFansDelegate,YBInshopLookedDelegate,YBShopInformationChangeGnameDelegate,YBSendActivityDelegate>
{
    UIButton *changeChatStyleButton;
    UILabel *invitationLabel;
    
    NSMutableArray *_mainShopDetailCommodityArray;
    int mainShopDetailCommodityOffset;
    int mainShopDetailCommodityCount;
    
    UICollectionView *myCollectionView;

}
@end

@implementation fansShopDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createUINav];
    
    [self createCollectionView];
    
    [self crreateBottomView];
    
    // Do any additional setup after loading the view.
}
-(void)crreateBottomView
{
    UIView *bottomView = [[UIView alloc]initWithFrame:CGRectMake(0,SCREENHEIGHT-44-64, SCREENWIDTH, 44)];
    bottomView.backgroundColor = [UIColor colorWithHexStr:@"#eeeeee"];
    bottomView.alpha = 0.9;
    [self.view addSubview:bottomView];
    
    //切换群聊天室和群组
//    changeChatStyleButton = [ZCControl createButtonWithFrame:CGRectMake(10, 10, SCREENWIDTH*0.15-20, 24) ImageName:@"btn_login_bg_2@2x" Target:self Action:@selector(changeStyleButtonBtn:) Title:nil];
//    [bottomView addSubview:changeChatStyleButton];
    
    //提示逛的label
    invitationLabel = [ZCControl createLabelWithFrame:CGRectMake(5, 5, SCREENWIDTH*0.4, 34) Font:SCREENWIDTH*0.04 Text:self.groupNameString];
    invitationLabel.textColor = [UIColor colorWithHexStr:@"#676767"];
    //invitationLabel.adjustsFontSizeToFitWidth = YES;
    //invitationLabel.backgroundColor = [UIColor orangeColor];
    [bottomView addSubview:invitationLabel];
    
    //显示和收缩的imageView
    UIImageView * contractionImageView = [ZCControl createImageViewWithFrame:CGRectMake(0, 0, SCREENWIDTH*0.12, 10) ImageName:nil];
    contractionImageView.center = CGPointMake(SCREENWIDTH/2, 10);
    contractionImageView.image = [UIImage imageNamed:@"首页_11"];

    [bottomView addSubview:contractionImageView];
    
    //在allContractionImagrView上添加点击收缩和处理的事件
    UIControl *control = [[UIControl alloc]initWithFrame:CGRectMake(SCREENWIDTH*0.41, 0, SCREENWIDTH*0.18, 44)];
    [control addTarget:self action:@selector(dealWithContraction:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:control];
    
    //拉好友群组的button
    UIButton *invitationButton = [ZCControl createButtonWithFrame:CGRectMake(SCREENWIDTH*0.88, 0, SCREENWIDTH*0.08, 44) ImageName:@"" Target:self Action:@selector(invitationButtonBtn:) Title:nil];
    [invitationButton setImage:[UIImage imageNamed:@"首页_14"] forState:UIControlStateNormal];
    //[bottomView addSubview:invitationButton];
}
//-(void)changeStyleButtonBtn:(UIButton *)button
//{
//    
//}

-(void)dealWithContraction:(UIControl *)control
{
   
    [self.YB_delegate YBFansShopDetailClickWithShopName:self.shopNamestrting andShopPic:self.shopPic andShopID:self.shopIDString];
    
    [self.navigationController popViewControllerAnimated:NO];
}

-(void)invitationButtonBtn:(UIButton *)button
{
    UIActionSheet *ac = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"切换聊天组",@"拉好友",@"摇一摇", nil];
    ac.tag = 101;
    [ac showInView:self.view];
}

//拉好友动作列表的代理
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(actionSheet.tag == 101)
    {
    if(buttonIndex == 0)
    {
        changeChatGroupViewController *ccgvc = [[changeChatGroupViewController alloc]init];
        [self.navigationController pushViewController:ccgvc animated:YES];
        
    }
    else if (buttonIndex == 1)
    {
        invivateFriendsShoppingViewController *isvc = [[invivateFriendsShoppingViewController alloc]init];
        [self.navigationController pushViewController:isvc animated:YES];
    }
    else if(buttonIndex == 2)
    {
        shakeAndShakeViewController *ssvc = [[shakeAndShakeViewController alloc]init];
        [self.navigationController pushViewController:ssvc animated:YES];
    }
    else
    {
        
    }
    }
    else if (actionSheet.tag == 102)
    {
        if(buttonIndex == 0)
        {
            inshopLookedViewController *vc = [[inshopLookedViewController alloc]init];
            vc.YB_delegate = self;
            vc.shopIDString = self.shopIDString;
            [self.navigationController pushViewController:vc animated:YES];
        }
        else if (buttonIndex == 1)
        {
            inShopFansViewController *vc = [[inShopFansViewController alloc]init];
            vc.YB_delegate = self;
            vc.shopIDString = self.shopIDString;
            [self.navigationController pushViewController:vc animated:YES];
        }
        else if (buttonIndex == 2)
        {
            shopInformationViewController *sfvc = [[shopInformationViewController alloc]init];
            sfvc.YB_delegate = self;
            sfvc.shopIDString = self.shopIDString;
            sfvc.shopNamestrting = self.shopNamestrting;
            sfvc.gnameString = self.gnameString;
            sfvc.invitationLabelString = self.groupNameString;
            [self.navigationController pushViewController:sfvc animated:YES];
        }
        else if (buttonIndex == 3)
        {
            inShopActivityViewController *vc = [[inShopActivityViewController alloc]init];
            vc.gnameString = self.gnameString;
            vc.invitationLabelString = self.groupNameString;
            vc.YB_delegate = self;
            
            [self.navigationController pushViewController:vc animated:YES];
        }
        else
        {
            
        }

    }
}
//商店详情界面的反向传值
-(void)YBShopInformationChangeGnameWithGname:(NSString *)gname andGroupName:(NSString *)groupName
{
    invitationLabel.text = groupName;
    self.gnameString = gname;
    [self.YB_delegate YBFansShopGnameDelegate:gname andGroupName:groupName];
}

//发送活动界面的反向传值
-(void)YBSendActivityDelgateWithGname:(NSString *)gname andGroupName:(NSString *)groupName
{
    invitationLabel.text = groupName;
    self.gnameString = gname;
    [self.YB_delegate YBFansShopGnameDelegate:gname andGroupName:groupName];
}

#pragma mark-(逛过点上面协议处理)
-(void)YBInshopLookedTableViewCellDidClickWithShopName:(NSString *)shopName andShopPic:(NSString *)shopPic andShopID:(NSString *)shopID
{
   
    
    self.shopPic = shopPic;
    self.shopNamestrting = shopName;
    self.shopIDString = shopID;
    [self downLoadMainShopDetailCommodityData];
    [self visitShop];
    
    UILabel *titleLabel = [ZCControl createLabelWithFrame:CGRectMake(0, 0, 100, 30) Font:22 Text:self.shopNamestrting];
    titleLabel.adjustsFontSizeToFitWidth = YES;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = titleLabel;
}

#pragma mark-(粉丝店上面协议传值的处理)
-(void)YBInshopFansTableViewCellDidClickWithShopName:(NSString *)shopName andShopPic:(NSString *)shopPic andShopID:(NSString *)shopID
{
    self.shopPic = shopPic;
    self.shopNamestrting = shopName;
    self.shopIDString = shopID;
    [self downLoadMainShopDetailCommodityData];
    [self visitShop];
    
    UILabel *titleLabel = [ZCControl createLabelWithFrame:CGRectMake(0, 0, 100, 30) Font:22 Text:self.shopNamestrting];
    titleLabel.adjustsFontSizeToFitWidth = YES;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = titleLabel;

}

#pragma mark-(下载商店内商品的数据)
-(void)downLoadMainShopDetailCommodityData
{
    _mainShopDetailCommodityArray = [[NSMutableArray alloc]init];
    mainShopDetailCommodityOffset = 0;
    mainShopDetailCommodityCount = 100;
    
    NSString *urlString = [NSString stringWithFormat:SHOPDETAILCOMMODITYURL,DomainName,self.shopIDString.intValue,mainShopDetailCommodityOffset,mainShopDetailCommodityCount];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSString *errString = dict[@"err"];
        if(errString.intValue == 0)
        {
            NSArray *array = dict[@"goodsList"];
            for(NSDictionary *goodListDict in array)
            {
                mainShopDetailCommodityModel *model = [[mainShopDetailCommodityModel alloc]init];
                [model setValuesForKeysWithDictionary:goodListDict];
                [_mainShopDetailCommodityArray addObject:model];
            }
            
            self.dataArray = _mainShopDetailCommodityArray;
            [myCollectionView reloadData];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"err = %@",error);
    }];

}


#pragma mark-(用户进店协议)
-(void)visitShop
{
    NSString *urlString = [NSString stringWithFormat:VISITSHOPURL,DomainName,self.shopIDString.intValue];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    [manager POST:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSString *errString = dict[@"err"];
        if(errString.intValue == 0)
        {
            //获取当前时间
            NSString *date = [[NSString alloc]init];
            NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
            [formatter setDateStyle:kCFDateFormatterFullStyle];
            [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            date = [formatter stringFromDate:[NSDate date]];
            
            //NSLog(@"当前时间%@",date);
            
            //进店成功之后  本地保存逛店记录 （当数据库中有记录的时候则更新记录 没有记录则插入记录）
            if([[myAppDataBase sharedInstance] isExistVisitShopRecordWithShopID:self.shopIDString recordTyoe:RecoredTypeAttention])
            {
                //[dc upDateVisitShopTimeWithShopID:self.shopIDString time:date];
                //[dc deleteVisitShopRecordWithRecordType:<#(RecordType)#>]
                //先删除上次记录 然后插入本次记录
                NSNumber *shopIDNumber =[[NSNumber alloc]initWithInt:self.shopIDString.intValue];
                
                [[myAppDataBase sharedInstance] deleteVisitShopREcordWithShopID:shopIDNumber recordType:RecoredTypeAttention];
                
                NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
                [dict setObject:date forKey:@"time"];
                [dict setObject:shopIDNumber forKey:@"shopID"];
                [dict setObject:self.shopNamestrting forKey:@"shopName"];
                [dict setObject:self.shopPic forKey:@"shopPic"];
                NSLog(@"逛店记录的字典%@",dict);
                
                [[myAppDataBase sharedInstance] addVisitShopRecordWithDicitionary:dict recordType:RecoredTypeAttention];
                
                
            }
            else
            {
                NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
                NSNumber *shopIDNumber =[[NSNumber alloc]initWithInt:self.shopIDString.intValue];
                [dict setObject:date forKey:@"time"];
                [dict setObject:shopIDNumber forKey:@"shopID"];
                [dict setObject:self.shopNamestrting forKey:@"shopName"];
                [dict setObject:self.shopPic forKey:@"shopPic"];
                NSLog(@"逛店记录的字典%@",dict);
                
                [[myAppDataBase sharedInstance] addVisitShopRecordWithDicitionary:dict recordType:RecoredTypeAttention];
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
    
    
}


-(void)createCollectionView
{
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
    flowLayout.minimumInteritemSpacing = 5;
    flowLayout.minimumLineSpacing = 5;
    flowLayout.itemSize = CGSizeMake((SCREENWIDTH-15)/2, SCREENHEIGHT*0.4);
    
    myCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(5, 0, SCREENWIDTH-10, SCREENHEIGHT-64-44) collectionViewLayout:flowLayout];
    myCollectionView.backgroundColor = [UIColor whiteColor];
    myCollectionView.showsHorizontalScrollIndicator = NO;
    myCollectionView.showsVerticalScrollIndicator = NO;
    myCollectionView.userInteractionEnabled = YES;
    myCollectionView.delegate = self;
    myCollectionView.dataSource = self;
    
    [myCollectionView registerClass:[MyCollectionViewCell class] forCellWithReuseIdentifier:@"CellReuseIdentifier"];
    [myCollectionView registerClass:[MyCollectionHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderIdentifier"];
    [myCollectionView registerClass:[MycollectionFooterView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterIdentifier"];
    [self.view addSubview:myCollectionView];
    
    
    
}
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    //return 11;
    return self.dataArray.count;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"CellReuseIdentifier";
    MyCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    //cell.iconImageView.image = [UIImage imageNamed:@"s"];
    
    mainShopDetailCommodityModel *model = self.dataArray[indexPath.row];
    
    NSNumber *widthNumber = [[NSNumber alloc]initWithLong:(long)((SCREENWIDTH-15)/2)];
    NSNumber *heightNumber = [[NSNumber alloc]initWithLong:(long)(SCREENHEIGHT*0.4*0.85)];
    
    
    [cell.iconImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@@%@w_%@h_1e_0l_1c",model.pic,widthNumber,heightNumber]]];
    cell.goodsNameLabel.textColor = [UIColor colorWithHexStr:@"#666666"];
    cell.goodsNameLabel.text = model.name;
//    //判断是否存在促销价格
//    NSString *promotString = [NSString stringWithFormat:@"%@",model.promot];
//    //NSLog(@"哈哈哈哈哈哈哈哈哈%@",promotString);
//    if([promotString isEqualToString:@"(null)"])
//    {
//        
//        //不存在促销价格
//        cell.lineIamgeView.hidden = YES;
//        NSString *priceNullString = [NSString stringWithFormat:@"%@",model.price];
//        if(![priceNullString isEqualToString:@"(null)"])
//        {
//        cell.promoteLabel.text = [NSString stringWithFormat:@"￥%@",model.price];
//        }
//        
//    }
//    else
//    {
//        //存在促销价格
//        cell.priceLabel.text = [NSString stringWithFormat:@"￥%@",model.price];
//        cell.promoteLabel.text = [NSString stringWithFormat:@"￥%@",model.promot];
//    }
    
    return cell;
}
//每个cell的点击处理方法
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //在点击跳转之间 传入商品ID的参数值
    
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    collectionCommodityDetailViewController *ccdvc = [[collectionCommodityDetailViewController alloc]init];
    mainShopDetailCommodityModel *model = self.dataArray[indexPath.row];
    ccdvc.goodsIDString = model.id;
    ccdvc.shopIDString = self.shopIDString;
    [self.navigationController pushViewController:ccdvc animated:YES];
    
    
}

-(void)createUINav
{

    self.view.backgroundColor = [UIColor whiteColor];
    
    //导航栏左按钮
    UIButton *leftButton = [ZCControl createButtonWithFrame:CGRectMake(0, 0, 25, 20) ImageName:@"" Target:self Action:@selector(leftButtonBtn:) Title:nil    ];
    [leftButton setImage:[UIImage imageNamed:@"店铺-店铺详情_03"] forState:UIControlStateNormal];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithCustomView:leftButton];
    //    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"lady's-purse@2x"] style:UIBarButtonItemStylePlain target:self action:@selector(leftButtonBtn:)];
    self.navigationItem.leftBarButtonItem = leftItem;
    
//    //导航栏右按钮
//    UIButton *rightButton = [ZCControl createButtonWithFrame:CGRectMake(0, 0, 25, 20) ImageName:@"" Target:self Action:@selector(rightButtonBtn:) Title:nil];
//    [rightButton setImage:[UIImage imageNamed:@"店铺_05"] forState:UIControlStateNormal];
//    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:rightButton];
//    UIButton *rightButton2 = [ZCControl createButtonWithFrame:CGRectMake(0, 0, 20, 20) ImageName:@"" Target:self Action:@selector(titleButtonBtn:) Title:nil];
//    [rightButton2 setImage:[UIImage imageNamed:@"店铺_03"] forState:UIControlStateNormal];
//    UIBarButtonItem *rightItem2 = [[UIBarButtonItem alloc]initWithCustomView:rightButton2];
//    self.navigationItem.rightBarButtonItems = @[rightItem,rightItem2];
    
    //导航栏右按钮（改动之后）
    UIButton *rightButton = [ZCControl createButtonWithFrame:CGRectMake(0, 0, 25, 20) ImageName:@"" Target:self Action:@selector(rightButtonDidClick:) Title:nil];
    [rightButton setImage:[UIImage imageNamed:@"首页_15"] forState:UIControlStateNormal];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    
    //导航栏的title
    //self.title = self.shopNamestrting;
    UILabel *titleLabel = [ZCControl createLabelWithFrame:CGRectMake(0, 0, 100, 30) Font:22 Text:self.shopNamestrting];
     titleLabel.adjustsFontSizeToFitWidth = YES;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = titleLabel;

}

-(void)rightButtonDidClick:(UIButton *)button
{
    UIActionSheet *ac = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"逛过的店",@"关注的店",@"店面信息",@"商店活动", nil];
    ac.tag = 102;
    [ac showInView:self.view];
    
}

-(void)leftButtonBtn:(UIButton *)button
{
    //即将推退出之前 调用退店的协议
    
    [self existShop];
    
    NSArray *array = self.navigationController.viewControllers;
    if(array[2] == self)
    {
    [self.navigationController popToViewController:array[0] animated:YES];
    }
    else if (array[3] == self)
    {
        [self.navigationController popToViewController:array[1] animated:YES];
    }
    else if (array[4] == self)
    {
        [self.navigationController popToViewController:array[2] animated:YES];
    }
    else if (array[5] == self)
    {
        [self.navigationController popToViewController:array[3] animated:YES];
    }
    
    //[self.navigationController popViewControllerAnimated:NO];
}

-(void)existShop
{
    NSString *urlString = [NSString stringWithFormat:EXISTSHOPURL,DomainName,self.shopIDString.intValue];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    [manager POST:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSString *errString = dict[@"err"];
        if(errString.intValue == 0)
        {
            //进店成功之后  本地保存逛店记录 （当数据库中有记录的时候则更新记录 没有记录则插入记录）
            NSLog(@"本汪今天大展风采");
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}


-(void)titleButtonBtn:(UIButton *)button
{
    shopInformationViewController *sfvc = [[shopInformationViewController alloc]init];
    sfvc.shopIDString = self.shopIDString;
    sfvc.shopNamestrting = self.shopNamestrting;
    [self.navigationController pushViewController:sfvc animated:YES];
}

-(void)rightButtonBtn:(UIButton *)button
{
    inShopMyFansShopAndLookedViewController *isfvc = [[inShopMyFansShopAndLookedViewController alloc]init];
    [self.navigationController pushViewController:isfvc animated:YES];
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
