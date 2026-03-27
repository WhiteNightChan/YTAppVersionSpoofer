#import <objc/runtime.h>
#import "YouTubeHeader/YTIIcon.h"
#import "YouTubeHeader/YTSettingsGroupData.h"
#import "YouTubeHeader/YTSettingsViewController.h"
#import "YouTubeHeader/YTSettingsSectionItem.h"
#import "YouTubeHeader/YTSettingsSectionItemManager.h"
#import "YouTubeHeader/YTSettingsPickerViewController.h"
#import "Tweak.h"
#import "YTAVSMappings.h"

static NSString *YTAVSSavedRawVersionString(void) {
    id value = [[NSUserDefaults standardUserDefaults] objectForKey:@"versionSpooferString"];
    return [value isKindOfClass:[NSString class]] ? value : nil;
}

static NSInteger YTAVSDefaultSelectedVersionIndex(void) {
    NSInteger defaultIndex = YTAVSGetIndexForRawVersionString(YTAVSGetDefaultAppVersion());
    return defaultIndex != NSNotFound ? defaultIndex : 0;
}

static NSInteger YTAVSEffectiveSelectedVersionIndex(void) {
    NSString *savedVersionString = YTAVSSavedRawVersionString();
    NSInteger selectedIndex = YTAVSGetIndexForRawVersionString(savedVersionString);
    if (selectedIndex != NSNotFound) {
        return selectedIndex;
    }

    return YTAVSDefaultSelectedVersionIndex();
}

static NSString *YTAVSEffectiveSelectedDisplayTitle(void) {
    NSString *savedVersionString = YTAVSSavedRawVersionString();
    if (YTAVSContainsRawVersionString(savedVersionString)) {
        return YTAVSGetDisplayTitleForRawVersionString(savedVersionString);
    }

    return YTAVSGetDefaultDisplayTitle();
}

static NSString *YTAVSLocalizationBundlePath(void) {
    NSString *rootlessBundlePath =
        @"/var/jb/Library/Application Support/YTAppVersionSpoofer.bundle";

    if ([[NSFileManager defaultManager] fileExistsAtPath:rootlessBundlePath]) {
        return rootlessBundlePath;
    }

    NSString *sideloadBundlePath =
        [[NSBundle mainBundle] pathForResource:@"YTAppVersionSpoofer"
                                        ofType:@"bundle"];
    if (sideloadBundlePath.length > 0) {
        return sideloadBundlePath;
    }

    return nil;
}

static NSBundle *YTAVSLocalizationBundle(void) {
    static NSBundle *bundle = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        NSString *bundlePath = YTAVSLocalizationBundlePath();
        if (bundlePath.length > 0) {
            bundle = [NSBundle bundleWithPath:bundlePath];
        }
    });

    return bundle;
}

#ifndef PACKAGE_VERSION
#define PACKAGE_VERSION @"Unknown"
#endif

static NSString *YTAVSLocalizedText(NSString *key) {
    NSBundle *bundle = YTAVSLocalizationBundle();
    if (!bundle) {
        return key;
    }

    return [bundle localizedStringForKey:key
                                   value:key
                                   table:nil];
}

static inline NSString *YTAVSVersionLabel(void) {
    return PACKAGE_VERSION;
}

static const NSInteger YTAppVersionSpooferSection = 'yavs';

static YTSettingsSectionItem *YTAVSMakeSectionHeaderItem(NSString *title) {
    return [%c(YTSettingsSectionItem)
        itemWithTitle:@"\t"
        titleDescription:[title uppercaseString]
        accessibilityIdentifier:nil
        detailTextBlock:nil
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger sectionItemIndex) {
            return NO;
        }];
}

static void YTAVSAddSectionHeader(NSMutableArray<YTSettingsSectionItem *> *sectionItems, NSString *title) {
    [sectionItems addObject:YTAVSMakeSectionHeaderItem(title)];
}

