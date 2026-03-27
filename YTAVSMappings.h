#ifndef YTAVS_MAPPINGS_H
#define YTAVS_MAPPINGS_H

#import <Foundation/Foundation.h>

typedef struct {
    __unsafe_unretained NSString *rawVersionString;
    BOOL deprecated;
} YTAVSVersionMapping;

FOUNDATION_EXTERN const YTAVSVersionMapping *YTAVSGetMappings(NSUInteger *count);
FOUNDATION_EXTERN NSUInteger YTAVSGetMappingsCount(void);
FOUNDATION_EXTERN NSString *YTAVSGetRawVersionStringForIndex(int spoofedVersion);
FOUNDATION_EXTERN NSInteger YTAVSGetIndexForRawVersionString(NSString *versionString);
FOUNDATION_EXTERN BOOL YTAVSContainsRawVersionString(NSString *versionString);
FOUNDATION_EXTERN NSString *YTAVSGetDisplayTitleForIndex(int spoofedVersion);
FOUNDATION_EXTERN NSString *YTAVSGetDisplayTitleForRawVersionString(NSString *versionString);
FOUNDATION_EXTERN NSString *YTAVSGetDefaultAppVersion(void);
FOUNDATION_EXTERN NSString *YTAVSGetDefaultDisplayTitle(void);

#endif
