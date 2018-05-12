//
//  BTViewController.h
//  Telecontroller
//
//  Created by hk on 17/10/25.
//  Copyright © 2017年 hk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BTViewController : UIViewController
+(BTViewController*)shareInstance;
-(void)writeToPeripheral:(NSData *)data;
@end
