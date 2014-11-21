//
//  ViewController.m
//  XMPPPush
//
//  Created by nonato on 14-11-21.
//  Copyright (c) 2014年 Nonato. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property(nonatomic,strong) UIWebView * WebView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.title = @"论坛";
    if (self.WebView) {
        [self loadWebView:@"http://120.24.82.164/forum.php"];
    }
}

-(UIWebView *)WebView
{
    if (!_WebView) {
        CGRect frame = [UIScreen mainScreen].bounds;
        _WebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame))];
        [self.view addSubview:_WebView];
    }
    return _WebView;
}

-(void)loadWebView:(NSString *)url
{
    if (self.WebView) {
        NSURLRequest * request =[NSURLRequest requestWithURL:[NSURL URLWithString:url]];
        [self.WebView loadRequest:request];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
