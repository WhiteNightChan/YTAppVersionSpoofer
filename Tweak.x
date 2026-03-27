#import "Tweak.h"
#import "YTAVSMappings.h"

static NSString *YTAVSSavedRawVersionString(void) {
    id value = [[NSUserDefaults standardUserDefaults] objectForKey:@"versionSpooferString"];
    return [value isKindOfClass:[NSString class]] ? value : nil;
}

static NSString *YTAVSEffectiveSpoofedVersionString(void) {
    NSString *savedVersionString = YTAVSSavedRawVersionString();
    if (YTAVSContainsRawVersionString(savedVersionString)) {
        return savedVersionString;
    }

    return YTAVSGetDefaultAppVersion();
}

static BOOL isVersionSpooferEnabled() {
    return IS_ENABLED(@"enableVersionSpoofer_enabled");
}

%hook YTVersionUtils
+ (NSString *)appVersion {
    if (!isVersionSpooferEnabled()) {
        return %orig;
    }

    NSString *appVersion = YTAVSEffectiveSpoofedVersionString();
    return appVersion ? appVersion : %orig;
}
%end
