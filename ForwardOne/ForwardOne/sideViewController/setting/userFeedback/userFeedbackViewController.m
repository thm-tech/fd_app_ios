//
//  userFeedbackViewController.m
//  ForwardOne
//
//  Created by 杨波 on 15/5/9.
//  Copyright (c) 2015年 杨波. All rights reserved.
//

#import "userFeedbackViewController.h"
#import "TouchDownGestureRecognizer.h"

//用户反馈URL
#define USERFEEDBACKURL @"http://%@/user/feedback?offset=%d&count=%d"


@interface userFeedbackViewController () <UITextViewDelegate,UITextFieldDelegate,UIGestureRecognizerDelegate>
{
     UITableView *_tableView;
    UITextField *feedTextField ;
    UIButton *sendButton;
    
    //反馈的数据源
    NSMutableArray *_feedBackArray;
    int offset;
    int count;
    
}
- (void)p_tapOnTableView:(UIGestureRecognizer*)sender;

@end

@implementation userFeedbackViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
//    __weak typeof(self) weakSelf = self;
//    if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)])
//    {
//        self.navigationController.interactivePopGestureRecognizer.delegate = weakSelf;
//    }
    
    [self createUINa];
    
    [self createChatTableView];
    
    [self createTextUI];
    
    //添加监听的事件
    [self addNotificationCenter];
    
    //聊天相关的数据
    [self loadChatData];
    
    // Do any additional setup after loading the view.
}
-(void)addNotificationCenter
{
    //通知的监听的处理事件
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleWillShowKeyboard:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleWillHideKeyboard:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    //当键盘出现的时候 tableView的高度改变 然后 tableView滚动到底部
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(tableViewScrollToBottom) name:UIKeyboardDidShowNotification object:nil];
    
    //添加轻击和拖移的手势去回收键盘
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(p_tapOnTableView:)];
    [_tableView addGestureRecognizer:tap];
    
    UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(p_tapOnTableView:)];
    pan.delegate = self;
    [_tableView addGestureRecognizer:pan];
    [_tableView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
}
//键盘显示和收缩  点击tableView的手势监听事件
- (void)handleWillShowKeyboard:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    //获取键盘的高度
    //[[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
    NSValue *value = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGFloat keyboardHeight = CGRectGetHeight([value CGRectValue]);
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];

    CGRect rect = _tableView.frame;
    rect.size.height = SCREENHEIGHT-keyboardHeight-64-SCREENHEIGHT*0.17;
    _tableView.frame = rect;
    
    feedTextField.frame = CGRectMake(5, rect.size.height, SCREENWIDTH-10, SCREENHEIGHT*0.08);
    sendButton.frame = CGRectMake(SCREENWIDTH*0.1,feedTextField.frame.origin.y+SCREENHEIGHT*0.1, SCREENWIDTH*0.8, SCREENHEIGHT*0.08);
    
    
    [UIView commitAnimations];
    
}
- (void)handleWillHideKeyboard:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    //获取键盘的高度
    //[[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
    //NSValue *value = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
   // CGFloat keyboardHeight = CGRectGetHeight([value CGRectValue]);
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    CGRect rect = _tableView.frame;
    rect.size.height = SCREENHEIGHT*0.7;
    _tableView.frame = rect;
    
    feedTextField.frame = CGRectMake(5, SCREENHEIGHT*0.7, SCREENWIDTH-10, SCREENHEIGHT*0.08);
    sendButton.frame = CGRectMake(SCREENWIDTH*0.1, SCREENHEIGHT*0.8, SCREENWIDTH*0.8, SCREENHEIGHT*0.08);
    
    
    [UIView commitAnimations];
}
- (void)p_tapOnTableView:(UIGestureRecognizer*)sender
{
    [feedTextField resignFirstResponder];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.250000];
    [UIView setAnimationCurve:7];
    CGRect rect = _tableView.frame;
    rect.size.height = SCREENHEIGHT*0.7;
    _tableView.frame = rect;
    
    feedTextField.frame = CGRectMake(5, SCREENHEIGHT*0.7, SCREENWIDTH-10, SCREENHEIGHT*0.08);
    sendButton.frame = CGRectMake(SCREENWIDTH*0.1, SCREENHEIGHT*0.8, SCREENWIDTH*0.8, SCREENHEIGHT*0.08);
    
    [UIView commitAnimations];

}

