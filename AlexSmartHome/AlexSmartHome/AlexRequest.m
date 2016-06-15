//
//  AlexRequest.m
//  AlexRequest
//
//  Created by ZhangBob on 4/11/16.
//  Copyright © 2016 JixinZhang. All rights reserved.
//

#import "AlexRequest.h"

@implementation AlexRequest

- (AlexRequestMethod)requestMethod{
    if (!_requestMethod) {
        _requestMethod = AlexRequestMethodGet;
    }
    return _requestMethod;
}

- (NSMutableDictionary *)parameters{
    if (!_parameters) {
        _parameters = [NSMutableDictionary dictionary];
    }
    return _parameters;
}

@end
