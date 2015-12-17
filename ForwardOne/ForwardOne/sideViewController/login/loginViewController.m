//
//  loginViewController.m
//  ForwardOne
//
//  Created by 杨波 on 15/5/14.
//  Copyright (c) 2015年 杨波. All rights reserved.
//

#import "loginViewController.h"
#import "findPassWordViewController.h"
#import "registerViewController.h"

#import "YBWebSocketManager.h"
#import "myAppDataBase.h"

#import "utils.h"
#import "OpenUDID.h"
#import "NSString+Hashing.h"

#define LOGINURL @"http://%@/user/login"

//个人信息的URL
#define PERSONALINFORMATION @"http://%@/user/personal"

@interface loginViewController () <UITextFieldDelegate,UIAlertViewDelegate>
{
    UITextField *phoneTextField;
    UITextField *passWordTextField;
    
    YBWebSocketManager *socketManager;
    myAppDataBase *dc;
}
@end

@implementation loginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createUINav];
    
    [self createTextUI];
    
    
    
    //添加手势 回收键盘
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dealWithTap:)];
    [self.view addGestureRecognizer:tap];
 
    // Do any additional setup after loading the view.
}
-(void)dealWithTap:(UITapGestureRecognizer *)tap

{
    [phoneTextField resignFirstResponder];
    [passWordTextField resignFirstResponder];
}


