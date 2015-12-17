//
//  miaomiaoChatDetailViewController.m
//  ForwardOne
//
//  Created by 杨波 on 15/5/21.
//  Copyright (c) 2015年 杨波. All rights reserved.
//

#import "miaomiaoChatDetailViewController.h"
#import "TouchDownGestureRecognizer.h"
#import "EmotionsModule.h"
#import "Mp3Recorder.h"
#import "UUProgressHUD.h"
#import "UUAVAudioPlayer.h"
#import "miaomiaoChatGroupSettingViewController.h"

#import "shopInformationViewController.h"
#import "collectionCommodityDetailViewController.h"
#import "mmxActivityDetailViewController.h"

//聊天数据相关
#import "myAppDataBase.h"
#import "staticUserInfo.h"
#import "ASIFormDataRequest.h"

#import "JSONKit.h"

//上拉加载更多的聊天内容
#import "UIView+MJExtension.h"
#import "MJRefresh.h"

#import "inShopActivityViewController.h"
#import "mainShopDetailViewController.h"


#define ACTIVITYDETAILURL @"http://%@/userweb/activity/%d"

//一系列的枚举
typedef NS_ENUM(NSUInteger, DDBottomShowComponent)
{
    DDInputViewUp                       = 1,
    DDShowKeyboard                      = 1 << 1,
    DDShowEmotion                       = 1 << 2,
    DDShowUtility                       = 1 << 3
};

typedef NS_ENUM(NSUInteger, DDBottomHiddComponent)
{
    DDInputViewDown                     = 14,
    DDHideKeyboard                      = 13,
    DDHideEmotion                       = 11,
    DDHideUtility                       = 7
};
//

typedef NS_ENUM(NSUInteger, DDInputType)
{
    DDVoiceInput,
    DDTextInput
};

typedef NS_ENUM(NSUInteger, PanelStatus)
{
    VoiceStatus,
    TextInputStatus,
    EmotionStatus,
    ImageStatus
};
#define NAVBAR_HEIGHT 64.f
#define SCREEN_WIDTH          [[UIScreen mainScreen] bounds].size.width
#define SCREEN_HEIGHT         [[UIScreen mainScreen] bounds].size.height-64
#define DDCOMPONENT_BOTTOM          CGRectMake(0, (SCREEN_HEIGHT - NAVBAR_HEIGHT) + NAVBAR_HEIGHT, SCREEN_WIDTH, 216)
#define DDINPUT_BOTTOM_FRAME        CGRectMake(0, (SCREEN_HEIGHT - NAVBAR_HEIGHT) - self.chatInputView.frame.size.height + NAVBAR_HEIGHT,SCREEN_WIDTH,self.chatInputView.frame.size.height)
#define DDINPUT_HEIGHT              self.chatInputView.frame.size.height
#define DDINPUT_TOP_FRAME           CGRectMake(0, (SCREEN_HEIGHT - NAVBAR_HEIGHT) - self.chatInputView.frame.size.height + NAVBAR_HEIGHT - 216, SCREEN_WIDTH, self.chatInputView.frame.size.height)
#define DDUTILITY_FRAME             CGRectMake(0, (SCREEN_HEIGHT - NAVBAR_HEIGHT) + NAVBAR_HEIGHT -216, SCREEN_WIDTH, 216)
#define DDEMOTION_FRAME             CGRectMake(0, (SCREEN_HEIGHT - NAVBAR_HEIGHT) + NAVBAR_HEIGHT-216, SCREEN_WIDTH, 216)

@interface miaomiaoChatDetailViewController () <Mp3RecorderDelegate,ASIHTTPRequestDelegate>
{
    UITableView *_tableView;
    
    Mp3Recorder *MP3;
    NSInteger playTime;
    NSTimer *playTimer;
   
   
   //聊天数据
   NSMutableArray *_chatArry;
   YBWebSocketManager *webSocketManager;
   
   //显示聊天记录的条数
   int pageCount;
}

- (void)p_clickThRecordButton:(UIButton*)button;
- (void)p_record:(UIButton*)button;
- (void)p_willCancelRecord:(UIButton*)button;
- (void)p_cancelRecord:(UIButton*)button;
- (void)p_sendRecord:(UIButton*)button;
- (void)p_endCancelRecord:(UIButton*)button;

- (void)p_hideBottomComponent;
- (void)p_tapOnTableView:(UIGestureRecognizer*)sender;

@end

@implementation miaomiaoChatDetailViewController
{
    TouchDownGestureRecognizer* _touchDownGestureRecognizer;
    DDBottomShowComponent _bottomShowComponent;
    UIButton *_recordButton;
    float _inputViewY;
    NSString* _currentInputContent;
}

//视图即将显示的时候
-(void)viewWillAppear:(BOOL)animated
{
    
    //聊天输入框输入为空 聊天框输入为空 刷新聊天输入框
    [self.chatInputView.textView setText:nil];
    
    //隐藏聊天输入框
   // [self p_hideBottomComponent];
}
//当视图已经显示的时候
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:animated];
    
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

}


