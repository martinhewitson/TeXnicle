//
//  TPFileEntityMetadata.h
//  TeXnicle
//
//  Created by Martin Hewitson on 12/7/12.
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

#import <Foundation/Foundation.h>
#import "TPSyntaxChecker.h"

@class TPFileEntityMetadata;
@class FileEntity;
@class TPMetadataOperation;

@protocol TPFileEntityMetadataDelegate <NSObject>

- (NSString*) text;

@end

@interface TPFileEntityMetadata : NSObject <SyntaxCheckerDelegate> {
  
  TPSyntaxChecker *checker;
  NSString *temporaryFileForSyntaxCheck;
  
  // meta data update
  NSDate *lastMetadataUpdate;
  NSTimer *metadataTimer;
  
  // new commands
  NSArray *userNewCommands;
  NSDate *lastUpdateOfNewCommands;
  
  // sections
  NSArray *sections;
  NSDate *lastUpdateOfSections;
  
  // citations
  NSArray *citations;
  
  // labels
  NSArray *labels;
  
  // includes/inputs
  NSArray *includes;
  
  // syntax errors
  NSArray *syntaxErrors;
  
  FileEntity *parent;
  dispatch_queue_t queue;
  NSOperationQueue* aQueue;
}

@property (retain) TPSyntaxChecker *checker;
@property (copy) NSString *temporaryFileForSyntaxCheck;

@property (retain) NSOperationQueue* aQueue;
@property (assign) FileEntity *parent;

@property (retain) NSDate *lastMetadataUpdate;
@property (retain) NSTimer *metadataTimer;

@property (retain) NSArray *sections;
@property (retain) NSDate *lastUpdateOfSections;

@property (retain) NSArray *syntaxErrors;

@property (retain) NSArray *userNewCommands;
@property (retain) NSDate *lastUpdateOfNewCommands;

@property (retain) NSArray *citations;

@property (retain) NSArray *labels;

@property (retain) NSArray *includes;

- (id) initWithParent:(id)aFile;
- (NSArray*)updateSectionsForTypes:(NSArray*)templates forceUpdate:(BOOL)force;
- (void) generateSectionsForTypes:(NSArray*)templates forceUpdate:(BOOL)force;

#pragma mark -
#pragma mark get new commands

- (NSArray*)listOfNewCommands;
- (void) updateMetadata;

- (void) stopMetadataTimer;

@end
