//
//  AlexResponse.h
//  AlexRequest
//
//  Created by ZhangBob on 4/11/16.
//  Copyright © 2016 JixinZhang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AlexResponse : NSObject

@property (nonatomic, strong) id resultModel;
@property (nonatomic, assign) BOOL isSucceed;
@property (nonatomic, copy) NSString *errorCode;
@property (nonatomic, copy) NSString *errorMsg;
@property (nonatomic, strong) NSData *resultData;
@property (nonatomic, strong) NSDictionary *resultDic;

@end