- (void)viewDidLoad {
    [super viewDidLoad];
   
   //添加手势的全屏返回的实现


    //创建MP3播放器
    webSocketManager = [YBWebSocketManager sharedInstance];
    MP3 = [[Mp3Recorder alloc]initWithDelegate:self];
   _chatArry = [[NSMutableArray alloc]init];
   self.chatModel = [[chatModel alloc]init];
   self.chatModel.isGroupChat = NO;
   
    //键盘的显示和收缩  监听处理事件
    [self notificationCenter];
    
    [self createUINaV];
    
    [self createTableView];
    
    //创建聊天输入框
    [self initialInput];
    
    //聊天的模块
    [self loadBaseViewAndData];
    
   //通知 （实时聊天）
   NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
   [nc addObserver:self selector:@selector(insertBaseViewAndData:) name:@"startLoadWebSocketData" object:nil];
   
   //加载聊天记录
   [nc addObserver:self selector:@selector(loadBaseViewAndData) name:@"startLoadChatDataFromeNet" object:nil];
   
    //添加轻击和拖移的手势去回收键盘
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(p_tapOnTableView:)];
    [_tableView addGestureRecognizer:tap];
    
    UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(p_tapOnTableView:)];
    pan.delegate = self;
    [_tableView addGestureRecognizer:pan];
    [_tableView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];

    
    
    // Do any additional setup after loading the view.
}



- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self p_hideBottomComponent];
    //解除通知
    //[[NSNotificationCenter defaultCenter]removeObserver:self];
   
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}


