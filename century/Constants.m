//
//  Constants.m
//  century
//
//  Created by Christine Yen on 1/2/12.
//  Copyright (c) 2012 MIT. All rights reserved.
//

#ifdef STR_CONST
  #undef STR_CONST
#endif

#define STR_CONST(name, value) NSString *const name = @ value
#include "ConstantList.h"

@implementation Constants

@end
