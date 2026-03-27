#import <objc/runtime.h>
#import "YouTubeHeader/YTIIcon.h"
#import "YouTubeHeader/YTSettingsGroupData.h"
#import "YouTubeHeader/YTSettingsViewController.h"
#import "YouTubeHeader/YTSearchableSettingsViewController.h"
#import "YouTubeHeader/YTSettingsSectionItem.h"
#import "YouTubeHeader/YTSettingsSectionItemManager.h"
#import "YouTubeHeader/YTUIUtils.h"
#import "YouTubeHeader/YTSettingsPickerViewController.h"
#import "Tweak.h"

static int appVersionSpoofer() {
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"versionSpoofer"];
}

#define SECTION_HEADER(s) [sectionItems addObject:[%c(YTSettingsSectionItem) itemWithTitle:@"\t" titleDescription:[s uppercaseString] accessibilityIdentifier:nil detailTextBlock:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger sectionItemIndex) { return NO; }]]

#define SPOOFER_VERSION(version, index) \
    [YTSettingsSectionItemClass checkmarkItemWithTitle:version titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) { \
        [[NSUserDefaults standardUserDefaults] setInteger:index forKey:@"versionSpoofer"]; \
        [settingsViewController reloadData]; \
        return YES; \
    }]

#define SWITCH(t, d, k) [sectionItems addObject:[YTSettingsSectionItemClass switchItemWithTitle:t titleDescription:d accessibilityIdentifier:nil switchOn:IS_ENABLED(k) switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {[[NSUserDefaults standardUserDefaults] setBool:enabled forKey:k];return YES;} settingItemId:0]]

#define LOC(x) [tweakBundle localizedStringForKey:x value:nil table:nil]

static const NSInteger YTAppVersionSpooferSection = 'yavs';

@interface NSObject (YTAppVersionSpooferSettings)
- (void)reloadData;
- (void)pushViewController:(UIViewController *)viewController;
- (void)setSectionItems:(NSArray *)sectionItems
            forCategory:(NSInteger)category
                  title:(NSString *)title
                   icon:(id)icon
       titleDescription:(NSString *)titleDescription
           headerHidden:(BOOL)headerHidden;
- (void)setSectionItems:(NSArray *)sectionItems
            forCategory:(NSInteger)category
                  title:(NSString *)title
       titleDescription:(NSString *)titleDescription
           headerHidden:(BOOL)headerHidden;
@end

@interface YTSettingsSectionItemManager (YTAppVersionSpoofer)
- (void)updateYTAppVersionSpooferSectionWithEntry:(id)entry;
@end

NSBundle *tweakBundle;

extern NSBundle *YTAppVersionSpooferBundle();

NSBundle *YTAppVersionSpooferBundle() {
    static NSBundle *bundle = nil;
    static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
        NSString *tweakBundlePath = [[NSBundle mainBundle] pathForResource:@"YTAppVersionSpoofer" ofType:@"bundle"];
        if (tweakBundlePath)
            bundle = [NSBundle bundleWithPath:tweakBundlePath];
        else
            bundle = [NSBundle bundleWithPath:ROOT_PATH_NS(@"/Library/Application Support/YTAppVersionSpoofer.bundle")];
    });
    return bundle;
}

