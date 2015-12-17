//
//  myCollectionCommodityViewController.m
//  ForwardOne
//
//  Created by 杨波 on 15/5/9.
//  Copyright (c) 2015年 杨波. All rights reserved.
//

#import "myCollectionCommodityViewController.h"
#import "firendDetailSecondTableViewCell.h"
#import "collectionCommodityDetailViewController.h"

#import "OpenUDID.h"
#import "myAppDataBase.h"
#import "collectionDataBaseModel.h"

#import "chatCollectionCommodtyDetailViewController.h"

//商品最近最新促销model
#import "collectionCommodityNewDiscountModel.h"

//查询本地存储和后台的差异
#define GOOIDDIFFERURL @"http://%@/user/favorite/diff"

//增加的goodID的信息
#define ADDGOODIDINFORMATIONURL @"http://%@/user/favorite/info?"

//商品最近最新的促销价格的数据URL
#define COMMODITYNEWDISCOUNTPRICEURL @"http://%@/user/goods/promot?"

//收藏和取消收藏商品
#define COLLECTIONURL @"http://%@/user/goods/concern?gid=%d"

@interface myCollectionCommodityViewController ()<UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate,YBMyCollectionGoodsButtonDelegate,UIActionSheetDelegate,UIGestureRecognizerDelegate,chatCollectionDetailChatChangeGnameDelegate>
{
    UITableView *_tableView;
    NSMutableArray *_dataArray;
    
    myAppDataBase *dc;
    
    //最新促销价
    NSMutableArray *_newDiscountArray;
    
    //增加的goodID
    NSMutableArray *_addGoodIDArray;
    
}
@end

