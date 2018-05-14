//
//  BTViewController.m
//  Telecontroller
//
//  Created by hk on 17/10/25.
//  Copyright © 2017年 hk. All rights reserved.
//
#import "AppDelegate.h"
#import "BTViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>

#define writeWithOutResponce  @"00010203-0405-0607-0809-0A0B0C0D2B11" //读写无回音
#define readAndNotifi   @"00010203-0405-0607-0809-0A0B0C0D2B10"    //通知 读
#define readAndNotifi2   @"00010203-0405-0607-0809-0A0B0C0D2B12"   //读写无回音

#define UUID_bt  @"blueTooth_uuid"
@interface BTViewController ()<UITableViewDataSource,UITableViewDelegate,CBCentralManagerDelegate,CBPeripheralDelegate,UIAlertViewDelegate>
{
    int scanNumber ;
    UIAlertView *viewAlert;
    NSTimer *timerT;
    int timeInt;
    int changeBTLinkInt;
    int countTimer;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) CBCentralManager* myCentralManager;
@property (strong, nonatomic) NSMutableArray* myPeripherals;
@property (strong, nonatomic) CBPeripheral* myPeripheral;
@property (strong, nonatomic) NSMutableArray* nServices;
@property (strong, nonatomic) NSMutableArray* nDevices;
@property (strong, nonatomic) NSMutableArray* nCharacteristics;
@property (strong, nonatomic) CBCharacteristic* writeCharacteristic;
@property (strong, nonatomic) CBCharacteristic* readCharacteristic;

@end

