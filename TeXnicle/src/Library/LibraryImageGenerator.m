//
//  LibraryImageGenerator.m
//  TeXnicle
//
//  Created by Martin Hewitson on 16/2/10.
//  Copyright 2010 bobsoft. All rights reserved.
//

#import "LibraryImageGenerator.h"
#import "NSStringUUID.h"
#import "NSWorkspaceExtended.h"
#import "NSNotificationAdditions.h"

@implementation LibraryImageGenerator

NSString * const TPLibraryImageGeneratorTaskDidFinishNotification = @"TPLibraryImageGeneratorTaskDidFinishNotification";

@synthesize mathMode;
@synthesize symbol;

- (id) initWithSymbol:(NSMutableDictionary*)aSymbol mathMode:(BOOL)mode andController:(LibraryController*)aController
{
  self = [super init];
	if (self) {
    
    controller = aController;
    self.symbol = aSymbol;
    self.mathMode = mode;
        
    //	NSLog(@"Created generator with symbol: %@", [symbol valueForKey:@"Code"]);
    
  }
	
	return self;
}

- (void) dealloc
{
//	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
//	[typesetTask release];
//	[nc removeObserver:self];
//	[image release];
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
	NSString *code = [symbol valueForKey:@"Code"];
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
	[doc writeToFile:filepath atomically:YES
					encoding:NSUTF8StringEncoding
						 error:&error];
	if (error) {
		[doc release];
		[NSApp presentError:error];
		return;
	}
	
	[doc release];
	
  // file://localhost/private/var/folders/V3/V3+QAXE-HIi9y796X1o4Q++++TI/-Tmp-/TeXnicle-1/
	
	// pdflatex it
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *gspath = [[defaults valueForKey:@"TPGSPath"] stringByDeletingLastPathComponent];
	NSString *texpath = [[defaults valueForKey:@"TPPDFLatexPath"] stringByDeletingLastPathComponent]; 
	NSString* script = [NSString stringWithFormat:@"%@/makePDFimage.sh",[[NSBundle mainBundle] resourcePath]];
		
	// check if the pdf exists
	NSFileManager *fm = [NSFileManager defaultManager];
	if ([fm fileExistsAtPath:croppedPDF]) {
		[fm removeItemAtPath:croppedPDF error:&error];
		if (error) {
			[NSApp presentError:error];
		}
	}		
	
	NSString *cmd = [NSString stringWithFormat:@"%@ %@ %@ %@ %@ %@", script, workingDirectory, filepath, croppedPDF, texpath, gspath] ;
	system([cmd cStringUsingEncoding:NSUTF8StringEncoding]);
	
	// Set image
	NSImage *image = [[NSImage alloc] initWithContentsOfFile:croppedPDF];
	if (!image) {
		image = [[NSImage alloc] initWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Palette/unknown.pdf"]];				
	}	
	[symbol setObject:[NSKeyedArchiver archivedDataWithRootObject:image] forKey:@"Image"];	
	[symbol setValue:[NSNumber numberWithBool:YES] forKey:@"validImage"];
	[image release];
	// tell the controller so the library can be saved
	[controller performSelectorOnMainThread:@selector(imageGeneratorTaskEnded:) withObject:croppedPDF waitUntilDone:NO];
	
	// clean up
//	[fm removeItemAtPath:filepath error:&error];
//	[fm removeItemAtPath:croppedPDF error:&error];
//	[fm removeItemAtPath:[[filepath stringByDeletingPathExtension] stringByAppendingPathExtension:@"pdf"] error:&error];
//	[fm removeItemAtPath:[[filepath stringByDeletingPathExtension] stringByAppendingPathExtension:@"aux"] error:&error];
//	[fm removeItemAtPath:[[filepath stringByDeletingPathExtension] stringByAppendingPathExtension:@"log"] error:&error];
	
  [pool drain], pool = nil;
  //END:mainloop
	
}



@end
