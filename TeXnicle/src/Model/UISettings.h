//
//  UISettings.h
//  TeXnicle
//
//  Created by Martin Hewitson on 08/01/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ProjectEntity;

@interface UISettings : NSManagedObject

@property (nonatomic, retain) NSNumber * selectedControlsTab;
@property (nonatomic, retain) NSString * pdfViewScrollRect;
@property (nonatomic, retain) NSNumber * controlsWidth;
@property (nonatomic, retain) NSNumber * editorWidth;
@property (nonatomic, retain) ProjectEntity *project;

@end
