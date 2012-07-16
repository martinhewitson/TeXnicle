//
//  LibraryImageGenerator.m
//  TeXnicle
//
//  Created by Martin Hewitson on 16/2/10.
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
//  DISCLAIMED. IN NO EVENT SHALL DAN WOOD, MIKE ABDULLAH OR KARELIA SOFTWARE BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "TPLibraryImageGenerator.h"
#import "NSStringUUID.h"
#import "NSWorkspaceExtended.h"
#import "NSNotificationAdditions.h"
#import "RegexKitLite.h"
#import "externs.h"
#import "TPLibraryEntry.h"

@implementation TPLibraryImageGenerator

NSString * const TPLibraryImageGeneratorTaskDidFinishNotification = @"TPLibraryImageGeneratorTaskDidFinishNotification";

@synthesize mathMode;
@synthesize clip;
@synthesize delegate;

- (id) initWithSymbol:(TPLibraryEntry*)aSymbol mathMode:(BOOL)mode andController:(id<TPLibraryImageGeneratorDelegate>)aController
{
  self = [super init];
	if (self) {
    
    self.delegate = aController;
    self.clip = aSymbol;
    self.mathMode = mode;
        
    //	NSLog(@"Created generator with symbol: %@", [symbol valueForKey:@"Code"]);
    
  }
	
	return self;
}

- (void) dealloc
{
  self.delegate = nil;
  self.clip = nil;
	[super dealloc];
}

