//
//  miaomiaoChatGroupSettingViewController.m
//  ForwardOne
//
//  Created by 杨波 on 15/6/1.
//  Copyright (c) 2015年 杨波. All rights reserved.
//

#import "miaomiaoChatGroupSettingViewController.h"

#import "miaomiaoChatGroupSettingCollectionViewCell.h"
#import "MyCollectionHeaderView.h"
#import "MycollectionFooterView.h"

#import "invivateFriendsShoppingViewController.h"
#import "friendsDetailViewController.h"

#import "staticUserInfo.h"
#import "myAppDataBase.h"
#import "ASIFormDataRequest.h"

#import "danLiDataCenter.h"

#import "miaomiaoViewController.h"

#define GROUPINFORMATIONURL @"http://%@/chat/room/%@/info"

@interface miaomiaoChatGroupSettingViewController () <UICollectionViewDelegate,UICollectionViewDataSource,UIAlertViewDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,ASIHTTPRequestDelegate>
{
    UICollectionView *mycollectionView;
    
    NSMutableArray *nameArray;
    NSMutableArray *iconIamgeArray;
    
    UIView *bottomView;
    UILabel *nameLabel;
    UIImageView *iconImageView;
    UILabel *nameDetailLabel;
    
    YBWebSocketManager *socketManager;
}

@end

@implementation miaomiaoChatGroupSettingViewController

-(void)viewWillAppear:(BOOL)animated
{
    [self createData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    //单例 Socket
    socketManager = [YBWebSocketManager sharedInstance];
    
    [self createUINAv];
    
    [self createUICollectionView];
    
    //[self createBottomView];
    
    [self createBackGroupButton];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(hasExistGroup) name:@"existGroup" object:nil];
    
    //[self createData];
    
    // Do any additional setup after loading the view.
}
-(void)hasExistGroup
{
    UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"退出成功" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    al.tag = 200;
    [al show];
}

-(void)createData
{
    //nameArray = [[NSMutableArray alloc]initWithObjects:@"陈呆瓜",@"哈哈哈",@"嘿嘿嘿",@"呵呵呵",@"你妹啊",@"想什么呢",@"去死",@"不去",@"你这是",@"不着调",@"哈哈", nil];
    nameArray = [[NSMutableArray alloc]init];
    if(![self.usersIDString isEqualToString:@""])
    {
        //群聊
        NSArray *groupChatUsersArray = [self.usersIDString componentsSeparatedByString:@","];
        for(int i = 0; i<groupChatUsersArray.count;i++)
        {
            NSString *myIDString = [[NSUserDefaults standardUserDefaults]objectForKey:UserAccount];
            
            NSString *userIDString = [NSString stringWithFormat:@"%@",groupChatUsersArray[i]];
            if([myIDString isEqualToString:userIDString])
            {
                
            }
            else
            {
            NSDictionary *userInformationDict = [staticUserInfo getUserInformationWithUserID:userIDString];
            [nameArray addObject:userInformationDict];
            }
        }
        
    }
    else
    {
        //单聊
        NSDictionary *userInformationDict = [staticUserInfo getUserInformationWithUserID:self.senderIDString];
        [nameArray addObject:userInformationDict];
    }
    
    [bottomView removeFromSuperview];
    
    [self createBottomView];
    
    [mycollectionView reloadData];
}

-(void)createBackGroupButton
{
    
    UIButton *backGroupButton = [ZCControl createButtonWithFrame:CGRectMake(SCREENWIDTH*0.1, SCREENHEIGHT*0.75, SCREENWIDTH*0.8, SCREENHEIGHT*0.1) ImageName:@"" Target:self Action:@selector(backButtonBtn:) Title:@"退出群组"];
    [backGroupButton setBackgroundColor:[UIColor colorWithHexStr:@"#56d585"]];
    [self.view addSubview:backGroupButton];
}
-(void)backButtonBtn:(UIButton *)button
{
    if(![self.usersIDString isEqualToString:@""])
    {
        //[bottomView removeFromSuperview];
        //[self createBottomView];
        NSString *myIDString = [[NSUserDefaults standardUserDefaults]objectForKey:UserAccount];
        
        [socketManager YBExitGroupWithUser:myIDString andGname:self.gnameString];
    }
    else
    {
        UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"只有聊天组才能退出" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [al show];

    }
}

