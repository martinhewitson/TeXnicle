//
//  MHMiniConsoleBackground.m
//  TeXnicle
//
//  Created by Martin Hewitson on 26/10/11.
//  Copyright (c) 2011 bobsoft. All rights reserved.
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

#import "MHMiniConsoleBackground.h"

@implementation MHMiniConsoleBackground

- (void)awakeFromNib
{
  self.endingColor = [NSColor colorWithDeviceRed:235.0/255.0 green:235.0/255.0 blue:235.0/255.0 alpha:1.0];
  self.startingColor = [NSColor colorWithDeviceRed:235.0/255.0 green:235.0/255.0 blue:235.0/255.0 alpha:1.0];
//  self.startingColor = [NSColor colorWithDeviceRed:210.0/255.0 green:220.0/255.0 blue:230.0/255.0 alpha:1.0];
  self.angle = 90;
  self.cornerRadius = 2;
  self.borderWidth = 0.5;
  self.borderColor = [NSColor colorWithDeviceRed:150.0/255.0 green:150.0/255.0 blue:150.0/255.0 alpha:1.0];
}

@end
