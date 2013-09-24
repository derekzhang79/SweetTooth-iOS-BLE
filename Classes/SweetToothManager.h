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

@interface SweetToothManager : NSObject

@property (nonatomic, assign) BOOL isScanning;

+ (SweetToothManager *)initSharedClient:(dispatch_queue_t)queue options:(NSDictionary*)options;
+ (SweetToothManager *)sharedClient;

- (void)start;
- (void)start:(NSArray*)servicesUUIDs options:(NSDictionary*)options;
- (void)stop;

- (void)setDiscoverPeripheralBlock:(DiscoverPeripheral)discoverPeripheral;

@end
