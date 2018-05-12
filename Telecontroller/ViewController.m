//
//  ViewController.m
//  Telecontroller
//
//  Created by hk on 17/5/12.
//  Copyright © 2017年 hk. All rights reserved.
//
#import "BTViewController.h"
#import "ViewController.h"
#import "EADSessionController.h"
#import <ExternalAccessory/ExternalAccessory.h>
#define BUNDLEID @"com.haoke.tele"
#import "ModeViewController.h"
#import "AppDelegate.h"
#define errorStr @"Please connect Bluetooth"
#define disconnectStr @"APP Disconnect"
typedef NS_OPTIONS(NSInteger, FMclass) {
    FM1            = 0,
    FM2              ,
    FM3              ,
    AM1              ,
    AM2              ,
    WB1               ,
};

@interface ViewController ()<buttonDELE,BleDelegate>
{
    BOOL isLink;
    BOOL isMute;
    NSTimer *timer;
    int timerInt;
    int zoneInt;
    int indexPinLv;
    NSMutableArray * pinlvArray;
    CGFloat oldPinLv;
    FMclass FMCLASS;
    BOOL isEnable;
    BOOL zoneIsOpen;
    NSTimer *scanTimer;
}
@property (weak, nonatomic) IBOutlet UIButton *nextMusicButton;
@property (weak, nonatomic) IBOutlet UIButton *preMusicButton;
@property (weak, nonatomic) IBOutlet UIButton *sixButton;
@property (weak, nonatomic) IBOutlet UIButton *fireButton;
@property (weak, nonatomic) IBOutlet UIButton *fourButton;
@property (weak, nonatomic) IBOutlet UIButton *threeButton;
@property (weak, nonatomic) IBOutlet UIButton *twoButton;
@property (weak, nonatomic) IBOutlet UIButton *oneButton;
@property (weak, nonatomic) IBOutlet UIButton *zoneHeadButton;
@property (weak, nonatomic) IBOutlet UIButton *zoneSelectButton;
@property (nonatomic, strong) EADSessionController *eaSessionController;
@property (nonatomic, strong) NSArray *supportedProtocolsStrings;
@property (nonatomic, strong) NSMutableArray *accessoryList;
@property (nonatomic,strong)NSMutableDictionary *dataDict;
@property (nonatomic, strong) NSMutableArray *frequencyArray;
@end

@implementation ViewController



- (IBAction)headButton:(id)sender {
   // [self initTimer];
    if (((AppDelegate *)[UIApplication sharedApplication].delegate).BTisOpen) {
        [self presentViewController:[BTViewController shareInstance] animated:NO completion:nil];
    }else{
       UIAlertView* viewAlert = [[UIAlertView alloc]initWithTitle:nil message:@"Please open Bluetooth" delegate:nil cancelButtonTitle:@"I Know" otherButtonTitles:nil, nil];
       [viewAlert  show];
    }
}


-(void)setEnable{
    isEnable = YES;
}
-(BOOL)setButtonAfterEnable{
    if (!isEnable) {
        NSLog(@"请不要连续按键");
        return NO;
    }
    isEnable = NO;
    
    [self performSelector:@selector(setEnable) withObject:nil afterDelay:0.2];
    return YES;
}

