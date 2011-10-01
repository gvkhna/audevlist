//
//  main.m
//  audevlist
//
//  Created by Gaurav Khanna on 10/1/11.
//  Copyright (c) 2011 GK Apps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>
#import <CoreAudio/CoreAudio.h>
#import <CoreServices/CoreServices.h>
#import <AudioUnit/AudioUnit.h>
#import <AudioUnit/AUComponent.h>
#include <stdio.h>
#include <pthread.h>
#include <checkint.h>
#include <stdarg.h>

AudioObjectPropertyAddress theAddress = { kAudioHardwarePropertyDevices, kAudioObjectPropertyScopeGlobal, kAudioObjectPropertyElementMaster };

void CleanLog(NSString *format, ...) {
    va_list args;
    va_start(args, format);
    NSString *string = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    fprintf(stderr, "%s\n", [string UTF8String]);
}

UInt32 getDataSize(void) {
    UInt32 dataSize;
    OSStatus err = noErr;
    theAddress.mSelector = kAudioHardwarePropertyDevices;
    err = AudioObjectGetPropertyDataSize( kAudioObjectSystemObject, &theAddress, 0, NULL, &dataSize);
    if (err) exit(-1);
    return dataSize;
}

int main (int argc, const char * argv[])
{

    @autoreleasepool {
        
        UInt32 dataSize = getDataSize();
        uint32_t numDevices;
        int divideErr;
        
        numDevices = check_uint32_div(dataSize, sizeof(AudioDeviceID), &divideErr);
        if(numDevices == -1) exit(-1);
        
        AudioDeviceID deviceIDs[numDevices];
        OSStatus err = noErr;

        theAddress.mSelector = kAudioHardwarePropertyDevices;
        err = AudioObjectGetPropertyData(kAudioObjectSystemObject, &theAddress, 0, NULL, &dataSize, &deviceIDs);
        if (err) exit(-1);
        
        for (int i=0;i<numDevices;i++) {
            CFStringRef aDeviceName;
            UInt32 aDataSize = sizeof(CFStringRef);
            OSStatus aErr = noErr;
            
            theAddress.mSelector = kAudioDevicePropertyDeviceNameCFString;
            aErr = AudioObjectGetPropertyData(deviceIDs[i], &theAddress, 0, NULL, &aDataSize, &aDeviceName);
            if (aErr) exit(-1);
            
            CFMutableStringRef cleanedStr = CFStringCreateMutableCopy(NULL, 0, aDeviceName);
            CFStringTrimWhitespace(cleanedStr);
            
            CleanLog(@"<AUDevice: Name=%@;DeviceID=%u>", cleanedStr, deviceIDs[i]);
        }
        
    }
    return 0;
}

