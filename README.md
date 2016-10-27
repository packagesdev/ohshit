## Synopsis

The OhShit framework (or static library) simulates errors when trying to read, write or access filesystem items using the Foundation APIs.

## Code Example

```Objective-C
#import <Foundation/Foundation.h>
#import <OhShit/OhShit.h>

int main(int argc, const char * argv[])
{
	@autoreleasepool
	{
		// Simulate no more space on the startup disk when trying to write things to /Users/Shared
		
		NSArray * tList=@[@{OHSHITStorageLocationKey:[OHSHITStorageLocation storageLocationWithPath:@"/Users/Shared/"],
							OHSHITStorageFailureTypeKey:@(OHSHIT_StorageSimulateNoMoreSpace)}]
		
		[[OHSHITManager defaultManager] setStorageFailuresList:tList];
																   
		NSError * tError=nil;
		
		if ([[NSData dataWithBytes:"dummy" length:5] writeToFile:@"/Users/Shared/TestData" 
														 options:NSDataWritingAtomic 
														   error:&tError]==NO)
		{
			if (tError!=nil)
				NSLog(@"Oh Shit! %@",tError.localizedDescription);
		}
	}
	
    return 0;
}
```

## Motivation

As the great North American philosopher F. Gump once mentioned, shit happens. And sometimes it happens when you're trying to access, read or write contents from the disk using the Foundation APIs. If you're trying to make sure your code is appropriately taken care of those cases, the OhShit framework may prove helpful.

Instead of having to create volumes that are read-only or with no empty space, or change the permissions of existing files/folders, you will just have to define the simulated issues and run your unit tests or manual tests.

## Installation

1. Add the OhShit.xcode project to your Xcode project.
2. Set the OhShit framework as a Target Dependency in the Build Phases settings of your project.
3. Add the OhShit.framework to the Link Binary With Libraries list in the Build Phases settings of your project.
4. Import the OhShit/OhShit.h file in your project main file (or in another file where you want to set/change the simulated storage failures).
5. Define the list of simulated failures with the - [OHSHITManager setStorageFailuresList:]; method.

## API Reference

Description forthcoming

## Tests

Description forthcoming

## License

Copyright (c) 2016, Stephane Sudre
All rights reserved.
 
Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 
- Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
- Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
- Neither the name of the WhiteBox nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 