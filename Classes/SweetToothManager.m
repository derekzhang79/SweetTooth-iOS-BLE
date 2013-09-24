//
//  SweetToothManager.m
//  SweetTooth
//
//  Created by Josh Holtz on 9/24/13.
//  Copyright (c) 2013 RokkinCat. All rights reserved.
//

#import "SweetToothManager.h"

#import <CoreBluetooth/CoreBluetooth.h>

@interface SweetToothManager()<CBCentralManagerDelegate, CBPeripheralDelegate>

@property (nonatomic, strong) CBCentralManager* centralManager;

@property (nonatomic, strong) NSMutableArray *peripherals;

@property (readwrite, copy) DiscoverPeripheral discoverPeripheral;
@property (readwrite, copy) PeripheralConnected peripheralConnected;
@property (readwrite, copy) PeripheralDiscoverServices peripheralDiscoverServices;

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
        sharedInstance = [[super allocWithZone:NULL] init:nil options:nil];
    }
    
    return sharedInstance;
}

- (id)init:(dispatch_queue_t)queue options:(NSDictionary*)options {
    self = [super init];
    if (self) {
        self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:queue options:options];
        self.peripherals = [NSMutableArray array];
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

- (void)setDiscoverPeripheralBlock:(DiscoverPeripheral)theDiscoverPeripheral {
    self.discoverPeripheral = theDiscoverPeripheral;
}

- (void)setPeripheralConnectedBlock:(PeripheralConnected)peripheralConnected {
    self.peripheralConnected = peripheralConnected;
}

- (void)setPeripheralDiscoverServicesBlock:(PeripheralDiscoverServices)thePeripheralDiscoverServices {
    self.peripheralDiscoverServices = thePeripheralDiscoverServices;
}

- (void)connectPeripheral:(CBPeripheral*)peripheral options:(NSDictionary *)options {
    [self.centralManager connectPeripheral:peripheral options:options];
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
    
    if (![self.peripherals containsObject:peripheral]) {
        [self.peripherals addObject:peripheral];
        [peripheral setDelegate:self];
    }
    
    if (self.discoverPeripheral != nil) {
        self.discoverPeripheral(peripheral, advertisementData, RSSI);
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    if (self.peripheralConnected != nil) {
        self.peripheralConnected(peripheral);
    }
}

#pragma mark - CBPeripheralDelegate

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    if (self.peripheralDiscoverServices != nil) {
        self.peripheralDiscoverServices(peripheral, error);
    }
}

@end