@implementation myCollectionCommodityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    __weak typeof(self) weakSelf = self;
//    if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)])
//    {
//        self.navigationController.interactivePopGestureRecognizer.delegate = weakSelf;
//    }
    
    [self createUINa];
    
    NSString *loginString = [[NSUserDefaults standardUserDefaults]objectForKey:IsLogin];
    if([loginString isEqualToString:@"login"])
    {
    
    [self createTableView];
    
    _newDiscountArray = [[NSMutableArray alloc]init];
    
    dc = [myAppDataBase sharedInstance];
    //判断两次的设备是否一致 (与是否登录没有关系)
    NSString *lastUserDevice = [[NSUserDefaults standardUserDefaults]objectForKey:UserDevice];
    NSString *nowUserDevice = [OpenUDID value];
    if([lastUserDevice isEqualToString:nowUserDevice])
    {
        //两次设备相同 从本地数据库中取数据
        NSArray *array = [dc getCollectionRecordWithRecordType:RecoredTypeAttention];
        _dataArray = [[NSMutableArray alloc]init];
        
        for(long i = array.count-1;i>=0;i--)
        {
            [_dataArray addObject:array[i]];
        }
        
       // NSLog(@"收藏商品的数组%@",_dataArray);
        if(_dataArray.count != 0)
        {

            [_tableView reloadData];
        }
        else
        {
            UILabel *label = [ZCControl createLabelWithFrame:CGRectMake(0, SCREENHEIGHT*0.2, SCREENWIDTH, SCREENHEIGHT*0.1) Font:SCREENWIDTH*0.048 Text:@"你还没有任何收藏商品哟，请先关注商店吧"];
            label.textAlignment = NSTextAlignmentCenter;
            [self.view addSubview:label];
        }

       
    }
    else
    {
        NSString *togetherCollectionString = [[NSUserDefaults standardUserDefaults]objectForKey:IsTogetherCollection];
        if([togetherCollectionString isEqualToString:@"1"])
        {
            NSArray *array = [dc getCollectionRecordWithRecordType:RecoredTypeAttention];
            _dataArray = [[NSMutableArray alloc]init];
            
            for(long i = array.count-1;i>=0;i--)
            {
                [_dataArray addObject:array[i]];
            }
            
            // NSLog(@"收藏商品的数组%@",_dataArray);
            if(_dataArray.count != 0)
            {
                
                [_tableView reloadData];
            }
            else
            {
                UILabel *label = [ZCControl createLabelWithFrame:CGRectMake(0, SCREENHEIGHT*0.2, SCREENWIDTH, SCREENHEIGHT*0.1) Font:SCREENWIDTH*0.048 Text:@"你还没有任何收藏商品哟，请先收藏商品吧"];
                label.textAlignment = NSTextAlignmentCenter;
                [self.view addSubview:label];
            }

        }
        else
        {
        //两次设备不同 从后台取数据 goodID
        [self downloadGoodIDDataFromNet];
            
            [[NSUserDefaults standardUserDefaults]setObject:@"1" forKey:IsTogetherCollection];
            [[NSUserDefaults standardUserDefaults]synchronize];
            
        }
    }

    //商品最近最新的促销价格的数据
    [self downLoadCommodityDiscountData];
    }
    else
    {
        UILabel *label = [ZCControl createLabelWithFrame:CGRectMake(0, SCREENHEIGHT*0.2, SCREENWIDTH, SCREENHEIGHT*0.1) Font:SCREENWIDTH*0.048 Text:@"你还没登录，请先登录"];
        label.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:label];
    }
    // Do any additional setup after loading the view.
}
#pragma mark-(比较本地存储的goodID后后台的差异)
-(void)downloadGoodIDDataFromNet
{
    //先得到本地存储的goodID数组
    NSArray *array = [dc getCollectionRecordWithRecordType:RecoredTypeAttention];
    NSMutableArray *goodIDArray = [[NSMutableArray alloc]init];
    for(int i = 0;i<array.count;i++)
    {
        collectionDataBaseModel *model = array[i];
        [goodIDArray addObject:model.gid];
    }
    
    NSString *urlString = [NSString stringWithFormat:GOOIDDIFFERURL,DomainName];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    [manager POST:urlString parameters:@{@"goodsIDs":goodIDArray} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        NSLog(@"差异的字典 = %@",dict);
        
        NSString *errString = dict[@"err"];
        if(errString.intValue == 0)
        {
            //增加的
            NSArray *addArray = dict[@"addGoodsIDs"];
            _addGoodIDArray = [[NSMutableArray alloc]initWithArray:addArray];
            
            //删除的
            NSArray *deleteArray = dict[@"delGoodsIDs"];
            for(int i = 0;i<deleteArray.count;i++)
            {
                collectionDataBaseModel *model =[[collectionDataBaseModel alloc]init];
                model.gid = deleteArray[i];
                [dc deleteCollectionRecordWithDicitionary:model recordType:RecoredTypeAttention];
                
            }
            if(addArray.count == 0&&deleteArray.count == 0)
            {
                UILabel *label = [ZCControl createLabelWithFrame:CGRectMake(0, SCREENHEIGHT*0.2, SCREENWIDTH, SCREENHEIGHT*0.1) Font:SCREENWIDTH*0.048 Text:@"你还没有任何收藏商品哟，请先收藏商品吧"];
                label.textAlignment = NSTextAlignmentCenter;
                [self.view addSubview:label];
                
            }
            {
            //下载增加的goodID的信息
            [self downloadAddGoodIDData];
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"差异收藏 err = %@",error);
        
    }];
    
}
#pragma mark-(下载增加的goodID信息)
-(void)downloadAddGoodIDData
{
    NSString *goodIDString = [[NSString alloc]init];
    NSString *string = [NSString stringWithFormat:ADDGOODIDINFORMATIONURL,DomainName];
    for(int i = 0;i<_addGoodIDArray.count;i++)
    {
        if(i == _addGoodIDArray.count-1)
        {
            goodIDString = [NSString stringWithFormat:@"gid=%@",_addGoodIDArray[i]];
        }
        else
        {
            goodIDString = [NSString stringWithFormat:@"gid=%@&",_addGoodIDArray[i]];
        }
        string = [string stringByAppendingString:goodIDString];
    }
    NSLog(@"差异商品请求url = %@",string);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:string parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        NSLog(@"差异商品信息的字典 = %@",dict);
        
        NSString *errString = dict[@"err"];
        if(errString.intValue == 0)
        {
            NSArray *array = dict[@"goodsList"];
            
            
            for(NSDictionary *goodDict in array)
            {
                collectionDataBaseModel *model = [[collectionDataBaseModel alloc]init];
                [model setValuesForKeysWithDictionary:goodDict];
                [dc addCollectionRecordWithDicitionary:model recordType:RecoredTypeAttention];
                
            }
            //添加完毕后获取所有的记录
            NSArray *finalArray = [dc getCollectionRecordWithRecordType:RecoredTypeAttention];
            _dataArray = [[NSMutableArray alloc]init];
            for(long i = finalArray.count-1;i>=0;i--)
            {
                [_dataArray addObject:finalArray[i]];
            }
            if(_dataArray.count != 0)
            {
                [self downLoadCommodityDiscountData];
                
                [_tableView reloadData];
            }
            else
            {
                UILabel *label = [ZCControl createLabelWithFrame:CGRectMake(0, SCREENHEIGHT*0.2, SCREENWIDTH, SCREENHEIGHT*0.1) Font:SCREENWIDTH*0.048 Text:@"你还没有任何收藏商品哟，请先收藏商品吧"];
                label.textAlignment = NSTextAlignmentCenter;
                [self.view addSubview:label];
            }

        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}


#pragma mark-(查询商品最近最新的促销价格的数据)
-(void)downLoadCommodityDiscountData
{
    
    
    NSString *string = [NSString stringWithFormat:COMMODITYNEWDISCOUNTPRICEURL,DomainName];
   
    NSString *goodIDString = [[NSString alloc]init];
    for(int i = 0;i<_dataArray.count;i++)
    {
        collectionDataBaseModel *model = _dataArray[i];
        if(i == _dataArray.count-1)
        {
            goodIDString = [NSString stringWithFormat:@"gid=%d",model.gid.intValue];
        }
        else
        {
            goodIDString = [NSString stringWithFormat:@"gid=%d&",model.gid.intValue];
        }
        
        string = [string stringByAppendingString:goodIDString];
    }
     NSLog(@"商品最近促销价格的URL%@",string);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager GET:string parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSString *errString = dict[@"err"];
        if(errString.intValue == 0)
        {
            NSArray *array =dict[@"goodsList"];
            NSLog(@"商品促销价格数组%@",array);
            for(NSDictionary *goodDict in array)
            {
                collectionCommodityNewDiscountModel *model = [[collectionCommodityNewDiscountModel alloc]init];
                [model setValuesForKeysWithDictionary:goodDict];
                [_newDiscountArray addObject:model];
            }
            
            //刷新
            [_tableView reloadData];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

    }];
}


