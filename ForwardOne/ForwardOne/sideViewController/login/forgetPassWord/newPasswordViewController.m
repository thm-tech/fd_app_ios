//
//  newPasswordViewController.m
//  ForwardOne
//
//  Created by 杨波 on 15/5/14.
//  Copyright (c) 2015年 杨波. All rights reserved.
//

#import "newPasswordViewController.h"

#import "loginViewController.h"
#import "ViewController.h"
#import "NSString+Hashing.h"
#import "utils.h"


#define NEWPASSWORDURL @"http://%@/user/resetpw"


@interface newPasswordViewController () <UITextFieldDelegate,UIAlertViewDelegate>
{
    UITextField *newPassWordTextField;
    UITextField *confirmNewPassWordTextField;
}
@end

@implementation newPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createUINAv];
    
    [self createTextUI];
    
    //添加手势 回收键盘
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dealWithTap:)];
    [self.view addGestureRecognizer:tap];
    
    // Do any additional setup after loading the view.
}
-(void)dealWithTap:(UITapGestureRecognizer *)tap

{
    [newPassWordTextField resignFirstResponder];
    [confirmNewPassWordTextField resignFirstResponder];
    
}

-(void)createTextUI
{
    UIView *textFiledView = [[UIView alloc]initWithFrame:CGRectMake(SCREENWIDTH*0.1, SCREENHEIGHT*0.2, SCREENWIDTH*0.8, SCREENHEIGHT*0.12)];
    textFiledView.backgroundColor = [UIColor whiteColor];
    textFiledView.layer.cornerRadius = 10;
    textFiledView.layer.masksToBounds = YES;
    [self.view addSubview:textFiledView];
    
    newPassWordTextField = [ZCControl createTextFieldWithFrame:CGRectMake(0, 0, SCREENWIDTH*0.8, SCREENHEIGHT*0.06) placeholder:@"新密码" passWord:NO leftImageView:nil rightImageView:nil Font:SCREENWIDTH*0.048];
    newPassWordTextField.delegate  =self;
    newPassWordTextField.borderStyle = UITextBorderStyleRoundedRect;
    [textFiledView addSubview:newPassWordTextField];
    
    
    confirmNewPassWordTextField = [ZCControl createTextFieldWithFrame:CGRectMake(0, SCREENHEIGHT*0.06, SCREENWIDTH*0.8, SCREENHEIGHT*0.06) placeholder:@"确认新密码" passWord:NO leftImageView:nil rightImageView:nil Font:SCREENWIDTH*0.048];
    confirmNewPassWordTextField.borderStyle = UITextBorderStyleRoundedRect;
    confirmNewPassWordTextField.delegate = self;
    confirmNewPassWordTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    [textFiledView addSubview:confirmNewPassWordTextField];
    
    UIButton *commitButton = [ZCControl createButtonWithFrame:CGRectMake(SCREENWIDTH*0.1, SCREENHEIGHT*0.36, SCREENWIDTH*0.8, SCREENHEIGHT*0.08) ImageName:@"btn_login_bg_2@2" Target:self Action:@selector(commitButtonBtn:) Title:@"提交"];
    commitButton.backgroundColor = [UIColor colorWithHexStr:@"#56b585"];
    commitButton.layer.cornerRadius = 10;
    commitButton.layer.masksToBounds = YES;
    [self.view addSubview:commitButton];

}
-(void)commitButtonBtn:(UIButton *)button
{
//    NSArray *arrayController = self.navigationController.viewControllers;
//    [self.navigationController popToViewController:arrayController[1] animated:YES];
    
    //判断密码是否合法
    if([utils validatePassword:newPassWordTextField.text])
    {
        //判断两次的密码是否一致
        if([newPassWordTextField.text isEqualToString:confirmNewPassWordTextField.text])
        {
            NSString *newPasswordString = [NSString stringWithFormat:NEWPASSWORDURL,DomainName];
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            manager.responseSerializer = [AFHTTPResponseSerializer serializer];
            manager.requestSerializer = [AFJSONRequestSerializer serializer];
            manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
            NSString *md5String = [newPassWordTextField.text MD5Hash];
            NSLog(@"______%@",self.findPasswordPhoneString);
            
            [manager POST:newPasswordString parameters:@{@"phone":self.findPasswordPhoneString,@"password":md5String} success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
                NSLog(@"重置密码的字典%@",dict);
                NSString *errString = dict[@"err"];
                if(errString.intValue == 0)
                {
                    UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"提交成功，请重新登录" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                    al.tag = 300;
                    [al show];
                    
                }
                else
                {
                    UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"提交失败" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                    [al show];
                }
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                
                UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"提交失败" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                [al show];
                
            }];
            
            
        }
        else
        {
            UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"密码不一致，请重新输入" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            [al show];
        }
    }
    else
    {
        UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"请输入6位以上密码" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [al show];
    }
    
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 300)
    {
        if(buttonIndex == 1)
        {
            NSArray *arrayController = self.navigationController.viewControllers;
            [self.navigationController popToViewController:arrayController[1] animated:YES];
        }
    }
}

//键盘回收代理
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


-(void)createUINAv
{
    self.view.backgroundColor = [UIColor colorWithHexStr:@"#555555"];
    UILabel *titleLabel = [ZCControl createLabelWithFrame:CGRectMake(0, 0, 100, 30) Font:22 Text:@"重设密码"];
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
