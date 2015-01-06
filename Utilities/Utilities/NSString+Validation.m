// NSString+Validation.m
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

#import "NSString+Validation.h"

#define VALIDATION_ERROR_DOMAIN @"com.validation.paperwoven"

typedef NS_ENUM(NSInteger, StringValidationErrorCode) {
    StringValidationErrorCodeDefault,
    StringValidationErrorCodeFirstName,
    StringValidationErrorCodeLastName,
    StringValidationErrorCodeBillingAddress,
    StringValidationErrorCodeBillingCity,
    StringValidationErrorCodeBillingState,
    StringValidationErrorCodeBillingZip,
    StringValidationErrorCodeEmailRequired,
    StringValidationErrorCodeEmailInvalid,
    StringValidationErrorCodeExpireRequired,
    StringValidationErrorCodeExpireInvalid,
    StringValidationErrorCodePasswordRequired,
    StringValidationErrorCodePasswordInvalid,
    StringValidationErrorCodeCreditCardNumberRequired,
    StringValidationErrorCodeCreditCardNumberInvalid,
    StringValidationErrorCodeCreditCardCVVInvalid,
    StringValidationErrorCodeCreditCardCVVRequired,
    StringValidationErrorCodeCreditCardNameRequired,
    StringValidationErrorCodeCreditCardNameInvalid,
    StringValidationErrorCodeZipCode
};

@implementation NSString (Validation)

- (BOOL)isEmpty
{
    return ![self length];
}

+ (ValidationBlock)isValid
{
    ValidationBlock validationBlock = ^BOOL(NSString *text, NSError **error) {
        BOOL success = !text.isEmpty;
        
        if (!success) {
            if (error != NULL) {
                *error = [NSError errorWithDomain:VALIDATION_ERROR_DOMAIN code:StringValidationErrorCodeDefault userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"default_required", nil)}];
            }
        }
        
        return success;
    };
    
    return validationBlock;
}

+ (ValidationBlock)isValidEmail
{
    ValidationBlock validationBlock = ^BOOL(NSString *text, NSError **error) {
        if (text.isEmpty) {
            if (error != NULL) {
                *error = [NSError errorWithDomain:VALIDATION_ERROR_DOMAIN code:StringValidationErrorCodeEmailRequired userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"email_address_required", nil)}];
            }
            return NO;
        }
        
        BOOL stricterFilter = NO; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
        NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
        NSString *laxString = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";
        NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
        NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
        
        BOOL success = [emailTest evaluateWithObject:text];
        
        if (!success) {
            if (error != NULL) {
                *error = [NSError errorWithDomain:VALIDATION_ERROR_DOMAIN code:StringValidationErrorCodeEmailInvalid userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"email_address_invalid", nil)}];
            }
        }
        
        return success;
    };
    
    return validationBlock;
}

+ (ValidationBlock)isValidPassword
{
    ValidationBlock validationBlock = ^BOOL(NSString *text, NSError **error) {
        BOOL success = NO;
        
        if (text.isEmpty) {
            success = NO;
            if (error != NULL) {
                *error = [NSError errorWithDomain:VALIDATION_ERROR_DOMAIN code:StringValidationErrorCodePasswordRequired userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"password_required", nil)}];
            }
            return success;
        }
        
        if (text.length >= 6 && text.length <= 20) {
            success = YES;
        }
        
        if (!success) {
            if (error != NULL) {
                *error = [NSError errorWithDomain:VALIDATION_ERROR_DOMAIN code:StringValidationErrorCodePasswordInvalid userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"password_invalid", nil)}];
            }
        }
        
        return success;
    };
    
    return validationBlock;
}

+ (ValidationBlock)isValidCardholderName
{
    ValidationBlock validationBlock = ^BOOL(NSString *text, NSError **error) {
        BOOL success = YES;
        
        if (text.isEmpty) {
            if (error != NULL) {
                *error = [NSError errorWithDomain:VALIDATION_ERROR_DOMAIN code:StringValidationErrorCodeCreditCardNameRequired userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"cardholder_name_required", nil)}];
            }
            return NO;
        }

        if ([text length] > 255) {
            if (error != NULL) {
                *error = [NSError errorWithDomain:VALIDATION_ERROR_DOMAIN code:StringValidationErrorCodeCreditCardNameInvalid userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"cardholder_name_invalid", nil)}];
            }
            success = NO;
        }
        
        return success;
    };
    
    return validationBlock;
}