-(void)insertBaseViewAndData:(NSNotification *)notification
{
   NSString *currentGname = notification.userInfo[@"currentGname"];
   if([currentGname isEqualToString:self.gnameString])
   {
   
   NSArray *messageArray = [staticUserInfo getMessagesWithGname:self.gnameString];
//   NSArray *finalMessageArray = messageArray[messageArray.count -1];
//   [self.chatModel populateRandomDataSource:finalMessageArray];
//   [_tableView reloadData];
   if(messageArray.count != 0)
   {
   NSDictionary *messageDict = messageArray[messageArray.count -1];
   [_chatArry addObject:messageDict];
   NSLog(@"具体的聊天数组%@",_chatArry);
   [self.chatModel insertOneMessageToTableViewWithDict:messageDict];
      [_tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.chatModel.dataSource.count-1 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
   //[_tableView reloadData];
   [self tableViewScrollToBottom];
   }
   }
}

#pragma mark-(聊天的模块)
-(void)loadBaseViewAndData
{
   //[_chatArry removeAllObjects];
  // [[NSNotificationCenter defaultCenter]removeObserver:self name:@"startLoadWebSocketData" object:nil];
   
   [_chatArry removeAllObjects];
   pageCount = 7;
   
    //聊天模块中数据源数组中加入数据
   if([[myAppDataBase sharedInstance]isExistMessageWith:self.gnameString])
   {
      //数据中有则static中获取
      NSArray *messageArray = [staticUserInfo getMessagesWithGname:self.gnameString];
      if(messageArray.count>pageCount)
      {
      for(int i = messageArray.count-pageCount;i<messageArray.count;i++)
      {
         [_chatArry addObject:messageArray[i]];
      }
     // _chatArry = [NSMutableArray arrayWithArray:messageArray];
      NSLog(@"具体的聊天数组%@",_chatArry);
      //加载数据源数组
      }
      else
      {
         _chatArry = [NSMutableArray arrayWithArray:messageArray];
         NSLog(@"具体的聊天数组%@",_chatArry);
      }
      
      [self.chatModel populateRandomDataSource:_chatArry];
      
      [_tableView reloadData];
      
      //聊天记录tableView滚动到底部
      [self tableViewScrollToBottom];
   }
   else
   {
      //从网络中获取聊天记录
      [webSocketManager YBGetRecordWithGname:self.gnameString andStartTime:@"0" andRecordCount:@"30"];
      //取出数据
      NSArray *messageArray = [staticUserInfo getMessagesWithGname:self.gnameString];
      _chatArry = [NSMutableArray arrayWithArray:messageArray];
      
      
       //加载数据源数组
      
      [self.chatModel populateRandomDataSource:_chatArry];
      
      
      [_tableView reloadData];
      
      //聊天记录tableView滚动到底部
      [self tableViewScrollToBottom];
   }
   

}
//聊天的tableView滚动到底部
-(void)tableViewScrollToBottom
{
    if(self.chatModel.dataSource.count == 0)
        return;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.chatModel.dataSource.count-1 inSection:0];
    [_tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
}
    



#pragma  mark - PrivateAPI
- (void)p_hideBottomComponent
{
    _bottomShowComponent = _bottomShowComponent * 0;
    [self.chatInputView.textView resignFirstResponder];
  //  [UIView animateWithDuration:0.25 animations:^{
        self.ddUtility.view.frame = DDCOMPONENT_BOTTOM;
        self.emotions.view.frame = DDCOMPONENT_BOTTOM;
        self.chatInputView.frame = DDINPUT_BOTTOM_FRAME;
        
        CGRect rect = _tableView.frame;
        rect.size.height = SCREENHEIGHT-44-64;
        _tableView.frame = rect;
    //}];
//    NSLog(@"%f",self.chatInputView.frame.origin.y);
    [self setValue:@(self.chatInputView.frame.origin.y) forKeyPath:@"_inputViewY"];
}

-(void)notificationCenter
{
    //创建约束
//    NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:self.chatInputView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_tableView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
//    
//    self.bottomConstraint =  [NSLayoutConstraint constraintWithItem:_tableView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
//    
//    NSLayoutConstraint *rightSideConstraint = [NSLayoutConstraint constraintWithItem:_tableView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0];
//    
//    NSLayoutConstraint *leftSideConstraint = [NSLayoutConstraint constraintWithItem:_tableView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0];
//    
//    [_tableView addConstraints:@[leftSideConstraint,rightSideConstraint,topConstraint,self.bottomConstraint]];
}


- (void)initialInput
{
    //视图的原点y从64开始
     CGRect inputFrame = CGRectMake(0, SCREEN_HEIGHT -44,SCREEN_WIDTH,44.0f);
  
    
    self.chatInputView = [[JSMessageInputView alloc] initWithFrame:inputFrame delegate:self];
    //[self.chatInputView setBackgroundColor:[UIColor orangeColor]];
   [self.chatInputView setBackgroundColor:[UIColor colorWithRed:249/255.0 green:249/255.0 blue:249/255.0 alpha:1.0]];
    [self.view addSubview:self.chatInputView];
    
    //表情
    [self.chatInputView.emotionbutton addTarget:self
                                         action:@selector(showEmotions:)
                               forControlEvents:UIControlEventTouchUpInside];
    //➕号
    [self.chatInputView.showUtilitysbutton addTarget:self
                                              action:@selector(showUtilitys:)
                                    forControlEvents:UIControlEventTouchDown];
    //语音
    [self.chatInputView.voiceButton addTarget:self
                                       action:@selector(p_clickThRecordButton:)
                             forControlEvents:UIControlEventTouchUpInside];
    
    //录音上面一系列的手势效果
    _touchDownGestureRecognizer = [[TouchDownGestureRecognizer alloc] initWithTarget:self action:nil];
    __weak miaomiaoChatDetailViewController* weakSelf = self;
    _touchDownGestureRecognizer.touchDown = ^{
        [weakSelf p_record:nil];
    };
    
    _touchDownGestureRecognizer.moveInside = ^{
        [weakSelf p_endCancelRecord:nil];
    };
    
    _touchDownGestureRecognizer.moveOutside = ^{
        [weakSelf p_willCancelRecord:nil];
    };
    
    _touchDownGestureRecognizer.touchEnd = ^(BOOL inside){
        if (inside)
        {
            [weakSelf p_sendRecord:nil];
        }
        else
        {
            [weakSelf p_cancelRecord:nil];
        }
    };
    [self.chatInputView.recordButton addGestureRecognizer:_touchDownGestureRecognizer];
//    _recordingView = [[RecordingView alloc] initWithState:DDShowVolumnState];
//    [_recordingView setHidden:YES];
//    [_recordingView setCenter:CGPointMake(SCREENWIDTH/2, SCREENHEIGHT*0.4)];
    [self addObserver:self forKeyPath:@"_inputViewY" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
}
//-(IBAction)showEmotions:(id)sender
-(void)showEmotions:(id)sende
{
   
    [_recordButton setImage:[UIImage imageNamed:@"dd_record_normal"] forState:UIControlStateNormal];
    _recordButton.tag = DDVoiceInput;
    [self.chatInputView willBeginInput];
    if ([_currentInputContent length] > 0)
    {
        [self.chatInputView.textView setText:_currentInputContent];
    }
    
    if (self.emotions == nil) {
        self.emotions = [EmotionsViewController new];
        [self.emotions.view setBackgroundColor:[UIColor darkGrayColor]];
        self.emotions.view.frame=DDCOMPONENT_BOTTOM;
        self.emotions.delegate = self;
        [self.view addSubview:self.emotions.view];
    }
    if (_bottomShowComponent & DDShowKeyboard)
    {
        //显示的是键盘,这是需要隐藏键盘，显示表情，不需要动画
        _bottomShowComponent = (_bottomShowComponent & 0) | DDShowEmotion;
        [self.chatInputView.textView resignFirstResponder];
        [self.emotions.view setFrame:DDEMOTION_FRAME];
        [self.ddUtility.view setFrame:DDCOMPONENT_BOTTOM];
    }
    else if (_bottomShowComponent & DDShowEmotion)
    {
        //表情面板本来就是显示的,这时需要隐藏所有底部界面
        [self.chatInputView.textView resignFirstResponder];
        _bottomShowComponent = _bottomShowComponent & DDHideEmotion;
    }
    else if (_bottomShowComponent & DDShowUtility)
    {
        //显示的是插件，这时需要隐藏插件，显示表情
        [self.ddUtility.view setFrame:DDCOMPONENT_BOTTOM];
        [self.emotions.view setFrame:DDEMOTION_FRAME];
        _bottomShowComponent = (_bottomShowComponent & DDHideUtility) | DDShowEmotion;
    }
    else
    {
        //这是什么都没有显示，需用动画显示表情
        _bottomShowComponent = _bottomShowComponent | DDShowEmotion;
        [UIView animateWithDuration:0.25 animations:^{
            [self.emotions.view setFrame:DDEMOTION_FRAME];
            [self.chatInputView setFrame:DDINPUT_TOP_FRAME];
        }];
        [self setValue:@(DDINPUT_TOP_FRAME.origin.y) forKeyPath:@"_inputViewY"];
    }
    
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.250000];
    [UIView setAnimationCurve:7];
    
    CGRect rect = _tableView.frame;
    rect.size.height = SCREENHEIGHT-216-44-64;
    _tableView.frame = rect;
    //adjust UUInputFunctionView's originPoint
    [UIView commitAnimations];
    [self tableViewScrollToBottom];

}
//-(IBAction)showUtilitys:(id)sender
-(void)showUtilitys:(id)sende
{
    [_recordButton setImage:[UIImage imageNamed:@"dd_record_normal"] forState:UIControlStateNormal];
    _recordButton.tag = DDVoiceInput;
    [self.chatInputView willBeginInput];
    if ([_currentInputContent length] > 0)
    {
        [self.chatInputView.textView setText:_currentInputContent];
        
    }
    
    if (self.ddUtility == nil)
    {
        self.ddUtility = [ChatUtilityViewController new];
        self.ddUtility.delegate = self;
        [self addChildViewController:self.ddUtility];
        self.ddUtility.view.frame=CGRectMake(0, self.view.frame.size.height,self.view.frame.size.width , 280);
        [self.view addSubview:self.ddUtility.view];
        
    }
    
    if (_bottomShowComponent & DDShowKeyboard)
    {
        //显示的是键盘,这是需要隐藏键盘，显示插件，不需要动画
        _bottomShowComponent = (_bottomShowComponent & 0) | DDShowUtility;
        [self.chatInputView.textView resignFirstResponder];
        [self.ddUtility.view setFrame:DDUTILITY_FRAME];
        [self.emotions.view setFrame:DDCOMPONENT_BOTTOM];
       
    }
    else if (_bottomShowComponent & DDShowUtility)
    {
        //插件面板本来就是显示的,这时需要隐藏所有底部界面
        //        [self p_hideBottomComponent];
//        [self.chatInputView.textView becomeFirstResponder];
//        _bottomShowComponent = _bottomShowComponent & DDHideUtility;
        
    }
    else if (_bottomShowComponent & DDShowEmotion)
    {
        //显示的是表情，这时需要隐藏表情，显示插件
        [self.emotions.view setFrame:DDCOMPONENT_BOTTOM];
        [self.ddUtility.view setFrame:DDUTILITY_FRAME];
        _bottomShowComponent = (_bottomShowComponent & DDHideEmotion) | DDShowUtility;
       
    }
    else
    {
        //这是什么都没有显示，需用动画显示插件
        _bottomShowComponent = _bottomShowComponent | DDShowUtility;
        [UIView animateWithDuration:0.25 animations:^{
            [self.ddUtility.view setFrame:DDUTILITY_FRAME];
            [self.chatInputView setFrame:DDINPUT_TOP_FRAME];
        }];
        [self setValue:@(DDINPUT_TOP_FRAME.origin.y) forKeyPath:@"_inputViewY"];
        
        
    }
    
    //调节tableView的高度 tableView滚动到底部
    if(_tableView.frame.size.height == SCREENHEIGHT-216-64-44)
    {
        return;
    }
    else
    {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.250000];
        [UIView setAnimationCurve:7];
        
        CGRect rect = _tableView.frame;
        rect.size.height = SCREENHEIGHT-216-44-64;
        _tableView.frame = rect;
        //adjust UUInputFunctionView's originPoint
        [UIView commitAnimations];
        [self tableViewScrollToBottom];
   
    }
    
    
    
}
- (void)p_clickThRecordButton:(UIButton*)button
{
    switch (button.tag) {
        case DDVoiceInput:
            //开始录音 界面UI进行连动的改变
            [self p_hideBottomComponent];
            [button setImage:[UIImage imageNamed:@"dd_input_normal"] forState:UIControlStateNormal];
            button.tag = DDTextInput;
            [self.chatInputView willBeginRecord];
            [self.chatInputView.textView resignFirstResponder];
            _currentInputContent = self.chatInputView.textView.text;
            if ([_currentInputContent length] > 0)
            {
                [self.chatInputView.textView setText:nil];
            }
            break;
        case DDTextInput:
            //开始输入文字
            [button setImage:[UIImage imageNamed:@"dd_record_normal"] forState:UIControlStateNormal];
            button.tag = DDVoiceInput;
            [self.chatInputView willBeginInput];
            if ([_currentInputContent length] > 0)
            {
                [self.chatInputView.textView setText:_currentInputContent];
            }
            [self.chatInputView.textView becomeFirstResponder];
            break;
    }
}

