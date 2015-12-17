//
//  searchViewController.m
//  ForwardOne
//
//  Created by 杨波 on 15/8/5.
//  Copyright (c) 2015年 杨波. All rights reserved.
//

#import "searchViewController.h"
#import "waterfullModel.h"
#import "searchModel.h"
#import "mainShopDetailViewController.h"
#import "YBSearchTableViewCell.h"

#define SEARCHSHOPINFORMATIONURL @"http://%@/user/shop/search?name=%@&city=%d&long=%f&lat=%f&offset=%d&count=%d"
#define SEARCHSHOPINFORMATIONURL2 @"http://%@/user/shop/search"

@interface searchViewController ()<UITableViewDelegate,UITableViewDataSource,UISearchResultsUpdating,UISearchControllerDelegate,YBShopDetailChangeGroupNameDelegate>
{
    NSMutableArray *_dataArray;
    UITableView *_tableView;
    
    UISearchBar *_searchBar;

     UISearchController *_searchController;
    
    NSString *_searchString;
    
    //保存搜索结果的数组
     NSMutableArray *_searchResultsArray;
    
    float longtitude;
    float latitude;
    int offset;
    int count;
}
@end

@implementation searchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _dataArray = [[NSMutableArray alloc]init];
    _searchResultsArray = [[NSMutableArray alloc]init];
    _searchString = [[NSString alloc]init];
    
    [self createUINavigation];
    
    [self createTextUI];
    
    //下载所有搜索商店的数据
    [self downloadAllShopData];
    
    // Do any additional setup after loading the view.
}
-(void)downloadAllShopData
{
    longtitude = 12.0000;
    latitude = 12.00000;
    offset = 0;
    count = 100;
    
    NSString *longString = [NSString stringWithFormat:@"%f",longtitude];
    NSString *latString = [NSString stringWithFormat:@"%f",latitude];
    
    NSString *urlString = [NSString stringWithFormat:SEARCHSHOPINFORMATIONURL2,DomainName];
    NSDictionary *parameter = @{@"name":@"",@"city":self.cityIDString,@"long":longString,@"lat":latString,@"offset":@"0",@"count":@"100"};
    NSLog(@"**********%@",urlString);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:urlString parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"x**************%@",dict);
        NSString *errString = dict[@"err"];
        if(errString.intValue == 0)
        {
            NSArray *array = dict[@"shopList"];
             NSLog(@"s所有搜索的数组%@",array);
            
            if(array.count == 0)
            {
                //                UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"商店不存在，请重新查找" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                //                [al show];
            }
            else
            {
                for(NSDictionary *shopDict in array)
                {
                    searchModel *model = [[searchModel alloc]init];
                    [model setValuesForKeysWithDictionary:shopDict];
                    [_dataArray addObject:model];
                }
            }
            //刷新tableView;
            [_tableView reloadData];
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"__________%@",error);
        
    }];

}

