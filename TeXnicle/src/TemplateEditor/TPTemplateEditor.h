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
//  DISCLAIMED. IN NO EVENT SHALL MARTIN HEWITSON OR BOBSOFT SOFTWARE BE LIABLE FOR ANY
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
  NSView *__unsafe_unretained templateEditorViewContainer;
  TPTemplateEditorView *templateEditorView;
  id<TemplateEditorDelegate> __unsafe_unretained delegate;
  BOOL showFilename;
  
  NSButton *__unsafe_unretained cancelButton;
  NSButton *__unsafe_unretained selectButton;
  NSButton *__unsafe_unretained setAsMainFileButton;
  NSTextField *__unsafe_unretained filenameField;
  NSTextField *__unsafe_unretained filenameLabel;
}

- (id) initWithDelegate:(id<TemplateEditorDelegate>)aDelegate activeFilename:(BOOL)withFilename;

@property (unsafe_unretained) id<TemplateEditorDelegate> delegate;
@property (unsafe_unretained) IBOutlet NSView *templateEditorViewContainer;
@property (unsafe_unretained) IBOutlet NSButton *cancelButton;
@property (unsafe_unretained) IBOutlet NSButton *selectButton;
@property (unsafe_unretained) IBOutlet NSButton *setAsMainFileButton;
@property (unsafe_unretained) IBOutlet NSTextField *filenameField;
@property (unsafe_unretained) IBOutlet NSTextField *filenameLabel;
@property (assign) BOOL showFilename;

@property (strong) TPTemplateEditorView *templateEditorView;

- (void)setFilename:(NSString*)aFilename;
- (BOOL) setAsMainFile;
- (NSString*)filename;

@end
