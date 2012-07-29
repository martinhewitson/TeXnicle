//
//  TPLabelsViewController.h
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

@class TPLabelsViewController;
@class TPLabel;

@protocol TPLabelsViewDelegate <NSObject>

- (NSArray*) labelsViewlistOfFiles:(TPLabelsViewController*)aLabelsView;
- (NSArray*) labelsView:(TPLabelsViewController*)aLabelsView labelsForFile:(id)file;
- (void) labelsView:(TPLabelsViewController*)aLabelsView didSelectLabel:(TPLabel*)aLabel;

@end

@interface TPLabelsViewController : NSViewController <NSUserInterfaceValidations, NSOutlineViewDelegate, NSOutlineViewDataSource, TPLabelsViewDelegate> {
@private
  BOOL firstView;
}

@property (unsafe_unretained) id<TPLabelsViewDelegate> delegate;
@property (strong) NSMutableArray *sets;

- (id) initWithDelegate:(id<TPLabelsViewDelegate>)aDelegate;

- (void) updateUI;
- (IBAction)reveal:(id)sender;

@end
