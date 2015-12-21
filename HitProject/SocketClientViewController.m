//
//  SocketClientViewController.m
//  TeskSocket
//
//  Created by apple on 13-5-24.
//  Copyright (c) 2013年 Kid-mind Studios. All rights reserved.
//

#import "SocketClientViewController.h"
#import <ifaddrs.h>
#import <arpa/inet.h>
@interface SocketClientViewController ()

@end

@implementation SocketClientViewController

- (void)connectHost:(NSString *)ip port:(NSUInteger)port
{
    if (![clientSocket isConnected])
    {
        NSError *error = nil;
        [clientSocket connectToHost:ip onPort:port withTimeout:-1 error:&error];
        if (error)
        {
            NSLog(@"connectToHost error %@",error);
            [clientSocket disconnect];
        }
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
        {
        clientSocket = [[AsyncSocket alloc] initWithDelegate:self];
        [clientSocket setRunLoopModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
            
        messages = [[NSMutableArray alloc] initWithCapacity:1];
    }
    return self;
}
- (void)downKeyboard:(UITextField *)textField
{
    
}

- (void)writeData:(NSString *)string
{
    NSData *cmdData = [string dataUsingEncoding:NSUTF8StringEncoding];
    [clientSocket writeData:cmdData withTimeout:-1 tag:0];
}

- (NSString *)getIPAddress
{
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0)
    {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL)
        {
            if(temp_addr->ifa_addr->sa_family == AF_INET)
            {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"])
                {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
    
}

- (void)insertStringToTable:(NSString *)string
{
    if (string == nil) return;
    [messages insertObject:string atIndex:0];
    [self.chatTableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
//    {
//        keyboradHeight = 216;
//        screenHeight = 480;
//        downHeight = 373;
//    }
//    else
//    {
//        keyboradHeight = 264;
//        screenHeight = 1024;
//        downHeight = 373 +543;
//    }
//    
//    [self.ipField becomeFirstResponder];
//    self.ipField.keyboardType = UIKeyboardTypeNumberPad;
//    self.portField.keyboardType = UIKeyboardTypeNumberPad;
//    self.ipField.returnKeyType = UIReturnKeyDone;
//    self.portField.returnKeyType = UIReturnKeyDone;
//    [self.portField addTarget:self action:@selector(downKeyboard:) forControlEvents:UIControlEventEditingDidEndOnExit];
//    [self.ipField addTarget:self action:@selector(downKeyboard:) forControlEvents:UIControlEventEditingDidEndOnExit];
//    
//    
//    self.chatTableView.dataSource = self;
//    self.chatTableView.delegate = self;
//    
//    self.textField.delegate = self;
//    self.textField.returnKeyType = UIReturnKeyDone;
//    [self.textField addTarget:self action:@selector(moveDownTextFieldAndButton) forControlEvents:UIControlEventEditingDidEndOnExit];
//
//    imageData = [[NSMutableData alloc] init];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *btn =[UIButton new];
    [self.view addSubview:btn];
    btn.backgroundColor = [UIColor orangeColor];
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
    }];
    [btn setTitle:@"llianjie" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(sele:) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void) sele :(id)sender {
//    NSString *serverip = [CommonsFunc getIPAddressByHostName:@"guolongios.imwork.net"];//http://guolongios.imwork.net:20935/
    NSString *serverip = @"60.166.32.242";
    NSLog(@"serverip: %@",serverip);
    [self connectHost:serverip port:1234];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)connect:(id)sender
{
    [self connectHost:self.ipField.text port:self.portField.text.integerValue];
    
}
- (void)moveDownTextFieldAndButton
{
    [self.textField resignFirstResponder];
    self.textField.frame = CGRectMake(0, downHeight, self.textField.frame.size.width, self.textField.frame.size.height);
    self.button.frame = CGRectMake(self.button.frame.origin.x, downHeight, self.button.frame.size.width, self.button.frame.size.height);
    
}
- (IBAction)sendButtonPressed:(id)sender
{
    NSLog(@"发送");
    NSString *message = self.textField.text;
    NSData *cmdData = [message dataUsingEncoding:NSUTF8StringEncoding];
    [clientSocket writeData:cmdData withTimeout:-1 tag:0];
    [messages insertObject:[NSString stringWithFormat:@"client:%@",self.textField.text] atIndex:0];
    [self.chatTableView reloadData];
    [self moveDownTextFieldAndButton];
}
#pragma mark Delegate

- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err
{
    NSLog(@"client willDisconnectWithError:%@",err);
}

- (void)onSocketDidDisconnect:(AsyncSocket *)sock
{
    [messages insertObject:@"服务器已断开" atIndex:0];
    [self.chatTableView reloadData];
    NSLog(@"client onSocketDidDisconnect");
}

- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    
    NSLog(@"client didConnectToHost");
    
    self.resultTextview.text = host;
    
    //这是异步返回的连接成功，
    [sock readDataWithTimeout:-1 tag:0];
}

- (NSString *)dataToString:(NSData *)data
{
    return [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
}

- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    
    NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    if(msg)
    {
        //处理受到的数据
//        NSLog(@"收到的数据:%@",msg);
        [messages insertObject:[NSString stringWithFormat:@"server:%@",msg] atIndex:0];
        if ([msg isEqualToString:@"9999"])
        {
//            [clientSocket disconnect];
            UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
            if ([keyWindow viewWithTag:50] == nil)
            {
                UIView *v = [[UIView alloc] initWithFrame:keyWindow.bounds];
                v.backgroundColor = [UIColor blackColor];
                v.alpha = 0.5f;
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
                label.text = @"认真听课，您被控屏了，哈哈！";
                label.font = [UIFont systemFontOfSize:40];
                [label sizeToFit];
                [v addSubview:label];
                label.center = v.center;
                v.tag = 50;
                [label release];
                [keyWindow addSubview:v];
                [v release];
                [self.ipField resignFirstResponder];
                [self.portField resignFirstResponder];
            }
        }
        
        if ([msg isEqualToString:@"10000"])
        {
            [[[UIApplication sharedApplication].keyWindow viewWithTag:50] removeFromSuperview];
        }
        
        if ([msg isEqualToString:@"西点军校在哪个国家 ？"])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:msg message:nil delegate:nil cancelButtonTitle:@"美国" otherButtonTitles:@"中国",@"日本",@"英国",nil];
            [alert show];
            alert.delegate = self;
            [alert autorelease];
        }
        
        if ([msg isEqualToString:@"sharescreen"])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"教师要和你共享屏幕，是否接受？" delegate:nil cancelButtonTitle:@"否" otherButtonTitles:@"是",nil];
            alert.tag = 40;
            [alert show];
            alert.delegate = self;
            [alert autorelease];
        }
        
        if ([msg isEqualToString:@"stopsharescreen"])
        {
//            [self hideServerScreen];
        }
        
        if (isSharing)
        {
            [imageData appendData:data];
            [self writeData:msg];
        }
        
        if ([msg isEqualToString:@"stopWriteScreen"])
        {
//            [self showScreenData];
        }
        
        [self.chatTableView reloadData];
    }
    else
    {
        
        NSLog(@"Error converting received data into UTF-8 String");
        
    }
    
    static int first = 0;
    if (!first)
    {
        NSString *message = @"连接成功";
        NSData *cmdData = [message dataUsingEncoding:NSUTF8StringEncoding];
        [sock writeData:cmdData withTimeout:-1 tag:0];
        first ++;
    }

    [sock readDataWithTimeout:-1 tag:0];
}

