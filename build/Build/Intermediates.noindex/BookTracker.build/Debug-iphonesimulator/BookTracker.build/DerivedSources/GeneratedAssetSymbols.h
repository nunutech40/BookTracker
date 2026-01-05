#import <Foundation/Foundation.h>

#if __has_attribute(swift_private)
#define AC_SWIFT_PRIVATE __attribute__((swift_private))
#else
#define AC_SWIFT_PRIVATE
#endif

/// The "OnBoarding1" asset catalog image resource.
static NSString * const ACImageNameOnBoarding1 AC_SWIFT_PRIVATE = @"OnBoarding1";

/// The "OnBoarding2" asset catalog image resource.
static NSString * const ACImageNameOnBoarding2 AC_SWIFT_PRIVATE = @"OnBoarding2";

/// The "OnBoarding3" asset catalog image resource.
static NSString * const ACImageNameOnBoarding3 AC_SWIFT_PRIVATE = @"OnBoarding3";

/// The "OnBoarding4" asset catalog image resource.
static NSString * const ACImageNameOnBoarding4 AC_SWIFT_PRIVATE = @"OnBoarding4";

#undef AC_SWIFT_PRIVATE
