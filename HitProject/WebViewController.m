//
//  WebViewController.m
//  HitProject
//
//  Created by 郭龙 on 15/12/2.
//  Copyright © 2015年 郭龙. All rights reserved.
//

#import "WebViewController.h"
#import <UIView+Toast.h>

@interface WebViewController () <UIWebViewDelegate>
{
    UIActivityIndicatorView *activityIndicatorView;
}

@property (nonatomic) UIWebView *webView;

@end

@implementation WebViewController
@synthesize webView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"公司简介";
    
    webView = [UIWebView new];
    [self.view addSubview:webView];
    [webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    webView.scalesPageToFit =YES;
    webView.delegate = self;
    
    activityIndicatorView = [[UIActivityIndicatorView alloc]
                             initWithFrame : CGRectMake(0.0f, 0.0f, 32.0f, 32.0f)] ;
    [activityIndicatorView setCenter: self.view.center] ;
    [activityIndicatorView setActivityIndicatorViewStyle: UIActivityIndicatorViewStyleGray] ;
    [self.view addSubview : activityIndicatorView];
    
    UIButton *backBtn = [UIButton new];
    backBtn.backgroundColor = [UIColor blueColor];
    [backBtn setTitle:@"<-返回" forState:UIControlStateNormal];
    [self.view addSubview:backBtn];
    [backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(-20);
        make.left.equalTo(self.view).offset(20);
        make.size.mas_equalTo(CGSizeMake(90, 40));
    }];
    [backBtn addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)back :(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self loadWebPageWithString:@"http://www.hitrobot.com.cn/"];
    [activityIndicatorView startAnimating] ;
}

- (void)loadWebPageWithString:(NSString*)urlString
{
    NSURL *url =[NSURL URLWithString:urlString];
    NSLog(@"urlString: %@", urlString);
    NSURLRequest *request =[NSURLRequest requestWithURL:url];
    [webView loadRequest:request];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
//    [activityIndicatorView startAnimating] ;
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [activityIndicatorView stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
//    UIAlertView *alterview = [[UIAlertView alloc] initWithTitle:@"" message:[error localizedDescription]  delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
//    [alterview show];
//    [activityIndicatorView stopAnimating];
//    [self.view makeToast:@"stoping"];
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
