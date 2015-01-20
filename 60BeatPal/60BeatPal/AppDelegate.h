//
//  AppDelegate.h
//  60BeatPal
//
//  Created by Splunker on 1/19/15.
//  Copyright (c) 2015 Splunker. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <IOBluetooth/IOBluetooth.h>

@interface AppDelegate : NSObject <NSApplicationDelegate, CBCentralManagerDelegate, CBPeripheralDelegate>
{
    CBCentralManager *manager;
    CBPeripheral *peripheral;
}

- (void) startScan;
- (void) stopScan;

@end

