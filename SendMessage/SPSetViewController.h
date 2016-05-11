//
//  SPSetViewController.h
//  SendMessage
//
//  Created by fudon on 16/4/16.
//  Copyright © 2016年 fusu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SPSetViewController : UIViewController
- (IBAction)saveData:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UITextField *countTF;

@end
