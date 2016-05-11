//
//  SPSetViewController.m
//  SendMessage
//
//  Created by fudon on 16/4/16.
//  Copyright © 2016年 fusu. All rights reserved.
//

#import "SPSetViewController.h"

@interface SPSetViewController ()

@end

@implementation SPSetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.countTF.keyboardType = UIKeyboardTypeNumberPad;
    // Do any additional setup after loading the view from its nib.
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

- (IBAction)saveData:(UIButton *)sender {
    if ([self.countTF.text integerValue]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ChangeBackCount" object:self.countTF.text];
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
@end