//开始录音的部分
- (void)p_record:(UIButton*)button
{
    [MP3 startRecord];
    playTime = 0;
    playTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countVoiceTime) userInfo:nil repeats:YES];
    [UUProgressHUD show];
    
//    [self.chatInputView.recordButton setHighlighted:YES];
//    if (![[self.view subviews] containsObject:_recordingView])
//    {
//        [self.view addSubview:_recordingView];
//    }
//    [_recordingView setHidden:NO];
//    [_recordingView setRecordingState:DDShowVolumnState];

//    [[RecorderManager sharedManager] setDelegate:self];
//    [[RecorderManager sharedManager] startRecording];
//    NSLog(@"record");
}
- (void)countVoiceTime
{
    playTime ++;
    if (playTime>=60) {
        [self p_sendRecord:nil];
    }
}

//结束取消发送
- (void)p_endCancelRecord:(UIButton*)button
{
//    [_recordingView setHidden:NO];
//    [_recordingView setRecordingState:DDShowVolumnState];
    [UUProgressHUD changeSubTitle:@"向上滑动，取消发送"];
    
}
//即将开始取消发送
- (void)p_willCancelRecord:(UIButton*)button
{
//    [_recordingView setHidden:NO];
//    [_recordingView setRecordingState:DDShowCancelSendState];
//    NSLog(@"will cancel record");
    [UUProgressHUD changeSubTitle:@"松开 取消"];
    
}
//发送
- (void)p_sendRecord:(UIButton*)button
{
   // [self.chatInputView.recordButton setHighlighted:NO];
//    [[RecorderManager sharedManager] stopRecording];
//    NSLog(@"send record");
    
    if(playTimer)
    {
        [MP3 stopRecord];
        [playTimer invalidate];
        playTimer = nil;
    }
}
- (void)p_cancelRecord:(UIButton*)button
{
    if(playTimer)
    {
        [MP3 cancelRecord];
        [playTimer invalidate];
        playTimer = nil;
    }
    
    [UUProgressHUD dismissWithError:@"取消"];
    
//    [self.chatInputView.recordButton setHighlighted:NO];
//        [_recordingView setHidden:YES];
//    [[RecorderManager sharedManager] cancelRecording];
//    NSLog(@"cancel record");
}
#pragma mark - Mp3RecorderDelegate（这个回调得到的数据位MP3）
-(void)endConvertWithData:(NSData *)voiceData
{
//    NSDictionary *dic = @{@"voice": voiceData,
//                          @"strVoiceTime": [NSString stringWithFormat:@"%d",(int)playTime],
//                          @"type": @(UUMessageTypeVoice)};
//   [self dealTheFunctionData:dic];
   
   NSString *timeString = [NSString stringWithFormat:@"%d",(int)playTime];
   [[NSUserDefaults standardUserDefaults]setObject:timeString forKey:Voicetime];
   [[NSUserDefaults standardUserDefaults]synchronize];
   
   NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
   NSString* documentsDirectory = [paths objectAtIndex:0];
   NSString* fullPathToFile = [documentsDirectory stringByAppendingPathComponent:@"audio.mp3"];
   [voiceData writeToFile:fullPathToFile atomically:YES];
   
   
   NSURL*url=[NSURL URLWithString:@"http://chat.immbear.com:8889/file/uploader"];
   /*上传按钮 使用路径的上传方式*/
   ASIFormDataRequest*logpicrequest=[ASIFormDataRequest requestWithURL:url];
   //[logpicrequest addRequestHeader:@"Content-Type" value:@"audio/mp3"];
   [logpicrequest addFile:fullPathToFile withFileName:@"impower" andContentType:@"audio/mp3" forKey:@"Content-Type"];
   logpicrequest.delegate=self;
   [voiceData writeToFile:fullPathToFile atomically:NO];
   [logpicrequest setFile:fullPathToFile forKey:@"uploadFile"];
   // [logpicrequest   setData:imageData forKey:@"cont"];
   logpicrequest.tag=103;
   [logpicrequest startAsynchronous];//异步开始
   
    [UUProgressHUD dismissWithSuccess:@"发送成功"];
    
    //缓冲消失时间 (最好有block回调消失完成)
    self.chatInputView.recordButton.userInteractionEnabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.chatInputView.recordButton.userInteractionEnabled = YES;
    });
}
-(void)failRecord
{
    [UUProgressHUD dismissWithError:@"时间太短"];
    
    
    //缓冲消失时间 (最好有block回调消失完成)  缓冲消失时间
    self.chatInputView.recordButton.userInteractionEnabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.chatInputView.recordButton.userInteractionEnabled = YES;
    });
   
}
-(void)beginConvert
{
   
}