@implementation BTViewController
+(BTViewController*)shareInstance{
    static BTViewController *instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^
                  {
                      instance = [[[self class] alloc] init];
                  });
    return instance;
}
-(id)init{
    if (self = [super init]) {
        scanNumber = 0;
        countTimer = 0;
        _isCanLink = YES;
        _frequencyArray = [NSMutableArray array];
        self.myCentralManager = [[CBCentralManager alloc]initWithDelegate:self queue:nil options:nil];
        _myPeripherals = [NSMutableArray array];
        
        double delayInSeconds = 0.5;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds* NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self scanClick];
        });
        timerT = [NSTimer scheduledTimerWithTimeInterval:3.0
                                                  target:self
                                                selector:@selector(cherkModeOrfrequency)
                                                userInfo:nil
                                                 repeats:YES];
    }
    return self;
}
- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
}
- (IBAction)scan:(id)sender {
    [self scanClick];
}
-(void)cherkModeOrfrequency{
    if (_BTisLink) {
        if (_isNeedCheck) {
            [self writeToPeripheral:@"aa550310ff12"];
        }
    }

}
//扫描
- (void)scanClick{
    countTimer = 0;
    NSArray *peripheralArr = [_myPeripherals copy];
    
    for (NSDictionary *peripheralDict in peripheralArr) {
        CBPeripheral *peripheral = peripheralDict[@"peripheral"];
        if (![self isPeripheralConnected:peripheral]) {
            [_myPeripherals removeObject:peripheralDict];
        }
    }
    [_tableView reloadData];

    [self.myCentralManager scanForPeripheralsWithServices:nil options:nil];

    scanNumber ++;
    int a = scanNumber;
    double delayInSeconds = 20.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds* NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        if (a == scanNumber) {
            [self.myCentralManager stopScan];
            NSLog(@"扫描超时,停止扫描!");
        }
    });
}
//连接
- (void)connectClick{
    [self.myCentralManager connectPeripheral:self.myPeripheral options:nil];
}
//开始查看服务, 蓝牙开启
- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    switch (central.state) {
        case CBCentralManagerStatePoweredOn:
            NSLog(@"蓝牙已打开, 请扫描外设!");
            [viewAlert dismissWithClickedButtonIndex:0 animated:NO];
            ((AppDelegate *)[UIApplication sharedApplication].delegate).BTisOpen = YES;
            break;
            
        default:
        {
            _myPeripheral  = nil;
            [_tableView reloadData];
            if (_BLEDEGATE && [_BLEDEGATE respondsToSelector:@selector(btIsConnect:)]) {
                [_BLEDEGATE btIsConnect:NO];
            }
            ((AppDelegate *)[UIApplication sharedApplication].delegate).BTisOpen = NO;
            
            viewAlert = [[UIAlertView alloc]initWithTitle:nil message:@"Please open Bluetooth" delegate:nil cancelButtonTitle:@"I Know" otherButtonTitles:nil, nil];
            [viewAlert  show];
        }
            break;
    }
}
//查到外设后的方法,peripherals
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
    if ([peripheral.name isEqualToString:@"tModule"] || [peripheral.name isEqualToString:@"tModul"] || [peripheral.name isEqualToString:@"Hertz App"]) {
        NSString* uuid = [NSString stringWithFormat:@"%@", [peripheral identifier]];
        uuid = [uuid substringFromIndex:[uuid length] - 13];
        
        NSArray *peripheralArr = [_myPeripherals copy];
        BOOL isFind = NO;
        for (NSDictionary *peripheralDict in peripheralArr) {
            NSString *peripheralUUID = peripheralDict[@"uuid"];
            if ([peripheralUUID isEqualToString:uuid]) {
                isFind = YES;
            }
        }
        if (isFind) {
            return;
        }
        countTimer = 0;
        NSDictionary *peripheralDict = @{@"peripheral":peripheral,@"uuid":uuid};
        
        [_myPeripherals addObject:peripheralDict];
        NSInteger count = [_myPeripherals count];
        NSLog(@"my periphearls count : %ld\n", (long)count);
        [_tableView reloadData];
        if (_isCanLink) {  //[[[NSUserDefaults standardUserDefaults]objectForKey:UUID_bt] isEqualToString:uuid]
            if (_myPeripheral == nil) {
                _myPeripheral = peripheral;
                [self connectClick];
            }
        }
    }
}
//连接外设成功
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    //  NSLog(@"成功连接 peripheral: %@ with UUID: %@",peripheral, peripheral.UUID);
    [_tableView reloadData];
    [self.myPeripheral setDelegate:self];
    [self.myPeripheral discoverServices:nil];
    NSLog(@"扫描服务...");
    
    
    if (_BLEDEGATE && [_BLEDEGATE respondsToSelector:@selector(btIsConnect:)]) {
        [_BLEDEGATE btIsConnect:YES];
    }
    timeInt = 8;

    
}
-(void)cherkBT{
    timeInt --;
    changeBTLinkInt --;
    NSLog(@"timeInt = %d  changeBTLinkInt= %d",timeInt,changeBTLinkInt);
    if (timeInt <= 0) {
        if (_myPeripheral!= nil) {
            [_myCentralManager cancelPeripheralConnection:_myPeripheral];
            _myPeripheral = nil;
        }
        [self scanClick];
        timeInt = 0;
    }
    if (changeBTLinkInt <= 0) {

        if (_BLEDEGATE && [_BLEDEGATE respondsToSelector:@selector(btIsConnect:)]) {
            [_BLEDEGATE btIsConnect:NO];
        }
        changeBTLinkInt = 0;
    }
    if (_myPeripherals.count == 0 ) {
        countTimer ++;
        if (countTimer >= 8) {
            if (_myPeripheral!= nil) {
                [_myCentralManager cancelPeripheralConnection:_myPeripheral];
                _myPeripheral = nil;
            }
            [self scanClick];
            timeInt = 0;
            if (_BLEDEGATE && [_BLEDEGATE respondsToSelector:@selector(btIsConnect:)]) {
                [_BLEDEGATE btIsConnect:NO];
            }
            changeBTLinkInt = 0;
        }
    }
}
//连接断开时调用
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@"%@   _myPeripheral = nil", error);
    _myPeripheral  = nil;
    [_tableView reloadData];
    if (_BLEDEGATE && [_BLEDEGATE respondsToSelector:@selector(btIsConnect:)]) {
        [_BLEDEGATE btIsConnect:NO];
    }
    [self scanClick];
}
//连接外设失败
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@"%@   _myPeripheral = nil", error);
    _myPeripheral  = nil;
    [_tableView reloadData];
    if (_BLEDEGATE && [_BLEDEGATE respondsToSelector:@selector(btIsConnect:)]) {
        [_BLEDEGATE btIsConnect:NO];
    }
    [self scanClick];
}
//已发现服务
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    NSLog(@"发现服务!");
    int i = 0;
    for(CBService* s in peripheral.services){
        [self.nServices addObject:s];
    }
    for(CBService* s in peripheral.services){
        NSLog(@"%d :服务 UUID: %@(%@)", i, s.UUID.data, s.UUID);
        i++;
        [peripheral discoverCharacteristics:nil forService:s];
        NSLog(@"扫描Characteristics...");
    }
}
//已发现characteristcs
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    for(CBCharacteristic* c in service.characteristics){
        NSLog(@"特征 UUID: %@ (%@)-------%lu", c.UUID.data,c.UUID,(unsigned long)c.properties);
//        if(c.properties & CBCharacteristicPropertyWrite){
//            
//            NSLog(@"找到WRITE : %@", c.UUID);
//            if ([c.UUID isEqual:[CBUUID UUIDWithString:@"8888"]]) {
//                self.writeCharacteristic = c;
//                NSLog(@"设置WRITE : %@", c.UUID);
//            }
//        }
        if(c.properties & CBCharacteristicPropertyWriteWithoutResponse){
            
            NSLog(@"找到WRITE : %@", c.UUID);
            if ([c.UUID isEqual:[CBUUID UUIDWithString:writeWithOutResponce]]) {
                self.writeCharacteristic = c;
                NSLog(@"设置WRITE : %@", c.UUID);
            }
            
            
            NSString* uuid = [NSString stringWithFormat:@"%@", [peripheral identifier]];
            uuid = [uuid substringFromIndex:[uuid length] - 13];
            [[NSUserDefaults standardUserDefaults]setObject:uuid forKey:UUID_bt];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
        }

        if(c.properties & CBCharacteristicPropertyRead){
            NSLog(@"找到READ and  notify: %@", c.UUID);
//            if ([c.UUID isEqual:[CBUUID UUIDWithString:readAndNotifi]]) {
//                self.readCharacteristic = c;
//                [self.myPeripheral setNotifyValue:YES forCharacteristic:c];
//                [self.myPeripheral readValueForCharacteristic:c];
//                NSLog(@"设置READ and  notify: %@", c.UUID);
//            }
        }
        if(c.properties & CBCharacteristicPropertyNotify){
            NSLog(@"找到Notify : %@", c.UUID);
            if ([c.UUID isEqual:[CBUUID UUIDWithString:readAndNotifi]]) {
                self.readCharacteristic = c;
                [self.myPeripheral setNotifyValue:YES forCharacteristic:c];
                [self.myPeripheral readValueForCharacteristic:c];
                NSLog(@"设置Notify : %@", c.UUID);
            }
        }
    }
}
//获取外设发来的数据,不论是read和notify,获取数据都从这个方法中读取
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    
    timeInt = 8;
    changeBTLinkInt = 15;
    
    [peripheral readRSSI];
    NSNumber* rssi = [peripheral RSSI];