-(void)createTextUI
{
    
    //logo
    UIImageView *logoImageView = [ZCControl createImageViewWithFrame:CGRectMake(SCREENWIDTH*0.25, SCREENHEIGHT*0.025, SCREENWIDTH*0.5, SCREENHEIGHT*0.15) ImageName:@""];
    logoImageView.backgroundColor = [UIColor whiteColor];
    //[self.view addSubview:logoImageView];
    
    
    //忘记密码
    UIButton *forgetPassWordButton = [ZCControl createButtonWithFrame:CGRectMake(SCREENWIDTH*0.1, SCREENHEIGHT*0.32, SCREENWIDTH*0.3, SCREENHEIGHT*0.05) ImageName:nil Target:self Action:@selector(forgetButtonBtn:) Title:@"忘记密码？"];
    [forgetPassWordButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view addSubview:forgetPassWordButton];
    
    //注册
    UIButton *registerButton = [ZCControl createButtonWithFrame:CGRectMake(SCREENWIDTH*0.7, SCREENHEIGHT*0.32, SCREENWIDTH*0.3, SCREENHEIGHT*0.05) ImageName:nil Target:self Action:@selector(registerButtonBtn:) Title:@"注册"];
    [registerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view addSubview:registerButton];
    
    UIView *textFiledView = [[UIView alloc]initWithFrame:CGRectMake(SCREENWIDTH*0.1, SCREENHEIGHT*0.2, SCREENWIDTH*0.8, SCREENHEIGHT*0.12)];
    textFiledView.backgroundColor = [UIColor whiteColor];
    textFiledView.layer.cornerRadius = 10;
    textFiledView.layer.masksToBounds = YES;
    [self.view addSubview:textFiledView];
    
    //手机
    UIImageView *phoneLeftImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH*0.1, SCREENHEIGHT*0.04)];
    phoneLeftImageView.image = [UIImage imageNamed:@"登陆_03"];
    phoneTextField = [ZCControl createTextFieldWithFrame:CGRectMake(0, 0, SCREENWIDTH*0.8, SCREENHEIGHT*0.06) placeholder:@"手机" passWord:NO leftImageView:phoneLeftImageView rightImageView:nil Font:SCREENWIDTH*0.048];
    phoneTextField.delegate = self;
    phoneTextField.background = [UIImage imageNamed:@"54"];
    //phoneTextField.backgroundColor = [UIColor whiteColor];
    phoneTextField.borderStyle = UITextBorderStyleRoundedRect;
    [textFiledView addSubview:phoneTextField];
    
    //密码
    UIImageView *passWordLeftImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH*0.1, SCREENHEIGHT*0.04)];
    passWordLeftImageView.image = [UIImage imageNamed:@"登陆_03-02"];
    
    passWordTextField = [ZCControl createTextFieldWithFrame:CGRectMake(0, SCREENHEIGHT*0.06, SCREENWIDTH*0.8, SCREENHEIGHT*0.06) placeholder:@"密码" passWord:YES leftImageView:passWordLeftImageView rightImageView:nil Font:SCREENWIDTH*0.048];
    passWordTextField.delegate = self;
    passWordTextField.background = [UIImage imageNamed:@"54"];
   // passWordTextField.backgroundColor = [UIColor whiteColor];
   passWordTextField.borderStyle = UITextBorderStyleRoundedRect;
    [textFiledView addSubview:passWordTextField];
    
    //登录
    UIButton *loginButton = [ZCControl createButtonWithFrame:CGRectMake(SCREENWIDTH*0.1, SCREENHEIGHT*0.4, SCREENWIDTH*0.8, SCREENHEIGHT*0.08) ImageName:@"" Target:self Action:@selector(loginButtonBtn:) Title:@"登录"];
    [loginButton setBackgroundColor:[UIColor colorWithHexStr:@"#56d585"]];
    loginButton.layer.cornerRadius = 10;
    loginButton.layer.masksToBounds = YES;
    [self.view addSubview:loginButton];
    
    UILabel *thirdLoginLabel = [ZCControl createLabelWithFrame:CGRectMake(0, SCREENHEIGHT*0.5, SCREENWIDTH, SCREENHEIGHT*0.05) Font:SCREENWIDTH*0.048 Text:@"第三方账号快速登录"];
    thirdLoginLabel.textColor = [UIColor whiteColor];
    thirdLoginLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:thirdLoginLabel];
    
    //QQ登录
    UIButton *QQ = [ZCControl createButtonWithFrame:CGRectMake(SCREENWIDTH*0.1, SCREENHEIGHT*0.57, SCREENWIDTH*0.2, SCREENWIDTH*0.2) ImageName:@"" Target:self Action:@selector(QQBtn:) Title:@""];

    
    [QQ setImage:[UIImage imageNamed:@"2"] forState:UIControlStateNormal];
    [self.view addSubview:QQ];
    
    //微信登录
    UIButton *weiChat = [ZCControl createButtonWithFrame:CGRectMake(SCREENWIDTH*0.4, SCREENHEIGHT*0.57, SCREENWIDTH*0.2, SCREENWIDTH*0.2) ImageName:@"" Target:self Action:@selector(weiChatBtn:) Title:@""];
    [weiChat setImage:[UIImage imageNamed:@"1"] forState:UIControlStateNormal];
    [self.view addSubview:weiChat];
    
    //微博登录
    UIButton *weibo = [ZCControl createButtonWithFrame:CGRectMake(SCREENWIDTH*0.7, SCREENHEIGHT*0.57, SCREENWIDTH*0.2, SCREENWIDTH*0.2) ImageName:@"" Target:self Action:@selector(weiboBtn:) Title:@""];
    [weibo setImage:[UIImage imageNamed:@"4"] forState:UIControlStateNormal];
    [self.view addSubview:weibo];
    
}
//微博登录
-(void)weiboBtn:(UIButton *)button
{
    
}
//微信登录
-(void)weiChatBtn:(UIButton *)button
{

}

//QQ登录
-(void)QQBtn:(UIButton *)button
{
    
}

