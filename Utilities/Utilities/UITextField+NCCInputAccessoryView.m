// UITextField+NCCInputAccessoryView.m
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

#import "UITextField+NCCInputAccessoryView.h"
#import "UITextField+NCCResponderChain.h"
#import <objc/runtime.h>

@implementation UITextField (NCCInputAccessoryView)

- (void)addResponderChainInputAccessoryViewWithDelegate:(id<UITextFieldNCCInputAccessoryViewDelegate>)inputAccessoryDelegate
{
    self.inputAccessoryDelegate = inputAccessoryDelegate;
    [self addResponderChainInputAccessoryView];
}

- (void)addResponderChainInputAccessoryView
{
    if (!self.inputAccessoryView) {
        UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.superview.bounds.size.width, 44)];
        UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        
        UISegmentedControl *control = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:
                                                                                 @"Previous",
                                                                                 @"Next",
                                                                                 nil]];
        control.segmentedControlStyle = UISegmentedControlStyleBar;
        control.momentary = YES;
        
        [control addTarget:self action:@selector(nextPrevious:) forControlEvents:UIControlEventValueChanged];
        
        if(![self.superview viewWithTag:self.nextTextFieldTag] || [self.superview viewWithTag:self.nextTextFieldTag].hidden){
            [control setEnabled:NO forSegmentAtIndex:1];
        }
        
        if(![self.superview viewWithTag:self.previousTextFieldTag] || [self.superview viewWithTag:self.previousTextFieldTag].hidden){
            [control setEnabled:NO forSegmentAtIndex:0];
        }
        
        UIBarButtonItem *controlItem = [[UIBarButtonItem alloc] initWithCustomView:control];
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(endEditing:)];
        
        NSArray *items = [[NSArray alloc] initWithObjects:controlItem, spacer, doneButton, nil];
        [toolBar setItems:items];
        
        toolBar.barStyle = UIBarStyleBlackTranslucent;
        [self setInputAccessoryView:toolBar];
    }
}

- (void)nextPrevious:(id)sender
{
    switch([(UISegmentedControl *)sender selectedSegmentIndex]){
        case 0:
        {
            [self previous];
        }
            break;
        case 1:
        {
            [self next];
        }
            break;
    }
}

- (void)next
{
    UIResponder* nextResponder = [self.superview viewWithTag:self.nextTextFieldTag];
    if (nextResponder) {
        /*
        if (self.delegate) {
            if ([self.delegate respondsToSelector:@selector(textFieldShouldEndEditing:)]) {
                if ([self.delegate textFieldShouldEndEditing:self]) {
                    [nextResponder becomeFirstResponder];
                }
            }
        }
         */
        if (self.delegate) {
            if ([self.delegate respondsToSelector:@selector(textFieldShouldSelectNextResponder:)]) {
                if ([self.inputAccessoryDelegate textFieldShouldSelectNextResponder:self]) {
                    [nextResponder becomeFirstResponder];
                }
            } else {
                [nextResponder becomeFirstResponder];
            }
        } else {
            [nextResponder becomeFirstResponder];
        }
    }
}

- (void)previous
{
    UIResponder* nextResponder = [self.superview viewWithTag:self.previousTextFieldTag];
    if (nextResponder) {
        /*
        if (self.delegate) {
            if ([self.delegate respondsToSelector:@selector(textFieldShouldEndEditing:)]) {
                if ([self.delegate textFieldShouldEndEditing:self]) {
                    [nextResponder becomeFirstResponder];
                }
            }
        }
         */
        if (self.delegate) {
            if ([self.delegate respondsToSelector:@selector(textFieldShouldSelectPreviousResponder:)]) {
                if ([self.inputAccessoryDelegate textFieldShouldSelectPreviousResponder:self]) {
                    [nextResponder becomeFirstResponder];
                }
            } else {
                [nextResponder becomeFirstResponder];
            }
        } else {
            [nextResponder becomeFirstResponder];
        }
    }
}

#pragma mark - Delegate

- (void)setInputAccessoryDelegate:(id)newInputAccessoryDelegate {
    objc_setAssociatedObject(self, @selector(inputAccessoryDelegate), newInputAccessoryDelegate, OBJC_ASSOCIATION_ASSIGN);
}

- (id)inputAccessoryDelegate {
    return objc_getAssociatedObject(self, @selector(inputAccessoryDelegate));
}

@end
