//
//  TodayViewController.m
//  Widget
//
//  Created by WSCN on 24/04/2017.
//  Copyright © 2017 JixinZhang. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>
#import "AFNetworking.h"

//yeelink的网络请求地址
static NSString *const yeelinkAPI = @"http://api.yeelink.net/v1.0/device/345323/sensor/";
//yeelink提供的Apikey
static NSString *const yeelinkApiKey = @"f9a6b41b07f6304103068e4b35eeae78";

static NSString *const tempSensor = @"384355";

typedef void(^NetworkBlock)(BOOL isSuccess, id response);

@interface TodayViewController () <NCWidgetProviding>

@end

@implementation TodayViewController

- (UIButton *)switchBtn {
    if (!_switchBtn) {
        _switchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _switchBtn.frame = CGRectMake(10, 10, 90, 90);
        _switchBtn.imageView.contentMode = UIViewContentModeScaleAspectFill;
        [_switchBtn setImage:[UIImage imageNamed:@"light_off.jpg"] forState:UIControlStateNormal];
        [_switchBtn setImage:[UIImage imageNamed:@"light_on.jpg"] forState:UIControlStateSelected];
        [_switchBtn addTarget:self action:@selector(switchBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _switchBtn;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.preferredContentSize = CGSizeMake(self.view.frame.size.width, 110);
    // Do any additional setup after loading the view from its nib.
    
    [self.view addSubview:self.switchBtn];
    __weak typeof (self)weakSelf = self;
    [self getStatusWithBlock:^(BOOL isSuccess, NSNumber *response) {
        if (isSuccess) {
            BOOL ligtOn = [response boolValue];
            weakSelf.switchBtn.selected = ligtOn;
        } else {
            weakSelf.switchBtn.selected = NO;
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData

    completionHandler(NCUpdateResultNewData);
}

- (IBAction)switchBtnClicked:(UIButton *)sender {
    self.switchBtn.selected = !sender.selected;
    [self switchBtnActionWith:self.switchBtn.selected];
}

//请求服务器上存储的开关状态
- (void)getStatusWithBlock:(NetworkBlock)block {
    NSString *string = [NSString stringWithFormat:@"%@384355/datapoints",yeelinkAPI];
    NSURL *url = [NSURL URLWithString:string];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionTask *task = [session dataTaskWithRequest:request
                                        completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
    {
        if (data.length > 0 && error == nil) {
            NSDictionary *dataJson =
            [NSJSONSerialization JSONObjectWithData:data
                                            options:0
                                              error:NULL];
            NSNumber *value = [dataJson valueForKey:@"value"];
            if (block) {
                block(YES,value);
            }
        }
    }];
    [task resume];
}

- (void)switchBtnActionWith:(BOOL)lightOn {
    NSString *urlString = [NSString stringWithFormat:@"%@384355/datapoints",yeelinkAPI];
    AFHTTPSessionManager *sessionManager = [AFHTTPSessionManager manager];
    sessionManager.requestSerializer = [AFJSONRequestSerializer new];
    [sessionManager.requestSerializer setValue:yeelinkApiKey forHTTPHeaderField:@"U-ApiKey"];
    [sessionManager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [sessionManager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSDictionary *parameter = @{@"value" : [NSString stringWithFormat:@"%d",lightOn]};
    [sessionManager POST:urlString parameters:parameter progress:^(NSProgress * _Nonnull uploadProgress) {
        NSLog(@"progress");
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%@",responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"请求失败%@",error);
    }];

}

@end
