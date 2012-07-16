//
//  SyntaxHighlightControlController.m
//  TeXnicle
//
//  Created by Martin Hewitson on 18/12/10.
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