-(void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    NSLog(@"client didWriteDataWithTag:%ld",tag);
    [sock readDataWithTimeout:-1 tag:0];
}
- (void)dealloc
{
    [clientSocket disconnect];
    clientSocket.delegate = nil;
    
    [clientSocket release];
    [_ipField release];
    [_portField release];
    [_resultTextview release];
    
    [_textField release];
    [_chatTableView release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setResultTextview:nil];
    [super viewDidUnload];
}
#pragma mark - UITableView DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [messages count];
}
#pragma mark - UITableView Delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSString *text = [messages objectAtIndex:indexPath.row];
    if ([text hasPrefix:@"server"])
    {
        cell.textLabel.textAlignment = NSTextAlignmentLeft;
        cell.textLabel.text = text;
    }
    else
    {
        cell.textLabel.textAlignment = NSTextAlignmentRight;
        cell.textLabel.text = text;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
#pragma mark - UITextField Delegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.textField.frame = CGRectMake(0, screenHeight-20-keyboradHeight-44-self.textField.frame.size.height, self.textField.frame.size.width, self.textField.frame.size.height);
    self.button.frame = CGRectMake(self.button.frame.origin.x, screenHeight-20-keyboradHeight-44-self.button.frame.size.height, self.button.frame.size.width, self.button.frame.size.height);
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 40)
    {
        if (buttonIndex == 0)
        {
            [self insertStringToTable:@"no"];
        }
        else
        {
            [self insertStringToTable:@"yes"];
        }
    }
    else
    {
        NSString *message = nil;
        switch (buttonIndex)
        {
            case 0:message = @"美国";break;
            case 1:message = @"中国";break;
            case 2:message = @"日本";break;
            case 3:message = @"英国";break;
            default:
                break;
        }
        NSData *cmdData = [message dataUsingEncoding:NSUTF8StringEncoding];
        [clientSocket writeData:cmdData withTimeout:-1 tag:0];
        
    }
}
@end
