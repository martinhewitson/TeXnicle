//
//  TPDocumentOutlineView.h
//  TeXnicle
//
//  Created by Martin Hewitson on 05/01/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TPDocumentOutlineView;

@protocol DocumentOutlineViewDataSource <NSObject>

- (id)outlineView:(TPDocumentOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item;
- (NSInteger)outlineView:(TPDocumentOutlineView *)outlineView numberOfChildrenOfItem:(id)item;
- (id)outlineView:(TPDocumentOutlineView *)outlineView objectValueForItem:(id)item;
- (NSUInteger)outlineView:(TPDocumentOutlineView*)outlineView indentLevelForItem:(id)item;

@end

@protocol DocumentOutlineViewDelegate <NSObject>


@end


@interface TPDocumentOutlineView : NSView <DocumentOutlineViewDelegate, DocumentOutlineViewDataSource> {
@private
  id<DocumentOutlineViewDataSource> dataSource; 
  id<DocumentOutlineViewDelegate> delegate;
}

@property (assign) IBOutlet id<DocumentOutlineViewDataSource> dataSource;
@property (assign) IBOutlet id<DocumentOutlineViewDelegate> delegate;

- (CGFloat) drawItem:(id)item yoffset:(CGFloat)yoffset;

@end
