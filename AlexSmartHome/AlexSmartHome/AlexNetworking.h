//
//  AlexNetworking.h
//  AlexRequest
//
//  Created by ZhangBob on 4/11/16.
//  Copyright © 2016 JixinZhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AlexRequest.h"
#import "AlexResponse.h"

typedef void(^AlexResponseSuccess)(id response);
typedef void(^AlexResponseFail)(NSError *error);

typedef void (^AlexDownloadProgress)(int64_t bytesRead, int64_t totalBytesRead);
typedef AlexDownloadProgress AlexGetProgress;
typedef AlexDownloadProgress AlexPostProgress;

@class NSURLSessionTask;
typedef NSURLSessionTask AlexURLSessionTask;

@interface AlexNetworking : NSObject

+ (void)cancelAllTasks;

+ (AlexURLSessionTask *)getWithRequest:(AlexRequest *)request
                               success:(AlexResponseSuccess)success
                                  fail:(AlexResponseFail)fail;

+ (AlexURLSessionTask *)postWithRequest:(AlexRequest *)request
                                success:(AlexResponseSuccess)success
                                   fail:(AlexResponseFail)fail;

@end