static YTSettingsSectionItem *YTAVSMakeSwitchItem(NSString *title, NSString *description, NSString *defaultsKey) {
    return [%c(YTSettingsSectionItem)
        switchItemWithTitle:title
        titleDescription:description
        accessibilityIdentifier:nil
        switchOn:IS_ENABLED(defaultsKey)
        switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
            [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:defaultsKey];
            return YES;
        }
        settingItemId:0];
}

static YTSettingsSectionItem *YTAVSMakeVersionPickerRow(NSString *title, NSInteger index, NSString *rawVersionString, YTSettingsViewController *settingsViewController) {
    return [%c(YTSettingsSectionItem)
        checkmarkItemWithTitle:title
        titleDescription:nil
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

            if (rawVersionString.length > 0) {
                [defaults setObject:rawVersionString forKey:@"versionSpooferString"];
            } else {
                [defaults removeObjectForKey:@"versionSpooferString"];
            }

            [defaults removeObjectForKey:@"versionSpoofer"];
            [settingsViewController reloadData];
            return YES;
        }];
}

static NSArray<YTSettingsSectionItem *> *YTAVSMakeVersionPickerRows(YTSettingsViewController *settingsViewController) {
    NSUInteger mappingsCount = YTAVSGetMappingsCount();
    NSMutableArray<YTSettingsSectionItem *> *rows = [NSMutableArray arrayWithCapacity:mappingsCount];

    for (NSUInteger i = 0; i < mappingsCount; i++) {
        NSString *displayTitle = YTAVSGetDisplayTitleForIndex((int)i);
        NSString *rawVersionString = YTAVSGetRawVersionStringForIndex((int)i);

        [rows addObject:YTAVSMakeVersionPickerRow(displayTitle,
                                                  (NSInteger)i,
                                                  rawVersionString,
                                                  settingsViewController)];
    }

    return rows.copy;
}

static YTSettingsViewController *YTAVSResolveSettingsViewController(id manager) {
    YTSettingsViewController *settingsViewController = nil;

    @try {
        settingsViewController = [manager valueForKey:@"_dataDelegate"];
    } @catch (id ex) {}

    if (!settingsViewController) {
        @try {
            settingsViewController = [manager valueForKey:@"_settingsViewControllerDelegate"];
        } @catch (id ex) {}
    }

    return settingsViewController;
}

static void YTAVSApplySectionItems(YTSettingsViewController *settingsViewController,
                                   NSMutableArray<YTSettingsSectionItem *> *sectionItems) {
    if ([settingsViewController respondsToSelector:@selector(setSectionItems:forCategory:title:icon:titleDescription:headerHidden:)]) {
        YTIIcon *icon = [%c(YTIIcon) new];
        icon.iconType = YT_LOCATION_ON;

        [settingsViewController setSectionItems:sectionItems
                                    forCategory:YTAppVersionSpooferSection
                                          title:@"App Version Spoofer"
                                           icon:icon
                               titleDescription:nil
                                   headerHidden:NO];
    } else {
        [settingsViewController setSectionItems:sectionItems
                                    forCategory:YTAppVersionSpooferSection
                                          title:@"App Version Spoofer"
                               titleDescription:nil
                                   headerHidden:NO];
    }
}

@interface NSObject (YTAppVersionSpooferSettings)
- (void)reloadData;
- (void)pushViewController:(UIViewController *)viewController;
- (void)setSectionItems:(NSMutableArray<YTSettingsSectionItem *> *)sectionItems
            forCategory:(NSInteger)category
                  title:(NSString *)title
                   icon:(id)icon
       titleDescription:(NSString *)titleDescription
           headerHidden:(BOOL)headerHidden;
- (void)setSectionItems:(NSMutableArray<YTSettingsSectionItem *> *)sectionItems
            forCategory:(NSInteger)category
                  title:(NSString *)title
       titleDescription:(NSString *)titleDescription
           headerHidden:(BOOL)headerHidden;
@end

@interface YTSettingsSectionItemManager (YTAppVersionSpoofer)
- (void)updateYTAppVersionSpooferSectionWithEntry:(id)entry;
@end

