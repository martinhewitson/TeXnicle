//
//  TPWarningsViewController.h
//  TeXnicle
//
//  Created by Martin Hewitson on 16/7/12.
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
#import "HHValidatedButton.h"

@class TPWarningsViewController;
@class TPSyntaxError;

@protocol TPWarningsViewDelegate <NSObject>

- (NSArray*) warningsViewlistOfFiles:(TPWarningsViewController*)warningsView;
- (NSArray*) warningsView:(TPWarningsViewController*)warningsView warningsForFile:(id)file;
- (void) warningsView:(TPWarningsViewController*)warningsView didSelectError:(TPSyntaxError*)anError;

@end

@interface TPWarningsViewController : NSViewController <NSUserInterfaceValidations, NSOutlineViewDelegate, NSOutlineViewDataSource, TPWarningsViewDelegate> {
  
  NSMutableArray *sets;
  NSOutlineView *__unsafe_unretained outlineView;
  id<TPWarningsViewDelegate> __unsafe_unretained delegate;
  HHValidatedButton *__unsafe_unretained revealButton;
  BOOL firstView;
}

@property (unsafe_unretained) IBOutlet HHValidatedButton *revealButton;
@property (unsafe_unretained) id<TPWarningsViewDelegate> delegate;
@property (unsafe_unretained) IBOutlet NSOutlineView *outlineView;
@property (strong) NSMutableArray *sets;

- (id) initWithDelegate:(id<TPWarningsViewDelegate>)aDelegate;

- (void) updateUI;
- (IBAction)reveal:(id)sender;

@end
