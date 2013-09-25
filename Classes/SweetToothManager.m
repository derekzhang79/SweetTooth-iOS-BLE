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

/*
 * BLOCKS
 */
@property (nonatomic, strong) NSMutableArray* discoverPeripheralBlocks;
@property (nonatomic, strong) NSMutableArray* peripheralConnectedBlocks;
@property (nonatomic, strong) NSMutableArray* peripheralFailedToConnectBlocks;
@property (nonatomic, strong) NSMutableArray* peripheralDisconnectedBlocks;

@property (nonatomic, strong) NSMutableArray* peripheralDiscoverServicesBlocks;
@property (nonatomic, strong) NSMutableArray* peripheralDiscoverCharacteristicsBlocks;
@property (nonatomic, strong) NSMutableArray* peripheralUpdateCharacteristcBlocks;
@property (nonatomic, strong) NSMutableArray* peripheralWriteCharacteristcBlocks;

@property (nonatomic, strong) NSMutableArray* retreievePeripheralsBlocks;
@property (nonatomic, strong) NSMutableArray* retreieveConnectedPeripheralsBlocks;



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
        
        self.discoverPeripheralBlocks = [NSMutableArray array];
        self.peripheralConnectedBlocks = [NSMutableArray array];
        self.peripheralFailedToConnectBlocks = [NSMutableArray array];
        self.peripheralDisconnectedBlocks =  [NSMutableArray array];
        
        self.peripheralDiscoverServicesBlocks = [NSMutableArray array];
        self.peripheralDiscoverCharacteristicsBlocks = [NSMutableArray array];
        self.peripheralUpdateCharacteristcBlocks = [NSMutableArray array];
        self.peripheralWriteCharacteristcBlocks = [NSMutableArray array];
        
        self.retreievePeripheralsBlocks = [NSMutableArray array];
        self.retreieveConnectedPeripheralsBlocks = [NSMutableArray array];
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

#pragma mark - Add Blocks

- (void)addDiscoverPeripheralBlock:(DiscoverPeripheral)theDiscoverPeripheral {
    [self.discoverPeripheralBlocks addObject:theDiscoverPeripheral];
}

- (void)addPeripheralConnectedBlock:(PeripheralConnected)peripheralConnected {
    [self.peripheralConnectedBlocks addObject:peripheralConnected];
}

- (void)addPeripheralFailedToConnectBlock:(PeripheralFailedToConnect)peripheralFailedToConnect {
    [self.peripheralFailedToConnectBlocks addObject:peripheralFailedToConnect];
}

- (void)addPeripheralDisconnectedBlock:(PeripheralDisconnected)peripheralDisconnected {
    [self.peripheralDisconnectedBlocks addObject:peripheralDisconnected];
}

- (void)addPeripheralDiscoverServicesBlock:(PeripheralDiscoverServices)thePeripheralDiscoverServices {
    [self.peripheralDiscoverServicesBlocks addObject:thePeripheralDiscoverServices];
}

- (void)addPeripheralDiscoverCharacteristicsBlock:(PeripheralDiscoverCharacteristics)peripheralDiscoverCharacteristics {
    [self.peripheralDiscoverCharacteristicsBlocks addObject:peripheralDiscoverCharacteristics];
}

- (void)addPeripheralUpdateCharacteristcBlock:(PeripheralUpdateCharacteristc)peripheralUpdateCharacteristc {
    [self.peripheralUpdateCharacteristcBlocks addObject:peripheralUpdateCharacteristc];
}

- (void)addPeripheralWriteCharacteristcBlock:(PeripheralWriteCharacteristc)peripheralWriteCharacteristc {
    [self.peripheralWriteCharacteristcBlocks addObject:peripheralWriteCharacteristc];
}

- (void)addRetreievePeripheralsBlock:(RetreievePeripherals)retreievePeripherals {
    [self.retreievePeripheralsBlocks addObject:retreievePeripherals];
}

- (void)addRetreieveConnectedPeripheralsBlock:(RetreieveConnectedPeripherals)retreieveConnectedPeripherals {
    [self.retreieveConnectedPeripheralsBlocks addObject:retreieveConnectedPeripherals];
}

#pragma mark - Remove Blocks

