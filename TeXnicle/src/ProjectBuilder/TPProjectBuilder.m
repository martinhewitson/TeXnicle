//
//  TPProjectBuilder.m
//  TeXnicle
//
//  Created by Martin Hewitson on 30/7/11.
//  Copyright 2011 bobsoft. All rights reserved.
//

#import "TPProjectBuilder.h"
#import "ConsoleController.h"
#import "NSString+LaTeX.h"
#import "RegexKitLite.h"
#import "NSString+RelativePath.h"
#import "ProjectEntity.h"
#import "FolderEntity.h"
#import "FileEntity.h"
#import "TeXFileEntity.h"
#import "ProjectItemTreeController.h"

@implementation TPProjectBuilder

@synthesize projectName;
@synthesize projectDir;
@synthesize mainfile;

+ (TPProjectBuilder*)builderWithDirectory:(NSString*)aPath
{
  return [[[TPProjectBuilder alloc] initWithDirectory:aPath] autorelease];
}

- (id) initWithDirectory:(NSString*)aPath
{
  NSString *file = [TPProjectBuilder mainfileForDirectory:aPath];
  if (!file)
    return nil;
  
  self = [self initWithMainfile:file];
  if (self) {
  }
  return self;
}

+ (TPProjectBuilder*)builderWithMainfile:(NSString*)aFile
{
  return [[[TPProjectBuilder alloc] initWithMainfile:aFile] autorelease];
}

- (id) initWithMainfile:(NSString*)aFile
{
  self = [super init];
  if (self) {
    self.mainfile = [aFile lastPathComponent];
    self.projectDir = [aFile stringByDeletingLastPathComponent];
    self.projectName = [[aFile lastPathComponent] stringByDeletingPathExtension];
  }
  return self;
}

// Look for the first tex file which has a \begin{document} in it and return that file.
+ (NSString*) mainfileForDirectory:(NSString*)aPath
{
//  NSLog(@"Scanning %@ for contents", aPath);
  NSFileManager *fm = [NSFileManager defaultManager];
  NSError *error = nil;
  NSArray *results = [fm contentsOfDirectoryAtPath:aPath error:&error];  
  if (error) {
    [NSApp presentError:error];
    return nil;
  }
  
  // look at each item in the directory
  for (NSString *path in results) {
    NSString *fullpath = [aPath stringByAppendingPathComponent:path];
//    NSLog(@"  checking %@", fullpath);
    // look for files
    NSDictionary *atts = [fm attributesOfItemAtPath:fullpath error:&error];
    if (atts) {
      if ([atts fileType] == NSFileTypeRegular) {
//        NSLog(@"    found file: %@", path);
        NSError *error = nil;
        // load the file as a string
        error = nil;
        NSString *str = [NSString stringWithContentsOfFile:fullpath
                                                  encoding:NSUTF8StringEncoding
                                                     error:&error];
        if (!error) {
          // look for \documentclass
          NSString *scanned = nil;
          NSScanner *scanner = [NSScanner scannerWithString:str];
          [scanner scanUpToString:@"\\documentclass" intoString:&scanned];
          if ([scanner scanLocation] < [str length]) {
            // we found the string
//            NSLog(@"*** Found document main file %@", path);
            return fullpath;
          }
        }
      }
    }
  }
    
  return nil;
}

- (NSArray*)includeTags
{
  return [NSArray arrayWithObjects:@"\\input", @"\\include", @"\\includegraphics", nil];
}

// follow all includes etc from main file and populate the document project
- (void)populateDocument:(TeXProjectDocument*)aDocument
{
  if (self.mainfile) {
    NSString *mainFilePath = [self.projectDir stringByAppendingPathComponent:self.mainfile];
    ProjectEntity *project = [aDocument project];
    NSManagedObjectContext *moc = [aDocument managedObjectContext];	
    FileEntity *file = [self addFileAtPath:mainFilePath toFolder:nil inProject:project inMOC:moc];
    // set as main file	
    [project setValue:file forKey:@"mainFile"];
    [self document:aDocument addProjectItemsFromFile:mainFilePath];
    [file setValue:[NSNumber numberWithInt:0] forKey:@"sortIndex"];
  }  
  [aDocument.projectItemTreeController updateSortOrder];
}

- (void)document:(TeXProjectDocument*)aDocument addProjectItemsFromFile:(NSString*)aFile
{
  ProjectEntity *project = [aDocument project];
  NSManagedObjectContext *moc = [aDocument managedObjectContext];	
	NSCharacterSet *ws = [NSCharacterSet whitespaceCharacterSet];
	NSCharacterSet *ns = [NSCharacterSet newlineCharacterSet];
  NSError *error = nil;
  // load the file as a string
  NSString *string = [NSString stringWithContentsOfFile:aFile
                                            encoding:NSUTF8StringEncoding
                                               error:&error];
  if (error) {
    [[ConsoleController sharedConsoleController] error:[NSString stringWithFormat:@"Failed to load contents of file %@", aFile]];    
  } else {
    
    string = [string stringByReplacingOccurrencesOfRegex:@"\n" withString:@" "];
    string = [@" " stringByAppendingString:string];
    
    // scan through looking for each include tag
    NSUInteger loc = 0;
    while (loc < [string length]) {
      if ([ws characterIsMember:[string characterAtIndex:loc]] ||
          [ns characterIsMember:[string characterAtIndex:loc]]) {
        
        NSString *word = [string nextWordStartingAtLocation:&loc];
        word = [word stringByTrimmingCharactersInSet:ws];
        
        // check if this word matches any of the tags
        for (NSString *tag in [self includeTags]) {
          if ([word hasPrefix:tag]) {            
            // get argument to this include tag
            NSString *arg = [word argument];
            // assume a default file extension of tex
            NSString *extension = [arg pathExtension];
            if (!extension || [extension length]==0) {
              arg = [arg stringByAppendingPathExtension:@"tex"];
            }            
            
            NSString *fullpath = [[self.projectDir stringByAppendingPathComponent:arg] stringByStandardizingPath];            
            NSString *relativePath = [[[self.projectDir relativePathTo:fullpath] stringByDeletingLastPathComponent] stringByStandardizingPath];            
            NSArray *pathComps = [relativePath pathComponents];                        

            // Make folders for each path component, if required
            FolderEntity *folder = [self makeFoldersForComponents:pathComps inProject:project inMOC:moc];
            
            // add file
            FileEntity *file = [self addFileAtPath:fullpath toFolder:folder inProject:project inMOC:moc];
            
            // if this is a tex file, recursive call
            if ([[file extension] isEqualToString:@"tex"]) {
              [self document:aDocument addProjectItemsFromFile:[file pathOnDisk]];
            }
          }                    
        } // end loop over tags        
      } // end if starting a word
      loc++;
    } // end while loop
  } // end if file load was successful
}

