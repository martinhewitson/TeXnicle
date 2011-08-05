//
//  TPLaTeXEngine.h
//  TeXnicle
//
//  Created by Martin Hewitson on 29/05/11.
//  Copyright 2011 bobsoft. All rights reserved.
//

#import <Foundation/Foundation.h>


extern NSString * const TPTypesettingCompletedNotification;

// delegate protocol

@class TPLaTeXEngine;

typedef enum {
  TPEngineCompilerLaTeX,
  TPEngineCompilerPDFLaTeX
} TPEngineCompiler;

@protocol TPLaTeXEngineDelegate <NSObject>

- (NSString*) engineDocumentToCompile:(TPLaTeXEngine*)anEngine;
- (NSString*) engineWorkingDirectory:(TPLaTeXEngine*)anEngine;
- (BOOL) engineCanBibTeX:(TPLaTeXEngine*)anEngine;
- (TPEngineCompiler) engineProjectType:(TPLaTeXEngine*)anEngine;
- (BOOL) engineDocumentIsProject:(TPLaTeXEngine*)anEngine;

@end


@class ProjectEntity;

@interface TPLaTeXEngine : NSObject <TPLaTeXEngineDelegate> {
@private
    
	// Typesetting
	NSTask *typesetTask;
	NSFileHandle *typesetFileHandle;
	BOOL openPDFAfterBuild;
	int compilationsDone;
	BOOL abortCompile;
  BOOL didPS2PDF;
	
	// BibTeX
	NSTask *bibtexTask;
	NSFileHandle *bibtexFileHandle;
	
	// dvips
	NSTask *dvipsTask;
	NSFileHandle *dvipsFileHandle;
  
	// ps2pdf
	NSTask *ps2pdfTask;
	NSFileHandle *ps2pdfFileHandle;
  
  id delegate;
  
}

@property (assign) id delegate;

- (void) setupObservers;

- (id) initWithDelegate:(id)aDelegate;
+ (TPLaTeXEngine*)engineWithDelegate:(id)aDelegate;

- (void) trashAuxFiles;
- (void) reset;
- (BOOL) build;
//- (NSString*)fileToCompile;
- (NSString*)compiledDocumentPath;
- (NSString*)pdfPath;

- (IBAction) dvips:(id)sender;
- (void) dvipsTaskFinished:(NSNotification*)aNote;
- (void) dvipsOutputAvailable:(NSNotification*)aNote;

- (IBAction) ps2pdf:(id)sender;
- (void) ps2pdfTaskFinished:(NSNotification*)aNote;
- (void) ps2pdfOutputAvailable:(NSNotification*)aNote;


@end
