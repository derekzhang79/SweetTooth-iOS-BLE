//
//  CBPeripheral+SweetTooth.h
//  SweetTooth
//
//  Created by Josh Holtz on 9/25/13.
//  Copyright (c) 2013 RokkinCat. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>

typedef void (^SweetToothPeripheralUpdateCharacteristc)(CBPeripheral* peripheral, NSArray* characteristics, NSError*error);

@interface CBPeripheral (SweetTooth)

- (void)readCharacteristics:(CBUUID*)service characteristicUUIDs:(NSArray*)characteristicUUIDs block:(SweetToothPeripheralUpdateCharacteristc)block;

@end