- (void) generateImage
{
  //START:mainloop
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	// create doc string
	NSMutableString *doc = [[NSMutableString alloc] init];
	
	[doc appendString:@"\\documentclass[136pt]{article}\n"];
	[doc appendString:@"\\usepackage[usenames]{color}\\color[rgb]{0,0,0} %used for font color\n"];
	[doc appendString:@"\\usepackage{amssymb} %maths\n"];
	[doc appendString:@"\\usepackage{amsmath} %maths\n"];
	[doc appendString:@"\\usepackage[utf8]{inputenc} %useful to type directly diacritic characters\n"];
	NSString *code = self.clip.code;
  
  // replace placeholders
  NSString *regexp = [self placeholderRegexp];
  NSArray *placeholders = [code componentsMatchedByRegex:regexp];
  for (NSString *placeholder in placeholders) {
    placeholder = [placeholder stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSRange r = [code rangeOfString:placeholder];
    NSString *replacement = [placeholder substringWithRange:NSMakeRange(1, [placeholder length]-2)];
    code = [code stringByReplacingCharactersInRange:r withString:replacement];
  }
  
	if (mathMode) {
		[doc appendFormat:@"\\pagestyle{empty} \\begin{document}$%@$\\end{document}", [code stringByReplacingOccurrencesOfString:@"\/" withString:@"\\/"]];
	} else {
		[doc appendFormat:@"\\pagestyle{empty} \\begin{document}%@\\end{document}", [code stringByReplacingOccurrencesOfString:@"\/" withString:@"\\/"]];
	}
	
	
	// write tmp file
	NSString* workingDirectory =  [[NSWorkspace sharedWorkspace] temporaryDirectory];
	NSString *uuid = [NSString stringWithUUID];
	NSString *tmpfile = [uuid stringByAppendingPathExtension:@"tex"];
	NSString *filepath = [workingDirectory stringByAppendingPathComponent:tmpfile];
	NSString *croppedPDF = [workingDirectory stringByAppendingPathComponent:[uuid stringByAppendingString:@"_cropped.pdf"]];
	
	//	NSLog(@"TeX file: %@, -> %@", filepath, croppedPDF);
	
	NSError *error = nil;
	BOOL success = [doc writeToFile:filepath atomically:YES
                         encoding:NSUTF8StringEncoding
                            error:&error];
	if (success == NO) {
		[doc release];
		[NSApp presentError:error];
		return;
	}
	
	[doc release];
	
  // file://localhost/private/var/folders/V3/V3+QAXE-HIi9y796X1o4Q++++TI/-Tmp-/TeXnicle-1/
	
	// pdflatex it
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *gspath = [[defaults valueForKey:TPGSPath] stringByDeletingLastPathComponent];
	NSString *texpath = [[defaults valueForKey:TPPDFLatexPath] stringByDeletingLastPathComponent]; 
	NSString* script = [NSString stringWithFormat:@"%@/makePDFimage.sh",[[NSBundle mainBundle] resourcePath]];
		
	// check if the pdf exists
	NSFileManager *fm = [NSFileManager defaultManager];
	if ([fm fileExistsAtPath:croppedPDF]) {
		BOOL success = [fm removeItemAtPath:croppedPDF error:&error];
		if (success == NO) {
			[NSApp presentError:error];
		}
	}		
	
	NSString *cmd = [NSString stringWithFormat:@"%@ %@ %@ %@ %@ %@", script, workingDirectory, filepath, croppedPDF, texpath, gspath] ;
	system([cmd cStringUsingEncoding:NSUTF8StringEncoding]);
	
	// Set image
	NSImage *image = [[[NSImage alloc] initWithContentsOfFile:croppedPDF] autorelease];
	if (image == nil) {
    image = [self generateBeamerImage];
    if (image == nil) {
      image = [[[NSImage alloc] initWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Palette/unknown.pdf"]] autorelease];				
    }
	}	
  
  // update clipping
  self.clip.image = [NSKeyedArchiver archivedDataWithRootObject:image];	
  self.clip.imageIsValid = [NSNumber numberWithBool:YES];
  
	// tell the controller so the library can be saved
  [self performSelectorOnMainThread:@selector(imageGeneratorTaskEnded:) withObject:croppedPDF waitUntilDone:NO];
	
	
  [pool drain], pool = nil;
  //END:mainloop
	
}


- (NSImage*) generateBeamerImage
{
	
	// create doc string
	NSMutableString *doc = [[NSMutableString alloc] init];
	
	[doc appendString:@"\\documentclass[20pt]{beamer}\n\\usetheme{default}\n"];
	NSString *code = clip.code;
  
  // replace placeholders
  NSString *regexp = [self placeholderRegexp];
  NSArray *placeholders = [code componentsMatchedByRegex:regexp];
  for (NSString *placeholder in placeholders) {
    placeholder = [placeholder stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSRange r = [code rangeOfString:placeholder];
    NSString *replacement = [placeholder substringWithRange:NSMakeRange(1, [placeholder length]-2)];
    code = [code stringByReplacingCharactersInRange:r withString:replacement];
  }
  
	if (mathMode) {
		[doc appendFormat:@"\\pagestyle{empty} \\begin{document}{\\Huge $%@$}\\end{document}", [code stringByReplacingOccurrencesOfString:@"\/" withString:@"\\/"]];
	} else {
		[doc appendFormat:@"\\pagestyle{empty} \\begin{document}{\\Huge %@}\\end{document}", [code stringByReplacingOccurrencesOfString:@"\/" withString:@"\\/"]];
	}
	
	
	// write tmp file
	NSString* workingDirectory =  [[NSWorkspace sharedWorkspace] temporaryDirectory];
	NSString *uuid = [NSString stringWithUUID];
	NSString *tmpfile = [uuid stringByAppendingPathExtension:@"tex"];
	NSString *filepath = [workingDirectory stringByAppendingPathComponent:tmpfile];
	NSString *croppedPDF = [workingDirectory stringByAppendingPathComponent:[uuid stringByAppendingString:@"_cropped.pdf"]];
	
	//	NSLog(@"TeX file: %@, -> %@", filepath, croppedPDF);
	
	NSError *error = nil;
	BOOL success = [doc writeToFile:filepath atomically:YES
                         encoding:NSUTF8StringEncoding
                            error:&error];
	if (success == NO) {
		[doc release];
		[NSApp presentError:error];
		return nil;
	}
	
	[doc release];
	
  // file://localhost/private/var/folders/V3/V3+QAXE-HIi9y796X1o4Q++++TI/-Tmp-/TeXnicle-1/
	
	// pdflatex it
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *gspath = [[defaults valueForKey:TPGSPath] stringByDeletingLastPathComponent];
	NSString *texpath = [[defaults valueForKey:TPPDFLatexPath] stringByDeletingLastPathComponent]; 
	NSString* script = [NSString stringWithFormat:@"%@/makePDFimage.sh",[[NSBundle mainBundle] resourcePath]];
  
	// check if the pdf exists
	NSFileManager *fm = [NSFileManager defaultManager];
	if ([fm fileExistsAtPath:croppedPDF]) {
		BOOL success = [fm removeItemAtPath:croppedPDF error:&error];
		if (success == NO) {
			[NSApp presentError:error];
		}
	}		
	
	NSString *cmd = [NSString stringWithFormat:@"%@ %@ %@ %@ %@ %@", script, workingDirectory, filepath, croppedPDF, texpath, gspath] ;
	system([cmd cStringUsingEncoding:NSUTF8StringEncoding]);
	
  // now check if the command was successful
	if ([fm fileExistsAtPath:croppedPDF] == NO) {
    return [[[NSImage alloc] initWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Palette/unknown.pdf"]] autorelease];				
  }
  
	// Set image
	return [[[NSImage alloc] initWithContentsOfFile:croppedPDF] autorelease];	
}

#pragma mark -
#pragma mark Delegate


- (void) imageGeneratorTaskEnded:(NSString *)path
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(imageGeneratorTaskEnded:)]) {
    [self.delegate imageGeneratorTaskEnded:path];
  }
}

- (NSString*)placeholderRegexp
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(placeholderRegexp)]) {
    return [self.delegate placeholderRegexp];
  }
  return nil;
}

@end
