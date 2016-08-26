//
//  ViewController.m
//  TestView
//
//  Created by BiuKia on 16/8/24.
//  Copyright © 2016年 SHP. All rights reserved.
//

#import "ViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>

@interface ViewController ()<UIWebViewDelegate>
@property (strong, nonatomic)UIWebView * web;
@end

@implementation ViewController
@synthesize web;

- (void)viewDidLoad {
    [super viewDidLoad];
    

    /*1.OC调用JS修改Html页面中的内容。 2.JS给OC传值Html中页面元素中的值。 3.OC和JS相互调用，JS给OC传Html页面元素值，OC调用JS设置Html页面中的内容*/
    
    web = [[UIWebView alloc]initWithFrame:CGRectMake(10, 100, 300, 300)];
    web.backgroundColor = [UIColor lightTextColor];
    web.delegate = self;
    
    NSString * path = [[NSBundle mainBundle]pathForResource:@"index_css" ofType:@"html"];
    [web loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:path]]];
    
    [self.view addSubview:web];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"调JS" style:UIBarButtonItemStylePlain target:self action:@selector(rightAction)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
}

- (void)rightAction
{
    NSString *js = [NSString stringWithFormat:@"showAlert('%@')",@"这里是JS中alert弹出的message"];
//    NSString * js = [NSString stringWithFormat:@"changeRate('%@')",@"当前费率：7%"];
    [web stringByEvaluatingJavaScriptFromString:js];
}



-(void)webViewDidFinishLoad:(UIWebView *)webView{
//    [self changeRate];
    [self changeRate2];
}

#pragma mark -- 方法一 单独OC调用JS中函数，可以修改HTML中的元素
-(void)changeRate{
    NSString * js = [NSString stringWithFormat:@"changeRate('%@')",@"当前费率：7%"];
    [web stringByEvaluatingJavaScriptFromString:js];
}


#pragma mark -- 方法二  OC和JS互相通信，OC可以取到Html中的值，相互调用，由Html中的元素进行触发（）
-(void)changeRate2{
    JSContext *context = [web valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    //相当于OC监听JS中的函数被调用，然后触发该Block，再由OC调用JS中的函数。
    context[@"ocListenner"] = ^(){
        
        NSArray * aContent = [JSContext currentArguments];
        NSMutableString * sParam = [NSMutableString string];
        for (int i = 0; i < aContent.count; ++i) {
            [sParam appendFormat:@"%@",[aContent[i]toString]];
        }
        NSLog(@"JS 传递过来的参数是：%@",sParam);
        
        NSLog(@"OC调用JS参数，传递的字符串参数不能有换行符\n");
        NSString * js = [NSString stringWithFormat:@"callOnJS('%@')",sParam];
        [[JSContext currentContext] evaluateScript:js];
    };
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    
    NSString * sRequest = [[request.URL absoluteString] stringByRemovingPercentEncoding];
    if ([sRequest hasPrefix:@"objc://"]) {
        
#pragma mark -- 方法三 OC可以取到Html中的值，由JS中的window.location.href 触发。
        NSArray * aValues = [sRequest componentsSeparatedByString:@"://"];
        NSArray * aSubValues = [aValues[1] componentsSeparatedByString:@":/"];
        for (NSString * strValue in aSubValues) {
            NSLog(@"JS传递回来的结果值：%@\n",strValue);
        }
        return NO;
    }
    return YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

@end
