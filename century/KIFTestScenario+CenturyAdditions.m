//
//  KIFTestScenario+CenturyAdditions.m
//  century
//
//  Created by Christine Yen on 1/2/12.
//  Copyright (c) 2012 MIT. All rights reserved.
//

#import "KIFTestScenario+CenturyAdditions.h"
#import "KIFTestStep+CenturyAdditions.h"
#import "KIFTestStep.h"

@implementation KIFTestScenario (CenturyAdditions)

+ (id)scenarioToViewPhotos {
    KIFTestScenario *scenario = [KIFTestScenario scenarioWithDescription:@"Test that a user can view and edit photos."];
    [scenario addStep:[KIFTestStep stepToReset]];
    [scenario addStep:[KIFTestStep stepToTapRowInTableViewWithAccessibilityLabel:ACC_PersonList
                                                                     atIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]]];
    [scenario addStepsFromArray:[KIFTestStep stepsToSelectAndEditPhoto]];
    
    return scenario;
}
@end
