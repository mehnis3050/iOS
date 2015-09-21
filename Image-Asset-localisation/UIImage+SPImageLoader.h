
#import <UIKit/UIKit.h>

@interface UIImage (SPImageLoader)

+(UIImage *) imageNamed:(NSString *)name andShouldCache:(BOOL) shouldCache;

@end