#pragma mark - KeyBoardNotification
- (void)handleWillShowKeyboard:(NSNotification *)notification
{
    //键盘改变设置聊天输入框的位置
    CGRect keyboardRect;
    keyboardRect = [(notification.userInfo)[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    
    _bottomShowComponent = _bottomShowComponent | DDShowKeyboard;
    //什么都没有显示
    //[UIView animateWithDuration:0.25 animations:^{
        [self.chatInputView setFrame:CGRectMake(0, keyboardRect.origin.y - DDINPUT_HEIGHT, self.view.frame.size.width, DDINPUT_HEIGHT)];
    //}];
    [self setValue:@(keyboardRect.origin.y - DDINPUT_HEIGHT) forKeyPath:@"_inputViewY"];
    
    //键盘改变设置tableView的位置
    
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
    rect.size.height = SCREENHEIGHT-keyboardHeight-64-self.chatInputView.frame.size.height;
    _tableView.frame = rect;
    //adjust UUInputFunctionView's originPoint
    [UIView commitAnimations];    
}

- (void)handleWillHideKeyboard:(NSNotification *)notification
{
    CGRect keyboardRect;
    keyboardRect = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    _bottomShowComponent = _bottomShowComponent & DDHideKeyboard;
    if (_bottomShowComponent & DDShowUtility)
    {
        //显示的是插件
        //[UIView animateWithDuration:0.25 animations:^{
            [self.chatInputView setFrame:DDINPUT_TOP_FRAME];
        //}];
        [self setValue:@(self.chatInputView.frame.origin.y) forKeyPath:@"_inputViewY"];
    }
    else if (_bottomShowComponent & DDShowEmotion)
    {
        //显示的是表情
        //[UIView animateWithDuration:0.25 animations:^{
            [self.chatInputView setFrame:DDINPUT_TOP_FRAME];
        //}];
        [self setValue:@(self.chatInputView.frame.origin.y) forKeyPath:@"_inputViewY"];
        
    }
    else
    {
        [self p_hideBottomComponent];
    }
    
    
    //键盘位置改变设置tableView的位置
    NSDictionary *userInfo = [notification userInfo];
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect keyboardEndFrame;
    
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    
    //adjust ChatTableView's height  调节聊天tableView的高度
//    if (notification.name == UIKeyboardWillShowNotification) {
//        
//        self.bottomConstraint.constant = keyboardEndFrame.size.height+40;
//    }else{
//        self.bottomConstraint.constant = 40;
//    }
    
    
    CGRect rect = _tableView.frame;
    rect.size.height = SCREENHEIGHT-64-44;
    _tableView.frame = rect;
   
    
    [UIView commitAnimations];

    
}
#pragma mark - Text view delegatef

- (void)viewheightChanged:(float)height
{
    [self setValue:@(self.chatInputView.frame.origin.y) forKeyPath:@"_inputViewY"];
}

//发送消息和表情（）
- (void)textViewEnterSend
{
   
    //发送消息
    NSString* text = [self.chatInputView.textView text];
   
   NSLog(@"输入框中的表情符号 = %@",text);
//    NSDictionary *dic = @{@"strContent":text,@"type":@(UUMessageTypeText)};
//    self.chatInputView.textView.text = @"";
//    [self dealTheFunctionData:dic];
   
   NSString *myIDString = [[NSUserDefaults standardUserDefaults]objectForKey:UserAccount];
   if(text.length != 0)
   {
   [webSocketManager YBSendMessageFromUser:myIDString toGname:self.gnameString message:text messageType:@"text"];
   }
   //单聊 （gname已经存在 不需要拼接）
   //[webSocketManager YBSendOnlyChatMessageFromUser:myIDString toGname:self.gnameString message:text messageType:@"text"];
   self.chatInputView.textView.text = nil;
   
   //[self loadBaseViewAndData];
   
    //对表情进行处理的正则表达式，如果输入框中含有表情 则需要将表情进行正则表达式的转换
    
    //    NSString* parten = @"\\s";
    //    NSRegularExpression* reg = [NSRegularExpression regularExpressionWithPattern:parten options:NSRegularExpressionCaseInsensitive error:nil];
    //
    //    NSString* checkoutText = [reg stringByReplacingMatchesInString:text options:NSMatchingReportProgress range:NSMakeRange(0, [text length]) withTemplate:@""];
    //    if ([checkoutText length] == 0)
    //    {
    //        return;
    //    }
}
//发送图片
-(void)sendPicture:(UIImage *)image
{
//    NSDictionary *dic = @{@"picture": image,
//                          @"type": @(UUMessageTypePicture)};
//    [self dealTheFunctionData:dic];
   
   NSData *imageData = UIImagePNGRepresentation(image);
   NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
   NSString* documentsDirectory = [paths objectAtIndex:0];
   NSString* fullPathToFile = [documentsDirectory stringByAppendingPathComponent:@"sendPic.png"];
   [imageData writeToFile:fullPathToFile atomically:YES];
   NSURL*url=[NSURL URLWithString:@"http://chat.immbear.com/file/uploader"];
   ASIFormDataRequest*logpicrequest=[ASIFormDataRequest requestWithURL:url];
   logpicrequest.delegate=self;
   [imageData writeToFile:fullPathToFile atomically:NO];
   [logpicrequest setFile:fullPathToFile forKey:@"uploadFile"];
   // [logpicrequest   setData:imageData forKey:@"cont"];
   logpicrequest.tag=101;
   [logpicrequest startAsynchronous];//异步开始
}

#pragma mark-(发送图片语音返回的ASI代理)
-(void)requestFinished:(ASIHTTPRequest *)request
{
   
   NSString *myIDString = [[NSUserDefaults standardUserDefaults]objectForKey:UserAccount];
   //发送图片
   if(request.tag == 101)
   {
      
      NSDictionary *picDict = [request.responseString objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode];
      [webSocketManager YBSendMessageFromUser:myIDString toGname:self.gnameString message:picDict[@"url"] messageType:picDict[@"content_type"]];
      //重新加载数据 刷新聊天tableView
      //[self loadBaseViewAndData];
      
   }
   if(request.tag == 103)
   {
      NSLog(@"_______________%@",request.responseString);
      NSDictionary *voiceDict = [request.responseString objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode];
      [webSocketManager YBSendMessageFromUser:myIDString toGname:self.gnameString message:voiceDict[@"url"] messageType:voiceDict[@"content_type"]];
      //[self loadBaseViewAndData];
   }
   
}


#pragma makr-(总的处理发送的文字消息 图片 表情 语音  交给chatModel处理)
- (void)dealTheFunctionData:(NSDictionary *)dic
{
    [self.chatModel addSpecifiedItem:dic];
    [_tableView reloadData];
    [self tableViewScrollToBottom];
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"_inputViewY"])
    {
        //            [self p_unableLoadFunction];
        [UIView animateWithDuration:0.25 animations:^{
            if (_bottomShowComponent & DDShowEmotion)
            {
                CGRect frame = self.emotions.view.frame;
                frame.origin.y = self.chatInputView.bottom;
                self.emotions.view.frame = frame;
            }
            if (_bottomShowComponent & DDShowUtility)
            {
                CGRect frame = self.ddUtility.view.frame;
                frame.origin.y = self.chatInputView.bottom;
                self.ddUtility.view.frame = frame;
            }
            
        } completion:^(BOOL finished) {
            //                [self p_enableLoadFunction];
        }];
    }
    
}
- (void)p_tapOnTableView:(UIGestureRecognizer*)sender
{
    if (_bottomShowComponent)
    {
        [self p_hideBottomComponent];
    }
    
}




