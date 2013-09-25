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
    [SweetToothManager initSharedManager:queue options:nil];
    
    [self test];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

#pragma mark - Test

- (void)test {
    
    // Set discover peripheral block
    [[SweetToothManager sharedManager] setDiscoverPeripheralBlock:^void(CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI) {
        NSLog(@"Discovered - %@", peripheral.name);
        
        /*
         * Retain this peripheral for future use - peripheral NEEDS to be retained to be connected to
         *
         * Peripheral also comes back with delegate preset to SweetToothManger
         * IF you change this (which you can), the block methods below won't get called
         */
        if (_somePeripheral == nil) {
            _somePeripheral = peripheral;
            [[SweetToothManager sharedManager] connectPeripheral:peripheral options:@{}];
        }
    }];
    
    // Set peripheral connected block
    [[SweetToothManager sharedManager] setPeripheralConnectedBlock:^(CBPeripheral *peripheral) {
        NSLog(@"Connected - %@", peripheral.name);
        [peripheral discoverServices:nil];
    }];
    
    // Set peripheral failed to connect block
    [[SweetToothManager sharedManager] setPeripheralFailedToConnectBlock:^(CBPeripheral *peripheral, NSError *error) {
        NSLog(@"Perpherial failed to connect");
    }];
    
    // Set peripheral failed to disconnect block
    [[SweetToothManager sharedManager] setPeripheralDisconnectedBlock:^(CBPeripheral *peripheral, NSError *error) {
        NSLog(@"Disconnect peripheral");
    }];
    
    // Set peripheral discover services block
    [[SweetToothManager sharedManager] setPeripheralDiscoverServicesBlock:^(CBPeripheral *peripheral, NSError *error) {
        NSLog(@"Services discovered - %@", [peripheral.services valueForKey:@"UUID"]);
        for (CBService *service in peripheral.services) {
            [peripheral discoverCharacteristics:nil forService:service];
        }
    }];
    
    // Set peripheral discover characteristics block
    [[SweetToothManager sharedManager] setPeripheralDiscoverCharacteristicsBlock:^(CBPeripheral *peripheral, CBService *service, NSError *error) {
        NSLog(@"Characteristics - %@", service.characteristics);
        for (CBCharacteristic *characteristic in service.characteristics) {
            [peripheral readValueForCharacteristic:characteristic];
        }
    }];
    
    // Set peripheral update characterics block
    [[SweetToothManager sharedManager] setPeripheralUpdateCharacteristcBlock:^(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error) {
        NSLog(@"Updated %@ to %@", characteristic.UUID, characteristic.value);
    }];
}

#pragma mark - Actions

- (IBAction)onValueChanged:(UISwitch*)sender {
    NSArray *serviceUUIDs = nil;
    
    // Starts SweetToothManager if switch is on and SweetToothManager isn't scanning already
    if ([sender isOn] && ![SweetToothManager sharedManager].isScanning ) {
        [[SweetToothManager sharedManager] start:serviceUUIDs options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@YES }];
    } else {
        [[SweetToothManager sharedManager] cancelPeripheralConnection:_somePeripheral];
        [[SweetToothManager sharedManager] stop];
        _somePeripheral = nil;
    }
}

- (IBAction)onClickWriteCharacteristic:(id)sender {
    [_somePeripheral writeValue:[@"joshdholtz is awesome" dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:_someCharacteristic type:CBCharacteristicWriteWithoutResponse];
}

@end
