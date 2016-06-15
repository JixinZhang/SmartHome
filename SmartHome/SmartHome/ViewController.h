//
//  ViewController.h
//  SmartHome
//
//  Created by ZhangBob on 5/3/16.
//  Copyright © 2016 JixinZhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *temperatureLabel;
@property (weak, nonatomic) IBOutlet UILabel *humidityLabel;
@property (weak, nonatomic) IBOutlet UIImageView *lightImageView;
@property (weak, nonatomic) IBOutlet UIImageView *fanImageView;
@property (weak, nonatomic) IBOutlet UIImageView *switchImageView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;
@property (weak, nonatomic) IBOutlet UIView *brokenLineView;

- (IBAction)switchAction:(UIButton *)sender;
- (IBAction)fanAction:(UISegmentedControl *)sender;
@end

