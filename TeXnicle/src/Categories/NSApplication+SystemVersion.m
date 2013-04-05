//
//  NSApplication+SystemVersion.m
//  TeXnicle
//
//  Created by Martin Hewitson on 19/06/11.
//  Copyright 2011 bobsoft. All rights reserved.
//
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//      * Redistributions of source code must retain the above copyright
//        notice, this list of conditions and the following disclaimer.
//      * Redistributions in binary form must reproduce the above copyright
//        notice, this list of conditions and the following disclaimer in the
//        documentation and/or other materials provided with the distribution.
//  
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL MARTIN HEWITSON OR BOBSOFT SOFTWARE BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "NSApplication+SystemVersion.h"

@implementation NSApplication (SystemVersion)

- (void)getSystemVersionMajor:(unsigned *)major
                        minor:(unsigned *)minor
                       bugFix:(unsigned *)bugFix;
{
  OSErr err;
  SInt32 systemVersion, versionMajor, versionMinor, versionBugFix;
  if ((err = Gestalt(gestaltSystemVersion, &systemVersion)) != noErr) goto fail;
  if (systemVersion < 0x1040)
  {
    if (major) *major = ((systemVersion & 0xF000) >> 12) * 10 +
      ((systemVersion & 0x0F00) >> 8);
    if (minor) *minor = (systemVersion & 0x00F0) >> 4;
    if (bugFix) *bugFix = (systemVersion & 0x000F);
  }
  else
  {
    if ((err = Gestalt(gestaltSystemVersionMajor, &versionMajor)) != noErr) goto fail;
    if ((err = Gestalt(gestaltSystemVersionMinor, &versionMinor)) != noErr) goto fail;
    if ((err = Gestalt(gestaltSystemVersionBugFix, &versionBugFix)) != noErr) goto fail;
    if (major) *major = versionMajor;
    if (minor) *minor = versionMinor;
    if (bugFix) *bugFix = versionBugFix;
  }
  
  return;
  
fail:
  NSLog(@"Unable to obtain system version: %ld", (long)err);
  if (major) *major = 10;
  if (minor) *minor = 0;
  if (bugFix) *bugFix = 0;
}

- (BOOL) isSnowLeopard
{
  unsigned major, minor, bugFix;
  [[NSApplication sharedApplication]
   getSystemVersionMajor:&major minor:&minor bugFix:&bugFix];
  if (major == 10 && minor == 6) {
    return YES;
  } else {
    return NO;
  }
}

- (BOOL) isLion 
{
  unsigned major, minor, bugFix;
  [[NSApplication sharedApplication]
   getSystemVersionMajor:&major minor:&minor bugFix:&bugFix];
  if (major == 10 && minor == 7) {
    return YES;
  } else {
    return NO;
  }
}

- (BOOL) isMountainLion
{
  unsigned major, minor, bugFix;
  [[NSApplication sharedApplication]
   getSystemVersionMajor:&major minor:&minor bugFix:&bugFix];
  if (major == 10 && minor == 8) {
    return YES;
  } else {
    return NO;
  }
}

@end
