//
//  addFirendsViewController.m
//  ForwardOne
//
//  Created by 杨波 on 15/5/7.
//  Copyright (c) 2015年 杨波. All rights reserved.
//

#import "addFirendsViewController.h"
#import "ZCZBarViewController.h"
#import "ZCAddressBook.h"

#import "myPhoneAddressViewController.h"

#import "utils.h"

#import "danLiDataCenter.h"

#define ADDFRIENDSURL @"http://%@/user/friend/invite"

#import "shopInformationViewController.h"
#import "friendsDetailViewController.h"

@interface addFirendsViewController ()<UITextFieldDelegate,UIGestureRecognizerDelegate,UIAlertViewDelegate,UITableViewDelegate,UITableViewDataSource,YBFriendDetailChatDelegate,YBShopInformationChangeGnameDelegate>
{
    UITextField *_textField;
    UITableView *_tableView;
    NSArray *_titleArray;
    NSArray *_imageArray;
}
@end

@implementation addFirendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createUINav];
    
    [self createTextUI];
    
    [self createLocalDataArray];
    
    // Do any additional setup after loading the view.
}
-(void)createLocalDataArray
{
    _titleArray = [[NSArray alloc]init];
    _imageArray = [[NSArray alloc]init];
    
    _titleArray = @[@"扫一扫",@"通讯录"];
    _imageArray = @[@"好友-添加好友_03",@"好友-添加好友_03-02"];
    
    [_tableView reloadData];
}

-(void)createTextUI
{
    UIView *backView = [[UIView alloc]initWithFrame:CGRectMake(0, SCREENHEIGHT*0.03, SCREENWIDTH, SCREENHEIGHT*0.08)];
    backView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:backView];
    
    _textField = [ZCControl createTextFieldWithFrame:CGRectMake(0, 0, SCREENWIDTH*0.7, SCREENHEIGHT*0.08) placeholder:@"手机号" passWord:NO leftImageView:nil rightImageView:nil Font:SCREENWIDTH*0.048];
    _textField.borderStyle = UITextBorderStyleRoundedRect;
    _textField.returnKeyType = UIReturnKeyDone;
    _textField.delegate = self;
    [backView addSubview:_textField];
    
    UIButton *addButton = [ZCControl createButtonWithFrame:CGRectMake(SCREENWIDTH*0.7, 0, SCREENWIDTH*0.3, SCREENHEIGHT*0.08) ImageName:@"" Target:self Action:@selector(addButtonBtn:) Title:@"确定"];
    addButton.backgroundColor = [UIColor whiteColor];
    [addButton setTitleColor:[UIColor colorWithHexStr:@"#56b585"] forState:UIControlStateNormal];
    [backView addSubview:addButton];
    
    //创建tableView
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, SCREENHEIGHT*0.15,SCREENWIDTH,SCREENHEIGHT*0.16) style:UITableViewStyleGrouped];
    _tableView.scrollEnabled = NO;
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
    
    //添加手势 回收键盘
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dealWithTap:)];
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];

}
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return NO;
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
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"cell";
    UITableViewCell  *cell  =[tableView dequeueReusableHeaderFooterViewWithIdentifier:cellID];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
    }
    //config cell
    cell.textLabel.text = _titleArray[indexPath.row];
    cell.imageView.image = [UIImage imageNamed:_imageArray[indexPath.row]];
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return SCREENHEIGHT*0.08;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.1f;
}



//cell上面的点击事件
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.row == 0)
    {
        ZCZBarViewController *vc = [[ZCZBarViewController alloc]initWithBlock:^(NSString *str, BOOL isFinish) {
            if(isFinish)
            {
                NSLog(@"扫描过后的结果%@",str);
                
                NSString *subString = [str substringFromIndex:28];
                
                //对扫描的结果进行处理
                //1.当扫描的是商家店铺时候 跳入商家店铺详情界面  2.当扫描用户二维码的时候 跳入添加好友界面
                if([str rangeOfString:@"user"].location != NSNotFound)
                {
                    //扫描用户的
                    danLiDataCenter *dc = [danLiDataCenter sharedInstance];
                    friendsDetailViewController *fvc =[[friendsDetailViewController alloc]init];
                    fvc.frdIDString = subString;
                    dc.frdIDString = subString;
                    fvc.gnameString = self.gnameString;
                    fvc.invitationLabelString = self.invitationLabelString;
                    fvc.YB_delegate = self;
                    
                    [self.navigationController pushViewController:fvc animated:YES];
                }
                if([str rangeOfString:@"shop"].location != NSNotFound)
                {
                    //扫描商家的
                    shopInformationViewController *sfvc = [[shopInformationViewController alloc]init];
                    sfvc.shopIDString = subString;
                    sfvc.gnameString = self.gnameString;
                    sfvc.invitationLabelString = self.invitationLabelString;
                    sfvc.YB_delegate = self;
                    
                    [self.navigationController pushViewController:sfvc animated:YES];
                }
            }
        }];
        
        [self presentViewController:vc animated:YES completion:nil];
        
    }
    else
    {
        //获取vCard
//        NSMutableDictionary *dict = [[ZCAddressBook shareControl]getPersonInfo];
//        
//        //获取索引
//        NSArray *array = [[ZCAddressBook shareControl]sortMethod];
//        
//        
//        NSLog(@"好友字典为————%@  索引为————————%@",dict,array);
        
        //通过访问系统通讯录的联系人的信息来构建界面
        myPhoneAddressViewController *vc = [[myPhoneAddressViewController alloc]init];
        [self.navigationController pushViewController:vc animated:YES];
    }
}
//二维码扫描的界面聊天的反向传值 (好友二维码)
-(void)YBYBFriendDetailChatWithGname:(NSString *)gname andGroupName:(NSString *)groupName
{
    [self.YB_delegate YBAddFriendChatChangGnameWith:gname andGroupName:groupName];
}
//二维码扫描的界面聊天的反向传值 (商店二维码)
-(void)YBShopInformationChangeGnameWithGname:(NSString *)gname andGroupName:(NSString *)groupName
{
    [self.YB_delegate YBAddFriendChatChangGnameWith:gname andGroupName:groupName];
}