- (IBAction)addVoice:(id)sender {
    if (![self setButtonAfterEnable]) {
        return;
    }
    if (isLink) {
//        Byte buff[] = {0xaa,0x55,0x03,0x10,0x01,0x14};
        [self sendData:@"aa5503100114"];
    }else{
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:disconnectStr message:errorStr delegate:nil cancelButtonTitle:@"cancel" otherButtonTitles:nil, nil];
        [alertView show];
    }   
}
- (IBAction)deleVoice:(id)sender {
    if (![self setButtonAfterEnable]) {
        return;
    }
    if (isLink) {
//        Byte buff[] = {0xaa,0x55,0x03,0x10,0x02,0x15};
        
        [self sendData:@"aa5503100215"];
    }else{
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:disconnectStr message:errorStr delegate:nil cancelButtonTitle:@"cancel" otherButtonTitles:nil, nil];
        [alertView show];
    }

}
- (IBAction)lastMusic:(id)sender {
    if (![self setButtonAfterEnable]) {
        return;
    }
    if (isLink) {
//        Byte buff[] = {0xaa,0x55,0x03,0x10,0x03,0x16};
        [self sendData:@"aa5503100316"];
    }else{
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:disconnectStr message:errorStr delegate:nil cancelButtonTitle:@"cancel" otherButtonTitles:nil, nil];
        [alertView show];
    }

}
- (IBAction)nextMusic:(id)sender {
    if (![self setButtonAfterEnable]) {
        return;
    }
    if (isLink) {
//        Byte buff[] = {0xaa,0x55,0x03,0x10,0x05,0x18};
        [self sendData:@"aa5503100518"];
    }else{
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:disconnectStr message:errorStr delegate:nil cancelButtonTitle:@"cancel" otherButtonTitles:nil, nil];
        [alertView show];
    }

}
- (IBAction)playPauseButton:(id)sender {
    if (![self setButtonAfterEnable]) {
        return;
    }
    if (isLink) {
//        Byte buff[] = {0xaa,0x55,0x03,0x10,0x04,0x17};
        [self sendData:@"aa5503100417"];
    }else{
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:disconnectStr message:errorStr delegate:nil cancelButtonTitle:@"cancel" otherButtonTitles:nil, nil];
        [alertView show];
    }

    
}
- (IBAction)bandButton:(id)sender {
    if (![self setButtonAfterEnable]) {
        return;
    }
    if (isLink) {
//        Byte buff[] = {0xaa,0x55,0x03,0x11,0x01,0x15};
        [self sendData:@"aa5503100619"];
        [BTViewController shareInstance].isNeedCheck = YES;
    }else{
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:disconnectStr message:errorStr delegate:nil cancelButtonTitle:@"cancel" otherButtonTitles:nil, nil];
        [alertView show];
    }   
}
- (IBAction)muteButton:(id)sender {
    if (![self setButtonAfterEnable]) {
        return;
    }
    if (isLink) {
        [self sendData:@"aa550310071a"];
//        if (isMute) {
////            Byte buff[] = {0xaa,0x55,0x03,0x12,0x02,0x17};
//            [self sendData:@"aa5503120217"];
//        }else{
////            Byte buff[] = {0xaa,0x55,0x03,0x12,0x01,0x16};
//            [self sendData:@"aa5503120116"];
//        }
//        double delayInSeconds = 0.05f;
//        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//        dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
//                       {
//                           //            当前静音状态
//                           [self sendData:@"aa5503220126"];
//                           
//                       });
    }else{
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:disconnectStr message:errorStr delegate:nil cancelButtonTitle:@"cancel" otherButtonTitles:nil, nil];
        [alertView show];
    }

}
- (IBAction)offButton:(id)sender {
    if (![self setButtonAfterEnable]) {
        return;
    }
    if (isLink) {
        [self sendData:@"aa5503100f22"];
        
        UIButton *button = sender;
        button.selected = !button.selected;
    }else{
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:disconnectStr message:errorStr delegate:nil cancelButtonTitle:@"cancel" otherButtonTitles:nil, nil];
        [alertView show];
    }

}
- (IBAction)oneButton:(id)sender {
    if (![self setButtonAfterEnable]) {
        return;
    }
    if (isLink) {
//        Byte buff[] = {0xaa,0x55,0x03,0x16,0x01,0x1a};
        [self sendData:@"aa550316011a"];
    }else{
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:disconnectStr message:errorStr delegate:nil cancelButtonTitle:@"cancel" otherButtonTitles:nil, nil];
        [alertView show];
    }
}
- (IBAction)twoButton:(id)sender {
    if (![self setButtonAfterEnable]) {
        return;
    }
    if (isLink) {
//        Byte buff[] = {0xaa,0x55,0x03,0x16,0x02,0x1b};
        [self sendData:@"aa550316021b"];
    }else{
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:disconnectStr message:errorStr delegate:nil cancelButtonTitle:@"cancel" otherButtonTitles:nil, nil];
        [alertView show];
    }
}
- (IBAction)threeButton:(id)sender {
    if (![self setButtonAfterEnable]) {
        return;
    }
    if (isLink) {
//        Byte buff[] = {0xaa,0x55,0x03,0x16,0x03,0x1c};
        [self sendData:@"aa550316031c"];
    }else{
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:disconnectStr message:errorStr delegate:nil cancelButtonTitle:@"cancel" otherButtonTitles:nil, nil];
        [alertView show];
    }
}
- (IBAction)fourButton:(id)sender {
    if (![self setButtonAfterEnable]) {
        return;
    }
    if (isLink) {
//        Byte buff[] = {0xaa,0x55,0x03,0x16,0x04,0x1d};
        [self sendData:@"aa550316041d"];

    }else{
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:disconnectStr message:errorStr delegate:nil cancelButtonTitle:@"cancel" otherButtonTitles:nil, nil];
        [alertView show];
    }

}

