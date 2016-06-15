//
//  ViewController.m
//  SmartHome
//
//  Created by ZhangBob on 5/3/16.
//  Copyright © 2016 JixinZhang. All rights reserved.
//

#import "ViewController.h"
#import "AFNetworking.h"
#import "AlexBrokenLineView.h"

typedef void(^NetworkBlock)(BOOL isSuccess, id response);

//yeelink的网络请求地址
static NSString *const yeelinkAPI = @"http://api.yeelink.net/v1.0/device/345323/sensor/";
//yeelink提供的Apikey
static NSString *const yeelinkApiKey = @"f9a6b41b07f6304103068e4b35eeae78";

@interface ViewController ()

@property (nonatomic, assign) BOOL switchStatus;    //开关的状态，True或者False
@property (nonatomic, assign) NSInteger fanStatus;  //风扇的状态，1，0或者－1（对应正转，停止或者反转）

@end

@implementation ViewController

//初始化开关状态
- (BOOL)switchStatus {
    if (!_switchStatus) {
        _switchStatus = NO;
    }
    return _switchStatus;
}

//页面加载后，相当于C语言的main函数
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //调用下面两个方法初始化显示温度的Label和开关控件
    [self setupTemperatureLabel];
    [self setupSwitchStatus];
    
    
    /*请求温度数据，绘制温度曲线
     1.调用 getHistoryTemperatureWithBlock 方法请求历史温度数据
     2.在网络请求成功后开始调用AlexBrokenLineView这个View来绘制温度曲线
     */
    __weak typeof (self)weakSelf = self;
    [self getHistoryTemperatureWithBlock:^(BOOL isSuccess, NSArray *response) {
        if (isSuccess) {
            //实例化一个AlexBrokenLineView
            AlexBrokenLineView *brokenLine = [[AlexBrokenLineView alloc] init];
            
            //设置brokenLine的相关属性：背景色，位置及大小，数据
            brokenLine.backgroundColor = [UIColor clearColor];
            CGRect frame = weakSelf.brokenLineView.frame;
            frame.origin = CGPointMake(0, 21);
            frame.size = CGSizeMake(320, 110);
            brokenLine.frame = frame;
            brokenLine.dataArr = response;
            brokenLine.backgroundColor = [UIColor whiteColor];
            
            //将brokenLine这个View添加到当前的ViewController中
            [weakSelf.brokenLineView addSubview:brokenLine];
        }
    }];
}

//在View出现后做操作
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    __weak typeof (self)weakSelf = self;
    /*获取步进电机的状态（顺时针、逆时针和停止）
     1.调用getFanStatusWithBlock 方法请求步进电机的状态
     2.在网络请求成功后，根据返回的结果设置步进电机状态fanStatus的值以及更新显示步进电机状态的控件segmentControl
     */
    [self getFanStatusWithBlock:^(BOOL isSuccess, id response) {
        if (isSuccess) {
            NSString *result = [NSString stringWithFormat:@"%@",response];
            if ([result isEqualToString:@"0"]) {
                weakSelf.segmentControl.selectedSegmentIndex = 1;
                weakSelf.fanStatus = 1;
            }else if ([result isEqualToString:@"1"]) {
                weakSelf.segmentControl.selectedSegmentIndex = 0;
                weakSelf.fanStatus = 0;
            }else {
                weakSelf.segmentControl.selectedSegmentIndex = 2;
                weakSelf.fanStatus = 2;
            }
            [self setupFanAction];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//温度Label赋值
- (void)setupTemperatureLabel {
    __weak typeof (self)weakSelf = self;
    /*
     1)调用 getTemperatureWithBlock 方法请求最后一条温度数据
     2)网络请求成功后将温度数据赋给temperatureLabel
     */
    [self getTemperatureWithBlock:^(BOOL isSuccess, NSString *response) {
        if (isSuccess) {
            weakSelf.temperatureLabel.text = [NSString stringWithFormat:@"%@℃",response];
        }
    }];
}
//开关switch赋值
- (void)setupSwitchStatus {
    __weak typeof (self)weakSelf = self;
    /*
     1)调用 getStatusWithBlock 方法请求开关数据
     2)网络请求成功后，根据返回的开关状态设置页面
     */
    [self getStatusWithBlock:^(BOOL isSuccess, id response) {
        if (isSuccess) {
            NSString *result = [NSString stringWithFormat:@"%@",response];
            if ([result isEqualToString:@"1"]) {
                //返回的数值为1时，开关状态为打开，switchImageView和lightImageView，设置为开状态对应的照片
                weakSelf.switchStatus = YES;
                weakSelf.switchImageView.image = [UIImage imageNamed:@"openStatus"];
                weakSelf.lightImageView.image = [UIImage imageNamed:@"light_on"];
            }else {
                weakSelf.switchStatus = NO;
                weakSelf.switchImageView.image = [UIImage imageNamed:@"closeStatus"];
                weakSelf.lightImageView.image = [UIImage imageNamed:@"light_off"];
            }
        }
    }];
}

- (void)setupFanAction {
    switch (self.fanStatus) {
        case 0:
            [self fanImageViewClockwise];
            break;
        case 1:
            [self fanImageViewStop];
            break;
        case 2:
            [self fanImageViewAnticlockwise];
            break;
        default:
            break;
    }
}

//点击开关动作
- (IBAction)switchAction:(UIButton *)sender {
    if (self.switchStatus == NO) {
        self.switchImageView.image = [UIImage imageNamed:@"openStatus"];
        self.lightImageView.image = [UIImage imageNamed:@"light_on"];
        [self openRequest];
        self.switchStatus = YES;
    }else {
        self.switchImageView.image = [UIImage imageNamed:@"closeStatus"];
        self.lightImageView.image = [UIImage imageNamed:@"light_off"];
        [self closeRequest];
        self.switchStatus = NO;
    }
}

//点击SegmentedControl动作
- (IBAction)fanAction:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 0) {
        [self fanImageViewClockwise];
        [self clockwiseRequest];
    }else if (sender.selectedSegmentIndex == 1) {
        [self fanImageViewStop];
        [self stopRequest];
    }else {
        [self fanImageViewAnticlockwise];
        [self anticlockwiseRequest];
    }
}

#pragma mark -  转动
//步进电机顺时针动画
- (void)fanImageViewClockwise {
    CABasicAnimation *rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat:M_PI * 2];
    rotationAnimation.duration = 1;
    rotationAnimation.repeatCount = FLT_MAX;
    rotationAnimation.cumulative = NO;
    rotationAnimation.removedOnCompletion = NO; //No Remove
    [self.fanImageView.layer addAnimation:rotationAnimation forKey:@"rotation"];
}

