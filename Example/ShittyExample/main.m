
#import <Foundation/Foundation.h>

#import <OhShit/OhShit.h>

int main(int argc, const char * argv[])
{
	@autoreleasepool
	{
		[[OHSHITManager sharedManager] setStorageFailuresList:@[@{OHSHITStorageLocationKey:[OHSHITStorageLocation storageLocationWithPath:[[@"~" stringByExpandingTildeInPath] stringByAppendingString:@"/"]],
																   OHSHITStorageFailureTypeKey:@(OHSHIT_StorageSimulateFileWritePermissionDenied)},
																 @{OHSHITStorageLocationKey:[OHSHITStorageLocation storageLocationWithPath:@"/Users/Shared/"],
																   OHSHITStorageFailureTypeKey:@(OHSHIT_StorageSimulateNoMoreSpace)},
																 @{OHSHITStorageLocationKey:[OHSHITStorageLocation storageLocationWithPath:@"/System/Library/CoreServices/SystemVersion.plist"],
																   OHSHITStorageFailureTypeKey:@(OHSHIT_StorageSimulateFileMissingIntermediaryDirectory)}
																 
																 ]];
		
		NSError * tError=nil;
		NSURL * tURL=[NSURL fileURLWithPath:[@"~/TestNewDirectory" stringByExpandingTildeInPath]];
		
		if ([[NSFileManager defaultManager] createDirectoryAtURL:tURL withIntermediateDirectories:YES attributes:nil error:&tError]==NO)
		{
			if (tError!=nil)
				NSLog(@"Oh Shit! %@",tError.localizedDescription);
		}
		
		tError=nil;
		
		if ([[NSData dataWithBytes:"tutu" length:4] writeToFile:@"/Users/Shared/TestData" options:NSDataWritingAtomic error:&tError]==NO)
		{
			if (tError!=nil)
				NSLog(@"Oh Shit! %@",tError.localizedDescription);
		}
		
		NSData * tData=[NSData dataWithContentsOfFile:@"/System/Library/CoreServices/SystemVersion.plist" options:0 error:&tError];
		
		if (tData==nil)
		{
			if (tError!=nil)
				NSLog(@"Oh Shit! %@",tError.localizedDescription);
		}
	}
	
    return 0;
}
