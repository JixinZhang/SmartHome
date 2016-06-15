//
//  AlexRequest.h
//  AlexRequest
//
//  Created by ZhangBob on 4/11/16.
//  Copyright © 2016 JixinZhang. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, AlexRequestMethod){
    AlexRequestMethodGet = 0,   //GET
    AlexRequestMethodPost,      //POST
};

@interface AlexRequest : NSObject

@property (nonatomic, copy) NSString *url;
@property (nonatomic, assign) AlexRequestMethod requestMethod;
@property (nonatomic, strong) NSDictionary *httpHeaders;
@property (nonatomic, strong) NSMutableDictionary *parameters;

@end
