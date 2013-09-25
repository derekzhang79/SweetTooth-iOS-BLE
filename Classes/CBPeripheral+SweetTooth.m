//
//  CBPeripheral+SweetTooth.m
//  SweetTooth
//
//  Created by Josh Holtz on 9/25/13.
//  Copyright (c) 2013 RokkinCat. All rights reserved.
//

#import "CBPeripheral+SweetTooth.h"

#import "SweetToothManager.h"
#import "CBUUID+StringExtraction.h"

#import <objc/runtime.h>

static char PERIPHERAL_CHARACTERISTICS_COUNT;
static char PERIPHERAL_CHARACTERISTICS;

static char PERIPHERAL_CONNECTED_IDENTIFIER;
static char PERIPHERAL_DISCOVER_SERVICES_IDENTIFIER;
static char PERIPHERAL_DISCOVER_CHARACTERISTICS_IDENTIFIER;
static char PERIPHERAL_UPDATE_CHARACTERISTICS_IDENTIFIER;
static char PERIPHERAL_DISCONNECTED_IDENTIFIER;

@implementation CBPeripheral (SweetTooth)

#pragma mark - Peripheral Characteristics Count

-(void)setPeripheralCharacteristicsCount:(NSNumber*)characteristicCount {
    objc_setAssociatedObject(self, &PERIPHERAL_CHARACTERISTICS_COUNT, characteristicCount, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSNumber*)getPeripheralCharacteristicsCount {
    return objc_getAssociatedObject(self, &PERIPHERAL_CHARACTERISTICS_COUNT);
}

#pragma mark - Peripheral Characteristics

-(void)setPeripheralCharacteristics:(NSMutableArray*)characteristics {
    objc_setAssociatedObject(self, &PERIPHERAL_CHARACTERISTICS, characteristics, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSMutableArray*)getPeripheralCharacteristics {
    return objc_getAssociatedObject(self, &PERIPHERAL_CHARACTERISTICS);
}

#pragma mark - Peripheral Connect Block

-(void)setPeripheralConnectBlock:(PeripheralConnected)block {
    objc_setAssociatedObject(self, &PERIPHERAL_CONNECTED_IDENTIFIER, block, OBJC_ASSOCIATION_COPY);
}

-(PeripheralConnected)getPeripheralConnectBlock {
    return objc_getAssociatedObject(self, &PERIPHERAL_CONNECTED_IDENTIFIER);
}

#pragma mark - Peripheral Discover Services Block

-(void)setPeripheralDiscoverServicesBlock:(PeripheralDiscoverServices)block {
    objc_setAssociatedObject(self, &PERIPHERAL_DISCOVER_SERVICES_IDENTIFIER, block, OBJC_ASSOCIATION_COPY);
}

-(PeripheralDiscoverServices)getPeripheralDiscoverServicesBlock {
    return objc_getAssociatedObject(self, &PERIPHERAL_DISCOVER_SERVICES_IDENTIFIER);
}

#pragma mark - Peripheral Discover Characteristics Block

-(void)setPeripheralDiscoverCharacteristicsBlock:(PeripheralDiscoverCharacteristics)block {
    objc_setAssociatedObject(self, &PERIPHERAL_DISCOVER_CHARACTERISTICS_IDENTIFIER, block, OBJC_ASSOCIATION_COPY);
}

-(PeripheralDiscoverCharacteristics)getPeripheralDiscoverCharacteristicsBlock {
    return objc_getAssociatedObject(self, &PERIPHERAL_DISCOVER_CHARACTERISTICS_IDENTIFIER);
}

#pragma mark - Peripheral Update Characteristics Block

-(void)setPeripheralUpdateCharacteristicsBlock:(PeripheralUpdateCharacteristc)block {
    objc_setAssociatedObject(self, &PERIPHERAL_UPDATE_CHARACTERISTICS_IDENTIFIER, block, OBJC_ASSOCIATION_COPY);
}

-(PeripheralUpdateCharacteristc)getPeripheralUpdateCharacteristicsBlock {
    return objc_getAssociatedObject(self, &PERIPHERAL_UPDATE_CHARACTERISTICS_IDENTIFIER);
}

#pragma mark - Peripheral Disconnect Block

-(void)setPeripheralDisconnectedBlock:(PeripheralDisconnected)block {
    objc_setAssociatedObject(self, &PERIPHERAL_DISCONNECTED_IDENTIFIER, block, OBJC_ASSOCIATION_COPY);
}

-(PeripheralDisconnected)getPeripheralDisconnectedBlock {
    return objc_getAssociatedObject(self, &PERIPHERAL_DISCONNECTED_IDENTIFIER);
}

#pragma mark - Let's do what we actually meant to do

- (void)readCharacteristics:(CBUUID*)service characteristicUUIDs:(NSArray *)characteristicUUIDs block:(SweetToothPeripheralUpdateCharacteristc)block {
    
    NSMutableArray *characteristics = [NSMutableArray array];
    [self setPeripheralCharacteristics:characteristics];
    
    __block CBPeripheral *this = self;
    
    [self setPeripheralConnectBlock:^(CBPeripheral *peripheral) {
        if (this != peripheral) return;
        
        NSLog(@"Connected - %@", peripheral.name);
        [peripheral discoverServices:@[service]];
    }];
    
    [self setPeripheralDiscoverServicesBlock:^(CBPeripheral *peripheral, NSError *error) {
        if (this != peripheral) return;
        
        NSLog(@"Services discovered - %@", [peripheral.services valueForKey:@"UUID"]);
        for (CBService *service in peripheral.services) {
            [peripheral discoverCharacteristics:nil forService:service];
        }
    }];
    
    [self setPeripheralDiscoverCharacteristicsBlock:^(CBPeripheral *peripheral, CBService *service, NSError *error) {
        if (this != peripheral) return;

        [this setPeripheralCharacteristicsCount:[NSNumber numberWithInt:service.characteristics.count]];
        
        for (CBCharacteristic *characteristic in service.characteristics) {
            [peripheral readValueForCharacteristic:characteristic];
        }
        
    }];
    
    [self setPeripheralUpdateCharacteristicsBlock:^(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error) {
        NSMutableArray *c = [this getPeripheralCharacteristics];
        
        if (characteristicUUIDs == nil || [characteristicUUIDs containsObject:characteristic.UUID]) {
            [c addObject:characteristic];
        }
        
        if (c.count == characteristicUUIDs.count || c.count == [this getPeripheralCharacteristicsCount].intValue) {
           [[SweetToothManager sharedManager] cancelPeripheralConnection:this];
        }
        
    }];
    
    [self setPeripheralDisconnectedBlock:^(CBPeripheral *peripheral, NSError *error) {
        NSLog(@"Disconnected");
        
        // Clean up blocks
        [[SweetToothManager sharedManager] removePeripheralConnectedBlock:[this getPeripheralConnectBlock]];
        [[SweetToothManager sharedManager] removePeripheralDiscoverServicesBlock:[this getPeripheralDiscoverServicesBlock]];
        [[SweetToothManager sharedManager] removePeripheralDiscoverCharacteristicsBlock:[this getPeripheralDiscoverCharacteristicsBlock]];
        [[SweetToothManager sharedManager] removePeripheralDisconnectedBlock:[this getPeripheralDisconnectedBlock]];
        
        block(this, [this getPeripheralCharacteristics], error);
    }];
    
    // Connects peripheral to do reads
    [[SweetToothManager sharedManager] addPeripheralConnectedBlock:[self getPeripheralConnectBlock]];
    
    // Sets peripheral discover services block
    [[SweetToothManager sharedManager] addPeripheralDiscoverServicesBlock:[self getPeripheralDiscoverServicesBlock]];

    // Sets peripheral discover characteristics block
    [[SweetToothManager sharedManager] addPeripheralDiscoverCharacteristicsBlock:[self getPeripheralDiscoverCharacteristicsBlock]];
    
    // Sets peripheral update characheristic block
    [[SweetToothManager sharedManager] addPeripheralUpdateCharacteristcBlock:[self getPeripheralUpdateCharacteristicsBlock]];
    
    // Sets peripheral disconnect block
    [[SweetToothManager sharedManager] addPeripheralDisconnectedBlock:[self getPeripheralDisconnectedBlock]];
    
    [[SweetToothManager sharedManager] connectPeripheral:self options:nil];
    
}

@end
