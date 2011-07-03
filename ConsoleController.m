//
//  ConsoleController.m
//  TeXnicle
//
//  Created by Martin Hewitson on 31/1/10.
//  Copyright 2010 AEI Hannover . All rights reserved.
//

#import "ConsoleController.h"
#import "externs.h"

@implementation ConsoleController

static ConsoleController *sharedConsoleController = nil;


- (id)init
{
	if (![super initWithWindowNibName:@"Console"])
		return nil;
	
	[[self window] setLevel:NSNormalWindowLevel];
  	
	return self;
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
	if ([someText length]>0) {
		if ([someText characterAtIndex:[someText length]-1] != '\n') {
			someText = [someText stringByAppendingString:@"\n"];
		}
		NSMutableAttributedString *attstr = [[NSMutableAttributedString alloc] initWithString:someText]; 
		NSRange stringRange = NSMakeRange(0, [attstr length]);
		[attstr addAttribute:NSForegroundColorAttributeName
									 value:[NSColor redColor]
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
			[[textView textStorage] appendAttributedString:attstr];
			[attstr release];
		}
	}
	
  [textView moveToEndOfDocument:self];
  [textView setNeedsDisplay:YES];
}

@end
