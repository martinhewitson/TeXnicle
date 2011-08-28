//
//  TPEngineEditor.m
//  TeXnicle
//
//  Created by Martin Hewitson on 27/08/11.
//  Copyright 2011 bobsoft. All rights reserved.
//

#import "TPEngineEditor.h"
#import "TeXEditorViewController.h"
#import "BashColoringEngine.h"

@implementation TPEngineEditor

@synthesize documentData;
@synthesize texEditorViewController;
@synthesize texEditorContainer;

- (NSString *)windowNibName 
{
	// Implement this to return a nib to load OR implement -makeWindowControllers to manually create your controllers.
	return @"EngineEditorWindow";
}

- (void) awakeFromNib
{
  self.texEditorViewController = [[[TeXEditorViewController alloc] init] autorelease];
  [self.texEditorViewController setDelegate:self];
  [[self.texEditorViewController view] setFrame:[self.texEditorContainer bounds]];
  [self.texEditorContainer addSubview:[self.texEditorViewController view]];
  [self.texEditorViewController disableJumpBar];
  [self.texEditorContainer setNeedsDisplay:YES];
  
  // set a bash engine
  self.texEditorViewController.textView.coloringEngine = [[[BashColoringEngine alloc] initWithTextView:self.texEditorViewController.textView] autorelease];	
  
  // disable spell checking
  [self.texEditorViewController.textView setContinuousSpellCheckingEnabled:NO];
  
	if (self.documentData) {
		[self.texEditorViewController performSelector:@selector(setString:) withObject:[self.documentData string] afterDelay:0.0];
	}
  
}


- (void)windowWillClose:(NSNotification *)notification 
{	
  //	NSLog(@"Closing window %@", [[NSDocumentController sharedDocumentController] documents]);
	
	if ([[[NSDocumentController sharedDocumentController] documents] count] == 1) {
    //    NSLog(@"Showing startup...");
		if ([[NSApp delegate] respondsToSelector:@selector(showStartupScreen:)]) {
			[[NSApp delegate] performSelector:@selector(showStartupScreen:) withObject:self];
		}
	}	
}

-(BOOL)shouldSyntaxHighlightDocument
{
  return YES;
}

- (BOOL)writeToURL:(NSURL *)absoluteURL ofType:(NSString *)typeName error:(NSError **)outError
{
	NSAttributedString *attStr = [self.texEditorViewController.textView attributedString];
	NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithAttributedString:attStr];
	
	NSString *str = [string string];
	BOOL res = [str writeToURL:absoluteURL
									atomically:YES
										encoding:NSUTF8StringEncoding
											 error:outError];
	[string release];
	return res;
}

- (BOOL)readFromURL:(NSURL *)absoluteURL ofType:(NSString *)typeName error:(NSError **)outError
{
	NSStringEncoding encoding;
//  NSLog(@"Reading from URL %@", absoluteURL);
	
	NSString *str = [NSString stringWithContentsOfURL:absoluteURL
                                       usedEncoding:&encoding
                                              error:outError];
	if (str) {
		[self setDocumentData:[[NSMutableAttributedString alloc] initWithString:str]];
		return YES;
	}
  
	return NO;
}


@end