-(void)loadChatData
{
    _feedBackArray = [[NSMutableArray alloc]init];
    offset = 0;
    count = 20;
    NSString *urlString = [NSString stringWithFormat:USERFEEDBACKURL,DomainName,offset,count];
    NSLog(@"用户反馈url%@",urlString);
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"用户反馈的字典%@",dict);
        NSString *errString = dict[@"err"];
        if(errString.intValue == 0)
        {
            NSArray *array = dict[@"feedList"];
            for(long i = array.count-1;i>=0;i--)
            {
                [_feedBackArray addObject:array[i]];
            }
                
        
           
            //聊天模块中数据源数组中加入数据
            self.chatModel = [[userFeedbackChatModel alloc]init];
            self.chatModel.isGroupChat = NO;
            [self.chatModel populateRandomDataSource:_feedBackArray];
            [_tableView reloadData];
            //聊天记录tableView滚动到底部
            [self tableViewScrollToBottom];
            
        }
        else
        {
            UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"加载失败" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            [al show];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"加载失败" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [al show];
    }];
    
    
}
//聊天的tableView滚动到底部
-(void)tableViewScrollToBottom
{
    if(self.chatModel.dataSource.count == 0)
        return;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.chatModel.dataSource.count-1 inSection:0];
    [_tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
}

-(void)createTextUI
{
    feedTextField = [ZCControl createTextFieldWithFrame:CGRectMake(5, SCREENHEIGHT*0.7, SCREENWIDTH-10, SCREENHEIGHT*0.08) placeholder:@"感谢您的反馈，以让我们的产品做得更好..." passWord:NO leftImageView:nil rightImageView:nil Font:SCREENWIDTH*0.048];
    feedTextField.returnKeyType = UIReturnKeyDone;
    feedTextField.borderStyle = UITextBorderStyleRoundedRect;
    feedTextField.delegate = self;
    [self.view addSubview:feedTextField];
    
    sendButton = [ZCControl createButtonWithFrame:CGRectMake(SCREENWIDTH*0.1, SCREENHEIGHT*0.8, SCREENWIDTH*0.8, SCREENHEIGHT*0.08) ImageName:@"" Target:self Action:@selector(sendButtonBtn:) Title:@"发送"];
    sendButton.backgroundColor = [UIColor colorWithHexStr:@"#56d585"];
   // [sendButton setTitleColor:[UIColor colorWithHexStr:@"#56d585"] forState:UIControlStateNormal];
    [self.view addSubview:sendButton];
    
}
-(void)sendButtonBtn:(UIButton *)button
{
    
    //发送消息
    NSString* text = [feedTextField text];
    if(text.length == 0)
    {
        UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"内容不能为空" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [al show];
    }
    else
    {
//        NSDictionary *dic = @{@"strContent":text,@"type":@(UUMessageTypeText)};
//        [self.chatModel addSpecifiedItem:dic];
//        [_tableView reloadData];
//        feedTextField.text = nil;
//        [self tableViewScrollToBottom];
        
        //自己的反馈信息先上传服务器 成功后本地显示
        NSString *urlString = [NSString stringWithFormat:USERFEEDBACKURL,DomainName,0,10];
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
        [manager POST:urlString parameters:@{@"feedback":text} success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            NSLog(@"反馈字典%@",dict);
            NSString *errString = dict[@"err"];
            if(errString.intValue == 0)
            {
                NSDictionary *dic = @{@"strContent":text,@"type":@(UUMessageTypeText)};
                [self.chatModel addSpecifiedItem:dic];
                [_tableView reloadData];
                feedTextField.text = nil;
                [self tableViewScrollToBottom];
            }
            else
            {
                UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"反馈失败" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                [al show];
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"反馈失败,请检查网络设置" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            [al show];
        
        }];
    }
}

