//
//  NSApplication+SystemVersion.h
//  Trips
//
//  Created by Martin Hewitson on 19/06/11.
//  Copyright 2011 AEI Hannover . All rights reserved.
//

#import <AppKit/AppKit.h>

@interface NSApplication (SystemVersion)

- (void)getSystemVersionMajor:(unsigned *)major
                        minor:(unsigned *)minor
                       bugFix:(unsigned *)bugFix;

- (BOOL) isLion;

@end
