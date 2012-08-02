//
//  TPPalette.m
//  TeXnicle
//
//  Created by Martin Hewitson on 2/8/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
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
      //			NSLog(@"Loading image: %@", imagePath);
			NSImage *image = [[NSImage alloc] initWithContentsOfFile:imagePath];
      //      NSLog(@" ... %@", image);
			if (!image) {
        //        NSLog(@"... Generating image");
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
		//NSLog(@"Failed to copy %@ to %@", croppedPDF, aPath);
		[NSApp presentError:error];
		return nil;
	}
	
	// read pdf data in
  //	NSData *data = [NSData dataWithContentsOfFile:croppedPDF];
	NSImage *pdfimage = [[NSImage alloc] initWithContentsOfFile:croppedPDF];
	//NSLog(@"made image at: %@", aPath);
	return pdfimage;
}


@end
