//
//  ConsoleController.m
//  TeXnicle
//
//  Created by Martin Hewitson on 31/1/10.
//  Copyright 2010 bobsoft. All rights reserved.
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

#import "ConsoleController.h"
#import "externs.h"

@implementation ConsoleController

static ConsoleController *sharedConsoleController = nil;

- (void)awakeFromNib
{
  if ([textView respondsToSelector:@selector(setUsesFindBar:)]) {
    [textView setUsesFindBar:YES];
  } else {
    [textView setUsesFindPanel:YES];
  }
}

- (id)init
{
  self = [super initWithWindowNibName:@"Console"];
	if (self){
    [[self window] setLevel:NSNormalWindowLevel];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSFont *font = [NSUnarchiver unarchiveObjectWithData:[defaults valueForKey:TEConsoleFont]];
    [textView setFont:font];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self
           selector:@selector(handleUserDefaultsChanged:)
               name:NSUserDefaultsDidChangeNotification
             object:nil];
  }  
	return self;
}

- (void) handleUserDefaultsChanged:(NSNotification*)aNote
{
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSFont *font = [NSUnarchiver unarchiveObjectWithData:[defaults valueForKey:TEConsoleFont]];
	[textView setFont:font];
}

+ (ConsoleController*)sharedConsoleController
{
	@synchronized(self) {
		if (sharedConsoleController == nil) {
			[[self alloc] init]; // assignment not done here
		}
	}
	return sharedConsoleController;
}

+ (id)allocWithZone:(NSZone *)zone
{
	@synchronized(self) {
		if (sharedConsoleController == nil) {
			sharedConsoleController = [super allocWithZone:zone];
			return sharedConsoleController;  // assignment and return on first allocation
		}
	}
	return nil; //on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone
{
	return self;
}

- (id)retain
{
	return self;
}

- (NSUInteger)retainCount
{
	return UINT_MAX;  //denotes an object that cannot be released
}

- (void)release
{
	//do nothing
}

- (id)autorelease
{
	return self;
}

- (void) clear
{
  [self clear:self];
}

- (IBAction) clear:(id)sender
{
	NSTextStorage *textStorage = [textView textStorage];	
	[textStorage deleteCharactersInRange:NSMakeRange(0, [textStorage length])];	
}

- (IBAction) displayLevelChanged:(id)sender
{
	
}

- (void) error:(NSString*)someText 
{
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSFont *font = [NSUnarchiver unarchiveObjectWithData:[defaults valueForKey:TEConsoleFont]];
	if ([someText length]>0) {
		if ([someText characterAtIndex:[someText length]-1] != '\n') {
			someText = [someText stringByAppendingString:@"\n"];
		}
		NSMutableAttributedString *attstr = [[NSMutableAttributedString alloc] initWithString:someText]; 
		NSRange stringRange = NSMakeRange(0, [attstr length]);
		[attstr addAttribute:NSForegroundColorAttributeName
									 value:[NSColor redColor]
									 range:stringRange];
    [attstr addAttribute:NSFontAttributeName
                   value:font
                   range:stringRange];
		[[textView textStorage] appendAttributedString:attstr];
		[attstr release];
		[textView moveToEndOfDocument:self];
		[textView setNeedsDisplay:YES];	
	}
}

- (void) message:(NSString*)someText 
{
	if ([displayLevel indexOfSelectedItem] < TPConsoleDisplayErrors) {
		[self appendText:someText withColor:[NSColor blueColor]];
	}
}


- (void) appendText:(NSString *)someText
{
	if ([displayLevel indexOfSelectedItem] < TPConsoleDisplayTeXnicle) {
		[self appendText:someText withColor:nil];
	}
}

- (void) appendText:(NSString*)someText withColor:(NSColor*)aColor
{
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSFont *font = [NSUnarchiver unarchiveObjectWithData:[defaults valueForKey:TEConsoleFont]];
	NSString *str = [someText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	NSColor *textColor = aColor;
	if (!textColor) {
		textColor = [NSColor blackColor];
	}
	NSArray *strings = [str componentsSeparatedByString:@"\n"];
	
	for (NSString *string in strings) {
		string = [string stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
		if ([string length]>0) {
			if ([string characterAtIndex:[string length]-1] != '\n') {
				string = [string stringByAppendingString:@"\n"];
			}
			NSMutableAttributedString *attstr = [[NSMutableAttributedString alloc] initWithString:string]; 
			NSRange stringRange = NSMakeRange(0, [attstr length]);
			[attstr addAttribute:NSForegroundColorAttributeName
										 value:textColor
										 range:stringRange];
      [attstr addAttribute:NSFontAttributeName
                     value:font
                     range:stringRange];
			[[textView textStorage] appendAttributedString:attstr];
			[attstr release];
		}
	}
	
  [textView moveToEndOfDocument:self];
  [textView setNeedsDisplay:YES];
}

@end
