//
//  TPBottomBarView.h
//  Trips
//
//  Created by Martin Hewitson on 30/8/10.
//  Copyright 2010 BOBsoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SBGradientView.h"


@interface TETopBarView : SBGradientView {

}

- (void) handleWindowDidBecomeMain:(NSNotification*)notification;
- (void) handleWindowResignedMain:(NSNotification*)notification;

@end
