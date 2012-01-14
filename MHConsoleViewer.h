//
//  MHConsoleViewer.h
//  TeXnicle
//
//  Created by Martin Hewitson on 26/10/11.
//  Copyright (c) 2011 bobsoft. All rights reserved.
//

#ifndef TeXnicle_MHConsoleViewer_h
#define TeXnicle_MHConsoleViewer_h

@protocol MHConsoleViewer <NSObject>
@optional
- (void) clear;
- (void) appendText:(NSString*)someText;
- (void) appendText:(NSString*)someText withColor:(NSColor*)aColor;
- (void) error:(NSString*)someText;
- (void) message:(NSString*)someText;
@end

#endif
