// UIFont+NCCInstall.m
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

#import "UIFont+NCCInstall.h"
#import <CoreText/CoreText.h>
#import <MobileCoreServices/MobileCoreServices.h>

@implementation UIFont (NCCInstall)

+ (NSArray *)allFonts
{
    NSMutableArray *fontNames = [[NSMutableArray alloc] init];
    
    // get font family
    NSArray *fontFamilyNames = [self familyNames];
    
    // font names under family
    NSArray *names = nil;
    
    // loop
    for (NSString *familyName in fontFamilyNames)
    {
        NSLog(@"Font Family Name = %@", familyName);
        
        // font names under family
        names = [self fontNamesForFamilyName:familyName];
        
        NSLog(@"Font Names = %@", fontNames);
        
        // add to array
        [fontNames addObjectsFromArray:names];
    }
    
    return names;
}

+ (void)installFonts
{
    // Load more than two fonts of the same family
    CTFontManagerRegisterFontsForURLs((__bridge CFArrayRef)((^{
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSURL *resourceURL = [[NSBundle mainBundle] resourceURL];
        NSArray *resourceURLs = [fileManager contentsOfDirectoryAtURL:resourceURL includingPropertiesForKeys:nil options:0 error:nil];
        return [resourceURLs filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSURL *url, NSDictionary *bindings) {
            CFStringRef pathExtension = (__bridge CFStringRef)[url pathExtension];
            NSArray *allIdentifiers = (__bridge_transfer NSArray *)UTTypeCreateAllIdentifiersForTag(kUTTagClassFilenameExtension, pathExtension, CFSTR("public.font"));
            if (![allIdentifiers count]) {
                return NO;
            }
            CFStringRef utType = (__bridge CFStringRef)[allIdentifiers lastObject];
            return (!CFStringHasPrefix(utType, CFSTR("dyn.")) && UTTypeConformsTo(utType, CFSTR("public.font")));
            
        }]];
    })()), kCTFontManagerScopeProcess, nil);
}

@end
