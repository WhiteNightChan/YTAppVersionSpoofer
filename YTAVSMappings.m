#import "YTAVSMappings.h"

static const YTAVSVersionMapping kVersionMappings[] = {
    {@"21.08.3", NO},
    {@"21.07.4", NO},
    {@"21.06.2", NO},
    {@"21.05.3", NO},
    {@"21.04.2", NO},
    {@"21.03.2", NO},
    {@"21.02.3", NO},
    {@"20.50.10", NO},
    {@"20.50.9", NO},
    {@"20.50.6", NO},
    {@"20.49.5", NO},
    {@"20.47.3", NO},
    {@"20.46.3", NO},
    {@"20.46.2", NO},
    {@"20.45.3", NO},
    {@"20.44.2", NO},
    {@"20.43.3", NO},
    {@"20.42.3", NO},
    {@"20.41.5", NO},
    {@"20.41.4", NO},
    {@"20.40.4", NO},
    {@"20.39.6", NO},
    {@"20.39.5", NO},
    {@"20.39.4", NO},
    {@"20.38.4", NO},
    {@"20.38.3", NO},
    {@"20.37.5", NO},
    {@"20.37.3", NO},
    {@"20.36.3", NO},
    {@"20.35.2", NO},
    {@"20.34.2", NO},
    {@"20.33.2", NO},
    {@"20.32.5", NO},
    {@"20.32.4", NO},
    {@"20.31.6", NO},
    {@"20.31.5", NO},
    {@"20.30.5", NO},
    {@"20.29.3", NO},
    {@"20.28.2", NO},
    {@"20.26.7", NO},
    {@"20.25.4", NO},
    {@"20.24.5", NO},
    {@"20.24.4", NO},
    {@"20.23.3", NO},
    {@"20.22.1", NO},
    {@"20.21.6", NO},
    {@"20.20.7", NO},
    {@"20.20.5", NO},
    {@"20.19.3", NO},
    {@"20.19.2", NO},
    {@"20.18.5", NO},
    {@"20.18.4", NO},
    {@"20.16.7", NO},
    {@"20.15.1", NO},
    {@"20.14.2", NO},
    {@"20.13.5", NO},
    {@"20.12.4", NO},
    {@"20.11.6", NO},
    {@"20.10.4", NO},
    {@"20.10.3", NO},
    {@"20.09.3", NO},
    {@"20.08.3", NO},
    {@"20.07.6", NO},
    {@"20.06.03", NO},
    {@"20.05.4", NO},
    {@"20.03.1", NO},
    {@"20.03.02", NO},
    {@"20.02.3", NO}
};

static const YTAVSVersionMapping *YTAVSGetMappingForIndex(int spoofedVersion) {
    if (spoofedVersion < 0) {
        return NULL;
    }

    NSUInteger count = sizeof(kVersionMappings) / sizeof(kVersionMappings[0]);
    NSUInteger index = (NSUInteger)spoofedVersion;

    if (index >= count) {
        return NULL;
    }

    return &kVersionMappings[index];
}

static const YTAVSVersionMapping *YTAVSGetMappingForRawVersionString(NSString *versionString) {
    if (![versionString isKindOfClass:[NSString class]] || versionString.length == 0) {
        return NULL;
    }

    NSUInteger count = sizeof(kVersionMappings) / sizeof(kVersionMappings[0]);

    for (NSUInteger i = 0; i < count; i++) {
        if ([kVersionMappings[i].rawVersionString isEqualToString:versionString]) {
            return &kVersionMappings[i];
        }
    }

    return NULL;
}

const YTAVSVersionMapping *YTAVSGetMappings(NSUInteger *count) {
    if (count) {
        *count = sizeof(kVersionMappings) / sizeof(kVersionMappings[0]);
    }
    return kVersionMappings;
}

NSUInteger YTAVSGetMappingsCount(void) {
    return sizeof(kVersionMappings) / sizeof(kVersionMappings[0]);
}

NSString *YTAVSGetRawVersionStringForIndex(int spoofedVersion) {
    const YTAVSVersionMapping *mapping = YTAVSGetMappingForIndex(spoofedVersion);
    return mapping ? mapping->rawVersionString : nil;
}

NSInteger YTAVSGetIndexForRawVersionString(NSString *versionString) {
    if (![versionString isKindOfClass:[NSString class]] || versionString.length == 0) {
        return NSNotFound;
    }

    NSUInteger count = sizeof(kVersionMappings) / sizeof(kVersionMappings[0]);

    for (NSUInteger i = 0; i < count; i++) {
        if ([kVersionMappings[i].rawVersionString isEqualToString:versionString]) {
            return (NSInteger)i;
        }
    }

    return NSNotFound;
}

BOOL YTAVSContainsRawVersionString(NSString *versionString) {
    return YTAVSGetIndexForRawVersionString(versionString) != NSNotFound;
}

NSString *YTAVSGetDisplayTitleForIndex(int spoofedVersion) {
    const YTAVSVersionMapping *mapping = YTAVSGetMappingForIndex(spoofedVersion);

    if (!mapping) {
        return YTAVSGetDefaultDisplayTitle();
    }

    if (mapping->deprecated) {
        return [NSString stringWithFormat:@"v%@ (Deprecated)", mapping->rawVersionString];
    }

    return [NSString stringWithFormat:@"v%@", mapping->rawVersionString];
}

NSString *YTAVSGetDisplayTitleForRawVersionString(NSString *versionString) {
    const YTAVSVersionMapping *mapping = YTAVSGetMappingForRawVersionString(versionString);

    if (!mapping) {
        return YTAVSGetDefaultDisplayTitle();
    }

    if (mapping->deprecated) {
        return [NSString stringWithFormat:@"v%@ (Deprecated)", mapping->rawVersionString];
    }

    return [NSString stringWithFormat:@"v%@", mapping->rawVersionString];
}

NSString *YTAVSGetDefaultAppVersion(void) {
    return @"21.08.3";
}

NSString *YTAVSGetDefaultDisplayTitle(void) {
    return @"v21.08.3";
}
