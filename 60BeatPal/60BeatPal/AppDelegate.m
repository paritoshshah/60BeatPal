//
//  AppDelegate.m
//  60BeatPal
//
//  Created by Splunker on 1/19/15.
//  Copyright (c) 2015 Splunker. All rights reserved.
//

#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import <Foundation/NSUUID.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {

    manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    
    [self startScan];
    
}

- (void) centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)aPeripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSLog(@"Found a device %@", [aPeripheral name]);
    if ([[aPeripheral name] isEqualToString:@"Weight Measurement"]) {
        [self stopScan];
        peripheral = aPeripheral;
        [manager connectPeripheral:peripheral options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:CBConnectPeripheralOptionNotifyOnDisconnectionKey]];
    }
}

/*
 Invoked whenever a connection is succesfully created with the peripheral.
 Discover available services on the peripheral
 */
- (void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)aPeripheral
{
    [aPeripheral setDelegate:self];
    [aPeripheral discoverServices:nil];
}

/*
 Invoked upon completion of a -[discoverServices:] request.
 Discover available characteristics on interested services
 */
- (void) peripheral:(CBPeripheral *)aPeripheral didDiscoverServices:(NSError *)error
{
    for (CBService *aService in aPeripheral.services)
    {
        NSLog(@"Service found with UUID: %@", aService.UUID);
        
        /* Weight Measurement Service */
        if ([[aService.UUID UUIDString] isEqualToString:@"299D1809-2F61-11E2-81C1-0800200C9A66"] )
        {
            [aPeripheral discoverCharacteristics:nil forService:aService];
        }
    }
}


/*
 Invoked upon completion of a -[discoverCharacteristics:forService:] request.
 Perform appropriate operations on interested characteristics
 */
- (void) peripheral:(CBPeripheral *)aPeripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if ([service.UUID isEqual:[CBUUID UUIDWithString:@"299D1809-2F61-11E2-81C1-0800200C9A66"]])
    {
        for (CBCharacteristic *aChar in service.characteristics)
        {
                [peripheral setNotifyValue:YES forCharacteristic:aChar];
                [aPeripheral readValueForCharacteristic:aChar];
        }
    }
    
}

/*
 Invoked upon completion of a -[readValueForCharacteristic:] request or on the reception of a notification/indication.
 */
- (void) peripheral:(CBPeripheral *)aPeripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"Characteristic UUID %@, value %@", characteristic.UUID, characteristic.value);
}


/*
 Invoked whenever the central manager's state is updated.
 */
- (void) centralManagerDidUpdateState:(CBCentralManager *)central
{
    [self isLECapableHardware];
}

/*
 Uses CBCentralManager to check whether the current platform/hardware supports Bluetooth LE. An alert is raised if Bluetooth LE is not enabled or is not supported.
 */
- (BOOL) isLECapableHardware
{
    NSString * state = nil;
    
    switch ([manager state])
    {
        case CBCentralManagerStateUnsupported:
            state = @"The platform/hardware doesn't support Bluetooth Low Energy.";
            break;
        case CBCentralManagerStateUnauthorized:
            state = @"The app is not authorized to use Bluetooth Low Energy.";
            break;
        case CBCentralManagerStatePoweredOff:
            state = @"Bluetooth is currently powered off.";
            break;
        case CBCentralManagerStatePoweredOn:
            return TRUE;
        case CBCentralManagerStateUnknown:
        default:
            return FALSE;
            
    }
    
    NSLog(@"Central manager state: %@", state);
    
//    NSAlert *alert = [[NSAlert alloc] init];
//    [alert setMessageText:state];
//    [alert addButtonWithTitle:@"OK"];
    return FALSE;
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (void) startScan {
    [manager scanForPeripheralsWithServices:nil options:nil];
}

- (void) stopScan
{
    [manager stopScan];
}

- (void) dealloc
{
    [self stopScan];
}

@end
