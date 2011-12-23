//
//  SyntaxHighlightControlController.m
//  TeXnicle
//
//  Created by Martin Hewitson on 18/12/10.
//  Copyright 2010 bobsoft. All rights reserved.
//

#import "SyntaxHighlightControlController.h"
#import "NSColorArrayTransformer.h"

@implementation SyntaxHighlightControlController

@synthesize bindingTag;
@synthesize name;

- (id) initWithTag:(NSString*)aTag name:(NSString*)aName
{
	self = [super initWithNibName:@"SyntaxColorControl" bundle:nil];
	if (self) {
		self.bindingTag = aTag;
    if (!aName || [aName length]==0) {
      self.name = @"Unknown";
    } else {
      self.name = aName;
    }
	}
	return self;
}


- (void) awakeFromNib
{
	[self setupBindings];
	[label setStringValue:self.name];
}

- (void) setupBindings
{
	
	[NSValueTransformer setValueTransformer: [[[NSColorArrayTransformer alloc] init] autorelease] 
																	forName: @"ColorArrayTransformer"];
	
	
	NSUserDefaultsController *defaults = [NSUserDefaultsController sharedUserDefaultsController];
	
	NSMutableDictionary *bindingOptions = [NSMutableDictionary dictionary];
	[bindingOptions setObject:@"ColorArrayTransformer"
										 forKey:@"NSValueTransformerName"];
	
	// Color well binding
	NSString *path = [NSString stringWithFormat:@"values.TESyntax%@Color", bindingTag] ;
	[colorWell bind:@"value"
				 toObject:defaults 
			withKeyPath:path
					options:bindingOptions];
	
	// Active binding
	path = [NSString stringWithFormat:@"values.TESyntaxColor%@", bindingTag] ;
	[activeButton bind:@"value"
					toObject:defaults 
			 withKeyPath:path
					 options:nil];
	
}


- (IBAction) syntaxColorActiveChanged:(id)sender
{
	if ([activeButton state] == NSOnState) {
		[colorWell setEnabled:YES];
		[label setTextColor:[NSColor controlTextColor]];
	} else {
		[colorWell setEnabled:NO];
		[label setTextColor:[NSColor disabledControlTextColor]];
	}
}





@end
