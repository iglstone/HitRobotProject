//
//  QQViewController.h
//  QQLogin
//
//  Created by 郭龙 on 15/12/2.
//  Copyright © 2015年 郭龙. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController
{
    NSMutableArray *_currentAccounts;
}

@property (retain, nonatomic) IBOutlet UIView *moveDownGroup;

@property (retain, nonatomic) IBOutlet UITextField *userPassword;
@property (retain, nonatomic) IBOutlet UILabel *passwordLabel;

@property (retain, nonatomic) IBOutlet UIImageView *userLargeHead;

@property (retain, nonatomic) NSMutableArray *userNamesArray;
- (IBAction)login:(id)sender;

@end