- (void)removeAllBlocks {
    [self.discoverPeripheralBlocks removeAllObjects];
    [self.peripheralConnectedBlocks removeAllObjects];
    [self.peripheralFailedToConnectBlocks removeAllObjects];
    [self.peripheralDisconnectedBlocks removeAllObjects];
    [self.peripheralDiscoverServicesBlocks removeAllObjects];
    [self.peripheralDiscoverCharacteristicsBlocks removeAllObjects];
    [self.peripheralUpdateCharacteristcBlocks removeAllObjects];
    [self.peripheralWriteCharacteristcBlocks removeAllObjects];
    [self.retreievePeripheralsBlocks removeAllObjects];
    [self.retreieveConnectedPeripheralsBlocks removeAllObjects];
}

- (void)removeDiscoverPeripheralBlock:(DiscoverPeripheral)theDiscoverPeripheral {
    [self.discoverPeripheralBlocks removeObject:theDiscoverPeripheral];
}

- (void)removePeripheralConnectedBlock:(PeripheralConnected)peripheralConnected {
    [self.peripheralConnectedBlocks removeObject:peripheralConnected];
}

- (void)removePeripheralFailedToConnectBlock:(PeripheralFailedToConnect)peripheralFailedToConnect {
    [self.peripheralFailedToConnectBlocks removeObject:peripheralFailedToConnect];
}

- (void)removePeripheralDisconnectedBlock:(PeripheralDisconnected)peripheralDisconnected {
    [self.peripheralDisconnectedBlocks removeObject:peripheralDisconnected];
}

- (void)removePeripheralDiscoverServicesBlock:(PeripheralDiscoverServices)thePeripheralDiscoverServices {
    [self.peripheralDiscoverServicesBlocks removeObject:thePeripheralDiscoverServices];
}

- (void)removePeripheralDiscoverCharacteristicsBlock:(PeripheralDiscoverCharacteristics)peripheralDiscoverCharacteristics {
    [self.peripheralDiscoverCharacteristicsBlocks removeObject:peripheralDiscoverCharacteristics];
}

- (void)removePeripheralUpdateCharacteristcBlock:(PeripheralUpdateCharacteristc)peripheralUpdateCharacteristc {
    [self.peripheralUpdateCharacteristcBlocks removeObject:peripheralUpdateCharacteristc];
}

- (void)removePeripheralWriteCharacteristcBlock:(PeripheralWriteCharacteristc)peripheralWriteCharacteristc {
    [self.peripheralWriteCharacteristcBlocks removeObject:peripheralWriteCharacteristc];
}

- (void)removeRetreievePeripheralsBlock:(RetreievePeripherals)retreievePeripherals {
    [self.retreievePeripheralsBlocks removeObject:retreievePeripherals];
}

- (void)removeRetreieveConnectedPeripheralsBlock:(RetreieveConnectedPeripherals)retreieveConnectedPeripherals {
    [self.retreieveConnectedPeripheralsBlocks removeObject:retreieveConnectedPeripherals];
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
    [self.discoverPeripheralBlocks enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        ((DiscoverPeripheral)obj)(peripheral, advertisementData, RSSI);
    }];
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    [peripheral setDelegate:self];
    [self.peripheralConnectedBlocks enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        ((PeripheralConnected)obj)(peripheral);
    }];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    [self.peripheralFailedToConnectBlocks enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        ((PeripheralFailedToConnect)obj)(peripheral, error);
    }];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    [self.peripheralDisconnectedBlocks enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        ((PeripheralDisconnected)obj)(peripheral, error);
    }];
}

- (void)centralManager:(CBCentralManager *)central didRetrievePeripherals:(NSArray *)peripherals {
    [self.retreievePeripheralsBlocks enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        ((RetreievePeripherals)obj)(peripherals);
    }];
}

- (void)centralManager:(CBCentralManager *)central didRetrieveConnectedPeripherals:(NSArray *)peripherals {
    [self.retreieveConnectedPeripheralsBlocks enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        ((RetreieveConnectedPeripherals)obj)(peripherals);
    }];
}

#pragma mark - CBPeripheralDelegate

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    [self.peripheralDiscoverServicesBlocks enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        ((PeripheralDiscoverServices)obj)(peripheral, error);
    }];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    [self.peripheralDiscoverCharacteristicsBlocks enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        ((PeripheralDiscoverCharacteristics)obj)(peripheral, service, error);
    }];
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    [self.peripheralUpdateCharacteristcBlocks enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        ((PeripheralUpdateCharacteristc)obj)(peripheral, characteristic, error);
    }];
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    [self.peripheralWriteCharacteristcBlocks enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        ((PeripheralWriteCharacteristc)obj)(peripheral, characteristic, error);
    }];
}

@end
