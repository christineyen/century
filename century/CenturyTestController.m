//
//  CenturyTestController.m
//  century
//
//  Created by Christine Yen on 1/2/12.
//  Copyright (c) 2012 MIT. All rights reserved.
//

#import "CenturyTestController.h"
#import "KIFTestScenario+CenturyAdditions.h"

@implementation CenturyTestController

- (void)initializeScenarios {
    [self addScenario:[KIFTestScenario scenarioToViewPhotos]];
}
@end
