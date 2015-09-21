#import "UIImage+SPImageLoader.h"
#import <objc/runtime.h>

@implementation UIImage (SPImageLoader)

+ (void)load {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    @autoreleasepool {
      image_load_swizzleSelector(object_getClass((id)self), @selector(imageNamed:), @selector(localize_imageNamed:));
      image_load_swizzleSelector(object_getClass((id)self), @selector(imageWithData:), @selector(localize_imageWithData:));
      image_load_swizzleSelector(object_getClass((id)self), @selector(imageWithData:scale:), @selector(localize_imageWithData:scale:));
      image_load_swizzleSelector(object_getClass((id)self), @selector(imageWithContentsOfFile:), @selector(localize_imageWithContentsOfFile:));
      image_load_swizzleSelector(self, @selector(initWithContentsOfFile:), @selector(localize_initWithContentsOfFile:));
      image_load_swizzleSelector(self, @selector(initWithData:), @selector(localize_initWithData:));
      image_load_swizzleSelector(self, @selector(initWithData:scale:), @selector(localize_initWithData:scale:));
    }
  });
}

static inline void image_load_swizzleSelector(Class class, SEL originalSelector, SEL swizzledSelector) {
  Method originalMethod = class_getInstanceMethod(class, originalSelector);
  Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
  if (class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))) {
    class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
  } else {
    method_exchangeImplementations(originalMethod, swizzledMethod);
  }
}


#pragma mark -

- (id)localize_initWithContentsOfFile:(NSString *)path __attribute__((objc_method_family(init))) {
  
  return [self localize_initWithContentsOfFile:path];
}

- (id)localize_initWithData:(NSData *)data __attribute__((objc_method_family(init))) {
  return [self localize_initWithData:data];
}

- (id)localize_initWithData:(NSData *)data
                      scale:(CGFloat)scale __attribute__((objc_method_family(init)))
{
  return [self localize_initWithData:data scale:scale];
}

#pragma mark Swizzled Methods

+ (UIImage *)localize_imageNamed:(NSString *)name __attribute__((objc_method_family(new))) {
  
  NSLocale *locale = [NSLocale currentLocale];
  NSString *countryCode = [locale objectForKey: NSLocaleLanguageCode];
  NSString *localizedName = name;

  localizedName = [NSString stringWithFormat:@"%@_%@", name, countryCode];
  
  UIImage *image = [self localize_imageNamed:localizedName];
  
  if(image == nil)
  {
    image = [self localize_imageNamed:name];
  }
  
  return image;
}

+ (UIImage *)localize_imageWithContentsOfFile:(NSString *)path __attribute__((objc_method_family(new))) {
  
  NSLocale *locale = [NSLocale currentLocale];
  NSString *countryCode = [locale objectForKey: NSLocaleLanguageCode];
  NSString *localizedPath = path;
  
  NSString* theFileName = [path stringByDeletingPathExtension];
  NSArray *fileExtension = [[path lastPathComponent] componentsSeparatedByString:@"."];
  
  localizedPath = [NSString stringWithFormat:@"%@_%@.", theFileName, countryCode];
  localizedPath = [localizedPath stringByAppendingString:fileExtension[1]];

  UIImage *image = [self localize_imageNamed:localizedPath];
  
  if(image != nil)
  {
    return [self localize_imageWithContentsOfFile:localizedPath];
  }
  
  return [self localize_imageWithContentsOfFile:path];
}

+ (UIImage *)localize_imageWithData:(NSData *)data __attribute__((objc_method_family(init))) {
  return [self localize_imageWithData:data];
}

+ (UIImage *)localize_imageWithData:(NSData *)data
                                  scale:(CGFloat)scale __attribute__((objc_method_family(init)))
{
  return [self localize_imageWithData:data scale:scale];
}


+(UIImage *) imageNamed:(NSString *)name andShouldCache:(BOOL) shouldCache
{
  UIImage *image = nil;
  
  if(shouldCache)
  {
    image = [UIImage imageNamed:name];
  }
  else
  {
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"png"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
      NSData *data = [[NSData alloc] initWithContentsOfFile:path options:NSDataReadingUncached error:nil];
      image = [UIImage imageWithData:data];
    }
  }
  
  if (image == nil) {
    return [UIImage imageNamed:name];
  }
  
  return image;
}


@end
