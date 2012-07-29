//
//  TPStatusViewController.h
//  TeXnicle
//
//  Created by Martin Hewitson on 9/11/11.
//  Copyright (c) 2011 bobsoft. All rights reserved.
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
#import "MHToolbarBackgroundView.h"


@interface TPStatusViewController : NSViewController {
  NSString *_editorStatusText;
  NSString *_filenameText;
  BOOL _showRevealButton;
  NSTextField *__unsafe_unretained editorStatusTextField;
  NSTextField *__unsafe_unretained filenameTextField;
  BOOL showRevealButton;
  NSButton *__unsafe_unretained revealButton;
  MHToolbarBackgroundView *__unsafe_unretained rightPanel;
  NSInteger wordCount;
  NSInteger character;
  NSInteger lineNumber;
}

@property (unsafe_unretained) IBOutlet NSTextField *editorStatusTextField;
@property (unsafe_unretained) IBOutlet NSTextField *filenameTextField;
@property (unsafe_unretained) IBOutlet NSButton *revealButton;
@property (unsafe_unretained) IBOutlet MHToolbarBackgroundView *rightPanel;

@property (assign) NSInteger character;
@property (assign) NSInteger lineNumber;
@property (assign) NSInteger wordCount;
@property (copy) NSString *editorStatusText;
@property (copy) NSString *filenameText;
@property (assign) BOOL showRevealButton;

- (void) resizeLabels;
- (void) enable:(BOOL)state;
- (void) updateDisplay;

@end
