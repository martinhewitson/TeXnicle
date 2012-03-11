//
//  TPConsoleViewControllerViewController.m
//  TeXnicle
//
//  Created by Martin Hewitson on 10/03/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import "TPConsoleViewController.h"
#import "externs.h"

@interface TPConsoleViewController ()

@end

@implementation TPConsoleViewController

- (void) dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [super dealloc];
}

- (id)init
{
  self = [super initWithNibName:@"TPConsoleViewController" bundle:nil];
  if (self) {
    // Initialization code here.
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

- (void)awakeFromNib
{
  NSColor *color1 = [NSColor colorWithDeviceRed:231.0/255.0 green:231.0/255.0 blue:231.0/255.0 alpha:1.0];
  [toolbarView setFillColor:color1];
}

- (void) handleUserDefaultsChanged:(NSNotification*)aNote
{
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSFont *font = [NSUnarchiver unarchiveObjectWithData:[defaults valueForKey:TEConsoleFont]];
	[textView setFont:font];
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
