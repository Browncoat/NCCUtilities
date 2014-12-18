// NSURLRequest+NCCCURL.m
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

#import "NSURLRequest+NCCCURL.h"

@implementation NSURLRequest (NCCCURL)

- (NSString *)curlString
{
    NSMutableString *headers = [NSMutableString string];
    for (NSString *key in self.allHTTPHeaderFields) {
        [headers appendFormat:@"-H \"%@:%@\" \\\n", key, self.allHTTPHeaderFields[key]];
    }
    
    NSString *body = [[NSString alloc] initWithData:self.HTTPBody encoding:NSASCIIStringEncoding];
    if (body) {
        body = [NSString stringWithFormat:@"-d \'%@\'", body];
    }
    NSString *curlRequest = [NSString stringWithFormat:@"curl -v \\\n%@-X %@ \\\n%@ \\\n'%@'", headers, (self.HTTPMethod), body, [self.URL absoluteString]];
    
    return curlRequest;
}

@end
