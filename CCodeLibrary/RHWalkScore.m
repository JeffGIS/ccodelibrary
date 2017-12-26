//  RHWalkScore.m
//  CCodeLibrary

#import "RHWalkScore.h"
#import "GSSiDefs.h"

typedef NS_ENUM(NSInteger, WSStatus)
{
    WSStatusOK=1,
    WSStatusNotAvailable=2,
    WSStatusInvalidLatLon=30,
    WSStatusInternalError=31,
    WSStatusInvalidApiKey=40,
    WSStatusQuotaExceeded=41,
    WSStatusBlocked=42,
};

@interface RHWalkScore ()

@property (nonatomic, weak) id<RHWalkScoreDelegate> delegate;
@property (nonatomic) NSURLSession *session;
@property int walkScore, transitScore, bikeScore, lastUpdate;
@property (nonatomic) NSString *walkDescription, *transitDescription, *bikeDescription, *url;

@end

@implementation RHWalkScore

+ (instancetype)walkScoreWithDelegate:(id<RHWalkScoreDelegate>)delegate
{
    RHWalkScore *ws = RHWalkScore.new;
    ws.delegate = delegate;
    ws.session = NSURLSession.sharedSession;
    return ws;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"WALK:{SCORE:%i, DESCRIPTION:\"%@\"}; "
            "TRANSIT:{SCORE:%i, DESCRIPTION:\"%@\"}; BIKE:{SCORE:%i, DESCRIPTION:\"%@\"}; "
            "UPDATED:%i; URL:%@",
            _walkScore, _walkDescription, _transitScore, _transitDescription,
            _bikeScore, _bikeDescription, _lastUpdate, _url];
}

- (void)getWalkScoreForAddress:(NSString *)address
                          city:(NSString *)city
                         state:(NSString *)state
                           zip:(int)zip
                           lat:(float)lat
                           lon:(float)lon
{
    if (_delegate && [_delegate respondsToSelector:@selector(walkScoreDidReturnItem:)] &&
        [_delegate respondsToSelector:@selector(walkScoreDidReceiveError:)])
    {
        if (address && address.length && city && city.length && state && state.length && zip && lat && lon)
        {
            NSString *fullAddress = [NSString stringWithFormat:@"%@ %@ %@ %i", address, city, state, zip];
            fullAddress = [fullAddress stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            NSString *urlString = [NSString stringWithFormat:@"http://api.walkscore.com/score?format=json&"
                                   "address=%@&lat=%f&lon=%f&transit=1&bike=1&wsapikey=%@",
                                   fullAddress, lat, lon, WALKSCORE_API_KEY];
            
            NSURL *url = [[NSURL alloc] initWithString:urlString];
            
            [[_session dataTaskWithURL:(NSURL *)url
                     completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
              {
                  if (error)
                      [_delegate walkScoreDidReceiveError:error.localizedDescription];
                  
                  else
                  {
                      NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data
                                                                           options:kNilOptions
                                                                             error:&error];
                      
                      if (error)
                          [_delegate walkScoreDidReceiveError:error.localizedDescription];
                      
                      else
                      {
                          WSStatus status = [[json objectForKey:@"status"] intValue];
                          NSString *errorString = nil;
                          
                          switch (status)
                          {
                              case WSStatusOK:{
                                  id item = [json objectForKey:@"walkscore"];
                                  
                                  if (!item || [item isKindOfClass:NSNull.class])
                                  {
                                      _walkScore = RH_SCORE_NONE;
                                      _walkDescription = RH_DESCRIPTION_NONE;
                                  }
                                  
                                  else
                                  {
                                      _walkScore = [(NSString *)item intValue];
                                      item = [json objectForKey:@"description"];
                                      
                                      if (!item || [item isKindOfClass:NSNull.class])
                                      {
                                          _walkDescription = RH_DESCRIPTION_NONE;
                                      }
                                      
                                      else
                                          _walkDescription = (NSString *)item;
                                  }
                                  
                                  item = [[json objectForKey:@"transit"] objectForKey:@"score"];
                                  
                                  if (!item || [item isKindOfClass:NSNull.class])
                                  {
                                      _transitScore = RH_SCORE_NONE;
                                      _transitDescription = RH_DESCRIPTION_NONE;
                                  }
                                  
                                  else
                                  {
                                      _transitScore = [(NSString *)item intValue];
                                      item = [[json objectForKey:@"transit"] objectForKey:@"description"];
                                      
                                      if (!item || [item isKindOfClass:NSNull.class])
                                      {
                                          _transitDescription = RH_DESCRIPTION_NONE;
                                      }
                                      
                                      else
                                          _transitDescription = (NSString *)item;
                                  }
                                  
                                  item = [[json objectForKey:@"bike"] objectForKey:@"score"];
                                  
                                  if (!item || [item isKindOfClass:NSNull.class])
                                  {
                                      _bikeScore = RH_SCORE_NONE;
                                      _bikeDescription = RH_DESCRIPTION_NONE;
                                  }
                                  
                                  else
                                  {
                                      _bikeScore = [(NSString *)item intValue];
                                      item = [[json objectForKey:@"bike"] objectForKey:@"description"];
                                      
                                      if (!item || [item isKindOfClass:NSNull.class])
                                      {
                                          _bikeDescription = RH_DESCRIPTION_NONE;
                                      }
                                      
                                      else
                                          _bikeDescription = (NSString *)item;
                                  }
                                  
                                  item = [json objectForKey:@"updated"];
                                  
                                  if (!item || [item isKindOfClass:NSNull.class])
                                  {
                                      _lastUpdate = RH_SCORE_NONE;
                                  }
                                  
                                  else
                                  {
                                      NSString *update = (NSString *)item;
                                      NSDateFormatter *formatter = NSDateFormatter.new;
                                      [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSSSSS"];
                                      NSDate *date = [formatter dateFromString:update];
                                      _lastUpdate = date.timeIntervalSince1970;
                                  }
                                  
                                  item = [json objectForKey:@"ws_link"];
                                  
                                  if (!item || [item isKindOfClass:NSNull.class])
                                  {
                                      _url = RH_DESCRIPTION_NONE;
                                  }
                                  
                                  else
                                      _url = [(NSString *)item stringByReplacingOccurrencesOfString:@" " withString:@""];
                                  
                                  [_delegate walkScoreDidReturnItem:self];
                                  break;}
                              case WSStatusNotAvailable:
                                  errorString = @"Walk Score not currently available for this address";
                                  break;
                              case WSStatusInvalidLatLon:
                                  errorString = @"Invalid latitude or longitude value";
                                  break;
                              case WSStatusInternalError:
                                  errorString = @"Internal error on remote server";
                                  break;
                              case WSStatusInvalidApiKey:
                                  errorString = @"Invalid API key";
                                  break;
                              case WSStatusQuotaExceeded:
                                  errorString = @"Daily API quota exceeded";
                                  break;
                              case WSStatusBlocked:
                                  errorString = @"Blocked by remote server";
                                  break;
                              default:
                                  errorString = @"Undefined status value";
                                  break;
                          }
                          
                          if (errorString)
                              [_delegate walkScoreDidReceiveError:errorString];
                      }
                  }
              }] resume];
        }
        
        else
            NSLog(@"RHWalkScore ERROR: one or more of the parameters is not valid.");
    }
    
    else
        NSLog(@"RHWalkScore ERROR: a delegate must implement all methods in protocol.");
}

@end