-(void)createTableView
{
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-64) style:UITableViewStyleGrouped];
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
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _dataArray.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"cell";
    firendDetailSecondTableViewCell  *cell  =[tableView dequeueReusableHeaderFooterViewWithIdentifier:cellID];
    if(cell == nil)
    {
        cell = [[firendDetailSecondTableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
    }
    //config cell
    //cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.YB_buttonDelegate = self;
    collectionDataBaseModel *model = _dataArray[indexPath.section];
    
    NSNumber *widthNumber = [[NSNumber alloc]initWithLong:(long)(SCREENWIDTH*0.25)];
    NSNumber *heightNumber = [[NSNumber alloc]initWithLong:(long)(SCREENHEIGHT*0.15*0.9)];
    
    [cell.iconImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@@%@w_%@h_1e_0l_1c",model.pic,widthNumber,heightNumber]]];
    cell.describtionLabel.text = model.desp;
    cell.discountImageView.image = [UIImage imageNamed:@"iconfont-arrowthindown"];
    if(_newDiscountArray.count != 0)
    {
    collectionCommodityNewDiscountModel *newDiscountModel = _newDiscountArray[indexPath.section];
    
    //价格下调的图片不存在
        NSString *newDiscountString = [NSString stringWithFormat:@"%@",newDiscountModel.promot ];
        NSString *discountString = [NSString stringWithFormat:@"%@",model.promot];
//        if(indexPath.section == 4)
//        {
//            NSLog(@"%@_________%@",newDiscountString,discountString);
//        }
        if([newDiscountString isEqualToString:@"(null)"]||[newDiscountString isEqualToString:@"<null>"])
    {
        if([discountString isEqualToString:@"(null)"]||[discountString isEqualToString:@"<null>"])
        {
            NSString *modelPriceNullString =[NSString stringWithFormat:@"%@",model.price];
            if([modelPriceNullString isEqualToString:@"(null)"])
            {
            
            }
            else if ([modelPriceNullString isEqualToString:@"<null>"])
            {
                
            }
            else
            {
                cell.discounLabel.text = [NSString stringWithFormat:@"￥%@",model.price];
            }
            //cell.discounLabel.text = @"";
            cell.lineImageView.hidden = YES;
            cell.discountImageView.hidden = YES;
        }
        else
        {
            cell.originalPriceLabel.text = [NSString stringWithFormat:@"￥%@",model.price];
            cell.discounLabel.text = [NSString stringWithFormat:@"￥%@",model.promot];
        }
    }
    //j价格下调的图片存在
    else
    {
        if([discountString isEqualToString:@"(null)"]||[discountString isEqualToString:@"<null>"])
        {
            cell.originalPriceLabel.text = [NSString stringWithFormat:@"￥%@",model.price];
            cell.discounLabel.text = [NSString stringWithFormat:@"￥%@",newDiscountModel.promot];
        }
        else
        {
            cell.originalPriceLabel.text = [NSString stringWithFormat:@"￥%@",model.promot];
            cell.discounLabel.text = [NSString stringWithFormat:@"￥%@",newDiscountModel.promot];
        }
    }
    }
    return cell;
    
}


//收藏和分享的按钮的点击
-(void)YBMyCollectionGoodsButtonDidClick:(UIButton *)button
{
    firendDetailSecondTableViewCell *cell = (firendDetailSecondTableViewCell *)[[button superview] superview];
    NSIndexPath *path = [_tableView indexPathForCell:cell];
    
    NSLog(@"我自己的收藏%@",path);
    
    collectionDataBaseModel *model = _dataArray[path.section];
    
    //与后台通讯
    NSString *urlString =[NSString stringWithFormat:COLLECTIONURL,DomainName,model.gid.intValue];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    
    //收藏
    if(button.tag == 201)
    {
        
        if([dc isExistCollectionRecordWithDicitionary:model recordType:RecoredTypeAttention])
        {
            
            //存在 删除收藏
            [manager DELETE:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
                NSLog(@"删除收藏的字典%@",dict);
                NSString *errString = dict[@"err"];
                if(errString.intValue == 0)
                {
                    [dc deleteCollectionRecordWithDicitionary:model recordType:RecoredTypeAttention];
                    [button setImage:[UIImage imageNamed:@"收藏_03-021@2x"] forState:UIControlStateNormal];
                }
                
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"err = %@",error);
            }];
        }
        else
        {
            //不存在 增加收藏
            [manager POST:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
                NSLog(@"增加收藏的字典%@",dict);
                NSString *errString = dict[@"err"];
                if(errString.intValue == 0)
                {
                    [dc addCollectionRecordWithDicitionary:model recordType:RecoredTypeAttention];
                    [button setImage:[UIImage imageNamed:@"收藏_03-02"] forState:UIControlStateNormal];
                }
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                
            }];
        }
    }
    //分享
    else if (button.tag == 202)
    {
        UITableViewCell *cell = (UITableViewCell *)[[button superview] superview];
        NSIndexPath *path = [_tableView indexPathForCell:cell];
        collectionDataBaseModel *model = _dataArray[path.section];
        //商品分享
        UIActionSheet *sharedSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"微信",@"新浪微博",@"QQ好友",@"朋友圈",@"短信消息", nil];
        [sharedSheet showInView:self.view];
    }
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.1f;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return SCREENHEIGHT*0.15;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return SCREENHEIGHT*0.01;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    //传入参数
    chatCollectionCommodtyDetailViewController *vc = [[chatCollectionCommodtyDetailViewController alloc]init];
    collectionDataBaseModel *model = _dataArray[indexPath.section];
    
    vc.shopIDString = model.sid;
    vc.goodsIDString = model.gid;
    vc.gnameString = self.gnameString;
    vc.invitationLabelString = self.invitationLabelString;
    vc.YB_delegate = self;
    
    [self.navigationController pushViewController:vc animated:YES];
}

