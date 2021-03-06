//
//  OMTrackMetadataConverter.m
//  OhMyAVFoundation
//
//  Created by 申屠云飞 on 2018/8/31.
//  Copyright © 2018年 styf. All rights reserved.
//

#import "OMTrackMetadataConverter.h"
#import "OMMetadataKeys.h"
@implementation OMTrackMetadataConverter
- (id)displayValueFromMetadataItem:(AVMetadataItem *)item {
    
    NSNumber *number = nil;
    NSNumber *count = nil;
    
    if ([item.value isKindOfClass:[NSString class]]) {                      // 1
        NSArray *components =
        [item.stringValue componentsSeparatedByString:@"/"];
        number = @([components[0] integerValue]);
        count = @([components[1] integerValue]);
    }
    else if ([item.value isKindOfClass:[NSData class]]) {                   // 2
        NSData *data = item.dataValue;
        if (data.length == 8) {
            uint16_t *values = (uint16_t *) [data bytes];
            if (values[1] > 0) {
                number = @(CFSwapInt16BigToHost(values[1]));                // 3
            }
            if (values[2] > 0) {
                count = @(CFSwapInt16BigToHost(values[2]));                 // 4
            }
        }
    }
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];           // 5
    [dict setObject:number ?: [NSNull null] forKey:THMetadataKeyTrackNumber];
    [dict setObject:count ?: [NSNull null] forKey:THMetadataKeyTrackCount];
    
    return dict;
}

- (AVMetadataItem *)metadataItemFromDisplayValue:(id)value
                                withMetadataItem:(AVMetadataItem *)item {
    
    AVMutableMetadataItem *metadataItem = [item mutableCopy];
    
    NSDictionary *trackData = (NSDictionary *)value;
    NSNumber *trackNumber = trackData[THMetadataKeyTrackNumber];
    NSNumber *trackCount = trackData[THMetadataKeyTrackCount];
    
    uint16_t values[4] = {0};                                                // 6
    
    if (trackNumber && ![trackNumber isKindOfClass:[NSNull class]]) {
        values[1] = CFSwapInt16HostToBig([trackNumber unsignedIntValue]);   // 7
    }
    
    if (trackCount && ![trackCount isKindOfClass:[NSNull class]]) {
        values[2] = CFSwapInt16HostToBig([trackCount unsignedIntValue]);    // 8
    }
    
    size_t length = sizeof(values);
    metadataItem.value = [NSData dataWithBytes:values length:length];       // 9
    
    return metadataItem;
}
@end