-(void)dealWithTap:(UITapGestureRecognizer *)tap
{
    [_textField resignFirstResponder];
}

//通过手机号码/喵喵号 添加好友
-(void)addButtonBtn:(UIButton *)button
{
    [_textField resignFirstResponder];
    
   if([utils validateMobile:_textField.text])
   {
       //添加好友 自己的备注信息
       UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"请输入备注信息" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
       al.alertViewStyle = UIAlertViewStylePlainTextInput;
       al.tag = 750;
       [al show];
   }
    else
    {
        UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"请输入正确的手机号" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [al show];
    }
}

//填写备注之后的提醒视图代理
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 750)
    {
        if(buttonIndex == 1)
        {
            //向后台post
            NSString *addFriendsString = [NSString stringWithFormat:ADDFRIENDSURL,DomainName];
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            //manager.responseSerializer = [AFHTTPResponseSerializer serializer];
            manager.responseSerializer = [AFHTTPResponseSerializer serializer];
            manager.requestSerializer = [AFJSONRequestSerializer serializer];
            manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
            UITextField *noteTextField = [alertView textFieldAtIndex:0];
            NSString *noteString = noteTextField.text;
            //需要对添加好友的方式进行判断
            NSDictionary *parameterDict = [[NSDictionary alloc]init];
            //用手机号码添加好友
//            if([utils validateMobile:_textField.text])
//            {
            NSNumber *modeNumber = [[NSNumber alloc]initWithInt:1];
            
                parameterDict = @{@"mode":modeNumber,@"phone":_textField.text,@"remark":noteString};
            //}
            //用喵喵号添加好友
//            else
//            {
//                parameterDict = @{@"mode":@"2",@"mcode":_textField.text,@"remark":noteString};
//            }
            [manager POST:addFriendsString parameters:parameterDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                //解析
                NSDictionary *addFriendDict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
                NSLog(@"添加好友结果字典%@",addFriendDict);
                NSString *errString = addFriendDict[@"is_success"];
                NSString *desString = addFriendDict[@"des"];
                if([desString isEqualToString:@"This User is already your friend!"])
                {
                    UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"此用户已经是你的好友啦" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                    [al show];
                }
                else if ([desString isEqualToString:@"This phone master is not our user, but we has send a phone message to him/her"])
                {
                    UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"此用户不是我们app用户哟，但是我们已经发送邀请信息给他啦" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                    [al show];
                }
                
                else if(errString.intValue == 0)
                {
                    UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"请求发送成功，请等待回复" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                    [al show];
                }
                else
                {
                //通过手机号码添加好友 当手机号码对应的用户不存在的时候 提示是否邀请安装
//                    UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"该用户未安装喵喵熊，是否邀请安装" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
//                    al.tag = 850;
//                    [al show];
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"添加好友失败" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                [al show];
            }];
            
        }
    }
    
    //短信邀请好友使用喵喵熊
    if(alertView.tag == 850)
    {
        UIApplication *app = [UIApplication sharedApplication];
        [app openURL:[NSURL URLWithString:[NSString stringWithFormat:@"sms://%@",_textField.text]]];
    }
    
}
    
//键盘代理
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void)createUINav
{
    self.view.backgroundColor = [UIColor colorWithHexStr:@"#eeeeee"];
    
    UILabel *titleLabel = [ZCControl createLabelWithFrame:CGRectMake(0, 0, 100, 30) Font:22 Text:@"加好友"];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = titleLabel;
    
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