-(void)createBottomView
{
    UIImageView *firstLineImageView = [ZCControl createImageViewWithFrame:CGRectMake(0, SCREENHEIGHT*0.34, SCREENWIDTH, SCREENHEIGHT*0.02) ImageName:@""];
    firstLineImageView.backgroundColor = [UIColor colorWithHexStr:@"#eeeeee"];
    [self.view addSubview:firstLineImageView];
    
    
    bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, SCREENHEIGHT*0.4, SCREENWIDTH, SCREENHEIGHT*0.2)];
    //bottomView.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:bottomView];
    
    nameLabel = [ZCControl createLabelWithFrame:CGRectMake(5, 0, SCREENWIDTH*0.5, SCREENHEIGHT*0.2*0.3) Font:SCREENWIDTH*0.048 Text:@"名称"];
    //nameLabel.backgroundColor = [UIColor orangeColor];
    [bottomView addSubview:nameLabel];
    
    UIImageView *lineImageView = [ZCControl createImageViewWithFrame:CGRectMake(0, SCREENHEIGHT*0.2*0.3, SCREENWIDTH, 0.5) ImageName:nil];
    lineImageView.backgroundColor = [UIColor grayColor];
    [bottomView addSubview:lineImageView];
    
    UILabel *iconImageLabel = [ZCControl createLabelWithFrame:CGRectMake(5, SCREENHEIGHT*0.2*0.3, SCREENWIDTH*0.4, SCREENHEIGHT*0.2*0.7) Font:SCREENWIDTH*0.048 Text:@"头像"];
    [bottomView addSubview:iconImageLabel];
    
    iconImageView = [ZCControl createImageViewWithFrame:CGRectMake(SCREENWIDTH*0.75, SCREENHEIGHT*0.2*0.37, SCREENWIDTH*0.2, SCREENWIDTH*0.2) ImageName:@""];
    iconImageView.layer.cornerRadius = SCREENWIDTH*0.2/2;
    iconImageView.layer.masksToBounds = YES;
    [bottomView addSubview:iconImageView];
    
    nameDetailLabel = [ZCControl createLabelWithFrame:CGRectMake(SCREENWIDTH*0.25, 0, SCREENWIDTH*0.7, SCREENHEIGHT*0.2*0.3) Font:SCREENWIDTH*0.048 Text:@""];
    //nameDetailLabel.backgroundColor = [UIColor orangeColor];
    nameDetailLabel.textColor = [UIColor grayColor];
    nameDetailLabel.textAlignment = NSTextAlignmentRight;
    [bottomView addSubview:nameDetailLabel];
    
    if(![self.usersIDString isEqualToString:@""])
    {
        //群聊  从数据库中获取群聊的聊天名字以及头像
        NSDictionary *userInformation = [[myAppDataBase sharedInstance]getOneMiaoMiaoRecordWithGname:self.gnameString];
        [iconImageView sd_setImageWithURL:[NSURL URLWithString:userInformation[@"portrait"]]];
        nameDetailLabel.text = userInformation[@"name"];
        
    }
    else
    {
        NSDictionary *userInformation = nameArray[0];
        [iconImageView sd_setImageWithURL:[NSURL URLWithString:userInformation[@"portrait"]]];
        nameDetailLabel.text = userInformation[@"rmkName"];
        
    }
        
    //在修改群组名字和群组图片上面添加点击事件
    UIControl *groupNameControl = [[UIControl alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT*0.2*0.3)];
    [groupNameControl addTarget:self action:@selector(changeGroupName:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:groupNameControl];
    
    UIControl *groupImageControl = [[UIControl alloc]initWithFrame:CGRectMake(0, SCREENHEIGHT*0.2*0.3, SCREENWIDTH, SCREENHEIGHT*0.2*0.7)];
    [groupImageControl addTarget:self action:@selector(changeGroupImage:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:groupImageControl];
    
}

//点击更换讨论组名字
-(void)changeGroupName:(UIControl *)control
{
    if(![self.usersIDString isEqualToString:@""])
    {
    UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"请输入讨论组名称" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        al.tag = 100;
    al.alertViewStyle = UIAlertViewStylePlainTextInput;
    [al show];
    }
    else
    {
            UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"只有聊天组才能修改名称" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [al show];
    }
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if(buttonIndex == 0)
    {
        return;
    }
    if(alertView.tag == 100)
    {
    UITextField *textField = [alertView textFieldAtIndex:0];
    NSString *nickNameString = textField.text;
    //将更改之后群组的名字进行上传
        NSString *urlString = [NSString stringWithFormat:GROUPINFORMATIONURL,DomainName2,self.gnameString];
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
        [manager POST:urlString parameters:@{@"roomName":nickNameString} success:^(AFHTTPRequestOperation *operation, id responseObject) {
           
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            NSString *errString = dict[@"error"];
            if(errString.intValue == 0)
            {
                nameDetailLabel.text = nickNameString;
                
                //同时修改数据库中值
                [[myAppDataBase sharedInstance]upDateMiaoMiaoRecordGroupName:nickNameString withGname:self.gnameString];
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
           
            NSLog(@"err = %@",error);
            
        }];
        
    }
    if(alertView.tag == 200)
    {
        NSArray *array = self.navigationController.viewControllers;
        [self.navigationController popToViewController:array[1] animated:YES];
    }
    
}

//点击更换讨论组图片
-(void)changeGroupImage:(UIControl *)control
{
    if(![self.usersIDString isEqualToString:@""])
    {
    //头像选择 调用本地相册
    UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"相机",@"相册", nil];
    [sheet showInView:self.view];
    }
    else
    {
        UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"只有聊天组才能修改头像" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [al show];
    }
}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 2)
    {
        return;
    }
    UIImagePickerController *picker = [[UIImagePickerController alloc]init];
    if(buttonIndex == 0)
    {
        //相机
        if([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront])
        {
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        }
    }
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];

}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //得到选择图片的数据 然后进行上传
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    //保存本地 跟新操作
    NSData *groupImageData = UIImageJPEGRepresentation(image, 0.1);
    
    //先把图片上传到服务器得到图片URL 然后把图片URL上传到服务器
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentsDirectory = [paths objectAtIndex:0];
    NSString* fullPathToFile = [documentsDirectory stringByAppendingPathComponent:@"groupImage.png"];
    [groupImageData writeToFile:fullPathToFile atomically:YES];
    NSURL*url=[NSURL URLWithString:@"http://chat.immbear.com:8889/file/uploader"];
    ASIFormDataRequest*logpicrequest=[ASIFormDataRequest requestWithURL:url];
    logpicrequest.delegate=self;
    [groupImageData writeToFile:fullPathToFile atomically:NO];
    [logpicrequest setFile:fullPathToFile forKey:@"uploadFile"];
    // [logpicrequest   setData:imageData forKey:@"cont"];
    logpicrequest.tag=115;
    [logpicrequest startAsynchronous];//异步开始

    [self dismissViewControllerAnimated:YES completion:nil];
    
}
-(void)requestFinished:(ASIHTTPRequest *)request
{
    if(request.tag == 115)
    {
        NSDictionary *picDict = [request.responseString objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode];
        //NSLog(@"返回图片字典%@",picDict);
        
        //将图片URL上传服务器
        NSString *picUrlString = picDict[@"url"];
        NSString *urlString = [NSString stringWithFormat:GROUPINFORMATIONURL,DomainName2,self.gnameString];
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
        [manager POST:urlString parameters:@{@"roomImg":picUrlString} success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            NSString *errString = dict[@"error"];
            if(errString.intValue == 0)
            {
                [iconImageView sd_setImageWithURL:[NSURL URLWithString:picUrlString]];
                //同时修改数据库里面的值
                [[myAppDataBase sharedInstance]upDateMiaoMiaoRecordGroupImage:picUrlString withGname:self.gnameString];
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            NSLog(@"err = %@",error);
            
        }];

    }
    
}