+ (ValidationBlock)isValidCreditCardNumber
{
    ValidationBlock validationBlock = ^BOOL(NSString *text, NSError **error) {
        BOOL success = NO;
        
        if (text.isEmpty) {
            success = NO;
            if (error != NULL) {
                *error = [NSError errorWithDomain:VALIDATION_ERROR_DOMAIN code:StringValidationErrorCodeCreditCardNumberRequired userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"card_number_required", nil)}];
            }
            
            return success;
        }
        
        // make sure the field contains numbers only
        NSString *cardNumberRegex = @"[0-9]{13,16}";
        NSPredicate *testCCNumber = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", cardNumberRegex];
        if ([testCCNumber evaluateWithObject:text]) {
            
            NSMutableArray *characters = [[NSMutableArray alloc] initWithCapacity:[text length]];
            for (int i=0; i < [text length]; i++) {
                NSString *ichar  = [NSString stringWithFormat:@"%c", [text characterAtIndex:i]];
                [characters addObject:ichar];
            }
            
            BOOL isOdd = YES;
            int oddSum = 0;
            int evenSum = 0;
            
            for (int i = [text length] - 1; i >= 0; i--) {
                
                int digit = [(NSString *)[characters objectAtIndex:i] intValue];
                
                if (isOdd)
                    oddSum += digit;
                else
                    evenSum += digit/5 + (2*digit) % 10;
                
                isOdd = !isOdd;
            }
            
            success = ((oddSum + evenSum) % 10 == 0);

        }
        
        if (!success) {
            if (error != NULL) {
                *error = [NSError errorWithDomain:VALIDATION_ERROR_DOMAIN code:StringValidationErrorCodeCreditCardNumberInvalid userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"card_number_invalid", nil)}];
            }
        }
        
        return success;
    };
    
    return validationBlock;
}

+ (ValidationBlock)isValidCreditCardCVV
{
    ValidationBlock validationBlock = ^BOOL(NSString *text, NSError **error) {
        BOOL success = YES;
        
        if (text.isEmpty) {
            success = NO;
            if (error != NULL) {
                *error = [NSError errorWithDomain:VALIDATION_ERROR_DOMAIN code:StringValidationErrorCodeCreditCardCVVRequired userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"cvv_code_required", nil)}];
            }
            
            return success;
        }
        
        NSString *passwordRegex = @"[0-9]{3,4}";
        NSPredicate *testPass = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", passwordRegex];
        if (![testPass evaluateWithObject:text]) {
            success = NO;
        }
        
        if (!success) {
            if (error != NULL) {
                *error = [NSError errorWithDomain:VALIDATION_ERROR_DOMAIN code:StringValidationErrorCodeCreditCardCVVInvalid userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"cvv_code_invalid", nil)}];
            }
        }
        
        return success;
    };
    
    return validationBlock;
}

+ (ValidationBlock)isValidExpirationDate
{
    ValidationBlock validationBlock = ^BOOL(NSString *text, NSError **error) {
        BOOL success = NO;
        
        if (text.isEmpty) {
            success = NO;
            if (error != NULL) {
                *error = [NSError errorWithDomain:VALIDATION_ERROR_DOMAIN code:StringValidationErrorCodeExpireRequired userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"expiration_date_required", nil)}];
            }
            
            return success;
        }
        
        NSArray *expireParts = [text componentsSeparatedByString:@"/"];
        int expireMonth = [[expireParts objectAtIndex:0] integerValue];
        int expireYear = [[expireParts objectAtIndex:1] integerValue];
        
        // convert the expiration date to an NSDate and make sure that it's this month or later
        // if the year is greater, good.  Otherwise check that the month is >=
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy"];
        int thisYear = [[formatter stringFromDate:[NSDate date]] integerValue];
        [formatter setDateFormat:@"M"];
        int thisMonth = [[formatter stringFromDate:[NSDate date]] integerValue];
        
        if (expireYear <= thisYear && expireMonth < thisMonth) {
            success = NO;
        } else {
            success = YES;
        }
        
        if (!success) {
            if (error != NULL) {
                *error = [NSError errorWithDomain:VALIDATION_ERROR_DOMAIN code:StringValidationErrorCodeExpireInvalid userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"expiration_date_invalid", nil)}];
            }
        }
        
        return success;
    };
    
    return validationBlock;
}

+ (ValidationBlock)isValidZipCode
{
    ValidationBlock validationBlock = ^BOOL(NSString *text, NSError **error) {
        BOOL success = [text length] > 4;
        
        if (!success) {
            if (error != NULL) {
                *error = [NSError errorWithDomain:VALIDATION_ERROR_DOMAIN code:StringValidationErrorCodeDefault userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"billing_zip_required", nil)}];
            }
        }
        
        return success;
    };
    
    return validationBlock;
}

@end

// Example localized strings
/*
 "default_required" = "This field is required";
 "billing_address1_required" = "Please enter your\nBilling Street Address.";
 "billing_city_required" = "Please enter your\nBilling City.";
 "billing_state_required" = "Please enter your\nBilling State.";
 "billing_zip_required" = "Please enter your\nBilling Zip Code.";
 "first_name_required" = "Please enter your\nFirst Name.";
 "last_name_required" = "Please enter your\nLast Name.";
 "email_address_required" = "Please enter an email address.";
 "email_address_invalid" = "Please enter\na valid Email Address.";
 "password_required" = "Please enter a password";
 "password_invalid" = "The password must be between 6 and 20 characters in length.";
 "cardholder_name_invalid" = "Name on Card is invalid.";
 "cardholder_name_required" = "Please enter the\ncardholder's name.";
 "card_number_invalid" = "Credit Card Number is invalid";
 "card_number_required" = "Please enter the\ncredit card number.";
 "cvv_code_invalid" = "CVV Code is invalid";
 "cvv_code_required" = "Please enter the\nCVV Code.";
 "expiration_date_required" = "Please enter the\ncard expiration date.";
 "expiration_date_invalid" = "Please enter a\nvalid Expiration Date";
 */
