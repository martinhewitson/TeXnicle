//
//  MHMiniConsoleViewController.m
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

#import "MHMiniConsoleViewController.h"

@interface MHMiniConsoleViewController ()

@property (unsafe_unretained) IBOutlet NSTextField *textField;
@property (unsafe_unretained) IBOutlet NSProgressIndicator *progressIndicator;

@end

@implementation MHMiniConsoleViewController

- (id)init
{
  self = [super initWithNibName:@"MHMiniConsoleViewController" bundle:nil];
  if (self) {
    // Initialization code here.
  }
  
  return self;
}

- (void) clear
{
  [self.textField setStringValue:@""];
  [self.textField setNeedsDisplay];
  [self.textField setToolTip:@""];
}

- (void) appendText:(NSString*)someText
{
  // do nothing
}

- (void) appendText:(NSString*)someText withColor:(NSColor*)aColor
{
  // do nothing
}

- (void) error:(NSString*)someText
{
  [self.textField setTextColor:[NSColor redColor]];
  [self.textField setStringValue:someText];
  [self.textField setNeedsDisplay];
  [self.textField setToolTip:someText];
}

- (void)message:(NSString *)someText
{
  [self.textField setTextColor:[NSColor darkGrayColor]];
  [self.textField setStringValue:someText];
  [self.textField setNeedsDisplay];
  [self.textField setToolTip:someText];
}

- (void) setAnimating:(BOOL)state
{
  if (state) {
    [self.progressIndicator startAnimation:self];
  } else {
    [self.progressIndicator stopAnimation:self];
  }
}

@end
