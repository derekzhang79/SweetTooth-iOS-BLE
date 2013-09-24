# SweetTooth
A simplistic iOS CoreBluetooth Wrapper

````objc

    // Initialize SweetToothManager
    dispatch_queue_t queue = dispatch_queue_create("com.joshholtz.sweettooth", 0);
    [SweetToothManager initSharedClient:queue options:nil];
    
    // Start scanning
    [[SweetToothManager sharedClient] start:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@YES }];
    
    // Set discover peripheral block
    [[SweetToothManager sharedClient] setDiscoverPeripheralBlock:^void(CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI) {
        NSLog(@"Name - %@", peripheral.name);
    }];


````
