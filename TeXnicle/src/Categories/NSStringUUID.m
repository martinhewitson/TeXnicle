//
//  NSStringUUID.m
//  SigProcOO
//
//  Created by Martin Hewitson on 02/06/2009.
//  Copyright 2009 bobsoft. All rights reserved.
//

#import "NSStringUUID.h"


@implementation NSString (UUID)

+ (NSString*) stringWithUUID {
	CFUUIDRef	uuidObj = CFUUIDCreate(nil);//create a new UUID
	//get the string representation of the UUID
  CFStringRef uuidCFString = CFUUIDCreateString(nil, uuidObj);
	NSString	*uuidString = [NSString stringWithString:(NSString*)uuidCFString];
	CFRelease(uuidObj);
  CFRelease(uuidCFString);
	return uuidString;
}

@end