#pragma mark-(创建tableView)
-(void)createTableView
{
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT-64-44) style:UITableViewStylePlain];
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
   
   //添加下拉刷新加载更多聊天记录的空进啊
   NSArray *messageArray = [staticUserInfo getMessagesWithGname:self.gnameString];
   if(messageArray.count > 7)
   {
   __weak typeof(self) weakSelf = self;
   [_tableView addLegendHeaderWithRefreshingBlock:^{
      
      [weakSelf loadMoreChatData];
      
   }];
   }
   [self tableViewScrollToBottom];
   
   //马上进入刷新的状态
   //[_tableView.legendHeader beginRefreshing];
   
   
    [self.view addSubview:_tableView];
}
#pragma mark-(下拉刷新加载更多的聊天记录)
-(void)loadMoreChatData
{
   
   pageCount = pageCount+7;
   NSMutableArray *addArray = [[NSMutableArray alloc]init];
   NSArray *messageArray = [staticUserInfo getMessagesWithGname:self.gnameString];
   //NSLog(@"加载消息记录的条数 = %d",pageCount);
   //NSLog(@"所有的消息记录的条数 = %d",messageArray.count);
   if(messageArray.count < pageCount)
   {
      if(pageCount-messageArray.count+1<=7)
      {
      for(int i = 0;i<messageArray.count-(pageCount-7);i++)
      {
         [addArray addObject:messageArray[i]];
         
      }
         for(int i = addArray.count-1;i>=0;i--)
         {
            [_chatArry insertObject:addArray[i] atIndex:0];
            NSLog(@"具体的聊天数组%@",_chatArry);
         }
         
      }
   }
   else
   {
   for(int i = messageArray.count-pageCount;i<messageArray.count-(pageCount-7);i++)
    {
      // NSLog(@"下拉加载具体的每一条数据 = %@",messageArray[i]);
      [addArray addObject:messageArray[i]];

    }
      
      for(int i = addArray.count-1;i>=0;i--)
      {
         [_chatArry insertObject:addArray[i] atIndex:0];
         NSLog(@"具体的聊天数组%@",_chatArry);
      }
      
   //NSLog(@"下拉加载更多的数据 = %@",addArray);
   }
   if(addArray.count != 0)
   {
   [self.chatModel addMoreChatData:addArray];
   }
   
   [_tableView reloadData];
   NSIndexPath *path = [NSIndexPath indexPathForRow:7 inSection:0];
   if(messageArray.count > 14)
  {
     
   [_tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionTop animated:NO];
   }
   [_tableView.header endRefreshing];
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
    //static NSString *cellID = @"cell";
    UUMessageCell  *cell  =[tableView dequeueReusableCellWithIdentifier:@"CellID"];
    if(cell == nil)
    {
        cell = [[UUMessageCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellID"];
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
//    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:cell.messageFrame.message.strName message:@"headImage clicked" delegate:nil cancelButtonTitle:@"sure" otherButtonTitles:nil];
//    [alert show];
}

//聊天视图上面cell上面的点击
-(void)cellContentDidClick:(UUMessageCell *)cell image:(UIImage *)contentImage
{
   NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
   NSLog(@"点击的所在行 = %@",indexPath);
  
   NSDictionary *messageDict = _chatArry[indexPath.row];
   NSLog(@"&&&&&&&&&&&&&&&&&&& = %@",messageDict);
   if([messageDict[@"mtype"] isEqualToString:@"mmx/goods"])
   {
      //商品
      collectionCommodityDetailViewController *vc = [[collectionCommodityDetailViewController alloc]init];
      NSString *detailDictString = messageDict[@"m"];
      NSDictionary *detailDict = [detailDictString objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode];
      vc.goodsIDString = [NSString stringWithFormat:@"%@",detailDict[@"id"]];
     // NSLog(@"***********%@",messageDict);
      [self.navigationController pushViewController:vc animated:YES];
   }
   else if ([messageDict[@"mtype"] isEqualToString:@"mmx/shop"])
   {
      //商店
      mainShopDetailViewController *vc = [[mainShopDetailViewController alloc]init];
      NSString *detailDictString = messageDict[@"m"];
      NSDictionary *detailDict = [detailDictString objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode];
      vc.shopIDString = [NSString stringWithFormat:@"%@",detailDict[@"id"]];
      vc.shopNamestrting = detailDict[@"name"];
      vc.shopPic = detailDict[@"img"];
      vc.gnameString = self.gnameString;
      vc.invitationLabelString = self.chatTitleName;
      //vc.YB_ShopDetailChangeDelegate = self;
      //NSLog(@"***********%@",messageDict);
      [self.navigationController pushViewController:vc animated:YES];
   }
   else if ([messageDict[@"mtype"] isEqualToString:@"mmx/act"])
   {
      //活动
      
      NSString *detailDictString = messageDict[@"m"];
      NSDictionary *detailDict = [detailDictString objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode];
      //vc.activityIDString = [NSString stringWithFormat:@"%@",detailDict[@"id"]];
      NSString *activiIDString = detailDict[@"id"];
      //由活动的ID去下载活动的具体信息
      NSString *urlString = [NSString stringWithFormat:ACTIVITYDETAILURL,DomainName,activiIDString.intValue];
      // NSLog(@"聊天内活动的URl%@",urlString);
      AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
      manager.responseSerializer = [AFHTTPResponseSerializer serializer];
      [manager GET:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
         
         NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
         inShopActivityViewController *vc = [[inShopActivityViewController alloc]init];
         vc.gnameString = self.gnameString;
         vc.invitationLabelString = self.chatTitleName;

         NSMutableArray *activityArray = [[NSMutableArray alloc]init];
         NSMutableDictionary *activityDict = [[NSMutableDictionary alloc]init];
         [activityDict setObject:dict[@"actID"] forKey:@"id"];
         [activityDict setObject:dict[@"title"] forKey:@"title"];
         [activityDict setObject:dict[@"content"] forKey:@"content"];
         [activityDict setObject:dict[@"bt"] forKey:@"bt"];
         [activityDict setObject:dict[@"et"] forKey:@"et"];
         NSArray *picArray = dict[@"shopPic"];
         [activityDict setObject:picArray[0] forKey:@"img"];
         [activityDict setObject:dict[@"shopID"] forKey:@"shopID"];
         [activityArray addObject:activityDict];
         
         vc.activityArray = activityArray;
         [self.navigationController pushViewController:vc animated:YES];
         
      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         
      }];

   }
}


//设计问题 暂时不反向传值
//#pragma mark-(点击发送商店的反向传值)
//-(void)YBShopDetailChangeGroupGname:(NSString *)gname andGroupName:(NSString *)groupName
//{
//   self.gnameString = gname;
//   self.chatTitleName = groupName;
//   [self loadBaseViewAndData];
//   [self createUINaV];
//}

-(void)createUINaV
{
   self.view.backgroundColor = [UIColor whiteColor];
   
   UILabel *titleLabel = [ZCControl createLabelWithFrame:CGRectMake(0, 0, 100, 30) Font:22 Text:self.chatTitleName];
   titleLabel.textAlignment = NSTextAlignmentCenter;
   titleLabel.textColor = [UIColor whiteColor];
   self.navigationItem.titleView = titleLabel;
   
   UIButton *imageLeftButton  =[ZCControl createButtonWithFrame:CGRectMake(0, 0, 25, 20) ImageName:@"" Target:self Action:@selector(imageLeftItemBtn) Title:nil];
   [imageLeftButton setImage:[UIImage imageNamed:@"店铺-店铺详情_03"] forState:UIControlStateNormal];
   UIBarButtonItem *imageLeftItem = [[UIBarButtonItem alloc]initWithCustomView:imageLeftButton];
   self.navigationItem.leftBarButtonItem = imageLeftItem;
   
   
   UIButton *imageRightButton = [ZCControl createButtonWithFrame:CGRectMake(0, 0, 25, 25) ImageName:@"" Target:self Action:@selector(searchButtonBtn:) Title:nil];
   [imageRightButton setImage:[UIImage imageNamed:@"设置"] forState:UIControlStateNormal];
   UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:imageRightButton];
   self.navigationItem.rightBarButtonItem = rightItem;
   
   
}
//导航栏左按钮的点击
-(void)imageLeftItemBtn
{
   [self.navigationController popViewControllerAnimated:YES];
}

//导航右按钮的点击
-(void)searchButtonBtn:(UIButton *)button
{
   miaomiaoChatGroupSettingViewController *vc = [[miaomiaoChatGroupSettingViewController alloc]init];
   
   vc.usersIDString = self.usersIDString;
   vc.senderIDString = self.senderIDString;
   vc.gnameString = self.gnameString;
   vc.invitationLabelString = self.chatTitleName;
   
   [self.navigationController pushViewController:vc animated:YES];
}

- (void)dealloc
{
   [[UUAVAudioPlayer sharedInstance]stopSound];
   
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self removeObserver:self forKeyPath:@"_inputViewY"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - EmotionsViewController Delegate
//发送图片表情
- (void)emotionViewClickSendButton
{
    [self textViewEnterSend];
}
//输入框中插入聊天表情
-(void)insertEmojiFace:(NSString *)string
{
    NSMutableString* content = [NSMutableString stringWithString:self.chatInputView.textView.text];
    [content appendString:string];
    [self.chatInputView.textView setText:content];
}
//输入框中删除聊天表情
-(void)deleteEmojiFace
{
    EmotionsModule* emotionModule = [EmotionsModule shareInstance];
    NSString* toDeleteString = nil;
    if (self.chatInputView.textView.text.length == 0)
    {
        return;
    }
    if (self.chatInputView.textView.text.length == 1)
    {
        self.chatInputView.textView.text = @"";
    }
    else
    {
        toDeleteString = [self.chatInputView.textView.text substringFromIndex:self.chatInputView.textView.text.length - 1];
        int length = [emotionModule.emotionLength[toDeleteString] intValue];
        if (length == 0)
        {
            toDeleteString = [self.chatInputView.textView.text substringFromIndex:self.chatInputView.textView.text.length - 2];
            length = [emotionModule.emotionLength[toDeleteString] intValue];
        }
        length = length == 0 ? 1 : length;
        self.chatInputView.textView.text = [self.chatInputView.textView.text substringToIndex:self.chatInputView.textView.text.length - length];
    }
    
}
//得到录音之后的语音的二进制数据
//#pragma Recording Delegate
//- (void)recordingFinishedWithFileName:(NSString *)filePath time:(NSTimeInterval)interval
//{
//    
//    NSMutableData* muData = [[NSMutableData alloc] init];
//    NSData* data = [NSData dataWithContentsOfFile:filePath];
//    int length = [RecorderManager sharedManager].recordedTimeInterval;
//    if (length < 1 )
//    {
//        //当录音时间太多的时候提醒
//        NSLog(@"录音时间太短");
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [_recordingView setHidden:NO];
//            [_recordingView setRecordingState:DDShowRecordTimeTooShort];
//        });
//        return;
//    }
//    else
//    {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [_recordingView setHidden:YES];
//        });
//    }
//    int8_t ch[4];
//    for(int32_t i = 0;i<4;i++){
//        ch[i] = ((length >> ((3 - i)*8)) & 0x0ff);
//    }
//    [muData appendBytes:ch length:4];
//    [muData appendData:data];
//    /**
//     *  muData ->  voice data  声音的二进制数据
//     *
//     *  length  ->  voice Length 声音的二进制数据的长度
//     */
//    
//    
//    //进行播放语音
//    [[PlayerManager sharedManager]playAudioWithFileName:filePath delegate:self];
//
//    NSDictionary *dic = @{@"voice": data,
//                          @"strVoiceTime": [NSString stringWithFormat:@"%d",(int)interval],
//                          @"type": @(UUMessageTypeVoice)};
//    [self dealTheFunctionData:dic];
//    
//}
//- (void)recordingTimeout
//{
//    
//}
///**
// *  录音机停止采集声音
// */
//- (void)recordingStopped
//{
//    
//}
//- (void)recordingFailed:(NSString *)failureInfoString
//{
//    
//}
//- (void)levelMeterChanged:(float)levelMeter
//{
//   // [_recordingView setVolume:levelMeter];
//}
#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint location = [gestureRecognizer locationInView:self.view];
    if (CGRectContainsPoint(DDINPUT_BOTTOM_FRAME, location))
    {
        return NO;
    }
    return YES;
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([gestureRecognizer.view isEqual:_tableView])
    {
        return YES;
    }
    return NO;
}
#pragma mark -
- (void)playingStoped
{
    
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
