//
//  ViewController.m
//  AlexSmartHome
//
//  Created by ZhangBob on 3/6/16.
//  Copyright © 2016 JixinZhang. All rights reserved.
//

#import "ViewController.h"
#import <AFNetworking.h>
#import "AlexNetworking.h"

static NSString *const yeelinkAPI = @"http://api.yeelink.net/v1.0/device/345323/sensor/";

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self getTempture];
    [self getTemptureWithNSURLConnection];
    [self stopRequest];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)switchAction:(UISwitch *)sender
{
    UISwitch *switchButton = (UISwitch*)sender;
    BOOL isButtonOn = [switchButton isOn];
    if (isButtonOn) {
        NSLog(@"开");
        [self openTheWindowRequest];
    }else {
        NSLog(@"关");
        [self closeTheWindowRequest];
    }
}

- (IBAction)statuesCheckAction:(id)sender
{
    NSString *urlString = [NSString stringWithFormat:@"%@384355/datapoints",yeelinkAPI];
    AlexRequest *request = [[AlexRequest alloc] init];
    request.url = urlString;
    [AlexNetworking getWithRequest:request success:^(AlexResponse *response) {
        BOOL switchStatus = [[response.resultDic valueForKey:@"value"] boolValue];
        NSLog(@"%d",switchStatus);
    } fail:^(NSError *error) {
        
    }];
}

#pragma mark - 获取温度数据网络请求

- (void) getTempture {
    //网络请求的url
    NSString *urlString = @"http://api.yeelink.net/v1.0/device/345323/sensor/384354.json?start=2016-02-02T14:01:46&end=2016-05-03T18:17:40&interval=1&page=1";
    //初始化requset
    AlexRequest *request = [[AlexRequest alloc] init];
    request.url = urlString;
    
    /*调用AlexNetworking类的下面这个方法
     1）+ (AlexURLSessionTask *)getWithRequest:(AlexRequest *)request success:(AlexResponseSuccess)success fail:(AlexResponseFail)fail
     2）在网络请求成功后
     */
    [AlexNetworking getWithRequest:request success:^(AlexResponse *response) {
        NSArray *dataArray = [response.resultDic valueForKey:@"data"];
        NSLog(@"%@",dataArray);
        NSMutableArray *tempArray = [NSMutableArray array];
        for (NSDictionary *item in dataArray) {
            [tempArray addObject:[item valueForKey:@"value"]];
        }
        NSLog(@"%@",tempArray);
    } fail:^(NSError *error) {
        
    }];

}

- (void)closeTheWindowRequest
{
    NSString *urlString = [NSString stringWithFormat:@"%@384355/datapoints",yeelinkAPI];
    AFHTTPSessionManager *sessionManager = [AFHTTPSessionManager manager];
    sessionManager.requestSerializer = [AFJSONRequestSerializer new];
    [sessionManager.requestSerializer setValue:@"f9a6b41b07f6304103068e4b35eeae78" forHTTPHeaderField:@"U-ApiKey"];
    [sessionManager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [sessionManager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSDictionary *parameter = [[NSDictionary alloc] initWithObjectsAndKeys:@"0",@"value", nil];
    [sessionManager POST:urlString parameters:parameter progress:^(NSProgress * _Nonnull uploadProgress) {
        NSLog(@"progress");
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"成功关闭窗子%@",responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"请求失败%@",error);
    }];
}

- (void)openTheWindowRequest
{
    NSString *urlString = [NSString stringWithFormat:@"%@384355/datapoints",yeelinkAPI];
    AFHTTPSessionManager *sessionManager = [AFHTTPSessionManager manager];
    sessionManager.requestSerializer = [AFJSONRequestSerializer new];
    [sessionManager.requestSerializer setValue:@"f9a6b41b07f6304103068e4b35eeae78" forHTTPHeaderField:@"U-ApiKey"];
    [sessionManager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [sessionManager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];

    
    NSDictionary *parameter = [[NSDictionary alloc] initWithObjectsAndKeys:@"1",@"value", nil];
    
    [sessionManager POST:urlString parameters:parameter progress:^(NSProgress * _Nonnull uploadProgress) {
        NSLog(@"progress");
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"成功打开窗子%@",responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"请求失败%@",error);
    }];
}

- (void)clockwiseRequest {
    NSString *urlString = [NSString stringWithFormat:@"%@387775/datapoints",yeelinkAPI];
    AFHTTPSessionManager *sessionManager = [AFHTTPSessionManager manager];
    sessionManager.requestSerializer = [AFJSONRequestSerializer new];
    [sessionManager.requestSerializer setValue:@"f9a6b41b07f6304103068e4b35eeae78" forHTTPHeaderField:@"U-ApiKey"];
    [sessionManager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [sessionManager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    NSDictionary *parameter = [[NSDictionary alloc] initWithObjectsAndKeys:@"1",@"value", nil];
    [sessionManager POST:urlString parameters:parameter progress:^(NSProgress * _Nonnull uploadProgress) {
        NSLog(@"progress");
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"成功打开窗子%@",responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"请求失败%@",error);
    }];
}

- (void)anticlockwiseRequest {
    NSString *urlString = [NSString stringWithFormat:@"%@387775/datapoints",yeelinkAPI];
    AFHTTPSessionManager *sessionManager = [AFHTTPSessionManager manager];
    sessionManager.requestSerializer = [AFJSONRequestSerializer new];
    [sessionManager.requestSerializer setValue:@"f9a6b41b07f6304103068e4b35eeae78" forHTTPHeaderField:@"U-ApiKey"];
    [sessionManager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [sessionManager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    NSDictionary *parameter = [[NSDictionary alloc] initWithObjectsAndKeys:@"-1",@"value", nil];
    [sessionManager POST:urlString parameters:parameter progress:^(NSProgress * _Nonnull uploadProgress) {
        NSLog(@"progress");
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"成功打开窗子%@",responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"请求失败%@",error);
    }];
}

- (void)stopRequest {
    NSString *urlString = [NSString stringWithFormat:@"%@387775/datapoints",yeelinkAPI];
    AFHTTPSessionManager *sessionManager = [AFHTTPSessionManager manager];
    sessionManager.requestSerializer = [AFJSONRequestSerializer new];
    [sessionManager.requestSerializer setValue:@"f9a6b41b07f6304103068e4b35eeae78" forHTTPHeaderField:@"U-ApiKey"];
    [sessionManager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [sessionManager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    NSDictionary *parameter = [[NSDictionary alloc] initWithObjectsAndKeys:@"0",@"value", nil];
    [sessionManager POST:urlString parameters:parameter progress:^(NSProgress * _Nonnull uploadProgress) {
        NSLog(@"progress");
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"成功打开窗子%@",responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"请求失败%@",error);
    }];
}

- (void)getTemptureWithNSURLConnection {
    NSString *urlString = @"http://api.yeelink.net/v1.0/device/345323/sensor/384354.json?start=2016-02-02T14:01:46&end=2016-05-03T18:17:40&interval=1&page=1";
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data, NSError *connectionError)
     {
         if (data.length > 0 && connectionError == nil)
         {
             NSDictionary *dataJson =
             [NSJSONSerialization JSONObjectWithData:data
                                             options:0
                                               error:NULL];
             NSMutableArray *tempArray = [NSMutableArray array];
             for (NSDictionary *item in dataJson) {
                 [tempArray addObject:[item valueForKey:@"value"]];
             }
             NSLog(@"温度数据%@",tempArray);
         }
     }];
}

@end


