//
//  gaugeViewController.m
//  Gauge
//
//  Created by Gianni on 5/5/14.
//  Copyright (c) 2014 Gianni. All rights reserved.
//

#import "gaugeViewController.h"
NSString *switchState;
@interface gaugeViewController ()

@end

@implementation gaugeViewController

// @synthesize JSONData;

@synthesize lblTemperature;
@synthesize lblHumidity;
@synthesize swtCelsiusFarenheit;

@synthesize txtMaxTemperature = _txtMaxTemperature;
@synthesize txtMaxHumidity = _txtMaxHumidity;

@synthesize lblFrontMaxTemperature = _lblFrontMaxTemperature;
@synthesize lblFrontMaxHumidity = _lblFrontMaxHumidity;

@synthesize lblTemperatureScale = _lblTemperatureScale;

@synthesize tempAlarmNormal;
@synthesize tempAlarmShow;
@synthesize humAlarmNormal;
@synthesize humAlarmShow;

@synthesize lblServerError;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.txtMaxTemperature.delegate = self; // For keyboard dismissal
    self.txtMaxHumidity.delegate = self;    // For keyboard dismissal
    
    // Set switch state according to last changed state
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"temperatureScaleSelection"]) {
        [swtCelsiusFarenheit setOn:YES];
    } else {
        [swtCelsiusFarenheit setOn:NO];
    }
    
    /*
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Info"
                                                    message:@"this is a very important info!"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles: nil];
    [alert show];
    [alert release];
    */
    
    // Read Plist
    [self readFromPlist];
    
	// Do any additional setup after loading the view, typically from a nib.
    [self startPoll];
}

// Write appDatat.plist Property List
// ==================================
- (void)saveToPlist {
    NSString *error;
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *plistPath = [rootPath stringByAppendingPathComponent:@"appData.plist"];
    NSDictionary *plistDict;
    
    // Celsius or Fahrenheit?
    // ======================
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"temperatureScaleSelection"]) {
        plistDict = [NSDictionary dictionaryWithObjects:
                                            [NSArray arrayWithObjects: [NSNumber numberWithBool:[[NSUserDefaults standardUserDefaults] boolForKey:@"temperatureScaleSelection"]], _txtMaxTemperature.text,_txtMaxHumidity.text, _lblTemperatureScale.text, nil]
                                                              forKeys:[NSArray arrayWithObjects: @"celsiusFarenheitSelect", @"maxTempFarenheit", @"maxHumidity", @"temperatureScale", nil]];
    } else {
        plistDict = [NSDictionary dictionaryWithObjects:
                                   [NSArray arrayWithObjects: [NSNumber numberWithBool:[[NSUserDefaults standardUserDefaults] boolForKey:@"temperatureScaleSelection"]], _txtMaxTemperature.text, _txtMaxHumidity.text, _lblTemperatureScale.text, nil]
                                                              forKeys:[NSArray arrayWithObjects: @"celsiusFarenheitSelect", @"maxTempCelsius", @"maxHumidity", @"temperatureScale", nil]];
    }
    
    NSData *plistData = [NSPropertyListSerialization dataFromPropertyList:plistDict
                                                                   format:NSPropertyListXMLFormat_v1_0
                                                         errorDescription:&error];

    if(plistData) {
        [plistData writeToFile:plistPath atomically:YES];
            }
    else {
        [error release];
    }
}