%ctor {
    tweakBundle = YTAppVersionSpooferBundle();
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
    YTSettingsViewController *settingsViewController = nil;

    @try {
        settingsViewController = [self valueForKey:@"_dataDelegate"];
    } @catch (id ex) {}

    if (!settingsViewController) {
        @try {
            settingsViewController = [self valueForKey:@"_settingsViewControllerDelegate"];
        } @catch (id ex) {}
    }

    if (!settingsViewController) {
        return;
    }

    NSMutableArray<YTSettingsSectionItem *> *sectionItems = [NSMutableArray array];
    Class YTSettingsSectionItemClass = %c(YTSettingsSectionItem);

    SECTION_HEADER(@"App Version Spoofer");

    SWITCH(LOC(@"APP_VERSION_SPOOFER"), LOC(@"APP_VERSION_SPOOFER_DESC"), @"enableVersionSpoofer_enabled");

    YTSettingsSectionItem *versionSpoofer = [%c(YTSettingsSectionItem)
        itemWithTitle:LOC(@"VERSION_SPOOFER_TITLE")
        accessibilityIdentifier:nil
        detailTextBlock:^NSString *() {
            switch (appVersionSpoofer()) {
                case 1:
                    return @"v19.49.5";
                case 2:
                    return @"v19.49.3";
                case 3:
                    return @"v19.47.7";
                case 4:
                    return @"v19.46.3";
                case 5:
                    return @"v19.45.4";
                case 6:
                    return @"v19.44.4";
                case 7:
                    return @"v19.43.2";
                case 8:
                    return @"v19.42.1";
                case 9:
                    return @"v19.41.3";
                case 10:
                    return @"v19.40.4";
                case 11:
                    return @"v19.39.1";
                case 12:
                    return @"v19.38.2";
                case 13:
                    return @"v19.37.2";
                case 14:
                    return @"v19.36.1";
                case 15:
                    return @"v19.35.3";
                case 16:
                    return @"v19.34.2";
                case 17:
                    return @"v19.33.2";
                case 18:
                    return @"v19.32.8";
                case 19:
                    return @"v19.32.6";
                case 20:
                    return @"v19.31.4";
                case 21:
                    return @"v19.30.2";
                case 22:
                    return @"v19.29.1";
                case 23:
                    return @"v19.28.1";
                case 24:
                    return @"v19.26.5";
                case 25:
                    return @"v19.25.4";
                case 26:
                    return @"v19.25.3";
                case 27:
                    return @"v19.24.3";
                case 28:
                    return @"v19.24.2";
                case 29:
                    return @"v19.23.3";
                case 30:
                    return @"v19.22.6";
                case 31:
                    return @"v19.22.3";
                case 32:
                    return @"v19.21.3";
                case 33:
                    return @"v19.21.2";
                case 34:
                    return @"v19.20.2";
                case 35:
                    return @"v19.19.7";
                case 36:
                    return @"v19.19.5";
                case 37:
                    return @"v19.18.2";
                case 38:
                    return @"v19.17.2";
                case 39:
                    return @"v19.16.3";
                case 40:
                    return @"v19.15.1";
                case 41:
                    return @"v19.14.3";
                case 42:
                    return @"v19.14.2";
                case 43:
                    return @"v19.13.1";
                case 44:
                    return @"v19.12.3";
                case 45:
                    return @"v19.10.7";
                case 46:
                    return @"v19.10.6";
                case 47:
                    return @"v19.10.5";
                case 48:
                    return @"v19.09.4";
                case 49:
                    return @"v19.09.3";
                case 50:
                    return @"v19.08.2";
                case 51:
                    return @"v19.07.5";
                case 52:
                    return @"v19.07.4";
                case 53:
                    return @"v19.06.2";
                case 54:
                    return @"v19.05.5";
                case 55:
                    return @"v19.05.3";
                case 56:
                    return @"v19.04.3";
                case 57:
                    return @"v19.03.2";
                case 58:
                    return @"v19.02.1";
                case 59:
                    return @"v19.01.1";
                case 60:
                    return @"v18.49.3";
                case 61:
                    return @"v18.48.3";
                case 62:
                    return @"v18.46.3";
                case 63:
                    return @"v18.45.2";
                case 64:
                    return @"v18.44.3";
                case 65:
                    return @"v18.43.4";
                case 66:
                    return @"v18.41.5";
                case 67:
                    return @"v18.41.3";
                case 68:
                    return @"v18.41.2";
                case 69:
                    return @"v18.40.1";
                case 70:
                    return @"v18.39.1";
                case 71:
                    return @"v18.38.2";
                case 72:
                    return @"v18.35.4";
                case 73:
                    return @"v18.34.5 (Deprecated)";
                case 74:
                    return @"v18.33.3 (Deprecated)";
                case 75:
                    return @"v18.33.2 (Deprecated)";
                case 76:
                    return @"v18.32.2 (Deprecated)";
                case 77:
                    return @"v18.31.3 (Deprecated)";
                case 78:
                    return @"v18.30.7 (Deprecated)";
                case 79:
                    return @"v18.30.6 (Deprecated)";
                case 80:
                    return @"v18.29.1 (Deprecated)";
                case 81:
                    return @"v18.28.3 (Deprecated)";
                case 82:
                    return @"v18.27.3 (Deprecated)";
                case 83:
                    return @"v18.25.1 (Deprecated)";
                case 84:
                    return @"v18.23.3 (Deprecated)";
                case 85:
                    return @"v18.22.9 (Deprecated)";
                case 86:
                    return @"v18.21.3 (Deprecated)";
                case 87:
                    return @"v18.20.3 (Deprecated)";
                case 88:
                    return @"v18.19.1 (Deprecated)";
                case 89:
                    return @"v18.18.2 (Deprecated)";
                case 90:
                    return @"v18.17.2 (Deprecated)";
                case 91:
                    return @"v18.16.2 (Deprecated)";
                case 92:
                    return @"v18.15.1 (Deprecated)";
                case 93:
                    return @"v18.14.1 (Deprecated)";
                case 94:
                    return @"v18.13.4 (Deprecated)";
                case 95:
                    return @"v18.12.2 (Deprecated)";
                case 96:
                    return @"v18.11.2 (Deprecated)";
                case 97:
                    return @"v18.10.1 (Deprecated)";
                case 98:
                    return @"v18.09.4 (Deprecated)";
                case 99:
                    return @"v18.08.1 (Deprecated)";
                case 100:
                    return @"v18.07.5 (Deprecated)";
                case 101:
                    return @"v18.05.2 (Deprecated)";
                case 102:
                    return @"v18.04.3 (Deprecated)";
                case 103:
                    return @"v18.03.3 (Deprecated)";
                case 104:
                    return @"v18.02.03 (Deprecated)";
                case 105:
                    return @"v18.01.6 (Deprecated)";
                case 106:
                    return @"v18.01.4 (Deprecated)";
                case 107:
                    return @"v18.01.2 (Deprecated)";
                case 108:
                    return @"v17.49.6 (Deprecated)";
                case 109:
                    return @"v17.49.4 (Deprecated)";
                case 110:
                    return @"v17.46.4 (Deprecated)";
                case 111:
                    return @"v17.45.1 (Deprecated)";
                case 112:
                    return @"v17.44.4 (Deprecated)";
                case 113:
                    return @"v17.43.1 (Deprecated)";
                case 114:
                    return @"v17.42.7 (Deprecated)";
                case 115:
                    return @"v17.42.6 (Deprecated)";
                case 116:
                    return @"v17.41.2 (Deprecated)";
                case 117:
                    return @"v17.40.5 (Deprecated)";
                case 118:
                    return @"v17.39.4 (Deprecated)";
                case 119:
                    return @"v17.38.10 (Deprecated)";
                case 120:
                    return @"v17.38.9 (Deprecated)";
                case 121:
                    return @"v17.37.2 (Deprecated)";
                case 122:
                    return @"v17.36.4 (Deprecated)";
                case 123:
                    return @"v17.36.3 (Deprecated)";
                case 124:
                    return @"v17.35.3 (Deprecated)";
                case 125:
                    return @"v17.34.3 (Deprecated)";
                case 126:
                    return @"v17.33.2 (Deprecated)";
                case 0:
                default:
                    return @"v19.49.7";
            }
        }
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
            NSArray <YTSettingsSectionItem *> *rows = @[
                SPOOFER_VERSION(@"v19.49.7", 0),
                SPOOFER_VERSION(@"v19.49.5", 1),
                SPOOFER_VERSION(@"v19.49.3", 2),
                SPOOFER_VERSION(@"v19.47.7", 3),
                SPOOFER_VERSION(@"v19.46.3", 4),
                SPOOFER_VERSION(@"v19.45.4", 5),
                SPOOFER_VERSION(@"v19.44.4", 6),
                SPOOFER_VERSION(@"v19.43.2", 7),
                SPOOFER_VERSION(@"v19.42.1", 8),
                SPOOFER_VERSION(@"v19.41.3", 9),
                SPOOFER_VERSION(@"v19.40.4", 10),
                SPOOFER_VERSION(@"v19.39.1", 11),
                SPOOFER_VERSION(@"v19.38.2", 12),
                SPOOFER_VERSION(@"v19.37.2", 13),
                SPOOFER_VERSION(@"v19.36.1", 14),
                SPOOFER_VERSION(@"v19.35.3", 15),
                SPOOFER_VERSION(@"v19.34.2", 16),
                SPOOFER_VERSION(@"v19.33.2", 17),
                SPOOFER_VERSION(@"v19.32.8", 18),
                SPOOFER_VERSION(@"v19.32.6", 19),
                SPOOFER_VERSION(@"v19.31.4", 20),
                SPOOFER_VERSION(@"v19.30.2", 21),
                SPOOFER_VERSION(@"v19.29.1", 22),
                SPOOFER_VERSION(@"v19.28.1", 23),
                SPOOFER_VERSION(@"v19.26.5", 24),
                SPOOFER_VERSION(@"v19.25.4", 25),
                SPOOFER_VERSION(@"v19.25.3", 26),
                SPOOFER_VERSION(@"v19.24.3", 27),
                SPOOFER_VERSION(@"v19.24.2", 28),
                SPOOFER_VERSION(@"v19.23.3", 29),
                SPOOFER_VERSION(@"v19.22.6", 30),
                SPOOFER_VERSION(@"v19.22.3", 31),
                SPOOFER_VERSION(@"v19.21.3", 32),
                SPOOFER_VERSION(@"v19.21.2", 33),
                SPOOFER_VERSION(@"v19.20.2", 34),
                SPOOFER_VERSION(@"v19.19.7", 35),
                SPOOFER_VERSION(@"v19.19.5", 36),
                SPOOFER_VERSION(@"v19.18.2", 37),
                SPOOFER_VERSION(@"v19.17.2", 38),
                SPOOFER_VERSION(@"v19.16.3", 39),
                SPOOFER_VERSION(@"v19.15.1", 40),
                SPOOFER_VERSION(@"v19.14.3", 41),
                SPOOFER_VERSION(@"v19.14.2", 42),
                SPOOFER_VERSION(@"v19.13.1", 43),
                SPOOFER_VERSION(@"v19.12.3", 44),
                SPOOFER_VERSION(@"v19.10.7", 45),
                SPOOFER_VERSION(@"v19.10.6", 46),
                SPOOFER_VERSION(@"v19.10.5", 47),
                SPOOFER_VERSION(@"v19.09.4", 48),
                SPOOFER_VERSION(@"v19.09.3", 49),
                SPOOFER_VERSION(@"v19.08.2", 50),
                SPOOFER_VERSION(@"v19.07.5", 51),
                SPOOFER_VERSION(@"v19.07.4", 52),
                SPOOFER_VERSION(@"v19.06.2", 53),
                SPOOFER_VERSION(@"v19.05.5", 54),
                SPOOFER_VERSION(@"v19.05.3", 55),
                SPOOFER_VERSION(@"v19.04.3", 56),
                SPOOFER_VERSION(@"v19.03.2", 57),
                SPOOFER_VERSION(@"v19.02.1", 58),
                SPOOFER_VERSION(@"v19.01.1", 59),
                SPOOFER_VERSION(@"v18.49.3", 60),
                SPOOFER_VERSION(@"v18.48.3", 61),
                SPOOFER_VERSION(@"v18.46.3", 62),
                SPOOFER_VERSION(@"v18.45.2", 63),
                SPOOFER_VERSION(@"v18.44.3", 64),
                SPOOFER_VERSION(@"v18.43.4", 65),
                SPOOFER_VERSION(@"v18.41.5", 66),
                SPOOFER_VERSION(@"v18.41.3", 67),
                SPOOFER_VERSION(@"v18.41.2", 68),
                SPOOFER_VERSION(@"v18.40.1", 69),
                SPOOFER_VERSION(@"v18.39.1", 70),
                SPOOFER_VERSION(@"v18.38.2", 71),
                SPOOFER_VERSION(@"v18.35.4", 72),
                SPOOFER_VERSION(@"v18.34.5", 73),
                SPOOFER_VERSION(@"v18.33.3", 74),
                SPOOFER_VERSION(@"v18.33.2", 75),
                SPOOFER_VERSION(@"v18.32.2", 76),
                SPOOFER_VERSION(@"v18.31.3", 77),
                SPOOFER_VERSION(@"v18.30.7", 78),
                SPOOFER_VERSION(@"v18.30.6", 79),
                SPOOFER_VERSION(@"v18.29.1", 80),
                SPOOFER_VERSION(@"v18.28.3", 81),
                SPOOFER_VERSION(@"v18.27.3", 82),
                SPOOFER_VERSION(@"v18.25.1", 83),
                SPOOFER_VERSION(@"v18.23.3", 84),
                SPOOFER_VERSION(@"v18.22.9", 85),
                SPOOFER_VERSION(@"v18.21.3", 86),
                SPOOFER_VERSION(@"v18.20.3", 87),
                SPOOFER_VERSION(@"v18.19.1", 88),
                SPOOFER_VERSION(@"v18.18.2", 89),
                SPOOFER_VERSION(@"v18.17.2", 90),
                SPOOFER_VERSION(@"v18.16.2", 91),
                SPOOFER_VERSION(@"v18.15.1", 92),
                SPOOFER_VERSION(@"v18.14.1", 93),
                SPOOFER_VERSION(@"v18.13.4", 94),
                SPOOFER_VERSION(@"v18.12.2", 95),
                SPOOFER_VERSION(@"v18.11.2", 96),
                SPOOFER_VERSION(@"v18.10.1", 97),
                SPOOFER_VERSION(@"v18.09.4", 98),
                SPOOFER_VERSION(@"v18.08.1", 99),
                SPOOFER_VERSION(@"v18.07.5", 100),
                SPOOFER_VERSION(@"v18.05.2", 101),
                SPOOFER_VERSION(@"v18.04.3", 102),
                SPOOFER_VERSION(@"v18.03.3", 103),
                SPOOFER_VERSION(@"v18.02.03", 104),
                SPOOFER_VERSION(@"v18.01.6", 105),
                SPOOFER_VERSION(@"v18.01.4", 106),
                SPOOFER_VERSION(@"v18.01.2", 107),
                SPOOFER_VERSION(@"v17.49.6", 108),
                SPOOFER_VERSION(@"v17.49.4", 109),
                SPOOFER_VERSION(@"v17.46.4", 110),
                SPOOFER_VERSION(@"v17.45.1", 111),
                SPOOFER_VERSION(@"v17.44.4", 112),
                SPOOFER_VERSION(@"v17.43.1", 113),
                SPOOFER_VERSION(@"v17.42.7", 114),
                SPOOFER_VERSION(@"v17.42.6", 115),
                SPOOFER_VERSION(@"v17.41.2", 116),
                SPOOFER_VERSION(@"v17.40.5", 117),
                SPOOFER_VERSION(@"v17.39.4", 118),
                SPOOFER_VERSION(@"v17.38.10", 119),
                SPOOFER_VERSION(@"v17.38.9", 120),
                SPOOFER_VERSION(@"v17.37.2", 121),
                SPOOFER_VERSION(@"v17.36.4", 122),
                SPOOFER_VERSION(@"v17.36.3", 123),
                SPOOFER_VERSION(@"v17.35.3", 124),
                SPOOFER_VERSION(@"v17.34.3", 125),
                SPOOFER_VERSION(@"v17.33.2", 126)
            ];
            YTSettingsPickerViewController *picker = [[%c(YTSettingsPickerViewController) alloc] initWithNavTitle:LOC(@"VERSION_SPOOFER_TITLE") pickerSectionTitle:nil rows:rows selectedItemIndex:appVersionSpoofer() parentResponder:settingsViewController];
            [settingsViewController pushViewController:picker];
            return YES;
        }
    ];
    [sectionItems addObject:versionSpoofer];

    if ([settingsViewController respondsToSelector:@selector(setSectionItems:forCategory:title:icon:titleDescription:headerHidden:)]) {
        YTIIcon *icon = [%c(YTIIcon) new];
		icon.iconType = YT_SETTINGS;

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

- (void)updateSectionForCategory:(NSUInteger)category withEntry:(id)entry {
    if (category == YTAppVersionSpooferSection) {
        [self updateYTAppVersionSpooferSectionWithEntry:entry];
        return;
    }

    %orig;
}

%end
