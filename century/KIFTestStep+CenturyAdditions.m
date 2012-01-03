//
//  KIFTestStep+CenturyAdditions.m
//  century
//
//  Created by Christine Yen on 1/2/12.
//  Copyright (c) 2012 MIT. All rights reserved.
//

#import "KIFTestStep+CenturyAdditions.h"
#import "UIApplication-KIFAdditions.h"
#import "UIAccessibilityElement-KIFAdditions.h"

@implementation KIFTestStep (CenturyAdditions)

+ (id)stepToReset {
    return [KIFTestStep stepWithDescription:@"Reset the application state." executionBlock:^(KIFTestStep *step, NSError **error) {
        BOOL successfulReset = YES;
        
        // Do the actual reset for your app. Set successfulReset = NO if it fails.
        KIFTestCondition(successfulReset, error, @"Failed to reset the application.");
        return KIFTestStepResultSuccess;
    }];     
}

+ (id)stepToClearTextFieldWithAccessibilityLabel:(NSString *)label {
    return [KIFTestStep stepWithDescription:@"Clear a text field." executionBlock:^(KIFTestStep *step, NSError **error) {
        UIAccessibilityElement *element = [[UIApplication sharedApplication] accessibilityElementWithLabel:label];
        if (!element) {
            return KIFTestStepResultWait;
        }
        
        UIView *view = [UIAccessibilityElement viewContainingAccessibilityElement:element];
        
        if ([view isKindOfClass:[UITextField class]] || [view isKindOfClass:[UITextView class]]) {
            [(UITextField *)view setText:@""];
        } else {
            KIFTestCondition(NO, error, @"Failed to find valid UITextField or UITextView to manipulate.");
        }
        
        return KIFTestStepResultSuccess;
    }];
}

+ (NSArray *)stepsToSelectAndEditPhoto {
    NSMutableArray *steps = [NSMutableArray array];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [steps addObject:[KIFTestStep stepToWaitForViewWithAccessibilityLabel:@"Photo List"]];
    [steps addObject:[KIFTestStep stepToTapRowInTableViewWithAccessibilityLabel:@"Photo List"
                                                                    atIndexPath:indexPath]];
    [steps addObject:[KIFTestStep stepToWaitForViewWithAccessibilityLabel:@"Photo View"]];
    [steps addObject:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Edit Button"]];
    
    [steps addObject:[KIFTestStep stepToWaitForViewWithAccessibilityLabel:@"Photo Name Field"]];
    [steps addObject:[KIFTestStep stepToClearTextFieldWithAccessibilityLabel:@"Photo Name Field"]];
    [steps addObject:[KIFTestStep stepToEnterText:@"NEW NAME" intoViewWithAccessibilityLabel:@"Photo Name Field"]];
    [steps addObject:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Save"]];
    
    [steps addObject:[KIFTestStep stepToWaitForViewWithAccessibilityLabel:@"Photo View"]];
    
    // find a way to make sure photo edit is saved?
    
    return steps;
}
@end
