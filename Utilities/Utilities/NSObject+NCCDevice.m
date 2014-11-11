// NSObject+NCCDevice.m
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

#import "NSObject+NCCDevice.h"

@implementation NSObject (NCCDevice)

-(BOOL)isPad
{
#ifdef UI_USER_INTERFACE_IDIOM
		return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
#else
		return NO;
#endif
}

-(BOOL)isPhone
{
#ifdef UI_USER_INTERFACE_IDIOM
	return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone);
#else
	return YES;
#endif
}

-(BOOL)isWideScreen
{
#ifdef UI_USER_INTERFACE_IDIOM
    if ([[self class] isPhone]) {
        return ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON );
    } else {
        return NO;
    }
#else
    return NO;
#endif
}

- (BOOL)isRetina
{
    return ([[UIScreen mainScreen] scale] >= 2);
}

- (BOOL)isCurrentSystemVersionLessThanSystemVersion:(NSString *)version
{
    NSString *currSystemVersion = [[UIDevice currentDevice] systemVersion];
    
    if ([currSystemVersion compare:version options:NSNumericSearch] != NSOrderedAscending) {
        return NO;
    }
    
    return YES;
}

@end
