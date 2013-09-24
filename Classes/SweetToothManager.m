//
//  SweetToothManager.m
//  SweetTooth
//
//  Created by Josh Holtz on 9/24/13.
//  Copyright (c) 2013 RokkinCat. All rights reserved.
//

#import "SweetToothManager.h"

#import <CoreBluetooth/CoreBluetooth.h>

@interface SweetToothManager()<CBCentralManagerDelegate>

@property (nonatomic, strong) CBCentralManager* centralManager;

@property(readwrite, copy) DiscoverPeripheral discoverPeripheral;

@end

@implementation SweetToothManager

#pragma mark - Singletone

static SweetToothManager *sharedInstance = nil;

+ (SweetToothManager *)initSharedClient:(dispatch_queue_t)queue options:(NSDictionary*)options {
    
    if (sharedInstance == nil) {
        sharedInstance = [[super allocWithZone:NULL] init:queue options:options];
    }
    
    return sharedInstance;
}

+ (SweetToothManager *)sharedClient {
    
    if (sharedInstance == nil) {
        sharedInstance = [[super allocWithZone:NULL] init];
    }
    
    return sharedInstance;
}

- (id)init:(dispatch_queue_t)queue options:(NSDictionary*)options {
    self = [super init];
    if (self) {
        self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:queue options:options];
    }
    return self;
}

#pragma mark - Start and stop

- (void)start {
    [self start:@[] options:@{}];
}

- (void)start:(NSArray*)servicesUUIDs options:(NSDictionary*)options {
    if (self.isScanning == YES) return;
    self.isScanning = YES;
    [self.centralManager scanForPeripheralsWithServices:servicesUUIDs options:options];
}

- (void)stop {
    self.isScanning = NO;
    [self.centralManager stopScan];
}

- (void)setDiscoverPeripheralBlock:(DiscoverPeripheral)discoverPeripheral {
    self.discoverPeripheral = discoverPeripheral;
}

#pragma mark - CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    switch (central.state) {
        case CBCentralManagerStatePoweredOn:
            NSLog(@"Power on");
            break;
        case CBCentralManagerStatePoweredOff:
            NSLog(@"Power off");
            break;
            
        case CBCentralManagerStateUnsupported: {
            NSLog(@"Unsupported");
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Dang."
                                                            message:@"Unfortunately this device can not talk to Bluetooth Smart (Low Energy) Devices"
                                                           delegate:nil
                                                  cancelButtonTitle:@"Dismiss"
                                                  otherButtonTitles:nil];
            
            [alert show];
            break;
        }
            
            
        default:
            break;
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
//    NSLog(@"Did we discover?");
//    NSLog(@"Discovered %@", peripheral.name);
    if (self.discoverPeripheral != nil) {
        self.discoverPeripheral(peripheral, advertisementData, RSSI);
    }
}

@end
