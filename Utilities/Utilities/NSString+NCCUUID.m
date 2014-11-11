// NSString+NCCUUID.m
//
// Copyright (c) 2013-2014 NCCCoreDataClient (http://coredataclient.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "NSString+NCCUUID.h"

#define SLD_DEVICE_ID @"sld_device_id"

@implementation NSString (NCCUUID)

+ (NSString *)uuid
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *uuidString = [userDefaults objectForKey:SLD_DEVICE_ID];
    
    if (!uuidString) {
        CFUUIDRef uuid = CFUUIDCreate(NULL);
        if (uuid) {
            uuidString = (NSString *)CFBridgingRelease(CFUUIDCreateString(NULL, uuid));
            CFRelease(uuid);
            
            [userDefaults setObject:uuidString forKey:SLD_DEVICE_ID];
        }
    }
    
    return uuidString;
}

@end
