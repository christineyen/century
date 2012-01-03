//
//  KIFTestStep+CenturyAdditions.h
//  century
//
//  Created by Christine Yen on 1/2/12.
//  Copyright (c) 2012 MIT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KIFTestStep.h"

@interface KIFTestStep (CenturyAdditions)

// Factory Steps
+ (id)stepToReset;

+ (id)stepToClearTextFieldWithAccessibilityLabel:(NSString *)label;

// Step Collections

// Assumes the application was reset and sitting at some Photo List screen
+ (NSArray *)stepsToSelectAndEditPhoto;

@end
