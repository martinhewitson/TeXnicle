//
//  TPPalette.m
//  TeXnicle
//
//  Created by Martin Hewitson on 2/8/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
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

#import "TPPalette.h"
#import "NSWorkspaceExtended.h"
#import "externs.h"

@implementation TPPalette

- (id) init
{
  self = [super init];
  if (self) {
    [self loadPalette];
  }
  return self;
}

- (void) loadPalette
{
	// Load the dictionary
	NSString *path = [[NSBundle mainBundle] pathForResource:@"palette" ofType:@"plist"];
	NSDictionary *paletteDictionary = [NSDictionary dictionaryWithContentsOfFile:path];
	
	self.palettes = [paletteDictionary valueForKey:@"Palettes"];
	
	// load all images
	for (NSDictionary *p in self.palettes) {
		
		NSArray *symbols = [p valueForKey:@"Symbols"];
		for (NSMutableDictionary *symbol in symbols) {
			
			NSString *imagePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:[symbol valueForKey:@"Image"]];
      //NSLog(@"Loading image: %@", imagePath);
			NSImage *image = [[NSImage alloc] initWithContentsOfFile:imagePath];
      //NSLog(@" ... %@", image);
			if (!image) {
        //NSLog(@"... Generating image");
				image = [self generateImageForCode:[symbol valueForKey:@"Code"]
																		atPath:imagePath
																inMathMode:[[symbol valueForKey:@"mathMode"] boolValue]];
				if (!image) {
					image = [[NSImage alloc] initWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Palette/unknown.pdf"]];
				}
			}
			symbol[@"ImageData"] = image;
		}
	}
}

- (NSImage*) generateImageForCode:(NSString*)code atPath:(NSString*)aPath inMathMode:(BOOL)mathMode
{
	// create doc string
	NSMutableString *doc = [[NSMutableString alloc] init];
	
	[doc appendString:@"\\documentclass[136pt]{article}\n"];
	[doc appendString:@"\\usepackage[usenames]{color}\\color[rgb]{0,0,0} %used for font color\n"];
	[doc appendString:@"\\usepackage{amssymb} %maths\n"];
	[doc appendString:@"\\usepackage{amsmath} %maths\n"];
	[doc appendString:@"\\usepackage[utf8]{inputenc} %useful to type directly diacritic characters\n"];
	if (mathMode) {
		[doc appendFormat:@"\\pagestyle{empty} \\begin{document}{$%@$\\end{document}", [code stringByReplacingOccurrencesOfString:@"\/" withString:@"\\/"]];
	} else {
		[doc appendFormat:@"\\pagestyle{empty} \\begin{document}%@\\end{document}", [code stringByReplacingOccurrencesOfString:@"\/" withString:@"\\/"]];
	}
	
	
	// write tmp file
	NSString* workingDirectory =  [[NSWorkspace sharedWorkspace] temporaryDirectory];
	NSString *filepath = [workingDirectory stringByAppendingPathComponent:@"texnicle.tex"];
	
	//NSLog(@"Tmp dir: %@", filepath);
	NSError *error = nil;
  BOOL success;
	success = [doc writeToFile:filepath atomically:YES
                    encoding:NSUTF8StringEncoding
                       error:&error];
	if (success == NO) {
		[NSApp presentError:error];
		return nil;
	}
	
	
  // file://localhost/private/var/folders/V3/V3+QAXE-HIi9y796X1o4Q++++TI/-Tmp-/TeXnicle-1/
	
	// pdflatex it
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *gspath = [[defaults valueForKey:TPGSPath] stringByDeletingLastPathComponent];
	NSString *texpath = [[defaults valueForKey:TPPDFLatexPath] stringByDeletingLastPathComponent];
	NSString *croppedPDF = [workingDirectory stringByAppendingPathComponent:@"cropped.pdf"];
	NSString* script = [NSString stringWithFormat:@"%@/makePDFimage.sh",[[NSBundle mainBundle] resourcePath]];
	
	NSString *cmd = [NSString stringWithFormat:@"%@ %@ %@ %@ %@ %@", script, workingDirectory, filepath, croppedPDF, texpath, gspath] ;
	//NSLog(@"Executing '%@'", cmd);
	system([cmd cStringUsingEncoding:NSUTF8StringEncoding]);
	
	// Copy cropped pdf to the right path
	NSFileManager *fm = [NSFileManager defaultManager];
	success = [fm copyItemAtPath:croppedPDF toPath:aPath error:&error];
	if (success == NO) {
		NSLog(@"Failed to copy %@ to %@", croppedPDF, aPath);
		//[NSApp presentError:error];
		return nil;
	}
	
	// read pdf data in
  //	NSData *data = [NSData dataWithContentsOfFile:croppedPDF];
	NSImage *pdfimage = [[NSImage alloc] initWithContentsOfFile:croppedPDF];
	//NSLog(@"made image at: %@", aPath);
	return pdfimage;
}


@end