-(void)createChatTableView
{
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT*0.7) style:UITableViewStylePlain];
    _tableView.backgroundColor = [UIColor colorWithHexStr:@"#eeeeee"];
    _tableView.delegate = self;
    _tableView.dataSource = self;
   
    //去除聊天界面的分割线
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
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

//行数是根据消息数组中消息数目来动态地确定
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //消息的行数
    return self.chatModel.dataSource.count ;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"cell";
    UUMessageCell  *cell  =[tableView dequeueReusableHeaderFooterViewWithIdentifier:cellID];
    if(cell == nil)
    {
        cell = [[UUMessageCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
        cell.delegate = self;
    }
    //config cell
    
    [cell setMessageFrame:self.chatModel.dataSource[indexPath.row]];
    
    return cell;
}

//根据消息内容cell动态地计算行高
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.chatModel.dataSource[indexPath.row] cellHeight];
}
//cell上面的点击
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self.view endEditing:YES];
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1f;
}

#pragma mark-(自己制定的cell上面头像的点击代理)
-(void)headImageDidClick:(UUMessageCell *)cell userId:(NSString *)userId
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:cell.messageFrame.message.strName message:@"headImage clicked" delegate:nil cancelButtonTitle:@"sure" otherButtonTitles:nil];
    [alert show];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
//#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return YES;
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

//-(void)createTextUI
//{
//    UITextView *textView = [[UITextView alloc]initWithFrame:CGRectMake(10, 10, SCREENWIDTH-20, SCREENHEIGHT*0.4)];
//    textView.backgroundColor = [UIColor orangeColor];
//    textView.text = @"感谢您的反馈，以让我们的产品做得更好...";
//    textView.tag = 200;
//    textView.delegate = self;
//    [self.view addSubview:textView];
//    
//    //回收键盘 虚拟键盘的附件区域添加完成按钮
//    UIToolbar *toolBar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 44)];
//    UIBarButtonItem *finishItem = [[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(dealTextBtn:)];
//    finishItem.tag = 100;
//    UIBarButtonItem *cancleItem = [[UIBarButtonItem alloc]initWithTitle:@"清空" style:UIBarButtonItemStylePlain target:self action:@selector(dealTextBtn:)];
//    cancleItem.tag = 101;
//    toolBar.items = @[cancleItem,finishItem];
//    textView.inputAccessoryView  = toolBar;
//    
//    UIButton *sendButton = [ZCControl createButtonWithFrame:CGRectMake(SCREENWIDTH*0.1, SCREENHEIGHT*0.5, SCREENWIDTH*0.8, SCREENHEIGHT*0.08) ImageName:@"btn_login_bg_2@2x" Target:self Action:@selector(sendButtonBtn:) Title:@"发送"];
//    [self.view addSubview:sendButton];
//    
//}
//-(void)sendButtonBtn:(UIButton *)button
//{
//    
//}
//
//-(void)dealTextBtn:(UIBarButtonItem *)item
//{
//    UITextView *textView = (UITextView *)[self.view viewWithTag:200];
//    if(item.tag == 101)
//    {
//        textView.text = @"";
//    }
//    else if (item.tag == 100)
//    {
//        [textView resignFirstResponder];
//    }
//}
//

-(void)createUINa
{
    self.view.backgroundColor = [UIColor colorWithHexStr:@"#eeeeee"];
    
    UILabel *titleLabel = [ZCControl createLabelWithFrame:CGRectMake(0, 0, 100, 30) Font:22 Text:@"反馈"];
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
