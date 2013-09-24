//
//  ViewController.h
//  SweetTooth
//
//  Created by Josh Holtz on 9/24/13.
//  Copyright (c) 2013 RokkinCat. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *lblScanning;
- (IBAction)onValueChanged:(id)sender;
- (IBAction)onClickWriteCharacteristic:(id)sender;

@end
