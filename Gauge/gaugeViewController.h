//
//  gaugeViewController.h
//  Gauge
//
//  Created by Gianni on 5/5/14.
//  Copyright (c) 2014 Gianni. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface gaugeViewController : UIViewController <UITextFieldDelegate> {
    BOOL temperatureScaleSelection;
    float actualTemperature;
    float setTemperatureAlarm;
    float actualHumidity;
    float setHumidityAlarm;
    
    float sendSetTemperatureAlarm;
}
@property (strong, nonatomic) IBOutlet UILabel *lblTemperature;
@property (strong, nonatomic) IBOutlet UILabel *lblHumidity;
@property (retain, nonatomic) IBOutlet UISwitch *swtCelsiusFarenheit;

@property (retain, nonatomic) IBOutlet UITextField *txtMaxTemperature;
@property (retain, nonatomic) IBOutlet UITextField *txtMaxHumidity;

@property (retain, nonatomic) IBOutlet UILabel *lblFrontMaxTemperature;
@property (retain, nonatomic) IBOutlet UILabel *lblFrontMaxHumidity;

@property (retain, nonatomic) IBOutlet UILabel *lblTemperatureScale;

@property (retain, nonatomic) IBOutlet UIImageView *tempAlarmShow;
@property (retain, nonatomic) IBOutlet UIImageView *tempAlarmNormal;
@property (retain, nonatomic) IBOutlet UIImageView *humAlarmShow;
@property (retain, nonatomic) IBOutlet UIImageView *humAlarmNormal;

@property (retain, nonatomic) IBOutlet UILabel *lblServerError;

@end