// Read appDatat.plist Property List
// ==================================
- (void) readFromPlist {
    self = [super init];
    if (self) {
        NSString *errorDesc = nil;
        NSPropertyListFormat format;
        NSString *plistPath;
        NSString *rootPath =
        [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        plistPath = [rootPath stringByAppendingPathComponent:@"appData.plist"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
           plistPath = [[NSBundle mainBundle] pathForResource:@"appData"
                                                       ofType:@"plist"];
        }
        NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
        NSDictionary *temp = (NSDictionary *)[NSPropertyListSerialization
                                              propertyListFromData:plistXML
                                                  mutabilityOption:NSPropertyListMutableContainersAndLeaves
                                                            format:&format
                                                  errorDescription:&errorDesc];
        if (!temp) {
            NSLog(@"Error reading plist: %@, format: %lu", errorDesc, format);
        }
        
        // Celsius or Fahrenheit?
        // ======================
        if ([[temp objectForKey:@"celsiusFarenheitSelect"] boolValue]) {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"temperatureScaleSelection"];
            self.txtMaxTemperature.text = [NSString stringWithFormat:@"%@", [temp objectForKey:@"maxTempFarenheit"]];
            setTemperatureAlarm = [[temp objectForKey:@"maxTempFarenheit"] floatValue];
            _lblFrontMaxTemperature.text = [NSString stringWithFormat:@"%@", [temp objectForKey:@"maxTempFarenheit"]];
        } else {
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"temperatureScaleSelection"];
            self.txtMaxTemperature.text = [NSString stringWithFormat:@"%@", [temp objectForKey:@"maxTempCelsius"]];
            setTemperatureAlarm = [[temp objectForKey:@"maxTempCelsius"] floatValue];
            _lblFrontMaxTemperature.text = [NSString stringWithFormat:@"%@", [temp objectForKey:@"maxTempCelsius"]];
        }

        self.txtMaxHumidity.text = [NSString stringWithFormat:@"%@", [temp objectForKey:@"maxHumidity"]];
        setHumidityAlarm = [[temp objectForKey:@"maxHumidity"] floatValue];
        
        // Change Farenheit to Celsius to Farenheit
        // ========================================
        _lblTemperatureScale.text = [NSString stringWithFormat:@"%@", [temp objectForKey:@"temperatureScale"]];
        
        // Display Front Alarm Value Label
        // ===============================
        _lblFrontMaxHumidity.text = [NSString stringWithFormat:@"%@", [temp objectForKey:@"maxHumidity"]];
        }
}

// Farehneit/Celsius Toggle Switch
// ===============================
- (IBAction) switchToggle :(id)sender {
    if (swtCelsiusFarenheit.on) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"temperatureScaleSelection"];
        _lblTemperatureScale.text = @"°F";
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"temperatureScaleSelection"];
        _lblTemperatureScale.text = @"°C";
    }
    
    [self saveToPlist];
}

// Save settings to plist when done with settings page
// ===================================================
- (IBAction)doneWithSettings:(id)sender {
    [self saveToPlist];
    [self readFromPlist];
    [self postAlarmLimits];
}

// Long Poll
// =========
- (void) longPoll {
    //create an autorelease pool for the thread
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    
    //compose the request
    NSError* error = nil;
    NSURLResponse* response = nil;
    NSURL* requestUrl = [NSURL URLWithString:@"http://bobst.no-ip.info/json/index.php"];
    NSURLRequest* request = [NSURLRequest requestWithURL:requestUrl];
    
    //send the request (will block until a response comes back)
    NSData* JSONData = [NSURLConnection sendSynchronousRequest:request
                                             returningResponse:&response error:&error];
    
    //pass the response on to the handler (can also check for errors here, if you want)
    [self performSelectorOnMainThread:@selector(dataReceived:)
                           withObject:JSONData waitUntilDone:YES];
    
    if (!JSONData) {
        lblTemperature.text = @"00.0";
        lblHumidity.text = @"00.0";
        lblServerError.text = @"Connecting...";
    } else {
        lblServerError.text = @"";
        id myJSON = [NSJSONSerialization JSONObjectWithData:JSONData options:NSJSONReadingMutableContainers error:nil];
        NSArray *jsonArray = (NSArray *)myJSON;
        NSString *myTemperatureC = [jsonArray[0] objectForKey:@"variableValue"];
        NSString *myTemperatureF = [jsonArray[1] objectForKey:@"variableValue"];
        NSString *myHumidity = [jsonArray[2] objectForKey:@"variableValue"];
        
        actualHumidity = [myHumidity floatValue];
        
        lblHumidity.text = [NSString stringWithFormat:@"%@%@", myHumidity, @"%"];
        
        // Celsius or Fahrenheit?
        // ======================
        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"temperatureScaleSelection"]) {
            lblTemperature.text = [NSString stringWithFormat:@"%@%@", myTemperatureC, @"°C"];
            actualTemperature = [myTemperatureC floatValue];
        } else {
            lblTemperature.text = [NSString stringWithFormat:@"%@%@", myTemperatureF, @"°F"];
            actualTemperature = [myTemperatureF floatValue];
        }
    }
    
    [self triggerAlarm];
    
    //clear the pool
    [pool drain];
    
    //send the next poll request
    [self performSelectorInBackground:@selector(longPoll) withObject: nil];
}