-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}



-(void)createUICollectionView
{
    UIView *topView = [[UIView alloc]initWithFrame:CGRectMake(0, 5, SCREENWIDTH, SCREENHEIGHT*0.3)];
    topView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:topView];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
    flowLayout.minimumInteritemSpacing = 5;
    flowLayout.minimumLineSpacing = 5;
    flowLayout.itemSize = CGSizeMake((SCREENWIDTH-30)/5, SCREENHEIGHT*0.3*0.45);
    
    mycollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(5, 5, SCREENWIDTH-10, SCREENHEIGHT*0.3) collectionViewLayout:flowLayout];
    mycollectionView.backgroundColor = [UIColor whiteColor];
    mycollectionView.showsHorizontalScrollIndicator = NO;
    mycollectionView.showsVerticalScrollIndicator = NO;
    mycollectionView.userInteractionEnabled = YES;
    mycollectionView.delegate = self;
    mycollectionView.dataSource = self;
    
    [mycollectionView registerClass:[miaomiaoChatGroupSettingCollectionViewCell class] forCellWithReuseIdentifier:@"CellReuseIdentifier"];
    [mycollectionView registerClass:[MyCollectionHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderIdentifier"];
    [mycollectionView registerClass:[MycollectionFooterView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterIdentifier"];
    [topView addSubview:mycollectionView];
    
    
}
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return nameArray.count+1;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == nameArray.count )
    {
    static NSString *cellIdentifier = @"CellReuseIdentifier";
    miaomiaoChatGroupSettingCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.nameLabel.text = @"";
        
    cell.iconImageView.image = [UIImage imageNamed:@"消息_03"];
    return cell;
    }
    else
    {
        static NSString *cellIdentifier = @"CellReuseIdentifier";
        miaomiaoChatGroupSettingCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
        NSDictionary *dict = nameArray[indexPath.row];
        if([[dict allKeys]containsObject:@"rmkName"])
        {
            if(![dict[@"rmkName"] isEqualToString:@""])
            {
             cell.nameLabel.text = dict[@"rmkName"];
            }
            else
            {
                cell.nameLabel.text = dict[@"nickName"];
            }
        }
        else
        {
            cell.nameLabel.text = dict[@"nickName"];
        }
        [cell.iconImageView sd_setImageWithURL:[NSURL URLWithString:dict[@"portrait"]]];
        return cell;
    }
}
//每个cell的点击处理方法
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //[collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    if(indexPath.row == nameArray.count)
    {
        invivateFriendsShoppingViewController *ivc = [[invivateFriendsShoppingViewController alloc]init];
        ivc.usersIDString = self.usersIDString;
        ivc.senderIDString = self.senderIDString;
        ivc.gnameString = self.gnameString;
        [self.navigationController pushViewController:ivc animated:YES];
    }
    else
    {
        friendsDetailViewController *fdvc = [[friendsDetailViewController alloc]init];
        NSDictionary *userInformationDict = nameArray[indexPath.row];
        danLiDataCenter *dc = [danLiDataCenter sharedInstance];
        //进行单例传值(下载好友收藏粉丝店等数据)
        if([[userInformationDict allKeys]containsObject:@"frdID"])
        {
          fdvc.frdIDString = userInformationDict[@"frdID"];
          dc.frdIDString = userInformationDict[@"frdID"];
        }
        else
        {
            NSString *passagerIDString = [NSString stringWithFormat:@"%@",userInformationDict[@"userID"]];
            
            fdvc.frdIDString = passagerIDString;
            dc.frdIDString = passagerIDString;
        }
        fdvc.gnameString = self.gnameString;
        fdvc.invitationLabelString = self.invitationLabelString;
        
        [self.navigationController pushViewController:fdvc animated:YES];
    }
}


-(void)createUINAv
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    UILabel *titleLabel = [ZCControl createLabelWithFrame:CGRectMake(0, 0, 100, 30) Font:22 Text:@"群组设置"];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = titleLabel;
    
    UIButton *imageLeftButton  =[ZCControl createButtonWithFrame:CGRectMake(0, 0, 25, 20) ImageName:@"" Target:self Action:@selector(imageLeftItemBtn) Title:nil];
    [imageLeftButton setImage:[UIImage imageNamed:@"店铺-店铺详情_03"] forState:UIControlStateNormal];
    UIBarButtonItem *imageLeftItem = [[UIBarButtonItem alloc]initWithCustomView:imageLeftButton];
    self.navigationItem.leftBarButtonItem = imageLeftItem;
}

//导航栏左按钮的点击
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
