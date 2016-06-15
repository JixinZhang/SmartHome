//
//  AlexBrokenLineView.m
//  SmartHome
//
//  Created by ZhangBob on 5/4/16.
//  Copyright © 2016 JixinZhang. All rights reserved.
//

#import "AlexBrokenLineView.h"

@interface AlexBrokenLineView()

@property (nonatomic, strong) NSThread *thread;
@property (nonatomic, strong) UIView *tempratureLineView;
@end

@implementation AlexBrokenLineView

- (void)drawRect:(CGRect)rect {
    [self drawXAxis];
    [self drawYAxis];
    [self draw0baseLine];
    [self drawLineWithData:self.dataArr];
}

//绘制Y坐标
- (void)drawYAxis {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBFillColor(context, 100, 16, 16, 1);
    CGContextSetLineWidth(context, 2.0);
    
    CGContextMoveToPoint(context, 30, 100);
    CGContextAddLineToPoint(context, 30, 10);
    CGContextDrawPath(context, kCGPathStroke);
}

//绘制X坐标
- (void)drawXAxis {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBFillColor(context, 100, 100, 100, 1);
    CGContextSetLineWidth(context, 2.0);
    
    CGContextMoveToPoint(context, 30, 100);
    CGContextAddLineToPoint(context, 300, 100);
    CGContextDrawPath(context, kCGPathStroke);
}

//绘制0摄氏度基准线
- (void)draw0baseLine {
    CGFloat lengths[] = {10,5};
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineDash(context, 0, lengths, 2);
    CGContextMoveToPoint(context, 30, 90);
    CGContextAddLineToPoint(context, 300, 90);
    CGContextSetRGBStrokeColor(context, 0.6, 0.6, 0.6, 1);
    CGContextSetLineWidth(context, 1.0);
    CGContextStrokePath(context);
}

//绘制曲线
- (void)drawLineWithData:(NSArray *)dataArray {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBFillColor(context, 100, 16, 16, 1);
    CGContextSetRGBStrokeColor(context, 1.0, 0, 0, 1);
    CGContextSetLineWidth(context, 1.0);
    
    NSMutableArray *pointY = [NSMutableArray array];
    for (int i = 0; i < dataArray.count; i++) {
        NSString *tempStr = [NSString stringWithFormat:@"%.2f",(90 - [dataArray[i] floatValue])];
        [pointY addObject:tempStr];
    }
    
    int i = 30;
//    for (id item in pointY) {
//        CGPoint currentPoint;
//        currentPoint.x = i;
//        i += 8;
//        currentPoint.y = [item doubleValue];
//        if ([pointY indexOfObject:item] == 0) {
//            CGContextMoveToPoint(context, currentPoint.x, currentPoint.y);
//            continue;
//        }
//        CGContextAddLineToPoint(context, currentPoint.x, currentPoint.y);
//        CGContextStrokePath(context);
//        if ([pointY indexOfObject:item] < pointY.count) {
//            CGContextMoveToPoint(context, currentPoint.x, currentPoint.y);
//        }
//    }
    for (int index = 0; index < pointY.count; index++) {
        CGPoint currentPoint;
        currentPoint.x = i;
        i += 8;
        currentPoint.y = [pointY[index] doubleValue];
        if (index == 0) {
            CGContextMoveToPoint(context, currentPoint.x, currentPoint.y);
            continue;
        }
        CGContextAddLineToPoint(context, currentPoint.x, currentPoint.y);
        CGContextStrokePath(context);
        if (index < pointY.count) {
            CGContextMoveToPoint(context, currentPoint.x, currentPoint.y);
        }
    }
    [self setNeedsDisplay];
    [self setNeedsLayout];
}

@end
