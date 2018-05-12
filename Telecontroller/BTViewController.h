//
//  BTViewController.h
//  Telecontroller
//
//  Created by hk on 17/10/25.
//  Copyright © 2017年 hk. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, Frequency) {
    FM = 0,
    AM = 1,
    WB = 2,
};

typedef NS_ENUM(NSInteger,ModeInt) {
    RADIO = 1,
    SXM ,
    USB ,
    BT ,
    AUX ,
};

@protocol BleDelegate <NSObject>
-(void)btIsConnect:(BOOL)isLink;
-(void)changeFrequency:(NSArray*)frequency;
-(void)changeHeadMode:(NSString *)modeStr;
-(void)changeMuteState:(NSString *)muteStr;
-(void)setHigthButton:(NSInteger)tag isSelected:(BOOL)isSele;
@end
@interface BTViewController : UIViewController

@property (nonatomic,weak)id<BleDelegate> BLEDEGATE;
@property (nonatomic ,assign)Frequency frequency;
@property (nonatomic ,assign)ModeInt modeInt;
@property (nonatomic ,assign)BOOL BTisLink;
@property (nonatomic ,assign)BOOL isNeedCheck;
@property (nonatomic ,assign)BOOL isCanLink;
@property (nonatomic,strong)NSMutableArray *frequencyArray;
+(BTViewController*)shareInstance;
-(void)writeToPeripheral:(NSString *)data;
-(void)scanClick;
@end