- (IBAction)fireBUtton:(id)sender {
    if (![self setButtonAfterEnable]) {
        return;
    }
    if (isLink) {
//        Byte buff[] = {0xaa,0x55,0x03,0x16,0x05,0x1e};
        [self sendData:@"aa550316051e"];
    }else{
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:disconnectStr message:errorStr delegate:nil cancelButtonTitle:@"cancel" otherButtonTitles:nil, nil];
        [alertView show];
    }
}
- (IBAction)sixButton:(id)sender {
    if (![self setButtonAfterEnable]) {
        return;
    }
    if (isLink) {
//        Byte buff[] = {0xaa,0x55,0x03,0x16,0x06,0x1f};
        [self sendData:@"aa550316061f"];        
    }else{
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:disconnectStr message:errorStr delegate:nil cancelButtonTitle:@"cancel" otherButtonTitles:nil, nil];
        [alertView show];
    }
}
-(void)zoneChange{
    if (![self setButtonAfterEnable]) {
        return;
    }
    if (isLink) {
        
        
        [self sendData:@"aa5503100e21"];

//        if (!zoneIsOpen) {
//            [self sendData:@"aa5503140118"];
//            zoneIsOpen = YES;
//        }else{
//            [self sendData:@"aa5503140017"];
//            zoneIsOpen = NO;
//        }
    }else{
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:disconnectStr message:errorStr delegate:nil cancelButtonTitle:@"cancel" otherButtonTitles:nil, nil];
        [alertView show];
    }
}
-(void)getData{
    [self sendData:@"aa550310ff12"];
/*
    switch (timerInt) {
        case 0:
        {
//            当前频点
            [self sendData:@"aa5503200124"];
//            [[EADSessionController sharedController] writeData:[NSData dataWithBytes:buff length:sizeof(buff)]];
        }
            break;
//        case 1:
//        {
////           当前zone
//            [self sendData:@"aa5503210125"];
//        }
            break;
        case 1:
        {
//            当前静音状态
            [self sendData:@"aa5503220126"];
        }
            break;
//        case 3:
//        {
////            当前模式
//            [self sendData:@"aa5503230127"];
//        }
//            break;
//        case 4:
//        {
////            当前频率类型
//            [self sendData:@"aa5503240128"];
//        }
//            break;
        default:
            break;
    }
    
    timerInt++;
    if (timerInt == 2) {
        timerInt = 0;
    }
 */
}
#pragma mark ViewDidLoad
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    scanTimer = [NSTimer scheduledTimerWithTimeInterval:21.0
                                                  target:self
                                                selector:@selector(btScan)
                                                userInfo:nil
                                                 repeats:YES];
    
    
    [BTViewController shareInstance].BLEDEGATE = self;
    isEnable = YES;
    timerInt = 0;
    zoneInt = 1;
    oldPinLv = 0.;
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_accessoryDidConnect:) name:EAAccessoryDidConnectNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_accessoryDidDisconnect:) name:EAAccessoryDidDisconnectNotification object:nil];
//    [[EAAccessoryManager sharedAccessoryManager] registerForLocalNotifications];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_sessionDataReceived:) name:EADSessionDataReceivedNotification object:nil];
//    _eaSessionController = [EADSessionController sharedController];
//    
//    NSBundle *mainBundle = [NSBundle mainBundle];
//    self.supportedProtocolsStrings = [mainBundle objectForInfoDictionaryKey:@"UISupportedExternalAccessoryProtocols"];
//    _accessoryList = [[NSMutableArray alloc] initWithArray:[[EAAccessoryManager sharedAccessoryManager] connectedAccessories]];
//    
//    if (_accessoryList.count != 0) {
//        [_eaSessionController setupControllerForAccessory:_accessoryList[0]
//                                       withProtocolString:self.supportedProtocolsStrings[0]];
//        [_eaSessionController openSession];
//        isLink = YES;
//        [_zoneHeadButton setTitle:@"BT connected" forState:UIControlStateNormal];
//        [self initTimer];
//    }
    zoneIsOpen = NO;

    _frequencyArray = [NSMutableArray array];

    [_frequencyArray addObjectsFromArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"frequency"]];
    NSArray *buttonArray = @[_oneButton,_twoButton,_threeButton,_fourButton,_fireButton,_sixButton];
    for (int i = 0; i< _frequencyArray.count; i++) {
        [(UIButton*)buttonArray[i] setTitle:[NSString stringWithFormat:@"%@",_frequencyArray[i]] forState:UIControlStateNormal];
    }

