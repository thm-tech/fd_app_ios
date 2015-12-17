//
//  inshopLookedViewController.m
//  ForwardOne
//
//  Created by 杨波 on 15/9/30.
//  Copyright (c) 2015年 杨波. All rights reserved.
//

#import "inshopLookedViewController.h"
#import "myAppDataBase.h"
#import "myLookedShopModel.h"

//退出商店的URL
#define EXISTSHOPURL @"http://%@/user/shop/exit?sid=%d"

@interface inshopLookedViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    UITableView *_tableView;
    NSMutableArray *_dataArray;
    
    myAppDataBase *dc;
}
@end

@implementation inshopLookedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createUINaviga];
    
    [self createTableView];
    
    [self loadData];
    
    // Do any additional setup after loading the view.
}
-(void)loadData
{
    //从数据库中读取  我逛过的商店的数据只本地保存  读取数据也只从本地读取
    dc = [myAppDataBase sharedInstance];
    _dataArray = [[NSMutableArray alloc]init];
    NSArray *array = [dc getVisitShopRecordWithRecordTyepe:RecoredTypeAttention];
    for(long i = array.count-1;i>=0;i--)
    {
        [_dataArray addObject:array[i]];
    }
    [_tableView reloadData];
}

-(void)createTableView
{
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT-64) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    //设置表格视图左边短15像素问题
    if([_tableView respondsToSelector:@selector(setSeparatorInset:)])
    {
        [_tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if([_tableView  respondsToSelector:@selector(setLayoutMargins:)])
    {
        [_tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    [self.view addSubview:_tableView];
}
#pragma mark-(设置解决表格视图左边短15像素问题)
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([cell respondsToSelector:@selector(setSeparatorInset:)])
    {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if([cell respondsToSelector:@selector(setLayoutMargins:)])
    {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"cell";
    UITableViewCell  *cell  =[tableView dequeueReusableHeaderFooterViewWithIdentifier:cellID];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID];
    }
    //config cell
    myLookedShopModel *model = _dataArray[indexPath.row];
    cell.textLabel.text = model.name;
    cell.textLabel.textColor = [UIColor colorWithHexStr:@"#333333"];
    
    return cell;
}

#pragma mark-(设置各种高度)

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return SCREENHEIGHT*0.1;
}

#pragma mark-(cell上面的点击事件)
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    myLookedShopModel *model = _dataArray[indexPath.row];
    
    [self.YB_delegate YBInshopLookedTableViewCellDidClickWithShopName:model.name andShopPic:model.shopPic andShopID:model.id];
    
     [self.navigationController popViewControllerAnimated:YES];
    
    //退出之前的商店
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


-(void)createUINaviga
{
    UILabel *titleLabel = [ZCControl createLabelWithFrame:CGRectMake(0, 0, 100, 30) Font:22 Text:@"逛过的店"];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = titleLabel;
    
    //导航栏左按钮
    UIButton *leftButton = [ZCControl createButtonWithFrame:CGRectMake(0, 0, 25, 20) ImageName:@"" Target:self Action:@selector(leftButtonBtn:) Title:nil    ];
    [leftButton setImage:[UIImage imageNamed:@"店铺-店铺详情_03"] forState:UIControlStateNormal];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = leftItem;
    
     self.view.backgroundColor = [UIColor whiteColor];
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