//聊天的反向传值
-(void)YBchatCollectionDetailChatChangeGnameWithGname:(NSString *)gname andGroupName:(NSString *)groupName
{
    self.gnameString = gname;
    self.invitationLabelString = groupName;
    
    [self.YB_delegate YBMyCollectionChatChangeGnameWithGname:gname andGroupName:groupName];
}

-(void)createUINa
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    UILabel *titleLabel = [ZCControl createLabelWithFrame:CGRectMake(0, 0, 100, 30) Font:22 Text:@"收藏"];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = titleLabel;
    
    //导航栏左按钮
    UIButton *imageLeftButton  =[ZCControl createButtonWithFrame:CGRectMake(0, 0, 25, 20) ImageName:@"" Target:self Action:@selector(imageLeftItemBtn) Title:nil];
    [imageLeftButton setImage:[UIImage imageNamed:@"逛过_03"] forState:UIControlStateNormal];
    UIBarButtonItem *imageLeftItem = [[UIBarButtonItem alloc]initWithCustomView:imageLeftButton];
    self.navigationItem.leftBarButtonItem = imageLeftItem;
    
    //导航栏右按钮
    UIButton *imageRightButton = [ZCControl createButtonWithFrame:CGRectMake(0, 0, 20, 20) ImageName:@"" Target:self Action:@selector(cancelButtonBtn:) Title:nil];
    [imageRightButton setImage:[UIImage imageNamed:@"收藏_03"] forState:UIControlStateNormal];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:imageRightButton];
    self.navigationItem.rightBarButtonItem = rightItem;
    
}
-(void)imageLeftItemBtn
{
    [self.navigationController popViewControllerAnimated:YES];
}

//删除收藏
-(void)cancelButtonBtn:(UIButton *)button
{
    UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"清空所有收藏" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [al show];
}
//提醒alertView的代理
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)
    {
        return;
    }
    for(int i = 0;i<_dataArray.count;i++)
    {
        collectionDataBaseModel *model = _dataArray[i];
        NSString *urlString =[NSString stringWithFormat:COLLECTIONURL,DomainName,model.gid.intValue];
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
        
        //存在 删除收藏
        [manager DELETE:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            NSString *errString = dict[@"err"];
            if(errString.intValue == 0)
            {
                if(i == _dataArray.count-1)
                {
                    [dc deleteAllCollectionRecordWithRecordType:RecoredTypeAttention];
                    [_dataArray removeAllObjects];
                    [_tableView reloadData];
                }
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
        }];
    }
   
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
