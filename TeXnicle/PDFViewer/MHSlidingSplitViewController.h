//
//  MHSlidingSplitViewController.h
//  TestSlidingSplitView
//
//  Created by Martin Hewitson on 30/12/11.
//  Copyright (c) 2011 bobsoft. All rights reserved.
//
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

@protocol MHSlidingSplitViewDelegate <NSObject>

-(void)splitView:(NSSplitView*)aSplitView didCollapseSubview:(NSView*)aView;
-(void)splitView:(NSSplitView*)aSplitView didUncollapseSubview:(NSView*)aView;

@end

@interface MHSlidingSplitViewController : NSObject <NSSplitViewDelegate> {
@private
  BOOL _sidePanelIsVisible;
  CGFloat _lastInspectorWidth;
}

@property (unsafe_unretained) id<MHSlidingSplitViewDelegate> delegate;
@property (unsafe_unretained) IBOutlet NSSplitView *splitView;
@property (unsafe_unretained) IBOutlet NSView *inspectorView;
@property (unsafe_unretained) IBOutlet NSView *mainView;
@property (assign) BOOL rightSided;


- (void)tearDown;
- (IBAction)toggle:(id)sender;
- (IBAction)slideOut:(id)sender;
- (void) slideOutAnimated:(BOOL)animate;
- (IBAction)slideIn:(id)sender;
- (void) slideInAnimated:(BOOL)animate;


@end
