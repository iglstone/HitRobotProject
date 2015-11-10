//
//  SocketClientViewController.h
//  TeskSocket
//
//  Created by apple on 13-5-24.
//  Copyright (c) 2013年 Kid-mind Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncSocket.h"
@interface SocketClientViewController : UIViewController<AsyncSocketDelegate,UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate>
{
    AsyncSocket *clientSocket;
    
    CGFloat keyboradHeight;
    CGFloat screenHeight;
    CGFloat downHeight;
    NSMutableArray *messages;
    
    BOOL isSharing;
    NSMutableData *imageData;
    
}
@property (retain, nonatomic) IBOutlet UITextField *ipField;
@property (retain, nonatomic) IBOutlet UITextField *portField;

@property (retain, nonatomic) IBOutlet UITextView *resultTextview;

@property (nonatomic, retain) IBOutlet UITableView *chatTableView;
@property (nonatomic, retain) IBOutlet UITextField *textField;
@property (nonatomic, retain) IBOutlet UIButton *button;
- (IBAction)sendButtonPressed:(id)sender;
@end
