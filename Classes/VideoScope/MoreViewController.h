//
//  MoreViewController.h
//  VideoScope
//
//  Created by JS Products on 04/03/16.
//  Copyright © 2016  JS Products. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AboutViewController.h"
@interface MoreViewController : UITableViewController
@property (weak, nonatomic) IBOutlet UIStepper *recordingTimeStepper;
@property (weak, nonatomic) IBOutlet UISwitch *recordAudioSwitch;
@property (weak, nonatomic) IBOutlet UILabel *lblRecordingTime;




- (IBAction)actionRecordingTimeStepper:(UIStepper*)sender;

- (IBAction)actionRecordSwitch:(UISwitch*)sender;
@end
