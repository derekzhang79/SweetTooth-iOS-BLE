//
//  ViewController.m
//  SweetTooth
//
//  Created by Josh Holtz on 9/24/13.
//  Copyright (c) 2013 RokkinCat. All rights reserved.
//

#import "ViewController.h"

#import "SweetToothManager.h"

#import <CoreBluetooth/CoreBluetooth.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Initialize SweetToothManager
    dispatch_queue_t queue = dispatch_queue_create("com.joshholtz.sweettooth", 0);
    [SweetToothManager initSharedClient:queue options:nil];
    
    // Set discover peripheral block
    [[SweetToothManager sharedClient] setDiscoverPeripheralBlock:^void(CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI) {
        
        NSLog(@"Name - %@", peripheral.name);
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

#pragma mark - Actions

- (IBAction)onValueChanged:(UISwitch*)sender {
    // Starts SweetToothManager if switch is on and SweetToothManager isn't scanning already
    if ([sender isOn] && ![SweetToothManager sharedClient].isScanning ) {
        [[SweetToothManager sharedClient] start:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@YES }];
    } else {
        [[SweetToothManager sharedClient] stop];
    }
}

@end