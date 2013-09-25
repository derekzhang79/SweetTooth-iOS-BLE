//
//  SweetToothManager.h
//  SweetTooth
//
//  Created by Josh Holtz on 9/24/13.
//  Copyright (c) 2013 RokkinCat. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreBluetooth/CoreBluetooth.h>

typedef void (^DiscoverPeripheral)(CBPeripheral* peripheral, NSDictionary* advertisementData, NSNumber* RSSI);
typedef void (^PeripheralConnected)(CBPeripheral* peripheral);
typedef void (^PeripheralFailedToConnect)(CBPeripheral* peripheral, NSError* error);
typedef void (^PeripheralDisconnected)(CBPeripheral* peripheral, NSError* error);

typedef void (^PeripheralDiscoverServices)(CBPeripheral* peripheral, NSError* error);
typedef void (^PeripheralDiscoverCharacteristics)(CBPeripheral* peripheral, CBService* service, NSError* error);
typedef void (^PeripheralUpdateCharacteristc)(CBPeripheral* peripheral, CBCharacteristic* characteristic, NSError*error);
typedef void (^PeripheralWriteCharacteristc)(CBPeripheral* peripheral, CBCharacteristic* characteristic, NSError*error);

typedef void (^RetreievePeripherals)(NSArray* peripherals);
typedef void (^RetreieveConnectedPeripherals)(NSArray* peripherals);

@interface SweetToothManager : NSObject

@property (nonatomic, assign) BOOL isScanning;

+ (SweetToothManager *)initSharedManager:(dispatch_queue_t)queue options:(NSDictionary*)options;
+ (SweetToothManager *)sharedManager;

- (void)start;
- (void)start:(NSArray*)servicesUUIDs options:(NSDictionary*)options;
- (void)stop;

- (void)connectPeripheral:(CBPeripheral*)peripheral options:(NSDictionary *)options;
- (void)cancelPeripheralConnection:(CBPeripheral*)peripheral;

- (void)addDiscoverPeripheralBlock:(DiscoverPeripheral)discoverPeripheral;
- (void)addPeripheralConnectedBlock:(PeripheralConnected)peripheralConnected;
- (void)addPeripheralFailedToConnectBlock:(PeripheralFailedToConnect)peripheralFailedToConnect;
- (void)addPeripheralDisconnectedBlock:(PeripheralDisconnected)peripheralDisconnected;

- (void)addRetreievePeripheralsBlock:(RetreievePeripherals)retreievePeripherals;
- (void)addRetreieveConnectedPeripheralsBlock:(RetreieveConnectedPeripherals)retreieveConnectedPeripherals;

- (void)addPeripheralDiscoverServicesBlock:(PeripheralDiscoverServices)peripheralDiscoverServices;
- (void)addPeripheralDiscoverCharacteristicsBlock:(PeripheralDiscoverCharacteristics)peripheralDiscoverCharacteristics;
- (void)addPeripheralUpdateCharacteristcBlock:(PeripheralUpdateCharacteristc)peripheralUpdateCharacteristc;
- (void)addPeripheralWriteCharacteristcBlock:(PeripheralWriteCharacteristc)peripheralWriteCharacteristc;

- (void)removeAllBlocks;

- (void)removeDiscoverPeripheralBlock:(DiscoverPeripheral)discoverPeripheral;
- (void)removePeripheralConnectedBlock:(PeripheralConnected)peripheralConnected;
- (void)removePeripheralFailedToConnectBlock:(PeripheralFailedToConnect)peripheralFailedToConnect;
- (void)removePeripheralDisconnectedBlock:(PeripheralDisconnected)peripheralDisconnected;

- (void)removeRetreievePeripheralsBlock:(RetreievePeripherals)retreievePeripherals;
- (void)removeRetreieveConnectedPeripheralsBlock:(RetreieveConnectedPeripherals)retreieveConnectedPeripherals;

- (void)removePeripheralDiscoverServicesBlock:(PeripheralDiscoverServices)peripheralDiscoverServices;
- (void)removePeripheralDiscoverCharacteristicsBlock:(PeripheralDiscoverCharacteristics)peripheralDiscoverCharacteristics;
- (void)removePeripheralUpdateCharacteristcBlock:(PeripheralUpdateCharacteristc)peripheralUpdateCharacteristc;
- (void)removePeripheralWriteCharacteristcBlock:(PeripheralWriteCharacteristc)peripheralWriteCharacteristc;

@end
