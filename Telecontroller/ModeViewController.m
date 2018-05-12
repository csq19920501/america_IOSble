//
//  ModeViewController.m
//  Telecontroller
//
//  Created by hk on 17/5/13.
//  Copyright © 2017年 hk. All rights reserved.
//

#import "ModeViewController.h"
#import "BTViewController.h"
@interface ModeViewController ()

@property (weak, nonatomic) IBOutlet UIButton *raidoButton;
@property (weak, nonatomic) IBOutlet UIButton *sxmButton;
@property (weak, nonatomic) IBOutlet UIButton *usbButton;
@property (weak, nonatomic) IBOutlet UIButton *auxButton;
@property (weak, nonatomic) IBOutlet UIButton *btButton;
@end

@implementation ModeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    dispatch_async(dispatch_get_main_queue(), ^{
        
    

        [self changeSelect:[BTViewController shareInstance].modeInt];
    });
    
}
-(void)changeSelect:(int )select{
    for (UIButton *view in self.view.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            [(UIButton*)view setSelected:NO];
        }
    }
    switch (select) {
        case 1:
        {
            _raidoButton.selected = YES;
           

        }
            break;
        case 2:
        {
            _sxmButton.selected = YES;
            
        }
            break;
        case 3:
        {
            _usbButton.selected = YES;
            
        }
            break;
        case 5:
        {
            _auxButton.selected = YES;
        }
            break;
        case 4:
        {
            _btButton.selected = YES;
        }
            break;
        default:
            break;
    }
}
- (IBAction)back:(id)sender {
    [self dismissModalViewControllerAnimated:true];
}


- (IBAction)cancelRadioButton:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(buttonNumber:)]) {
        [self changeSelect:1];
        [_delegate buttonNumber:1];
    }
    [self dismissModalViewControllerAnimated:true];
}
- (IBAction)SXMbutton:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(buttonNumber:)]) {
        [self changeSelect:2];
        [_delegate buttonNumber:2];
    }
    [self dismissModalViewControllerAnimated:true];

}
- (IBAction)USBbutton:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(buttonNumber:)]) {
        [self changeSelect:3];
        [_delegate buttonNumber:3];
    }
    [self dismissModalViewControllerAnimated:true];

}
- (IBAction)AUXbutton:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(buttonNumber:)]) {
        [_delegate buttonNumber:4];
        [self changeSelect:4];
    }
    [self dismissModalViewControllerAnimated:true];

}
- (IBAction)BTAudioButton:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(buttonNumber:)]) {
        [_delegate buttonNumber:5];
        [self changeSelect:5];
    }
    [self dismissModalViewControllerAnimated:true];
}
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
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
