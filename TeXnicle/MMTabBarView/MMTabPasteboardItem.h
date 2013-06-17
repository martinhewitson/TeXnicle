//
//  MMTabPasteboardItem.h
//  MMTabBarView
//
//  Created by Michael Monscheuer on 9/11/12.
//
//

#import <Cocoa/Cocoa.h>

@class MMAttachedTabBarButton;
@class MMTabBarView;

@interface MMTabPasteboardItem : NSPasteboardItem {

    MMTabBarView *_sourceTabBar;
    MMAttachedTabBarButton *_attachedTabBarButton;
    NSUInteger _sourceIndex;
}

@property (strong) MMTabBarView *sourceTabBar;
@property (strong) MMAttachedTabBarButton *attachedTabBarButton;
@property (assign) NSUInteger sourceIndex;

@end
