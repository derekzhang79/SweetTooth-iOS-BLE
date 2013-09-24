//
//  CBUUID+StringExtraction.h
//  SweetTooth
//
//  Created by Josh Holtz on 9/24/13.
//  Copyright (c) 2013 RokkinCat. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>

@interface CBUUID (StringExtraction)

- (NSString *)representativeString;

@end
