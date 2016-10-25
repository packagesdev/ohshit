/*
 Copyright (c) 2016, Stephane Sudre
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 
 - Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 - Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 - Neither the name of the WhiteBox nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "NSFileManager+OHSHIT.h"

#import "NSObject+OHSHIT.h"

#import "OHSHITManager+Private.h"

@interface NSFileManager (OHSHIT_Private)

- (BOOL)OHSHIT_createDirectoryAtURL:(NSURL *)url withIntermediateDirectories:(BOOL)createIntermediates attributes:(NSDictionary *)attributes error:(NSError **)errorPtr;

- (BOOL)OHSHIT_createSymbolicLinkAtURL:(NSURL *)url withDestinationURL:(NSURL *)destURL error:(NSError **)errorPtr;

- (BOOL)OHSHIT_createDirectoryAtPath:(NSString *)path withIntermediateDirectories:(BOOL)createIntermediates attributes:(NSDictionary *)attributes error:(NSError **)errorPtr;

- (BOOL)OHSHIT_createSymbolicLinkAtPath:(NSString *)path withDestinationPath:(NSString *)destPath error:(NSError **)errorPtr;

@end

@implementation NSFileManager (OHSHIT)

+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		[NSFileManager OHSHIT_start];
	});
}

- (BOOL)OHSHIT_createDirectoryAtURL:(NSURL *)url withIntermediateDirectories:(BOOL)createIntermediates attributes:(NSDictionary *)attributes error:(NSError **)errorPtr
{
	OHSHITStorageFailureType tMatchingFailureType=[[OHSHITManager defaultManager] failureTypeForURL:url matchingFailuresTypes:[OHSHITManager writeFailureTypes]];
	
	if (tMatchingFailureType==OHSHIT_StorageNoSimulatedFailure)
		return [self OHSHIT_createDirectoryAtURL:url withIntermediateDirectories:createIntermediates attributes:attributes error:errorPtr];
	
	if (errorPtr==NULL)
		return NO;
	
	switch(tMatchingFailureType)
	{
		case OHSHIT_StorageSimulateNoMoreSpace:
			
			if (errorPtr!=NULL)
			{
				NSError * tUnderlyingError=[NSError errorWithDomain:NSPOSIXErrorDomain code:ENOSPC userInfo:nil];
				
				*errorPtr=[NSError errorWithDomain:NSCocoaErrorDomain code:NSFileWriteOutOfSpaceError userInfo:@{OHSHITFilePathKey:[url path],
																												 OHSHITUnderlyingErrorKey:tUnderlyingError}];
			}
			
			break;
			
		case OHSHIT_StorageSimulateReadOnly:
			
			if (errorPtr!=NULL)
			{
				NSError * tUnderlyingError=[NSError errorWithDomain:NSPOSIXErrorDomain code:EROFS userInfo:nil];
				
				*errorPtr=[NSError errorWithDomain:NSCocoaErrorDomain code:NSFileWriteVolumeReadOnlyError userInfo:@{OHSHITFilePathKey:[url path],
																													 OHSHITUnderlyingErrorKey:tUnderlyingError}];
			}
			
			return NO;
			
		case OHSHIT_StorageSimulateFileWritePermissionDenied:
			
			if (errorPtr!=NULL)
			{
				NSError * tUnderlyingError=[NSError errorWithDomain:NSPOSIXErrorDomain code:EACCES userInfo:nil];
				
				*errorPtr=[NSError errorWithDomain:NSCocoaErrorDomain code:NSFileWriteNoPermissionError userInfo:@{OHSHITFilePathKey:[url path],
																												   OHSHITUnderlyingErrorKey:tUnderlyingError}];
			}
			
			return NO;
			
		case OHSHIT_StorageSimulateFileMissingIntermediaryDirectory:
			
			if (createIntermediates==YES)
				break;
			
			if (errorPtr!=NULL)
			{
				NSError * tUnderlyingError=[NSError errorWithDomain:NSPOSIXErrorDomain code:ENOENT userInfo:nil];
				
				*errorPtr=[NSError errorWithDomain:NSCocoaErrorDomain code:NSFileNoSuchFileError userInfo:@{OHSHITFilePathKey:[url path],
																											OHSHITUnderlyingErrorKey:tUnderlyingError}];
			}
			
			return NO;
			
		default:
			break;
	}
	
	return NO;
}

- (BOOL)OHSHIT_createSymbolicLinkAtURL:(NSURL *)url withDestinationURL:(NSURL *)destURL error:(NSError **)errorPtr
{
	OHSHITStorageFailureType tMatchingFailureType=[[OHSHITManager defaultManager] failureTypeForURL:url matchingFailuresTypes:[OHSHITManager writeFailureTypes]];
	
	if (tMatchingFailureType==OHSHIT_StorageNoSimulatedFailure)
		return [self OHSHIT_createSymbolicLinkAtURL:url withDestinationURL:destURL error:errorPtr];
	
	if (errorPtr==NULL)
		return NO;
	
	switch(tMatchingFailureType)
	{
		case OHSHIT_StorageSimulateNoMoreSpace:
			
			if (errorPtr!=NULL)
			{
				NSError * tUnderlyingError=[NSError errorWithDomain:NSPOSIXErrorDomain code:ENOSPC userInfo:nil];
				
				*errorPtr=[NSError errorWithDomain:NSCocoaErrorDomain code:NSFileWriteOutOfSpaceError userInfo:@{OHSHITFilePathKey:[url path],
																												 OHSHITUnderlyingErrorKey:tUnderlyingError}];
			}
			
			break;
			
		case OHSHIT_StorageSimulateReadOnly:
			
			if (errorPtr!=NULL)
			{
				NSError * tUnderlyingError=[NSError errorWithDomain:NSPOSIXErrorDomain code:EROFS userInfo:nil];
				
				*errorPtr=[NSError errorWithDomain:NSCocoaErrorDomain code:NSFileWriteVolumeReadOnlyError userInfo:@{OHSHITFilePathKey:[url path],
																													 OHSHITUnderlyingErrorKey:tUnderlyingError}];
			}
			
			return NO;
			
		case OHSHIT_StorageSimulateFileWritePermissionDenied:
			
			if (errorPtr!=NULL)
			{
				NSError * tUnderlyingError=[NSError errorWithDomain:NSPOSIXErrorDomain code:EACCES userInfo:nil];
				
				*errorPtr=[NSError errorWithDomain:NSCocoaErrorDomain code:NSFileWriteNoPermissionError userInfo:@{OHSHITFilePathKey:[url path],
																												   OHSHITUnderlyingErrorKey:tUnderlyingError}];
			}
			
			return NO;
		
		case OHSHIT_StorageSimulateFileMissingIntermediaryDirectory:
			
			if (errorPtr!=NULL)
			{
				NSError * tUnderlyingError=[NSError errorWithDomain:NSPOSIXErrorDomain code:ENOENT userInfo:nil];
				
				*errorPtr=[NSError errorWithDomain:NSCocoaErrorDomain code:NSFileNoSuchFileError userInfo:@{OHSHITFilePathKey:[url path],
																											OHSHITUnderlyingErrorKey:tUnderlyingError}];
			}
			
			return NO;
			
		default:
			break;
	}
	
	return NO;
}


- (BOOL)OHSHIT_createDirectoryAtPath:(NSString *)path withIntermediateDirectories:(BOOL)createIntermediates attributes:(NSDictionary *)attributes error:(NSError **)errorPtr
{
	OHSHITStorageFailureType tMatchingFailureType=[[OHSHITManager defaultManager] failureTypeForPath:path matchingFailuresTypes:[OHSHITManager writeFailureTypes]];
	
	if (tMatchingFailureType==OHSHIT_StorageNoSimulatedFailure)
		return [self OHSHIT_createDirectoryAtPath:path withIntermediateDirectories:createIntermediates attributes:attributes error:errorPtr];
	
	if (errorPtr==NULL)
		return NO;
	
	switch(tMatchingFailureType)
	{
		case OHSHIT_StorageSimulateNoMoreSpace:
			
			if (errorPtr!=NULL)
			{
				NSError * tUnderlyingError=[NSError errorWithDomain:NSPOSIXErrorDomain code:ENOSPC userInfo:nil];
			
				*errorPtr=[NSError errorWithDomain:NSCocoaErrorDomain code:NSFileWriteOutOfSpaceError userInfo:@{OHSHITFilePathKey:path,
																												 OHSHITUnderlyingErrorKey:tUnderlyingError}];
			}
			
			break;
			
		case OHSHIT_StorageSimulateReadOnly:
			
			if (errorPtr!=NULL)
			{
				NSError * tUnderlyingError=[NSError errorWithDomain:NSPOSIXErrorDomain code:EROFS userInfo:nil];
			
				*errorPtr=[NSError errorWithDomain:NSCocoaErrorDomain code:NSFileWriteVolumeReadOnlyError userInfo:@{OHSHITFilePathKey:path,
																													 OHSHITUnderlyingErrorKey:tUnderlyingError}];
			}
			
			return NO;
			
		case OHSHIT_StorageSimulateFileWritePermissionDenied:
			
			if (errorPtr!=NULL)
			{
				NSError * tUnderlyingError=[NSError errorWithDomain:NSPOSIXErrorDomain code:EACCES userInfo:nil];
			
				*errorPtr=[NSError errorWithDomain:NSCocoaErrorDomain code:NSFileWriteNoPermissionError userInfo:@{OHSHITFilePathKey:path,
																												   OHSHITUnderlyingErrorKey:tUnderlyingError}];
			}
			
			return NO;
			
		case OHSHIT_StorageSimulateFileMissingIntermediaryDirectory:
			
			if (createIntermediates==YES)
				break;
			
			if (errorPtr!=NULL)
			{
				NSError * tUnderlyingError=[NSError errorWithDomain:NSPOSIXErrorDomain code:ENOENT userInfo:nil];
				
				*errorPtr=[NSError errorWithDomain:NSCocoaErrorDomain code:NSFileNoSuchFileError userInfo:@{OHSHITFilePathKey:path,
																											OHSHITUnderlyingErrorKey:tUnderlyingError}];
			}
			
			return NO;
			
		default:
			break;
	}
	
	return NO;
}

- (BOOL)OHSHIT_createSymbolicLinkAtPath:(NSString *)path withDestinationPath:(NSString *)destPath error:(NSError **)errorPtr
{
	OHSHITStorageFailureType tMatchingFailureType=[[OHSHITManager defaultManager] failureTypeForPath:path matchingFailuresTypes:[OHSHITManager writeFailureTypes]];
	
	if (tMatchingFailureType==OHSHIT_StorageNoSimulatedFailure)
		return [self OHSHIT_createSymbolicLinkAtPath:path withDestinationPath:destPath error:errorPtr];
	
	if (errorPtr==NULL)
		return NO;
	
	switch(tMatchingFailureType)
	{
		case OHSHIT_StorageSimulateNoMoreSpace:
			
			if (errorPtr!=NULL)
			{
				NSError * tUnderlyingError=[NSError errorWithDomain:NSPOSIXErrorDomain code:ENOSPC userInfo:nil];
			
				*errorPtr=[NSError errorWithDomain:NSCocoaErrorDomain code:NSFileWriteOutOfSpaceError userInfo:@{OHSHITFilePathKey:path,
																												 OHSHITUnderlyingErrorKey:tUnderlyingError}];
			}
			
			break;
			
		case OHSHIT_StorageSimulateReadOnly:
			
			if (errorPtr!=NULL)
			{
				NSError * tUnderlyingError=[NSError errorWithDomain:NSPOSIXErrorDomain code:EROFS userInfo:nil];
			
				*errorPtr=[NSError errorWithDomain:NSCocoaErrorDomain code:NSFileWriteVolumeReadOnlyError userInfo:@{OHSHITFilePathKey:path,
																													 OHSHITUnderlyingErrorKey:tUnderlyingError}];
			}
			
			return NO;
			
		case OHSHIT_StorageSimulateFileWritePermissionDenied:
			
			if (errorPtr!=NULL)
			{
				NSError * tUnderlyingError=[NSError errorWithDomain:NSPOSIXErrorDomain code:EACCES userInfo:nil];
			
				*errorPtr=[NSError errorWithDomain:NSCocoaErrorDomain code:NSFileWriteNoPermissionError userInfo:@{OHSHITFilePathKey:path,
																												   OHSHITUnderlyingErrorKey:tUnderlyingError}];
			}
			
			return NO;
		
		case OHSHIT_StorageSimulateFileMissingIntermediaryDirectory:
			
			if (errorPtr!=NULL)
			{
				NSError * tUnderlyingError=[NSError errorWithDomain:NSPOSIXErrorDomain code:ENOENT userInfo:nil];
				
				*errorPtr=[NSError errorWithDomain:NSCocoaErrorDomain code:NSFileNoSuchFileError userInfo:@{OHSHITFilePathKey:path,
																											OHSHITUnderlyingErrorKey:tUnderlyingError}];
			}
			
			return NO;
			
		default:
			break;
	}
	
	return NO;
}

@end