#pragma mark-(下载搜索的商店的数据)
-(void)downloadAllShopDataWithSearchName:(NSString *)searchName
{
    longtitude = 12.0000;
    latitude = 12.00000;
    offset = 0;
    count = 100;
    
    NSString *longString = [NSString stringWithFormat:@"%f",longtitude];
    NSString *latString = [NSString stringWithFormat:@"%f",latitude];
    
    NSString *urlString = [NSString stringWithFormat:SEARCHSHOPINFORMATIONURL2,DomainName];
    NSDictionary *parameter = @{@"name":searchName,@"city":self.cityIDString,@"long":longString,@"lat":latString,@"offset":@"0",@"count":@"100"};
    //NSLog(@"**********%@",urlString);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:urlString parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSString *errString = dict[@"err"];
        if(errString.intValue == 0)
        {
            NSArray *array = dict[@"shopList"];
           // NSLog(@"搜索的数组%@",array);
            
            if(array.count == 0)
            {
//                UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"商店不存在，请重新查找" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
//                [al show];
            }
            else
            {
            for(NSDictionary *shopDict in array)
            {
                searchModel *model = [[searchModel alloc]init];
                [model setValuesForKeysWithDictionary:shopDict];
                [_searchResultsArray addObject:model];
            }
            }
            //刷新tableView;
            [_tableView reloadData];
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
    
}


-(void)createTextUI
{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT-44) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    //创建搜索条
   // _searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0,0 , SCREENWIDTH, 44)];
   // _searchBar.placeholder = @"请输入您要找的商店名称";
   // _tableView.tableHeaderView = _searchBar;
    
    _searchController = [[UISearchController alloc]initWithSearchResultsController:nil];
    _searchController.delegate = self;
    _searchController.searchResultsUpdater = self;
    _searchController.dimsBackgroundDuringPresentation = NO;
    _searchController.hidesNavigationBarDuringPresentation = NO;
    _searchController.searchBar.frame = CGRectMake(_searchController.searchBar.frame.origin.x, _searchController.searchBar.frame.origin.y, _searchController.searchBar.frame.size.width/2, 44.0);
    _searchController.searchBar.placeholder = @"请输入您要找的商店名称";
    _tableView.tableHeaderView = _searchController.searchBar;
   
}
//searchController的搜索代理
-(void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    //过滤数据的处理
    [_searchResultsArray removeAllObjects];
    if(_searchString!=nil)
    {
        _searchString = nil;
    }

    _searchString = _searchController.searchBar.text;
    [self downloadAllShopDataWithSearchName:_searchString];
    //[_tableView reloadData];
   
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //搜索框是是否活跃在当前屏幕上面
    if(_searchController.active)
    {
       return _searchResultsArray.count;
    }
    else
    {
       return _dataArray.count ;
    }

}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellID = @"cell";
    YBSearchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if(cell == nil)
    {
        cell  = [[YBSearchTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
    }
    //cellForRowAtIndexPath 中 if 下面
  
    if(_searchController.active)
    {
    searchModel *model = _searchResultsArray[indexPath.row];
    NSArray *picArray = model.picList;
    if(picArray.count != 0)
    {
    NSString *picUrlString = picArray[0];
        
        NSNumber *widthNumber = [[NSNumber alloc]initWithLong:(long)(SCREENWIDTH*0.2)];
        NSNumber *heightNumber = [[NSNumber alloc]initWithLong:(long)(SCREENHEIGHT*0.15*0.8)];
        
        [cell.iconImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@@%@w_%@h_1e_0l_1c",picUrlString,widthNumber,heightNumber]]];
    }
    cell.shopNameLabel.text = model.name;
    }
    else
    {
        searchModel *model = _dataArray[indexPath.row];
        NSArray *picArray = model.picList;
        if(picArray.count != 0)
        {
            NSString *picUrlString = picArray[0];
            
            NSNumber *widthNumber = [[NSNumber alloc]initWithLong:(long)(SCREENWIDTH*0.2)];
            NSNumber *heightNumber = [[NSNumber alloc]initWithLong:(long)(SCREENHEIGHT*0.15*0.8)];
            
            [cell.iconImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@@%@w_%@h_1e_0l_1c",picUrlString,widthNumber,heightNumber]]];

        }
        cell.shopNameLabel.text = model.name;
    }
        return cell;
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
   
    return SCREENHEIGHT*0.1;
}
//cell上面的点击事件
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    mainShopDetailViewController *msdvc = [[mainShopDetailViewController alloc]init];
    
    if(_searchController.active)
    {
        searchModel *model = _searchResultsArray[indexPath.row];
        msdvc.shopIDString = model.id;
        msdvc.shopNamestrting = model.name;
        msdvc.shopPic = model.picList[0];
    }
    else
    {
        searchModel *model = _dataArray[indexPath.row];
        msdvc.shopIDString = model.id;
        msdvc.shopNamestrting = model.name;
        msdvc.shopPic = model.picList[0];
    }
    
    _searchController.active = NO;
    msdvc.YB_ShopDetailChangeDelegate = self;
    msdvc.gnameString = self.gnameString;
    msdvc.invitationLabelString = self.invitationLabelString;
    
    [self.navigationController pushViewController:msdvc animated:YES];
    
}

#pragma mark-(从商店商品界面的聊天的反向传值)
-(void)YBShopDetailChangeGroupGname:(NSString *)gname andGroupName:(NSString *)groupName
{
    [self.YB_delegate YBSearchViewControllerChangeGname:gname andGroupName:groupName];
}

//导航栏
-(void)createUINavigation
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    UILabel *titleLabel = [ZCControl createLabelWithFrame:CGRectMake(0, 0, 100, 30) Font:22 Text:@"搜索"];
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
//    _searchController.delegate = nil;
//    _searchController.searchResultsUpdater = nil;
    
    //解决搜索框的是否活跃呈现在当前屏幕上面
    
    _searchController.active = NO;
    
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
