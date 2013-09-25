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

@property (readwrite, copy) DiscoverPeripheral discoverPeripheral;
@property (readwrite, copy) PeripheralConnected peripheralConnected;
@property (readwrite, copy) PeripheralFailedToConnect peripheralFailedToConnect;
@property (readwrite, copy) PeripheralDisconnected peripheralDisconnected;

@property (readwrite, copy) PeripheralDiscoverServices peripheralDiscoverServices;
@property (readwrite, copy) PeripheralDiscoverCharacteristics peripheralDiscoverCharacteristics;
@property (readwrite, copy) PeripheralUpdateCharacteristc peripheralUpdateCharacteristc;
@property (readwrite, copy) PeripheralWriteCharacteristc peripheralWriteCharacteristc;

@property (readwrite, copy) RetreievePeripherals retreievePeripherals;
@property (readwrite, copy) RetreieveConnectedPeripherals retreieveConnectedPeripherals;

@end

@implementation SweetToothManager

#pragma mark - Singletone

static SweetToothManager *sharedInstance = nil;

+ (SweetToothManager *)initSharedManager:(dispatch_queue_t)queue options:(NSDictionary*)options {
    
    if (sharedInstance == nil) {
        sharedInstance = [[super allocWithZone:NULL] init:queue options:options];
    }
    
    return sharedInstance;
}

+ (SweetToothManager *)sharedManager {
    
    if (sharedInstance == nil) {
        sharedInstance = [[super allocWithZone:NULL] init:nil options:nil];
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

#pragma mark - Blocks

- (void)setDiscoverPeripheralBlock:(DiscoverPeripheral)theDiscoverPeripheral {
    self.discoverPeripheral = theDiscoverPeripheral;
}

- (void)setPeripheralConnectedBlock:(PeripheralConnected)peripheralConnected {
    self.peripheralConnected = peripheralConnected;
}

- (void)setPeripheralFailedToConnectBlock:(PeripheralFailedToConnect)peripheralFailedToConnect {
    self.peripheralFailedToConnect = peripheralFailedToConnect;
}

- (void)setPeripheralDisconnectedBlock:(PeripheralDisconnected)peripheralDisconnected {
    self.peripheralDisconnected = peripheralDisconnected;
}

- (void)setPeripheralDiscoverServicesBlock:(PeripheralDiscoverServices)thePeripheralDiscoverServices {
    self.peripheralDiscoverServices = thePeripheralDiscoverServices;
}

- (void)setPeripheralDiscoverCharacteristicsBlock:(PeripheralDiscoverCharacteristics)peripheralDiscoverCharacteristics {
    self.peripheralDiscoverCharacteristics = peripheralDiscoverCharacteristics;
}

- (void)setPeripheralUpdateCharacteristcBlock:(PeripheralUpdateCharacteristc)peripheralUpdateCharacteristc {
    self.peripheralUpdateCharacteristc = peripheralUpdateCharacteristc;
}

- (void)setPeripheralWriteCharacteristcBlock:(PeripheralWriteCharacteristc)peripheralWriteCharacteristc {
    self.peripheralWriteCharacteristc = peripheralWriteCharacteristc;
}

- (void)setRetreievePeripheralsBlock:(RetreievePeripherals)retreievePeripherals {
    self.retreievePeripherals = retreievePeripherals;
}

- (void)setRetreieveConnectedPeripheralsBlock:(RetreieveConnectedPeripherals)retreieveConnectedPeripherals {
    self.retreieveConnectedPeripherals = retreieveConnectedPeripherals;
}

#pragma mark - Helper

- (void)connectPeripheral:(CBPeripheral*)peripheral options:(NSDictionary *)options {
    [self.centralManager connectPeripheral:peripheral options:options];
}

- (void)cancelPeripheralConnection:(CBPeripheral*)peripheral {
    if (peripheral != nil) {
        [self.centralManager cancelPeripheralConnection:peripheral];
    }
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
    [peripheral setDelegate:self];
    
    if (self.discoverPeripheral != nil) {
        self.discoverPeripheral(peripheral, advertisementData, RSSI);
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    [peripheral setDelegate:self];
    if (self.peripheralConnected != nil) {
        self.peripheralConnected(peripheral);
    }
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    if (self.peripheralFailedToConnect != nil) {
        self.peripheralFailedToConnect(peripheral, error);
    }
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    if (self.peripheralDisconnected != nil) {
        self.peripheralDisconnected(peripheral, error);
    }
}

- (void)centralManager:(CBCentralManager *)central didRetrievePeripherals:(NSArray *)peripherals {
    if (self.retreievePeripherals != nil) {
        self.retreievePeripherals(peripherals);
    }
}

- (void)centralManager:(CBCentralManager *)central didRetrieveConnectedPeripherals:(NSArray *)peripherals {
    if (self.retreieveConnectedPeripherals != nil) {
        self.retreieveConnectedPeripherals(peripherals);
    }
}

#pragma mark - CBPeripheralDelegate

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    if (self.peripheralDiscoverServices != nil) {
        self.peripheralDiscoverServices(peripheral, error);
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    if (self.peripheralDiscoverCharacteristics != nil) {
        self.peripheralDiscoverCharacteristics(peripheral, service, error);
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (self.peripheralUpdateCharacteristc != nil) {
        self.peripheralUpdateCharacteristc(peripheral, characteristic, error);
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (self.peripheralWriteCharacteristc != nil) {
        self.peripheralWriteCharacteristc(peripheral, characteristic, error);
    }
}

@end
