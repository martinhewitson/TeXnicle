//
//  TPTemplateEditor.h
//  TeXnicle
//
//  Created by Martin Hewitson on 28/1/12.
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
//  DISCLAIMED. IN NO EVENT SHALL DAN WOOD, MIKE ABDULLAH OR KARELIA SOFTWARE BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import <Cocoa/Cocoa.h>
#import "TPTemplateEditorView.h"

@class TPTemplateEditor;

@protocol TemplateEditorDelegate <NSObject>

@optional
- (void)templateEditor:(TPTemplateEditor*)editor didSelectTemplate:(NSDictionary*)aTemplate;
- (void)templateEditorDidCancelSelection:(TPTemplateEditor*)editor;

@end

@interface TPTemplateEditor : NSWindowController {
@private
  NSString *_filename;
  NSView *templateEditorViewContainer;
  TPTemplateEditorView *templateEditorView;
  id<TemplateEditorDelegate> delegate;
  BOOL showFilename;
  
  NSButton *cancelButton;
  NSButton *selectButton;
  NSButton *setAsMainFileButton;
  NSTextField *filenameField;
  NSTextField *filenameLabel;
}

- (id) initWithDelegate:(id<TemplateEditorDelegate>)aDelegate activeFilename:(BOOL)withFilename;

@property (assign) id<TemplateEditorDelegate> delegate;
@property (assign) IBOutlet NSView *templateEditorViewContainer;
@property (assign) IBOutlet NSButton *cancelButton;
@property (assign) IBOutlet NSButton *selectButton;
@property (assign) IBOutlet NSButton *setAsMainFileButton;
@property (assign) IBOutlet NSTextField *filenameField;
@property (assign) IBOutlet NSTextField *filenameLabel;
@property (assign) BOOL showFilename;

@property (retain) TPTemplateEditorView *templateEditorView;

- (void)setFilename:(NSString*)aFilename;
- (BOOL) setAsMainFile;
- (NSString*)filename;

@end
