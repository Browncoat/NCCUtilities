// NSDictionary+NCCNullToNil.m
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

#import "NSDictionary+NCCNullToNil.h"

@implementation NSDictionary (NullToNil)

- (NSDictionary *)dictionaryByReplacingNullObjectswithNil
{
    NSMutableDictionary *replaced = [self mutableCopy];

    NSMutableSet *nilKeys = [NSMutableSet set];
    for (NSString *key in self) {
        id val = [self valueForKey:key];
        if ([val isKindOfClass:[NSDictionary class]]) {
            [replaced setValue:[(NSDictionary *)val dictionaryByReplacingNullObjectswithNil] forKey:key];
        } else if ([val isEqual:[NSNull null]]) {
            [nilKeys addObject:key];
        }
    }
    
    for (NSString *nilKey in nilKeys) {
        [replaced setValue:nil forKey:nilKey];
    }
    
    return [NSDictionary dictionaryWithDictionary:replaced];
}

@end
