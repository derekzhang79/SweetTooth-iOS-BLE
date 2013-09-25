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

+ (SweetToothManager *)initSharedClient:(dispatch_queue_t)queue options:(NSDictionary*)options;
+ (SweetToothManager *)sharedClient;

- (void)start;
- (void)start:(NSArray*)servicesUUIDs options:(NSDictionary*)options;
- (void)stop;

- (void)connectPeripheral:(CBPeripheral*)peripheral options:(NSDictionary *)options;
- (void)cancelPeripheralConnection:(CBPeripheral*)peripheral;

- (void)setDiscoverPeripheralBlock:(DiscoverPeripheral)discoverPeripheral;
- (void)setPeripheralConnectedBlock:(PeripheralConnected)peripheralConnected;
- (void)setPeripheralFailedToConnectBlock:(PeripheralFailedToConnect)peripheralFailedToConnect;
- (void)setPeripheralDisconnectedBlock:(PeripheralDisconnected)peripheralDisconnected;

- (void)setRetreievePeripheralsBlock:(RetreievePeripherals)retreievePeripherals;
- (void)setRetreieveConnectedPeripheralsBlock:(RetreieveConnectedPeripherals)retreieveConnectedPeripherals;

- (void)setPeripheralDiscoverServicesBlock:(PeripheralDiscoverServices)peripheralDiscoverServices;
- (void)setPeripheralDiscoverCharacteristicsBlock:(PeripheralDiscoverCharacteristics)peripheralDiscoverCharacteristics;
- (void)setPeripheralUpdateCharacteristcBlock:(PeripheralUpdateCharacteristc)peripheralUpdateCharacteristc;
- (void)setPeripheralWriteCharacteristcBlock:(PeripheralWriteCharacteristc)peripheralWriteCharacteristc;

@end