//步进电机逆时针动画
- (void)fanImageViewAnticlockwise {
    CABasicAnimation *rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat:-M_PI * 2];
    rotationAnimation.duration = 1;
    rotationAnimation.repeatCount = FLT_MAX;
    rotationAnimation.cumulative = NO;
    rotationAnimation.removedOnCompletion = NO; //No Remove
    [self.fanImageView.layer addAnimation:rotationAnimation forKey:@"rotation"];
}

//步进电机动画停止
- (void)fanImageViewStop {
    [self.fanImageView.layer removeAnimationForKey:@"rotation"];
}

#pragma mark - 网络请求
#pragma mark - GET

//请求服务器上存储的开关状态
- (void)getStatusWithBlock:(NetworkBlock)block {
    NSString *string = [NSString stringWithFormat:@"%@384355/datapoints",yeelinkAPI];
    NSURL *url = [NSURL URLWithString:string];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data, NSError *connectionError)
     {
         if (data.length > 0 && connectionError == nil) {
             NSDictionary *dataJson =
             [NSJSONSerialization JSONObjectWithData:data
                                             options:0
                                               error:NULL];
             if (block) {
                 block(YES,[dataJson valueForKey:@"value"]);
             }
         }
     }];
}

//请求服务器上存储的步进电机动作状态
- (void)getFanStatusWithBlock:(NetworkBlock)block {
    NSString *string = [NSString stringWithFormat:@"%@387775/datapoints",yeelinkAPI];
    NSURL *url = [NSURL URLWithString:string];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data, NSError *connectionError)
     {
         if (data.length > 0 && connectionError == nil) {
             NSDictionary *dataJson =
             [NSJSONSerialization JSONObjectWithData:data
                                             options:0
                                               error:NULL];
             if (block) {
                 block(YES,[dataJson valueForKey:@"value"]);
             }
         }
     }];
}

//获取服务器上存储的温度数据的最后一个
- (void)getTemperatureWithBlock:(NetworkBlock)block {
    NSString *string = [NSString stringWithFormat:@"%@384354/datapoints",yeelinkAPI];
    NSURL *url = [NSURL URLWithString:string];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data, NSError *connectionError)
     {
         if (data.length > 0 && connectionError == nil) {
             NSDictionary *dataJson =
             [NSJSONSerialization JSONObjectWithData:data
                                             options:0
                                               error:NULL];
         if (block) {
             block(YES,[dataJson valueForKey:@"value"]);
         }
         }
     }];
}