//    if([characteristic.UUID isEqual:[CBUUID UUIDWithString:readAndNotifi]]){
    
        NSData* data = characteristic.value;
        NSString* value = [self hexadecimalString:data];
        NSLog(@"接受到数据%@  rssi%@",value,rssi);



    int dataLong = ((const char *)[data bytes])[2];
    switch (dataLong) {
        case 0x0e:
        {
            _isNeedCheck = NO;
            //        aa 55 0e 02 0212 0258 03e8 0578 06ae 0212 a0
            //        aa 55 0e 02 0212 0258 03e8 0578 06ae 222e ad
            if (((const char *)[data bytes])[3] == 0x02) {
                _frequency = AM;
            }else if(((const char *)[data bytes])[3] == 0x01){
                _frequency = FM;
            }else if(((const char *)[data bytes])[3] == 0x04){
                _frequency = WB;
            }
            [_frequencyArray removeAllObjects];
            
            for (int i = 4; i < 15; i = i + 2)  {
                UInt16 a = ((const char *)[data bytes])[i] & 0xFF;
                UInt16 b = ((const char *)[data bytes])[i + 1] & 0xFF;
                

                
                UInt16 c = (a << 8) + b;

                if  (_frequency == FM){
                    NSString *cStr = [NSString stringWithFormat:@"%.2f",c/100.];
                    [_frequencyArray addObject:cStr];
                }else if(_frequency == AM){
                    NSString *cStr = [NSString stringWithFormat:@"%d",c];
                    [_frequencyArray addObject:cStr];
                }
                else if(_frequency == WB){
                    NSString *cStr = [NSString stringWithFormat:@"162.%d",c];
                    [_frequencyArray addObject:cStr];
                }
            }
            if (_BLEDEGATE && [_BLEDEGATE respondsToSelector:@selector(changeFrequency:)]) {
                [_BLEDEGATE changeFrequency:_frequencyArray];
            }
        }
            break;
//        case 0x03:
//        {
//         
//            _modeInt = ((const char *)[data bytes])[3];
//            
//        }
//            break;
        default:
        {
            //aa 55 03 02 01 06
            int address = ((const char *)[data bytes])[3];
            switch (address) {
//                case 0x02:
//                {
//                    UInt16 b = ((const char *)[data bytes])[4];
//                    NSString *bStr = [NSString stringWithFormat:@"%d",b];
//                    
//                    if (_BLEDEGATE && [_BLEDEGATE respondsToSelector:@selector(changeHeadMode:)]) {
//                        [_BLEDEGATE changeHeadMode:bStr];
//                    }
//                }
//                    break;
                case 0x03:{
                    _isNeedCheck = NO;
                    if (((const char *)[data bytes])[4] != 0) {
                        _modeInt = ((const char *)[data bytes])[4];
                    }else{
                        _modeInt = ((const char *)[data bytes])[5];
                    }
                    
//                    NSString *bStr = [NSString stringWithFormat:@"%d",b];
//                    
//                    if (_BLEDEGATE && [_BLEDEGATE respondsToSelector:@selector(changeMuteState:)]) {
//                        [_BLEDEGATE changeMuteState:bStr];
//                    }
                }
                    break;
                case 0x04:
                {
                    //        aa 55 0e 02 0212 0258 03e8 0578 06ae 222e ad
//                    _frequency = WB;
//                    [_frequencyArray removeAllObjects];
//                    for (int i = 4; i < 15; i = i + 2)  {
//                        UInt16 a = ((const char *)[data bytes])[i] & 0xFF;
//                        UInt16 b = ((const char *)[data bytes])[i + 1] & 0xFF;
//                        
//                        
//                        
//                        UInt16 c = (a << 8) + b;
//                        NSString *cStr = [NSString stringWithFormat:@"162.%d",c];
//                        [_frequencyArray addObject:cStr];
//                        
//                    }
//                    if (_BLEDEGATE && [_BLEDEGATE respondsToSelector:@selector(changeFrequency:)]) {
//                        [_BLEDEGATE changeFrequency:_frequencyArray];
//                    }

                    
                    
                }
                    break;
                    //menu键状态
                case 0x05:
                {
//          接受到数据aa5503050109
                 int muteInt = ((const char *)[data bytes])[4];
                    if (muteInt == 0) {
                        if (_BLEDEGATE && [_BLEDEGATE respondsToSelector:@selector(setHigthButton:
                                                                                   isSelected:)]) {
                            [_BLEDEGATE setHigthButton:1005 isSelected:NO];
                        }
                    }else if(muteInt == 1){
                        if (_BLEDEGATE && [_BLEDEGATE respondsToSelector:@selector(setHigthButton:
                                                                                   isSelected:)]) {
                            [_BLEDEGATE setHigthButton:1005 isSelected:YES];
                        }
                    }
                    

                }
                    break;
                    //load键状态
                case 0x06:
                {
                    int muteInt = ((const char *)[data bytes])[4];
                    if (muteInt == 0) {
                        if (_BLEDEGATE && [_BLEDEGATE respondsToSelector:@selector(setHigthButton:
                                                                                   isSelected:)]) {
                            [_BLEDEGATE setHigthButton:1006 isSelected:NO];
                        }
                    }else if(muteInt == 1){
                        if (_BLEDEGATE && [_BLEDEGATE respondsToSelector:@selector(setHigthButton:
                                                                                   isSelected:)]) {
                            [_BLEDEGATE setHigthButton:1006 isSelected:YES];
                        }
                    }

                }
                    break;
                    //off键状态
                case 0x07:
                {
                    int muteInt = ((const char *)[data bytes])[4];
                    if (muteInt == 1) {
                        if (_BLEDEGATE && [_BLEDEGATE respondsToSelector:@selector(setHigthButton:
                                                                                   isSelected:)]) {
                            [_BLEDEGATE setHigthButton:1007 isSelected:NO];
                        }
                    }else if(muteInt == 0){
                        if (_BLEDEGATE && [_BLEDEGATE respondsToSelector:@selector(setHigthButton:
                                                                                   isSelected:)]) {
                            [_BLEDEGATE setHigthButton:1007 isSelected:YES];
                        }
                    }

                }
                    break;
                default:
                    break;
            }
        
        }
            break;
    }
}
//中心读取外设实时数据
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if(error){
        NSLog(@"Error changing notification state: %@", error.localizedDescription);
    }
    //Notification has started
    if(characteristic.isNotifying){
        [peripheral readValueForCharacteristic:characteristic];
    }else{
        NSLog(@"Notification stopped on %@. Disconnting", characteristic);
        [self.myCentralManager cancelPeripheralConnection:self.myPeripheral];
    }
}
//向peripheral中写入数据
- (void)writeToPeripheral:(NSString *)data{
    if(!_writeCharacteristic){
        NSLog(@"writeCharacteristic is nil!");
        return;
    }
    
    NSData* value = [self dataWithHexstring:data];
    [_myPeripheral writeValue:value forCharacteristic:_writeCharacteristic type:CBCharacteristicWriteWithoutResponse];
    
//    double delayInSeconds = 0.3f;
//    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//    dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
//                   {
//                       
//                       [self.myPeripheral readValueForCharacteristic:self.readCharacteristic];
//                       
//                   });

}
//向peripheral中写入数据后的回调函数
- (void)peripheral:(CBPeripheral*)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    NSLog(@"write value success : %@", characteristic);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _myPeripherals.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString* cellId = @"cellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
    }
    NSDictionary *peripheral = _myPeripherals[indexPath.row];
    CBPeripheral *objPeripheral = peripheral[@"peripheral"];
    cell.textLabel.text = objPeripheral.name;
    
    NSString* uuid = peripheral[@"uuid"];
    
    if([self isPeripheralConnected:objPeripheral]){
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@_connected",uuid];
    }else{
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@_disconnect",uuid];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    
    NSDictionary *peripheral = _myPeripherals[indexPath.row];
    CBPeripheral *objPeripheral = peripheral[@"peripheral"];
    if ([self isPeripheralConnected:objPeripheral]) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:@"Disconnecting Bluetooth will clear the Bluetooth connection record,confirm?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
        [alertView show];
    }else{
        _isCanLink = YES;
        NSDictionary *peripheral = _myPeripherals[indexPath.row];
        CBPeripheral *objPeripheral = peripheral[@"peripheral"];
        if (_myPeripheral!= nil) {
            [_myCentralManager cancelPeripheralConnection:_myPeripheral];
            _myPeripheral = nil;
        }
        _myPeripheral = objPeripheral;
        [self connectClick];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
            if(_myPeripheral != nil){
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:UUID_bt];
                [_myCentralManager cancelPeripheralConnection:_myPeripheral];
                _myPeripheral = nil;
                _isCanLink = NO;
            }
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//将传入的NSData类型转换成NSString并返回
- (NSString*)hexadecimalString:(NSData *)data{
    NSString* result;
    const unsigned char* dataBuffer = (const unsigned char*)[data bytes];
    if(!dataBuffer){
        return nil;
    }
    NSUInteger dataLength = [data length];
    NSMutableString* hexString = [NSMutableString stringWithCapacity:(dataLength * 2 )];
    for(int i = 0; i < dataLength; i++){
        [hexString appendString:[NSString stringWithFormat:@"%02lx", (unsigned long)dataBuffer[i]]];
    }
    result = [NSString stringWithString:hexString];
    return result;
}

