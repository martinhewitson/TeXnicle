//
//  NSDate+GMT.m
//  TeXnicle
//
//  Created by Martin Hewitson on 12/8/11.
//  Copyright 2011 bobsoft. All rights reserved.
//

#import "NSDate+GMT.h"

@implementation NSDate (GMT)

- (NSDate*)toGMT
{
  NSTimeInterval timeZoneOffset = [[NSTimeZone defaultTimeZone] secondsFromGMT]; // You could also use the systemTimeZone method
  NSTimeInterval gmtTimeInterval = [self timeIntervalSinceReferenceDate] - timeZoneOffset;
  return [NSDate dateWithTimeIntervalSinceReferenceDate:gmtTimeInterval];
}

@end
