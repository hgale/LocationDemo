#import "LocationManager.h"

#import <CoreLocation/CoreLocation.h>

#import <React/RCTLog.h>
#import <UIKit/UIKit.h>

@interface LocationManager()<CLLocationManagerDelegate>
@property (nonatomic, strong) CLLocationManager *locationManager;
@end

@implementation LocationManager

RCT_EXPORT_MODULE();

- (instancetype)init
{
  if (self = [super init])
  {
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.pausesLocationUpdatesAutomatically = NO;
    self.locationManager.allowsBackgroundLocationUpdates = YES;
    self.locationManager.delegate=self;
    self.locationManager.desiredAccuracy=kCLLocationAccuracyBest;
    
    if([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)])
    {
      [self.locationManager requestAlwaysAuthorization];
    }
  }
  return self;
}

- (NSArray<NSString *> *)supportedEvents
{
  return @[@"LocationUpdated"];
}

#pragma - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
  if(status==kCLAuthorizationStatusAuthorizedAlways)
  {
    [self.locationManager startUpdatingLocation];
  }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
  CLLocation *currentLocation=locations.lastObject;
  NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
  [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS"];
  NSString *dateString = [dateFormat stringFromDate:[NSDate date]];
  
  NSDictionary *params =  @{@"lat":@(currentLocation.coordinate.latitude), @"long":@(currentLocation.coordinate.longitude), @"time":dateString};
  NSError *error = nil;
  NSData *data = [NSJSONSerialization dataWithJSONObject:params
                                                 options:kNilOptions error:&error];
  if (!data || error) {
    return;
  }
  [self sendEventWithName:@"LocationUpdated" body:params];
}

@end