//    _zoneSelectButton.titleLabel.numberOfLines = 0;
//    _zoneSelectButton.titleLabel.font = [UIFont systemFontOfSize:14];
//    _zoneSelectButton.titleLabel.textAlignment = NSTextAlignmentCenter;
//    [_zoneSelectButton setTitle:@"ZONE\nLOUD" forState:UIControlStateNormal];
    [_zoneSelectButton addTarget:self action:@selector(zoneChange) forControlEvents:UIControlEventTouchUpInside];

   
    Byte buff[] = {0xaa,0x55,0x03,0x20,0x01,0x24};
    NSLog(@"buff = %ld",sizeof(buff));
    
    indexPinLv = 0;
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longAction:)];
    longPress.minimumPressDuration = 2.0;
    [_preMusicButton addGestureRecognizer:longPress];
    _preMusicButton.tag = 101;
    
    UILongPressGestureRecognizer *longPress2 = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longAction:)];
    longPress2.minimumPressDuration = 2.0;
    [_nextMusicButton addGestureRecognizer:longPress2];
    _nextMusicButton.tag = 102;
}
-(void)longAction:(UILongPressGestureRecognizer*)sender{
    switch (sender.view.tag ) {
        case 101:
        {
            switch (sender.state) {
                case UIGestureRecognizerStateBegan:
                {
                    NSLog(@"101手势开始");
                   
                        [self SingleSendData:@"aa5503101023"];
                    
                }
                    break;
                case UIGestureRecognizerStateEnded:
                {
                    NSLog(@"101手势结束");
                    [self SingleSendData:@"aa5503101124"];
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case 102:
        {
            switch (sender.state) {
                case UIGestureRecognizerStateBegan:
                {
                    NSLog(@"102手势开始");
                    [self SingleSendData:@"aa5503101225"];
                }
                    break;
                case UIGestureRecognizerStateEnded:
                {
                    NSLog(@"102手势结束");
                    [self SingleSendData:@"aa5503101326"];
                }
                    break;
                default:
                    break;
            }
        }
            break;
        default:
            break;
    }
}
-(void)btScan{
    if (!isLink) {
        NSLog(@"循环搜索");
        if (((AppDelegate *)[UIApplication sharedApplication].delegate).isCanScan) {
            [[BTViewController shareInstance]scanClick];
        }
    }
}
-(void)btIsConnect:(BOOL)isBtLink{
    isLink = isBtLink;
    [BTViewController shareInstance].BTisLink = isBtLink;
    if (isLink) {
        [_zoneHeadButton setTitle:@"APP Connected" forState:UIControlStateNormal];
        [BTViewController shareInstance].isNeedCheck = YES;
        double delayInSeconds = 3.0f;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                       {
                          [self initTimer];
                       });
        UIButton *button = [self.view viewWithTag:1007];
        button.selected = NO;
    }else{
        [_zoneHeadButton setTitle:disconnectStr forState:UIControlStateNormal];
        [self deallocTimer];
        
        UIButton *button = [self.view viewWithTag:1007];
        button.selected = YES;
        
        UIButton *button2 = [self.view viewWithTag:1006];
        button2.selected = NO;
        
        UIButton *button3 = [self.view viewWithTag:1005];
        button3.selected = NO;
    }
}
-(void)setHigthButton:(NSInteger)tag isSelected:(BOOL)isSele{
    switch (tag) {
        case 1005:
        {
            UIButton *button = [self.view viewWithTag:1005];
            button.selected = isSele;
        }
            break;
        case 1006:
        {
            UIButton *button = [self.view viewWithTag:1006];
            button.selected = isSele;
        }
            break;
        case 1007:
        {
            
            UIButton *button = [self.view viewWithTag:1007];
            button.selected = isSele;
        }
            break;

        default:
            break;
    }
}
-(void)changeFrequency:(NSArray *)frequency{
    NSArray *buttonArray = @[_oneButton,_twoButton,_threeButton,_fourButton,_fireButton,_sixButton];
    for (int i = 0; i< frequency.count; i++) {
        [(UIButton*)buttonArray[i] setTitle:[NSString stringWithFormat:@"%@",frequency[i]] forState:UIControlStateNormal];
    }
}
-(void)changeHeadMode:(NSString *)modeStr{
//    if ([modeStr isEqualToString:@"1"]) {
//        
//        [_zoneHeadButton setTitle:@"ZONE 1" forState:UIControlStateNormal];
//        zoneInt = 1;
//    }else if([modeStr isEqualToString:@"2"]){
//        
//        [_zoneHeadButton setTitle:@"ZONE 2" forState:UIControlStateNormal];
//        zoneInt = 2;
//    }else if([modeStr isEqualToString:@"3"]){
//        
//        [_zoneHeadButton setTitle:@"ZONE 3" forState:UIControlStateNormal];
//        zoneInt = 3;
//    }
}
-(void)changeMuteState:(NSString *)muteStr{
    if ([muteStr isEqualToString:@"1"]) {
        isMute = YES;
    }else{
        isMute = NO;
    }
}
-(void)sendData:(NSString*)byteStr{
    [[BTViewController shareInstance]writeToPeripheral:byteStr];
}
-(void)SingleSendData:(NSString*)byteStr{

    if (![self setButtonAfterEnable]) {
        return;
    }
    if (isLink) {
        [[BTViewController shareInstance]writeToPeripheral:byteStr];
    }else{
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:disconnectStr message:errorStr delegate:nil cancelButtonTitle:@"cancel" otherButtonTitles:nil, nil];
        [alertView show];
    }

}
/*
-(void)sendData:(Byte*)bytes{
    [[EADSessionController sharedController] writeData:[NSData dataWithBytes:bytes length:6]];

}
- (void)_sessionDataReceived:(NSNotification *)notification{
    NSDictionary *dataDict = notification.userInfo;
    NSData *data;
    EADSessionController *sessionController = (EADSessionController *)[notification object];
    uint32_t bytesAvailable = 0;
    
    while ((bytesAvailable = (uint32_t)[sessionController readBytesAvailable]) > 0) {
        data = [sessionController readData:bytesAvailable];
    }
    
    if (((const char *)[data bytes])[3] != 3) {
        NSLog(@"接收byte = %x,%x,%x,%x,%x,%x,%x",((const char *)[data bytes])[0],((const char *)[data bytes])[1],((const char *)[data bytes])[2],((const char *)[data bytes])[3],((const char *)[data bytes])[4],((const char *)[data bytes])[5],((const char *)[data bytes])[6]);
    }
    
    int address = ((const char *)[data bytes])[3];
    switch (address) {
        case 0x01:
        {
//            BOOL isFind = NO;
            UInt16 a = ((const char *)[data bytes])[4];
            UInt16 b = ((const char *)[data bytes])[5];
            UInt16 c = (a << 8) + b;
            
            NSString *cStr = nil;
            switch (FMCLASS) {
                case FM1:
                case FM2:
                case FM3:
                {

                    if (oldPinLv < 8750) {
                         indexPinLv = 0;
                    }
                    cStr = [NSString stringWithFormat:@"%.2f",c/100.];
                }
                    break;
                case AM1:
                case AM2:
                {
                    if (oldPinLv < 530 || oldPinLv > 1720) {
                        indexPinLv = 0;
                    }
                    cStr = [NSString stringWithFormat:@"%d",c];
                }
                    break;
                case WB:
                {
                    if (oldPinLv > 550) {
                        indexPinLv = 0;
                    }
                    cStr = [NSString stringWithFormat:@"162.%.2f",c/100.];
                }
                    break;
                default:
                    break;
            }
            oldPinLv = c;
            indexPinLv ++;

            
            NSLog(@"cStr  =  %@",cStr);
            
            
            switch (indexPinLv) {
                case 1:
                    [_oneButton setTitle:cStr forState:UIControlStateNormal];
                    break;
                case 2:
                    [_twoButton setTitle:cStr forState:UIControlStateNormal];
                    break;
                case 3:
                    [_threeButton setTitle:cStr forState:UIControlStateNormal];
                    break;
                case 4:
                    [_fourButton setTitle:cStr forState:UIControlStateNormal];
                    break;
                case 5:
                    [_fireButton setTitle:cStr forState:UIControlStateNormal];
                    break;
                case 6:
                    [_sixButton setTitle:cStr forState:UIControlStateNormal];
                    break;
                    
                default:
                    break;
            }
            [pinlvArray addObject:cStr];
            if (indexPinLv == 6) {
                [self savePinlv];
            }
            
            
            
        }
            break;
        case 0x02:
        {
            [self resetPinlv];
            UInt16 b = ((const char *)[data bytes])[5];
            NSString *bStr = [NSString stringWithFormat:@"%d",b];
            [[NSUserDefaults standardUserDefaults]setObject:bStr forKey:@"zoneSeletct"];
            
            if ([bStr isEqualToString:@"1"]) {
                [_zoneHeadButton setTitle:@"ZONE 1" forState:UIControlStateNormal];
                zoneInt = 1;
            }else if([bStr isEqualToString:@"2"]){
                [_zoneHeadButton setTitle:@"ZONE 2" forState:UIControlStateNormal];
                zoneInt = 2;
            }else if([bStr isEqualToString:@"3"]){
                [_zoneHeadButton setTitle:@"ZONE 3" forState:UIControlStateNormal];
                zoneInt = 3;
            }
        }
            break;
        case 0x03:
        {
            [self resetPinlv];
            UInt16 b = ((const char *)[data bytes])[5];
            NSString *bStr = [NSString stringWithFormat:@"%d",b];
            if ([bStr isEqualToString:@"1"]) {
                isMute = YES;
            }else{
                isMute = NO;
            }
            [[NSUserDefaults standardUserDefaults]setObject:bStr forKey:@"isMute"];//静音1非静音0
        }
            break;
        case 0x04:
        {
            [self resetPinlv];
            UInt16 b = ((const char *)[data bytes])[5];
            NSString *bStr = [NSString stringWithFormat:@"%d",b];
            [[NSUserDefaults standardUserDefaults]setObject:bStr forKey:@"nowMode"];
        }
            break;
        case 0x06:
        {
            [self resetPinlv];
            UInt16 b = ((const char *)[data bytes])[5];
            NSString *bStr = [NSString stringWithFormat:@"%d",b];
            
            switch (b) {
                case 0:
                {
                    FMCLASS = FM1;
                }
                    break;
                case 1:
                {
                    FMCLASS = FM2;
                }
                    break;
                case 2:
                {
                    FMCLASS = FM3;
                }
                    break;
                case 3:
                {
                    FMCLASS = AM1;
                }
                    break;
                case 4:
                {
                    FMCLASS = AM2;
                }
                    break;
                case 5:
                {
                    FMCLASS = WB;
                }
                    break;
                default:
                    break;
            }

        }
            break;
        default:
            break;
    }
}
*/

- (IBAction)modeButton:(id)sender {
    if (![self setButtonAfterEnable]) {
        return;
    }
    if (isLink) {
        [self performSegueWithIdentifier:@"mySegue" sender:nil];
        [BTViewController shareInstance].isNeedCheck = YES;

    }else{
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:disconnectStr message:errorStr delegate:nil cancelButtonTitle:@"cancel" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"mySegue"])
    {
        
        ModeViewController* vc = (ModeViewController*)segue.destinationViewController;
        vc.delegate = self;
        NSLog(@"获取跳转到mySegue");
    }
}
-(void)buttonNumber:(int )number{
    switch (number) {
        case 1:
        {
//            Byte buff[] = {0xaa,0x55,0x03,0x13,0x01,0x17};
            [self sendData:@"aa550310091c"];
        }
            break;
        case 2:
        {
//            Byte buff[] = {0xaa,0x55,0x03,0x13,0x02,0x18};
            [self sendData:@"aa5503100a1d"];
        }
            break;
        case 3:
        {
//            Byte buff[] = {0xaa,0x55,0x03,0x13,0x03,0x19};
            [self sendData:@"aa5503100b1e"];
        }
            break;
        case 4:
        {
//            Byte buff[] = {0xaa,0x55,0x03,0x13,0x04,0x1a};
            [self sendData:@"aa5503100c1f"];
        }
            break;
        case 5:
        {
//            Byte buff[] = {0xaa,0x55,0x03,0x13,0x05,0x1b};
            [self sendData:@"aa5503100d20"];
        }
            break;
        default:
            break;
    }
}
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
/*
#pragma mark Internal
- (void)_accessoryDidConnect:(NSNotification *)notification {
    NSLog(@"连接成功");
    if (!isLink) {
        EAAccessory *connectedAccessory = [[notification userInfo] objectForKey:EAAccessoryKey];
        [_eaSessionController setupControllerForAccessory:connectedAccessory
                                       withProtocolString:BUNDLEID];
        [_eaSessionController openSession];
        isLink = YES;
        [self initTimer];
        [_zoneHeadButton setTitle:@"BT connected" forState:UIControlStateNormal];
    }
}
- (void)_accessoryDidDisconnect:(NSNotification *)notification {
    NSLog(@"断开连接");
    [_accessoryList removeAllObjects];
    [_eaSessionController closeSession];
    isLink = NO;
    [_zoneHeadButton setTitle:@"BTdicconnect" forState:UIControlStateNormal];
    [self deallocTimer];
}
*/
-(void)initTimer{
    [self getData];
//    if (!timer) {
//        timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(getData) userInfo:nil repeats:YES];
//    }
    
//    double delayInSeconds = 3.0f;
//    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//    dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
//                   {
////                       Byte buff[] = {0xaa,0x55,0x03,0x20,0x01,0x24};
//                       [self sendData:@"aa5503200124"];
//                   });
}
-(void)deallocTimer{
    [timer invalidate];
    timer = nil;
}
-(void)dealloc{
//    [_eaSessionController closeSession];
    isLink = NO;
    [_zoneHeadButton setTitle:disconnectStr forState:UIControlStateNormal];
    [self deallocTimer];
}
-(void)viewWillAppear:(BOOL)animated{
//    if (isLink) {
//        [self initTimer];
//    }
    [self btScan];
}
-(void)viewWillDisappear:(BOOL)animated{
//    [self deallocTimer];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)savePinlv{
    [_frequencyArray removeAllObjects];
    [_frequencyArray addObjectsFromArray:pinlvArray];
    [[NSUserDefaults standardUserDefaults]setObject:_frequencyArray forKey:@"frequency"];
    indexPinLv = 0;
    [pinlvArray removeAllObjects];
}
-(void)resetPinlv{
    indexPinLv = 0;
    [pinlvArray removeAllObjects];
}
@end
