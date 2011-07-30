//
//  NSStringUUID.h
//  SigProcOO
//
//  Created by Martin Hewitson on 02/06/2009.
//  Copyright 2009 bobsoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/**
 A category of NSString which adds methods to do with UUIDs.
 */
@interface NSString (UUID) 

/**
 Create an NSString containing a random UUID.
 */
+ (NSString *) stringWithUUID;

@end
