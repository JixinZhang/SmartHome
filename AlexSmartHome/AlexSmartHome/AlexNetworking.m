//
//  AlexNetworking.m
//  AlexRequest
//
//  Created by ZhangBob on 4/11/16.
//  Copyright © 2016 JixinZhang. All rights reserved.
//

#import "AlexNetworking.h"

@implementation AlexNetworking

+ (NSURLSession *)shareEphemeralSession {
    static dispatch_once_t onceTask;
    static NSURLSession *session;
    dispatch_once(&onceTask, ^{
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        configuration.HTTPMaximumConnectionsPerHost = 3;
        session = [NSURLSession sessionWithConfiguration:configuration];
    });
    return session;
}

+ (void)cancelAllTasks {
    NSURLSession *session = [self shareEphemeralSession];
    [session getTasksWithCompletionHandler:^(NSArray<NSURLSessionDataTask *> * _Nonnull dataTasks, NSArray<NSURLSessionUploadTask *> * _Nonnull uploadTasks, NSArray<NSURLSessionDownloadTask *> * _Nonnull downloadTasks) {
        for (NSURLSessionDataTask *task in dataTasks) {
            [task cancel];
        }
    }];
}

#pragma mark - HTTPRequest
+ (AlexURLSessionTask *)getWithRequest:(AlexRequest *)request
                               success:(AlexResponseSuccess)success
                                  fail:(AlexResponseFail)fail {
    request.requestMethod = AlexRequestMethodGet;
    return [self request:request progress:nil success:success fail:fail];
}

+ (AlexURLSessionTask *)postWithRequest:(AlexRequest *)request
                                success:(AlexResponseSuccess)success
                                   fail:(AlexResponseFail)fail {
    request.requestMethod = AlexRequestMethodPost;
    return [self request:request progress:nil success:success fail:fail];
}

+ (AlexURLSessionTask *)request:(AlexRequest *)request
                       progress:(AlexDownloadProgress)progress
                        success:(AlexResponseSuccess)success
                           fail:(AlexResponseFail)fail {
    if ([NSURL URLWithString:request.url] == nil) {
        return nil;
    }
    
    if (request.requestMethod == AlexRequestMethodGet) {
        request.url = [NSString stringWithFormat:@"%@%@",request.url,[AlexNetworking parseParams:request.parameters]];
    }
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:request.url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15.0];
    if (urlRequest == nil) {
        return nil;
    }
    
    if (request.httpHeaders) {
        [urlRequest setAllHTTPHeaderFields:request.httpHeaders];
    }
    
    NSURLSession *session = [self shareEphemeralSession];
    switch (request.requestMethod) {
        case AlexRequestMethodGet:
            [urlRequest setHTTPMethod:@"GET"];
            break;
            
        case AlexRequestMethodPost:
            [urlRequest setHTTPMethod:@"POST"];
            break;
            
        default:
            break;
    }
    
    NSURLSessionDataTask *task = nil;
    __block NSURLSessionTask *weakTask = task;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        weakTask = [session dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!error) {
                    if (success) {
                        success([self parseData:data]);
                    }
                }else {
                    if (fail) {
                        fail(error);
                    }
                }
            });
        }];
        [weakTask resume];
    });
    return task;
}

#pragma mark - Other
+ (NSString *)parseParams:(NSDictionary *)params {
    NSString *keyValueFormat;
    NSMutableString *result = [NSMutableString new];
    NSMutableArray *array = [NSMutableArray new];
    //实例化一个key枚举器用来存放dictionary的key
    NSEnumerator *keyEnum = [params keyEnumerator];
    id key;
    while (key =[keyEnum nextObject]) {
        keyValueFormat = [NSString stringWithFormat:@"%@=%@",key,[params valueForKey:key]];
        NSLog(@"%@",keyValueFormat);
        [result appendString:keyValueFormat];
        [array addObject:keyValueFormat];
    }
    return result;
}

+ (id)parseData:(id)responseData {
    AlexResponse *reponseModel = [[AlexResponse alloc]init];
    reponseModel.isSucceed = NO;
    if ([responseData isKindOfClass:[NSData class]]) {
        reponseModel.resultData = responseData;
        if (responseData == nil) {
            reponseModel.errorMsg = @"返回数据Data为空";
            return reponseModel;
        } else {
            NSError *error = nil;
            NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:responseData
                                                                    options:NSJSONReadingAllowFragments
                                                                      error:&error];
            if (error) {
                reponseModel.errorMsg = @"utf8解析错误";
                return reponseModel;
            } else {
                //如果解析为NSArray，转化为字典
                if ([jsonDic isKindOfClass:[NSArray class]]) {
                    NSDictionary *resultDic = @{@"data":jsonDic};
                    reponseModel.resultDic = resultDic;
                } else {
                    reponseModel.resultDic = jsonDic;
                }
                
                //IFast 专用
                NSString *errorStr = [reponseModel.resultDic valueForKey:@"error"];
                if (errorStr) {
                    if ([errorStr isEqualToString:@"invalid_token"]) {
                        //token 失效
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"IFastRefreshUserToken" object:self userInfo:nil];
                    }
                }
                return reponseModel;
            }
        }
    } else {
        return reponseModel;
    }
}












@end