%ctor {
    %init;
}

%hook YTAppSettingsPresentationData

+ (NSArray<NSNumber *> *)settingsCategoryOrder {
    NSArray<NSNumber *> *order = %orig;
    if (!order) {
        return @[@(YTAppVersionSpooferSection)];
    }

    NSMutableArray<NSNumber *> *mutableOrder = order.mutableCopy;
    if ([mutableOrder containsObject:@(YTAppVersionSpooferSection)]) {
        return mutableOrder.copy;
    }

    NSUInteger insertIndex = [order indexOfObject:@(1)];
    if (insertIndex != NSNotFound) {
        [mutableOrder insertObject:@(YTAppVersionSpooferSection) atIndex:insertIndex + 1];
    } else {
        [mutableOrder addObject:@(YTAppVersionSpooferSection)];
    }

    return mutableOrder.copy;
}

%end

%hook YTSettingsGroupData

- (NSArray<NSNumber *> *)orderedCategories {
    if (self.type != 1 || class_getClassMethod(objc_getClass("YTSettingsGroupData"), @selector(tweaks))) {
        return %orig;
    }

    NSArray *original = %orig;
    NSMutableArray *mutableCategories = original ? original.mutableCopy : [NSMutableArray array];
    if (![mutableCategories containsObject:@(YTAppVersionSpooferSection)]) {
        [mutableCategories insertObject:@(YTAppVersionSpooferSection) atIndex:0];
    }

    return mutableCategories.copy;
}

%end

%hook YTSettingsSectionItemManager

%new(v@:@)
- (void)updateYTAppVersionSpooferSectionWithEntry:(id)entry {
    (void)entry;

    YTSettingsViewController *settingsViewController = YTAVSResolveSettingsViewController(self);
    if (!settingsViewController) {
        return;
    }

    NSMutableArray<YTSettingsSectionItem *> *sectionItems = [NSMutableArray array];

    YTAVSAddSectionHeader(sectionItems, @"App Version Spoofer");

    [sectionItems addObject:YTAVSMakeSwitchItem(YTAVSLocalizedText(@"APP_VERSION_SPOOFER"),
                                                YTAVSLocalizedText(@"APP_VERSION_SPOOFER_DESC"),
                                                @"enableVersionSpoofer_enabled")];

    YTSettingsSectionItem *versionSpoofer = [%c(YTSettingsSectionItem)
        itemWithTitle:YTAVSLocalizedText(@"VERSION_SPOOFER_TITLE")
        accessibilityIdentifier:nil
        detailTextBlock:^NSString *() {
            return YTAVSEffectiveSelectedDisplayTitle();
        }
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
            NSArray<YTSettingsSectionItem *> *rows = YTAVSMakeVersionPickerRows(settingsViewController);

            YTSettingsPickerViewController *picker =
                [[%c(YTSettingsPickerViewController) alloc]
                    initWithNavTitle:YTAVSLocalizedText(@"VERSION_SPOOFER_TITLE")
                    pickerSectionTitle:nil
                    rows:rows
                    selectedItemIndex:YTAVSEffectiveSelectedVersionIndex()
                    parentResponder:settingsViewController];

            [settingsViewController pushViewController:picker];
            return YES;
        }];
    [sectionItems addObject:versionSpoofer];

    YTSettingsSectionItem *versionItem = [%c(YTSettingsSectionItem)
        itemWithTitle:YTAVSLocalizedText(@"TWEAK_VERSION")
        accessibilityIdentifier:nil
        detailTextBlock:^NSString *() {
            return YTAVSVersionLabel();
        }
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
            return YES;
        }];
    [sectionItems addObject:versionItem];

    YTAVSApplySectionItems(settingsViewController, sectionItems);
}

- (void)updateSectionForCategory:(NSUInteger)category withEntry:(id)entry {
    if (category == YTAppVersionSpooferSection) {
        [self updateYTAppVersionSpooferSectionWithEntry:entry];
        return;
    }

    %orig;
}

%end
