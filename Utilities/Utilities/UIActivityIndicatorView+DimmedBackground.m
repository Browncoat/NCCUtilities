// NCCUtilities_h
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

#import "UIActivityIndicatorView+DimmedBackground.h"
#import <QuartzCore/QuartzCore.h>

static UIActivityIndicatorView *_activityIndicatorView;

@implementation UIActivityIndicatorView (DimmedBackground)

+ (void)show
{
    UIWindow *mainWindow = [[[UIApplication sharedApplication] delegate] window];
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _activityIndicatorView = activityIndicatorView;
    [_activityIndicatorView setHidesWhenStopped:YES];
    [mainWindow addSubview:activityIndicatorView];
    [activityIndicatorView dimBackground];
    [activityIndicatorView startAnimating];
}

+ (void)hide
{
    if (_activityIndicatorView) {
        [_activityIndicatorView stopAnimating];
    }
}

- (void)dimBackground
{
    self.frame = self.superview.bounds;
    [self.layer setBackgroundColor:[[UIColor colorWithWhite: 0.0 alpha:0.30] CGColor]];
}

@end
