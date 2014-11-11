// UIImageView+NCCDownload.m
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

#import <objc/runtime.h>
#import "UIImageView+NCCDownload.h"

@implementation UIImageView (NCCDownload)

- (void)cancelImageDownload
{
    [self.client cancelRequest];
    [self hideLoadingIndicator];
}

- (void)loadImageFromUrl:(NSString *)url fallback:(UIImage *)fallback fadeIn:(BOOL)shouldFadeIn completion:(DownloadComplete)completion
{
    if (!self.client) {
        self.client = [[NCCHTTPClient alloc] init];
    }
    [self cancelImageDownload];
    self.image = nil;
    self.fallbackImage = fallback;
    self.shouldFadeIn = shouldFadeIn;
    self.completion = completion;
    self.url = url;
    
    if (url) {
        UIImage *cachedImage = [self cachedImageForUrl:url];
        if (cachedImage) {
            self.image = cachedImage;
            if (self.completion) {
                self.completion(nil);
            }
        } else {
            [self showLoadingIndicator];
            NSOperationQueue *downloadQueue = [[NSOperationQueue alloc] init];
            [downloadQueue addOperationWithBlock:^{
                NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.url]];
                NSURLResponse *response;
                NSError *error;
                NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
                
                [[NSOperationQueue mainQueue] addOperationWithBlock: ^ {
                    if (!error) {
                        [self didCompleteWithData:data];
                    } else {
                        [self didFailWithError:error];
                    }
                }];
            }];
        }
    } else {
        [self didFailWithError:[NSError errorWithDomain:NSStringFromClass([self class]) code:0 userInfo:@{NSLocalizedDescriptionKey:@"Empty URL"}]];
    }
}

- (UIImage *)cachedImageForUrl:(NSString *)url
{
    NSURL *imageUrl = [NSURL URLWithString:url];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:imageUrl];
    NSCachedURLResponse *cachedResponse = [[NSURLCache sharedURLCache] cachedResponseForRequest:request];
    
    if (cachedResponse) {
        
        UIImage *image = [UIImage imageWithData:cachedResponse.data];
        return image;
    }
    
    return nil;
}

- (void)showLoadingIndicator
{
    if (![self viewWithTag:123456]) {
        UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        activityIndicator.hidesWhenStopped = YES;
        activityIndicator.center = self.center;
        activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
        activityIndicator.tag = 123456;
        [self addSubview:activityIndicator];
    }
    [(UIActivityIndicatorView *)[self viewWithTag:123456] startAnimating];
}

- (void)hideLoadingIndicator
{
    [(UIActivityIndicatorView *)[self viewWithTag:123456] stopAnimating];
}

- (void)fadeIn
{
    self.alpha = 0;
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 1;
    }];
}

- (void)fadeOut
{
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0;
    }];
}

- (void)didFailWithError:(NSError *)error
{
    self.image = self.fallbackImage;
    [self hideLoadingIndicator];
    if (self.shouldFadeIn) {
        [self fadeIn];
    }
    if (self.completion) {
        self.completion(error);
    }
}

- (void)didCompleteWithData:(NSData *)data
{
    self.image = [UIImage imageWithData:data];
    [self hideLoadingIndicator];
    if (self.shouldFadeIn) {
        [self fadeIn];
    }
    if (self.completion) {
        self.completion(nil);
    } 
}

- (void)setClient:(id)newClient {
    objc_setAssociatedObject(self, @selector(client), newClient, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)client {
    return objc_getAssociatedObject(self, @selector(client));
}

- (void)setFallbackImage:(id)newFallbackImage {
    objc_setAssociatedObject(self, @selector(fallbackImage), newFallbackImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)fallbackImage {
    return objc_getAssociatedObject(self, @selector(fallbackImage));
}


- (void)setUrl:(id)newUrl {
    objc_setAssociatedObject(self, @selector(url), newUrl, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)url {
    return objc_getAssociatedObject(self, @selector(url));
}

- (void)setShouldFadeIn:(BOOL)newShouldFadeIn {
    
    objc_setAssociatedObject(self, @selector(shouldFadeIn), [NSNumber numberWithBool:newShouldFadeIn], OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)shouldFadeIn {
    return [objc_getAssociatedObject(self, @selector(shouldFadeIn)) boolValue];
}

- (void)setCompletion:(DownloadComplete)newCompletion {
    objc_setAssociatedObject(self, @selector(completion), newCompletion, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (DownloadComplete)completion {
    return objc_getAssociatedObject(self, @selector(completion));
}

@end
