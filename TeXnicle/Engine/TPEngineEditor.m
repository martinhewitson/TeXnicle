//
//  TPEngineEditor.m
//  TeXnicle
//
//  Created by Martin Hewitson on 27/08/11.
//  Copyright 2011 bobsoft. All rights reserved.
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

#import "TPEngineEditor.h"
#import "TeXEditorViewController.h"
#import "BashColoringEngine.h"
#import "MHFileReader.h"
#import "UKXattrMetadataStore.h"

@implementation TPEngineEditor

- (NSString *)windowNibName 
{
	// Implement this to return a nib to load OR implement -makeWindowControllers to manually create your controllers.
	return @"EngineEditorWindow";
}


- (void) awakeFromNib
{
  self.texEditorViewController = [[TeXEditorViewController alloc] init];
  [self.texEditorViewController setDelegate:self];
  [self.texEditorViewController.view setFrame:[self.texEditorContainer bounds]];
  [self.texEditorContainer addSubview:self.texEditorViewController.view];
  [self.texEditorContainer setNeedsDisplay:YES];
  
  // set a bash engine
  self.texEditorViewController.textView.coloringEngine = [[BashColoringEngine alloc] initWithTextView:self.texEditorViewController.textView];	
  
  // disable spell checking
  [self.texEditorViewController.textView setContinuousSpellCheckingEnabled:NO];
  
	if (self.documentData) {
		[self.texEditorViewController performSelector:@selector(setString:) withObject:[self.documentData string] afterDelay:0.0];
	}
  
  [self.texEditorViewController.textView performSelector:@selector(colorWholeDocument)];
  
  [self.texEditorViewController enableEditor];
  [self.texEditorViewController hideJumpBar];
}


- (void)windowWillClose:(NSNotification *)notification 
{	
  //	NSLog(@"Closing window %@", [[NSDocumentController sharedDocumentController] documents]);
	
  [self.texEditorViewController tearDown];
  self.texEditorViewController.delegate = nil;
  self.texEditorViewController = nil;
  
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

- (BOOL)syntaxCheckerShouldCheckSyntax:(TPSyntaxChecker*)aChecker
{
  return NO;
}

- (IBAction)reopenUsingEncoding:(id)sender
{
  NSString *path = [[self fileURL] path];
  
  // clear the xattr
  [UKXattrMetadataStore setString:@""
                           forKey:@"com.bobsoft.TeXnicleTextEncoding"
                           atPath:path
                     traverseLink:YES];
  
  MHFileReader *fr = [[MHFileReader alloc] initWithEncodingNamed:[sender title]];
  NSString *str = [fr readStringFromFileAtURL:[self fileURL]];
  
	if (str) {
		[self setDocumentData:[[NSMutableAttributedString alloc] initWithString:str]];
	}
}

-(NSString*)fileExtension
{
  return [[self fileURL] pathExtension];
}

- (BOOL)writeToURL:(NSURL *)absoluteURL ofType:(NSString *)typeName error:(NSError **)outError
{
	NSAttributedString *attStr = [self.texEditorViewController.textView attributedString];
	NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithAttributedString:attStr];
	
	NSString *str = [string string];  
  MHFileReader *fr = [[MHFileReader alloc] init];
  BOOL res = [fr writeString:str toURL:absoluteURL];
	return res;
}

- (BOOL)readFromURL:(NSURL *)absoluteURL ofType:(NSString *)typeName error:(NSError **)outError
{
//	NSStringEncoding encoding;
  
  MHFileReader *fr = [[MHFileReader alloc] init];
  NSString *str = [fr readStringFromFileAtURL:absoluteURL];
  
	if (str) {
		[self setDocumentData:[[NSMutableAttributedString alloc] initWithString:str]];
		return YES;
	}
  
	return NO;
}


@end
