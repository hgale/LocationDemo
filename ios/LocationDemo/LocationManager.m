#import "LocationManager.h"

#import <CoreLocation/CoreLocation.h>

#import <React/RCTLog.h>
#import <UIKit/UIKit.h>

@interface LocationManager()<CLLocationManagerDelegate>

@property (nonatomic, strong) NSTimer *pollingTimer;
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *currentLocation;

@end

@implementation LocationManager

RCT_EXPORT_MODULE();

- (instancetype)init
{
  if (self = [super init])
  {
    self.session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.pausesLocationUpdatesAutomatically = NO;
    self.locationManager.allowsBackgroundLocationUpdates = YES;
    self.locationManager.delegate=self;
    self.locationManager.desiredAccuracy=kCLLocationAccuracyBest;
    
    if([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)])
    {
      [self.locationManager requestAlwaysAuthorization];
    }
    else
    {
      [self.locationManager startUpdatingLocation];
    }
  }
  return self;
}

RCT_EXPORT_METHOD(startPostingLocationTo:(NSString *)url everyInterval:(NSInteger)interval)
{
  if (!url || url.length == 0 || interval <= 0) {
    return;
  }
  
  self.url = [NSURL URLWithString:url];
  
  double seconds = interval / 1000.0;
  
  if (self.pollingTimer) {
    [self stopPostingLocation];
  }

  self.pollingTimer = [NSTimer scheduledTimerWithTimeInterval:seconds target:self selector:@selector(postLocation:) userInfo:nil repeats:YES];
}

- (dispatch_queue_t)methodQueue
{
  return dispatch_get_main_queue();
}

- (NSArray<NSString *> *)supportedEvents
{
  return @[@"LocationUpdated"];
}

RCT_EXPORT_METHOD(stopPostingLocation)
{
  [self.pollingTimer invalidate];
  self.pollingTimer = nil;
}

- (void)postLocation:(NSTimer *)timer
{
  if (!self.url && !self.currentLocation) {
    return;
  }

  NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:self.url];
  [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
  [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
  request.HTTPMethod = @"POST";

  NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
  [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS"];
  NSString *dateString = [dateFormat stringFromDate:[NSDate date]];
  
  NSDictionary *params =  @{@"lat":@(self.currentLocation.coordinate.latitude), @"long":@(self.currentLocation.coordinate.longitude), @"time":dateString};
  NSError *error = nil;
  NSData *data = [NSJSONSerialization dataWithJSONObject:params
                                                 options:kNilOptions error:&error];
  if (!data || error) {
    return;
  }
  
  [request setHTTPBody:data];
  NSURLSessionDataTask *postDataTask = [self.session dataTaskWithRequest:request
                                                       completionHandler:^(NSData *data, NSURLResponse *response, NSError *requestError) {
                                                         NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                                                         if (requestError || [httpResponse statusCode] != 200) {
                                                           return;
                                                         }
                                                         [self sendEventWithName:@"LocationUpdated" body:params];
                                                       }];
  
  [postDataTask resume];
  
  //[]
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
  self.currentLocation=locations.lastObject;
}

@end