//登录
-(void)loginButtonBtn:(UIButton *)button
{
    //登录前对手机号码以及密码的合法性进行判断
    if([utils validateMobile:phoneTextField.text])
    {
        NSString *loginString = [NSString stringWithFormat:LOGINURL,DomainName];
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
        NSString *nowUserDevice = [OpenUDID value];
        NSString *passWordString = [passWordTextField.text MD5Hash];
        //NSLog(@"_______________%@",passWordString);
        NSDictionary *loginDict = @{@"mode":@"2",@"type":@"4",@"account":@"",@"email":@"",@"phone":phoneTextField.text,@"password":passWordString,@"dev":nowUserDevice};
        [manager POST:loginString parameters:loginDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSDictionary *loginResponseDict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            NSLog(@"登录的字典%@",loginResponseDict);
            NSString *loginErrString = loginResponseDict[@"err"];
            if(loginErrString.intValue == 0)
            {
                //登录成功保存上次登录的设备
                [[NSUserDefaults standardUserDefaults]setObject:loginResponseDict[@"dev"] forKey:UserDevice];
                [[NSUserDefaults standardUserDefaults]setObject:@"login" forKey:IsLogin];
                
                NSString *myAccountString = [NSString stringWithFormat:@"%@",loginResponseDict[@"accID"]];
                
                [[NSUserDefaults standardUserDefaults]setObject:myAccountString forKey:UserAccount];
                [[NSUserDefaults standardUserDefaults]setObject:phoneTextField.text forKey:UserPhone];
                [[NSUserDefaults standardUserDefaults]setObject:passWordTextField.text forKey:UserPassword];
                
                //[[NSUserDefaults standardUserDefaults]setObject:@"我" forKey:MyNickName];
                
                [[NSUserDefaults standardUserDefaults]synchronize];
                
                
                
                NSString *getPersonalInformationString = [NSString stringWithFormat:PERSONALINFORMATION,DomainName];
                //NSLog(@"个人信息%@",getPersonalInformationString);
                AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
                manager.responseSerializer = [AFHTTPResponseSerializer serializer];
                [manager GET:getPersonalInformationString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    
                    NSDictionary *informationDict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
                    
                    NSString *informationErrString = informationDict[@"err"];
                    if(informationErrString.intValue == 0)
                    {
                        NSMutableDictionary *informationDetailDict = informationDict[@"info"];

                        
                        //存储自己的个人头像URL
                        [[NSUserDefaults standardUserDefaults]setObject:informationDetailDict[@"portrait"] forKey:MyPhotoImageURL];
                        [[NSUserDefaults standardUserDefaults]setObject:informationDetailDict[@"name"] forKey:MyNickName];
                        [[NSUserDefaults standardUserDefaults]synchronize];
                    }
                    
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    
                }];

                
                
                //创建并打开与用户相关的数据库
                [[myAppDataBase sharedInstance]openDataBase];
                
                //登录成功建立webSocket连接
                socketManager = [YBWebSocketManager sharedInstance];
                [socketManager openChatSocket];
               
                
                
                UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"登录成功" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                al.tag = 600;
                [al show];
            }
            else
            {
                UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"登录失败" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                [al show];
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"登录失败" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            [al show];
        }];
        
    }
    else
    {
        UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"请输入正确手机号" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [al show];
    }
    
    
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 600)
    {
        if(buttonIndex  == 1)
        {
            NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
            [nc postNotificationName:@"changeLogin" object:nil userInfo:nil];
            
        //NSArray *arrayController = self.navigationController.viewControllers;
            [self.navigationController popViewControllerAnimated:YES];
        //[self.navigationController popToViewController:arrayController[0] animated:YES];
        }
    }
}

////webSocket协议内容
//-(void)webSocketDidOpen:(SRWebSocket *)webSocket
//{
//    
//}
//-(void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean
//{
//    
//}
//-(void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error
//{
//    
//}
//-(void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message
//{
//    
//}
//注册
-(void)registerButtonBtn:(UIButton *)button
{
    registerViewController *rvc = [[registerViewController alloc]init];
    [self.navigationController pushViewController:rvc animated:YES];
    
}

//忘记密码
-(void)forgetButtonBtn:(UIButton *)button
{
    findPassWordViewController *fvc = [[findPassWordViewController alloc]init];
    [self.navigationController pushViewController:fvc animated:YES];
}

//键盘代理
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
    

-(void)createUINav
{
    self.view.backgroundColor = [UIColor colorWithHexStr:@"#555555"];
    UILabel *titleLabel = [ZCControl createLabelWithFrame:CGRectMake(0, 0, 100, 30) Font:22 Text:@"登录"];
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
