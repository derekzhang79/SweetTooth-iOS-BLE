//
//  ViewController.m
//  SweetTooth
//
//  Created by Josh Holtz on 9/24/13.
//  Copyright (c) 2013 RokkinCat. All rights reserved.
//

#import "ViewController.h"

#import "SweetToothManager.h"
#import "CBUUID+StringExtraction.h"

#import <CoreBluetooth/CoreBluetooth.h>

@interface ViewController ()

@property (nonatomic, strong) CBPeripheral *somePeripheral;

@property (nonatomic, strong) CBCharacteristic *someCharacteristic;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Initialize SweetToothManager
    dispatch_queue_t queue = dispatch_queue_create("com.joshholtz.sweettooth", 0);
    [SweetToothManager initSharedClient:queue options:nil];
    
    [self test];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

#pragma mark - Test

- (void)test {
    
    // Set discover peripheral block
    [[SweetToothManager sharedClient] setDiscoverPeripheralBlock:^void(CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI) {
        NSLog(@"Discovered - %@", peripheral.name);
        
        /*
         * Retain this peripheral for future use - peripheral NEEDS to be retained to be connected to
         *
         * Peripheral also comes back with delegate preset to SweetToothManger
         * IF you change this (which you can), the block methods below won't get called
         */
        if (_somePeripheral == nil) {
            _somePeripheral = peripheral;
            [[SweetToothManager sharedClient] connectPeripheral:peripheral options:@{}];
        }
    }];
    
    // Set peripheral connected block
    [[SweetToothManager sharedClient] setPeripheralConnectedBlock:^(CBPeripheral *peripheral) {
        NSLog(@"Connected - %@", peripheral.name);
        [peripheral discoverServices:nil];
    }];
    
    // Set peripheral failed to connect block
    [[SweetToothManager sharedClient] setPeripheralFailedToConnectBlock:^(CBPeripheral *peripheral, NSError *error) {
        NSLog(@"Perpherial failed to connect");
    }];
    
    // Set peripheral failed to disconnect block
    [[SweetToothManager sharedClient] setPeripheralDisconnectedBlock:^(CBPeripheral *peripheral, NSError *error) {
        NSLog(@"Disconnect peripheral");
    }];
    
    // Set peripheral discover services block
    [[SweetToothManager sharedClient] setPeripheralDiscoverServicesBlock:^(CBPeripheral *peripheral, NSError *error) {
        NSLog(@"Services discovered - %@", [peripheral.services valueForKey:@"UUID"]);
        for (CBService *service in peripheral.services) {
            [peripheral discoverCharacteristics:nil forService:service];
        }
    }];
    
    // Set peripheral discover characteristics block
    [[SweetToothManager sharedClient] setPeripheralDiscoverCharacteristicsBlock:^(CBPeripheral *peripheral, CBService *service, NSError *error) {
        NSLog(@"Characteristics - %@", service.characteristics);
        for (CBCharacteristic *characteristic in service.characteristics) {
            [peripheral readValueForCharacteristic:characteristic];
        }
    }];
    
    // Set peripheral update characterics block
    [[SweetToothManager sharedClient] setPeripheralUpdateCharacteristcBlock:^(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error) {
        NSLog(@"Updated %@ to %@", characteristic.UUID, characteristic.value);
    }];
}

#pragma mark - Actions

- (IBAction)onValueChanged:(UISwitch*)sender {
    NSArray *serviceUUIDs = nil;
    
    // Starts SweetToothManager if switch is on and SweetToothManager isn't scanning already
    if ([sender isOn] && ![SweetToothManager sharedClient].isScanning ) {
        [[SweetToothManager sharedClient] start:serviceUUIDs options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@YES }];
    } else {
        [[SweetToothManager sharedClient] cancelPeripheralConnection:_somePeripheral];
        [[SweetToothManager sharedClient] stop];
        _somePeripheral = nil;
    }
}

- (IBAction)onClickWriteCharacteristic:(id)sender {
    [_somePeripheral writeValue:[@"joshdholtz is awesome" dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:_someCharacteristic type:CBCharacteristicWriteWithoutResponse];
}

@end
