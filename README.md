# SweetTooth
A simplistic, sugarcoated, iOS CoreBluetooth Wrapper

## Let's Get Down To Business

1. Initialize shared SweetToothManager with its own queue and options (Optional)
    - By not calling "initSharedManager", SweetToothManager will be called on main thread with no options
2. Add DiscoverPeripheralBlock to SweetToothManager
    - This block will executed when peripherals are discovered
3. Start scanning
    - You know, it starts scanning for peripherals

````objc

    // Initialize SweetToothManager
    dispatch_queue_t queue = dispatch_queue_create("com.joshholtz.sweettooth", 0);
    [SweetToothManager initSharedManager:queue options:nil];
    
    // Set discover peripheral block
    [[SweetToothManager sharedManager] addDiscoverPeripheralBlock:^void(CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI) {
        NSLog(@"Name - %@", peripheral.name);
        
        // NOTE: Retain this peripheral for future use - peripheral NEEDS to be retained to be connected to otherwise it will be deallocated
    }];
    
    // Start scanning for peripherals
    [[SweetToothManager sharedManager] start:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@YES }];


````

## The Sweetness

We created some helpers for you to make simple tasks... simple

### Read characteristics of a peripheral 

````objc

    // This is a peripheral that we retain and set in our DiscoverPeripheralBlock
    @property (nonatomic, strong) CBPeripheral *somePeripheral;

    // Reads characteristics from a service - takes service CCUUID, takes and NSArray of characteristic CCUIDs (nil will get all characteristics)
    // This method connects peripheral, discovers service, discovers characterists, request update on characteristic values, and disconnects
    [_somePeripheral readCharacteristics:[CBUUID UUIDWithString:@"Some-Service-UUUID"] characteristicUUIDs:@[[CBUUID UUIDWithString:@"ed0d5a2e-00cd-4a3c-bd58-31e9e22a9c43"]] block:^(CBPeripheral *peripheral, NSArray *characteristics, NSError *error) {
        
        [characteristics enumerateObjectsUsingBlock:^(CBCharacteristic* characteristic, NSUInteger idx, BOOL *stop) {
            // Here is where you would map value to some variable or data object based on the characteristic's UUID
            NSLog(@"%@ has value %@", characteristic.UUID.representativeString, characteristic.value);
        }];
        
    }];

````