//获取服务器上存储的温度数据
- (void)getHistoryTemperatureWithBlock:(NetworkBlock)block {
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateString = [dateFormatter stringFromDate:date];
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    NSString *timeString = [dateFormatter stringFromDate:date];
    NSLog(@"%@T%@",dateString,timeString);
    NSString *string = [NSString stringWithFormat:@"%@384354.json?start=2016-05-05T14:01:46&end=%@T%@&interval=1&page=1",yeelinkAPI,dateString,timeString];
    NSURL *url = [NSURL URLWithString:string];
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
             if (block) {
                 block(YES,tempArray);
             }
             NSLog(@"温度数据%@",tempArray);
         }
     }];
}

#pragma mark - POST

//开关关闭请求
- (void)closeRequest {
    NSString *urlString = [NSString stringWithFormat:@"%@384355/datapoints",yeelinkAPI];
    AFHTTPSessionManager *sessionManager = [AFHTTPSessionManager manager];
    sessionManager.requestSerializer = [AFJSONRequestSerializer new];
    [sessionManager.requestSerializer setValue:yeelinkApiKey forHTTPHeaderField:@"U-ApiKey"];
    [sessionManager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [sessionManager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    NSDictionary *parameter = [[NSDictionary alloc] initWithObjectsAndKeys:@"0",@"value", nil];
    [sessionManager POST:urlString parameters:parameter progress:^(NSProgress * _Nonnull uploadProgress) {
        NSLog(@"progress");
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%@",responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"请求失败%@",error);
    }];
}

//开关打开请求
- (void)openRequest {
    NSString *urlString = [NSString stringWithFormat:@"%@384355/datapoints",yeelinkAPI];
    AFHTTPSessionManager *sessionManager = [AFHTTPSessionManager manager];
    sessionManager.requestSerializer = [AFJSONRequestSerializer new];
    [sessionManager.requestSerializer setValue:yeelinkApiKey forHTTPHeaderField:@"U-ApiKey"];
    [sessionManager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [sessionManager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSDictionary *parameter = [[NSDictionary alloc] initWithObjectsAndKeys:@"1",@"value", nil];
    [sessionManager POST:urlString parameters:parameter progress:^(NSProgress * _Nonnull uploadProgress) {
        NSLog(@"progress");
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%@",responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"请求失败%@",error);
    }];

}

//步进电机顺时针旋转请求
- (void)clockwiseRequest {
    NSString *urlString = [NSString stringWithFormat:@"%@387775/datapoints",yeelinkAPI];
    AFHTTPSessionManager *sessionManager = [AFHTTPSessionManager manager];
    sessionManager.requestSerializer = [AFJSONRequestSerializer new];
    [sessionManager.requestSerializer setValue:yeelinkApiKey forHTTPHeaderField:@"U-ApiKey"];
    [sessionManager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [sessionManager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    NSDictionary *parameter = [[NSDictionary alloc] initWithObjectsAndKeys:@"1",@"value", nil];
    [sessionManager POST:urlString parameters:parameter progress:^(NSProgress * _Nonnull uploadProgress) {
        NSLog(@"progress");
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%@",responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"请求失败%@",error);
    }];
}

//步进电机逆时针旋转请求
- (void)anticlockwiseRequest {
    NSString *urlString = [NSString stringWithFormat:@"%@387775/datapoints",yeelinkAPI];
    AFHTTPSessionManager *sessionManager = [AFHTTPSessionManager manager];
    sessionManager.requestSerializer = [AFJSONRequestSerializer new];
    [sessionManager.requestSerializer setValue:yeelinkApiKey forHTTPHeaderField:@"U-ApiKey"];
    [sessionManager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [sessionManager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    NSDictionary *parameter = [[NSDictionary alloc] initWithObjectsAndKeys:@"-1",@"value", nil];
    [sessionManager POST:urlString parameters:parameter progress:^(NSProgress * _Nonnull uploadProgress) {
        NSLog(@"progress");
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%@",responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"请求失败%@",error);
    }];
}

//步进电机停止转动请求
- (void)stopRequest {
    NSString *urlString = [NSString stringWithFormat:@"%@387775/datapoints",yeelinkAPI];
    AFHTTPSessionManager *sessionManager = [AFHTTPSessionManager manager];
    sessionManager.requestSerializer = [AFJSONRequestSerializer new];
    [sessionManager.requestSerializer setValue:yeelinkApiKey forHTTPHeaderField:@"U-ApiKey"];
    [sessionManager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [sessionManager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    NSDictionary *parameter = [[NSDictionary alloc] initWithObjectsAndKeys:@"0",@"value", nil];
    [sessionManager POST:urlString parameters:parameter progress:^(NSProgress * _Nonnull uploadProgress) {
        NSLog(@"progress");
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%@",responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"请求失败%@",error);
    }];
}

@end