- (void) startPoll {
    //not covered in this example:  stopping the poll or ensuring that only 1 poll is active at any given time
    [self performSelectorInBackground:@selector(longPoll) withObject: nil];
}

- (void) dataReceived: (NSData*) theData {
    //process the response here
}
// END LONG POLLING

// LIMIT TEXT FIELD LENGHT
// =======================
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return (newLength > 5) ? NO : YES;
}

// LIMIT TEXT FIELD RANGE
// ======================
/*
This method is called when the text field is asked to resign the first responder status.
*/
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    // LIMIT TEMPERATURE ALARM SETPOINT TO 300
    // =======================================
    NSString *temperatureStringValue = _txtMaxTemperature.text;
    float floatT = [temperatureStringValue floatValue];
    if (floatT < 0 || floatT > 300) {
        // You can make the text red here for example
        _txtMaxTemperature.textColor = [UIColor colorWithRed:256.0/256.0 green:0/256.0 blue:0/256.0 alpha:1.0];
        return NO;
    } else {
        _txtMaxTemperature.textColor = [UIColor colorWithRed:0/256.0 green:0/256.0 blue:0/256.0 alpha:1.0];
        // return YES;
    }
    
    // LIMIT HUMIDITY ALARM SETPOINT TO 100
    // ====================================
    NSString *humidityStringValue = _txtMaxHumidity.text;
    float floatH = [humidityStringValue floatValue];
    if (floatH < 0 || floatH > 100) {
        // You can make the text red here for example
        _txtMaxHumidity.textColor = [UIColor colorWithRed:256.0/256.0 green:0/256.0 blue:0/256.0 alpha:1.0];
        return NO;
    } else {
        _txtMaxHumidity.textColor = [UIColor colorWithRed:0/256.0 green:0/256.0 blue:0/256.0 alpha:1.0];
        return YES;
    }
}

// ALARM handling
// ==============
- (void) triggerAlarm {
    
    if (actualTemperature > setTemperatureAlarm) {
        tempAlarmShow.hidden = NO;
    } else {
        tempAlarmShow.hidden = YES;
    }
    
    if (actualHumidity > setHumidityAlarm) {
        humAlarmShow.hidden = NO;
    } else {
        humAlarmShow.hidden = YES;
    }
}

// Sending Alarm Settings to Server
// ================================
- (void) postAlarmLimits {
    
    // TACCONE
    // Se la temperatura selezionata é in Farenheit trasmetto il settaggio per l'allarme
    // senza conversione, se la selezione é in centigradi converto il settaggio per l'allarme
    // perché sul server non considero la selezione F/C
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"temperatureScaleSelection"]) {
        sendSetTemperatureAlarm = setTemperatureAlarm;
    } else {
        sendSetTemperatureAlarm = ((setTemperatureAlarm * 9 / 5) + 32);
    }
    
    NSURL *aUrl = [NSURL URLWithString:@"http://bobst.no-ip.info/json/jsonReceive/alarm.php"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:aUrl
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    [request setHTTPMethod:@"POST"];
    NSString *postString = [NSString stringWithFormat:@"maxTempAlarm=%f&maxHumAlarm=%f", sendSetTemperatureAlarm, setHumidityAlarm];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    NSURLConnection *connection= [[NSURLConnection alloc] initWithRequest:request
                                                                 delegate:self];
    NSLog(@"%@",connection);
}

// Dismiss keyboard when background is touched
// ===========================================
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.txtMaxTemperature resignFirstResponder];
    [self.txtMaxHumidity resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [lblTemperature release];
    [lblHumidity release];
    [swtCelsiusFarenheit release];
    [_txtMaxTemperature release];
    [_txtMaxHumidity release];
    [_lblFrontMaxTemperature release];
    [_lblFrontMaxHumidity release];
    [_lblTemperatureScale release];
    [tempAlarmShow release];
    [tempAlarmNormal release];
    [humAlarmShow release];
    [humAlarmNormal release];
    [lblServerError release];
    [super dealloc];
}
@end
