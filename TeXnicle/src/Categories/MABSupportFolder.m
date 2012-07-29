/*
 Copyright (c) 2006 Michael Bianco, <software@mabwebdesign.com>
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), 
 to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, 
 and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
 INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, 
 DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, 
 ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

/*
 There should only be once instance of this support controller, I usually created a instace in my MainMenu.nib file then
 use -[MABSupportFolder sharedController] to access the instance in my code.
 
 You can easily extend this class and add methods to manipulate/manage the support folder in any way you please.
 One glitch you may come across when extending subclassing is the +sharedController method. 
 GCC will give you warnings that MABSupportController will not respond to a method you added onto your subclass.
 You can silence GCC by adding this method to your subclass:
 +(AppSupportController *) sharedController { return (AppSupportController *) [super sharedController]; }
 where AppSupportController is you new subclass.
 */

#import "MABSupportFolder.h"

static MABSupportFolder *_sharedController;

@implementation MABSupportFolder
+(MABSupportFolder *) sharedController {
	extern MABSupportFolder *_sharedController;
	if(!_sharedController) //if we don't already have a instance created
		[MABSupportFolder new]; //create a instance, we don't have to save a reference to it since it will be the sharedController
	return _sharedController;
}

- (id) init {
	if (self = [super init]) {
		//set the shared controller
		extern MABSupportFolder *_sharedController;
		_sharedController = self;
		
		//create the application support folder path
		_supportFolder = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) objectAtIndex:0];
		_supportFolder = [_supportFolder stringByAppendingPathComponent:[[NSBundle mainBundle]  objectForInfoDictionaryKey:@"CFBundleName"]];
		
		_fileManager = [NSFileManager defaultManager];
	}
	
	return self;
}



-(void) createSupportFolder {
	if(![_fileManager fileExistsAtPath:_supportFolder]) {//if the app support folder for dictpod isn't created
		if(![_fileManager createDirectoryAtPath:_supportFolder
									 attributes:nil]) {
			NSLog(@"Error creating app-support folder");	
		}
	}
}

//-----------------------
//	Getter & Setter
//-----------------------
-(BOOL) isSupportFolderCreated {
	return [_fileManager fileExistsAtPath:_supportFolder];
}

-(NSString *) supportFolder {
	return _supportFolder;	
}
@end