- (FileEntity*) addFileAtPath:(NSString*)fullpath toFolder:(FolderEntity*)folder inProject:(ProjectEntity*)project inMOC:(NSManagedObjectContext*)moc
{
  NSString *extension = [fullpath pathExtension];
	FileEntity *newFile;
	NSEntityDescription *entity = nil;
	if ([extension isEqual:@"tex"]) {
		entity = [NSEntityDescription entityForName:@"TeXFile" inManagedObjectContext:moc];
	} else {
		entity = [NSEntityDescription entityForName:@"File" inManagedObjectContext:moc];		
	}
	
	newFile = [[FileEntity alloc] initWithEntity:entity
                insertIntoManagedObjectContext:moc];
  
	// set the parent object
  [newFile setParent:folder];
  
	[moc processPendingChanges];
	
  // set file content
	BOOL isTextFile = NO;
	NSStringEncoding encoding;
	NSError *error = nil;
	NSString *contents = [NSString stringWithContentsOfFile:fullpath
																						 usedEncoding:&encoding
																										error:&error];
  
  // check if the file was a text file, If it is a text file and we couldn't load it, throw an error.
  CFStringRef fileUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (CFStringRef) extension, NULL);  
  if (UTTypeConformsTo(fileUTI, kUTTypeText)) {
    if (error) {
      [NSApp presentError:error];
    }
  }
  
	if (contents) {
		isTextFile = YES;
	}	
  NSData *data = [contents dataUsingEncoding:NSUTF8StringEncoding];
  [newFile setValue:data forKey:@"content"];
  
	// set project
	[newFile setValue:project forKey:@"project"];
	
	// set name
	[newFile setValue:[[fullpath lastPathComponent] stringByDeletingPathExtension] forKey:@"name"];
	
	// set isText
	[newFile setValue:[NSNumber numberWithBool:isTextFile] forKey:@"isText"];
	
	// set extension
  [newFile setValue:extension forKey:@"extension"];
  
	// configure the textstorage
	[newFile reconfigureDocument];
			
	// Set the filepath to the given one, or to the path in the project
  [newFile setValue:fullpath forKey:@"filepath"];
	
	// set file load data
	[newFile setValue:[NSDate date] forKey:@"fileLoadDate"];
	[newFile setValue:[NSDate date] forKey:@"lastEditDate"];
  
  return newFile;
}



- (FolderEntity*) makeFoldersForComponents:(NSArray*)pathComps inProject:(ProjectEntity*)project inMOC:(NSManagedObjectContext*)moc
{
  NSString *lastComp = nil;
  FolderEntity *parentItem = nil;
  for (NSString *comp in pathComps) {
    // get a list of current folders in the project to check against
    NSArray *folders = [project folders];
    BOOL createFolder = YES;
    for (FolderEntity *folder in folders) {
      NSString *folderName = [folder valueForKey:@"name"];
      NSString *folderParentName = [[folder valueForKey:@"parent"] valueForKey:@"name"];
      if ([folderName isEqualToString:comp]) {
        if (folderParentName && [folderParentName isEqualToString:lastComp]) continue;
        // skip making this one
        createFolder = NO;
        parentItem = folder;                
        break;
      }
    }
    
    if (createFolder) {
      // make the folder
      NSEntityDescription *newFolderEntity = [NSEntityDescription entityForName:@"Folder" inManagedObjectContext:moc];
      FolderEntity *newFolder = [[FolderEntity alloc] initWithEntity:newFolderEntity insertIntoManagedObjectContext:moc];
      
      // set name
      [newFolder setValue:comp forKey:@"name"];
      //	NSLog(@"Adding new folder: %@", newFolder);
      
      // set parent
      [newFolder setParent:parentItem];
      [[project mutableSetValueForKey:@"items"] addObject:newFolder];
      parentItem = newFolder;
    }
    lastComp = comp;              
  } // end loop over path components
  return parentItem;
}

- (NSString*)description
{
  return [NSString stringWithFormat:@"ProjectBuilder: %@, %@, %@", self.projectName, self.projectDir, self.mainfile];
}

- (NSURL*)projectFileURL
{
  return [NSURL fileURLWithPath:[self.projectDir stringByAppendingPathComponent:[self.projectName stringByAppendingPathExtension:@"texnicle"]]];
}

@end