//将传入的NSString类型转换成NSData并返回
- (NSData*)dataWithHexstring:(NSString *)hexstring{
    NSMutableData* data = [NSMutableData data];
    int idx;
    for(idx = 0; idx + 2 <= hexstring.length; idx += 2){
        NSRange range = NSMakeRange(idx, 2);
        NSString* hexStr = [hexstring substringWithRange:range];
        NSScanner* scanner = [NSScanner scannerWithString:hexStr];
        unsigned int intValue;
        [scanner scanHexInt:&intValue];
        [data appendBytes:&intValue length:1];
    }
    return data;
}
-(BOOL)isPeripheralConnected:(CBPeripheral*)peripheral
{
    if (peripheral == nil)
    {
        return NO;
    }
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0)
    {
        return peripheral.state == CBPeripheralStateConnected?YES:NO;
    }
    else
    {
#ifndef __IPHONE_7_0
        return peripheral.isConnected;
#endif
    }
    return NO;
}
-(BOOL)isPeripheral:(CBPeripheral*)peripheral1 equalPeripheral:(CBPeripheral*)peripheral2
{
    if (peripheral1 == nil || peripheral2 == nil)
    {
        return NO;
    }
    if ([[UIDevice currentDevice].systemVersion floatValue] < 7.0)
    {
#ifndef __IPHONE_9_0 //如果__IPHONE_9_0没有被定义，则重定义__IPHONE_9_0，并执行#endif前面的return；如果__IPHONE_9_0已经被定义，则跳过直接执行#endif后面的语句
        return peripheral1.UUID == peripheral2.UUID;
#endif
    }
    else
    {
        return peripheral1.identifier == peripheral2.identifier;
    }
    return NO;
}
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
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
