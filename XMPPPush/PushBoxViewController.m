//
//  PushBoxViewController.m
//  XMPPPush
//
//  Created by nonato on 14-11-21.
//  Copyright (c) 2014年 Nonato. All rights reserved.
//

#import "PushBoxViewController.h"

@interface PushBoxViewController ()
@property(nonatomic,strong) UIWebView * WebView;
@end

@implementation PushBoxViewController

- (void)viewDidLoad {
    [super viewDidLoad];
      
    UIBarButtonItem* cancelBtnItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain
                                                                  target:self action:@selector(cancelBtnPress)];
    UIBarButtonItem* sureBtnItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStyleDone                                                  target:self action:@selector(sureBtnPress)];
  
    self.navigationItem.leftBarButtonItem = cancelBtnItem;
    self.navigationItem.rightBarButtonItem = sureBtnItem;

    
    // Do any additional setup after loading the view.
}
-(void)cancelBtnPress
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)sureBtnPress
{
    [self cancelBtnPress];
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
        if (![url hasPrefix:@"http://"]) {
            url = [NSString stringWithFormat:@"http://%@",url];
        }
        NSURLRequest * request =[NSURLRequest requestWithURL:[NSURL URLWithString:url]];
        [self.WebView loadRequest:request];
    }
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
