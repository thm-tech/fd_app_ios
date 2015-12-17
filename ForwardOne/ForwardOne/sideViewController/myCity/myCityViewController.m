//
//  myCityViewController.m
//  ForwardOne
//
//  Created by 杨波 on 15/5/9.
//  Copyright (c) 2015年 杨波. All rights reserved.
//

#import "myCityViewController.h"

#import "MyCollectionHeaderView.h"
#import "MycollectionFooterView.h"
#import "myCityCollectionViewCell.h"

#import "paltformSupportModel.h"

#define PLAFORMSUPPORTCITYURL @"http://%@/user/city"


@interface myCityViewController () <UICollectionViewDelegate,UICollectionViewDataSource,UIGestureRecognizerDelegate>
{
    UICollectionView *_collectionView;
    
    NSMutableArray *_titleArray;
}
@end

@implementation myCityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    __weak typeof(self) weakSelf = self;
//    if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)])
//    {
//        self.navigationController.interactivePopGestureRecognizer.delegate = weakSelf;
//    }
    
    [self createUINa];
    
    [self createCollection];
    
    //下载平台支持城市的数据
    [self downloadPlatformSupportCityData];
    
    // Do any additional setup after loading the view.
}


-(void)downloadPlatformSupportCityData
{
    _titleArray = [[NSMutableArray alloc]init];
    NSString *urlString = [NSString stringWithFormat:PLAFORMSUPPORTCITYURL,DomainName];
    NSLog(@"支持的城市%@",urlString);
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
       //解析
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSString *errString = dict[@"err"];
        if(errString.intValue == 0)
        {
            NSArray *array = dict[@"cityList"];
            for(NSDictionary *cityDict in array)
            {
                paltformSupportModel *model = [[paltformSupportModel alloc]init];
                [model setValuesForKeysWithDictionary:cityDict];
                [_titleArray addObject:model];
            }
            
            //数据下载完毕  刷新
            [_collectionView reloadData];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"err = %@",error);
    }];
}
-(void)createCollection
{
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
    flowLayout.minimumInteritemSpacing = 5;
    flowLayout.minimumLineSpacing = 10;
    flowLayout.itemSize = CGSizeMake(WIDTH*0.22,HEIGHT*0.06);
    _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 10, SCREENWIDTH, SCREENHEIGHT-74-10) collectionViewLayout:flowLayout];
    _collectionView.backgroundColor = [UIColor whiteColor];
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.showsVerticalScrollIndicator = NO;
    _collectionView.userInteractionEnabled = YES;
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    
    [_collectionView registerClass:[myCityCollectionViewCell class] forCellWithReuseIdentifier:@"CellReuseIdentifier"];
    [_collectionView registerClass:[MyCollectionHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderIdentifier"];
    [_collectionView registerClass:[MycollectionFooterView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterIdentifier"];
    [self.view addSubview:_collectionView];
    
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _titleArray.count;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"CellReuseIdentifier";
    myCityCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    paltformSupportModel *model = _titleArray[indexPath.item];
    
    cell.label.text = model.name;
    
    return cell;
}
//每个cell的点击处理方法
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    //在点击跳转页面之前，传入参数
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    paltformSupportModel *model = _titleArray[indexPath.item];
    
    //实现通知传值
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:@"changeMyCity" object:nil userInfo:@{@"myCity":model.name}];
    
    //当选择支持的城市之后 城市数据永久保存
    [[NSUserDefaults standardUserDefaults]setObject:model.name forKey:MyChooseCity];
    [[NSUserDefaults standardUserDefaults]synchronize];
   
    [self.YB_CollectionViewDelegate YBCollectionViewDidClickWithTitle:model.name];
    [self.navigationController popViewControllerAnimated:YES];
    
}

-(void)createUINa
{
    self.view.backgroundColor = [UIColor colorWithHexStr:@"#eeeeee"];
    
    UILabel *titleLabel = [ZCControl createLabelWithFrame:CGRectMake(0, 0, 100, 30) Font:22 Text:@"城市"];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = titleLabel;
    
    //导航栏左按钮
    UIButton *imageLeftButton  =[ZCControl createButtonWithFrame:CGRectMake(0, 0, 25, 20) ImageName:@"" Target:self Action:@selector(imageLeftItemBtn) Title:nil];
    [imageLeftButton setImage:[UIImage imageNamed:@"逛过_03"] forState:UIControlStateNormal];
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
