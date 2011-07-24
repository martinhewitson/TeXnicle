//
//  TPLaTeXEngine.h
//  TeXnicle
//
//  Created by Martin Hewitson on 29/05/11.
//  Copyright 2011 AEI Hannover . All rights reserved.
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
	
	// BibTeX
	NSTask *bibtexTask;
	NSFileHandle *bibtexFileHandle;
	
	// dvips
	NSTask *dvipsTask;
	NSFileHandle *dvipsFileHandle;
  
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

@end
