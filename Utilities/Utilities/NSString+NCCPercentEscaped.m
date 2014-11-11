// NSString+NCCPercentEscaped.m
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

#import "NSString+NCCPercentEscaped.h"

@implementation NSString (NCCPercentEscaped)

- (NSString*)percentEscape
{
    CFStringRef originalStringRef = (__bridge_retained CFStringRef)self;
    NSString *s = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,originalStringRef, NULL, NULL,kCFStringEncodingUTF8);
    CFRelease(originalStringRef);
    return s;
}

+ (NSString*)percentEscapedStringWithDictionary:(NSDictionary *)dictionary
{
    NSMutableString *urlEncodedString = [[NSMutableString alloc] init];
    
    for (id key in dictionary) {
        NSString *keyString = [key description];
        NSString *valueString = [[dictionary objectForKey:key] description];
        
        if ([urlEncodedString rangeOfString:@"?"].location == NSNotFound) {
            [urlEncodedString appendFormat:@"?%@=%@", [keyString percentEscape], [valueString percentEscape]];
        } else {
            [urlEncodedString appendFormat:@"&%@=%@", [keyString percentEscape], [valueString percentEscape]];
        }
    }
    
    return urlEncodedString;
}

@end
