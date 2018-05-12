//
//  BTViewController.m
//  Telecontroller
//
//  Created by hk on 17/10/25.
//  Copyright © 2017年 hk. All rights reserved.
//

#import "BTViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>

#define writeWithOutResponce  @"00010203-0405-0607-0809-0A0B0C0D2B11"
#define readAndNotifi   @"00010203-0405-0607-0809-0A0B0C0D2B10"
@interface BTViewController ()<UITableViewDataSource,UITableViewDelegate,CBCentralManagerDelegate,CBPeripheralDelegate>


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
        self.myCentralManager = [[CBCentralManager alloc]initWithDelegate:self queue:nil options:nil];
        _myPeripherals = [NSMutableArray array];
        
        double delayInSeconds = 2.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds* NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self scanClick];
        });
    }
    return self;
}
- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
}
- (IBAction)scan:(id)sender {
    [self scanClick];
}
//扫描
- (void)scanClick{
    [self.myCentralManager scanForPeripheralsWithServices:nil options:nil];
    if(_myPeripheral != nil){
        [_myCentralManager cancelPeripheralConnection:_myPeripheral];
    }
    
    double delayInSeconds = 20.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds* NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.myCentralManager stopScan];
        NSLog(@"扫描超时,停止扫描!");
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
            break;
            
        default:
            break;
    }
}
//查到外设后的方法,peripherals
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
    if (peripheral.name != nil) {
        [_myPeripherals addObject:peripheral];
        NSInteger count = [_myPeripherals count];
        NSLog(@"my periphearls count : %ld\n", (long)count);
        [_tableView reloadData];
    }
    
}
//连接外设成功
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    //  NSLog(@"成功连接 peripheral: %@ with UUID: %@",peripheral, peripheral.UUID);
    [_tableView reloadData];
    [self.myPeripheral setDelegate:self];
    [self.myPeripheral discoverServices:nil];
    NSLog(@"扫描服务...");
    
}
//连接断开时调用
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@"%@", error);
    [_tableView reloadData];
}
//连接外设失败
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@"%@", error);
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
        }

        if(c.properties & CBCharacteristicPropertyRead){
            NSLog(@"找到READ and  notify: %@", c.UUID);
            if ([c.UUID isEqual:[CBUUID UUIDWithString:readAndNotifi]]) {
                self.readCharacteristic = c;
                [self.myPeripheral setNotifyValue:YES forCharacteristic:c];
                [self.myPeripheral readValueForCharacteristic:c];
                NSLog(@"设置READ and  notify: %@", c.UUID);
            }
        }
//        if(c.properties & CBCharacteristicPropertyNotify){
//            NSLog(@"找到Notify : %@", c.UUID);
//            if ([c.UUID isEqual:[CBUUID UUIDWithString:@"8877"]]) {
//                self.readCharacteristic = c;
//                [self.myPeripheral setNotifyValue:YES forCharacteristic:c];
//                [self.myPeripheral readValueForCharacteristic:c];
//                NSLog(@"设置Notify : %@", c.UUID);
//            }
//        }
    }
}
//获取外设发来的数据,不论是read和notify,获取数据都从这个方法中读取
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    [peripheral readRSSI];
    NSNumber* rssi = [peripheral RSSI];
    if([characteristic.UUID isEqual:[CBUUID UUIDWithString:readAndNotifi]]){
        
        NSData* data = characteristic.value;
        NSString* value = [self hexadecimalString:data];
        NSLog(@"接受到数据%@  rssi%@",value,rssi);
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
- (void)writeToPeripheral:(NSData *)data{
    if(!_writeCharacteristic){
        NSLog(@"writeCharacteristic is nil!");
        return;
    }
    
//    NSData* value = [self dataWithHexstring:data];
    [_myPeripheral writeValue:data forCharacteristic:_writeCharacteristic type:CBCharacteristicWriteWithResponse];
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
    CBPeripheral *objPeripheral = _myPeripherals[indexPath.row];
    cell.textLabel.text = objPeripheral.name;
    
    NSString* uuid = [NSString stringWithFormat:@"%@", [[_myPeripherals objectAtIndex:indexPath.row] identifier]];
    uuid = [uuid substringFromIndex:[uuid length] - 13];
    
    if([self isPeripheralConnected:objPeripheral]){
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@_已连接",uuid];
    }else{
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@_未连接",uuid];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSUInteger rowNo = indexPath.row;
    _myPeripheral = [_myPeripherals objectAtIndex:rowNo];
    [self connectClick];
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
    NSMutableString* hexString = [NSMutableString stringWithCapacity:(dataLength * 2)];
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
