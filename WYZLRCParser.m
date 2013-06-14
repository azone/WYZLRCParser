//
//  WYZLRCParser.m
//  Long Weibo Sharing
//
//  Created by Yozone Wang on 13-6-1.
//  Copyright (c) 2013年 Yozone Wang. All rights reserved.
//

#import "WYZLRCParser.h"

NSTimeInterval convertStringToTimeInterval(NSString * timeIntervalString) {
    NSTimeInterval timeInterval = 0.0;
    NSArray * microSecondComponents = [timeIntervalString componentsSeparatedByString:@"."];
    NSArray * secondAndMinutesComponents = [microSecondComponents[0] componentsSeparatedByString:@":"];
    NSTimeInterval microSecond = 0.0;
    if ([microSecondComponents count] >= 2) {
        microSecond = [microSecondComponents[1] doubleValue] * 0.001;
    }
    NSTimeInterval minute = [secondAndMinutesComponents[0] doubleValue];
    NSTimeInterval second = [secondAndMinutesComponents[1] doubleValue];
    
    timeInterval = minute * 60 + second + microSecond;
    
    return timeInterval;
}

@interface WYZLRCParser () {
    NSString * _LRCString;
}

@end

@implementation WYZLRCParser

- (instancetype)initWithFile:(NSString *)file {
    return [self initWithFile:file encoding:NSUTF8StringEncoding];
}

- (instancetype)initWithFile:(NSString *)file encoding:(NSStringEncoding)encoding {
    self = [super init];
    if (self) {
        NSData * LRCData = [NSData dataWithContentsOfFile:file];
        _LRCString = [[NSString alloc] initWithData:LRCData encoding:encoding];
        self.LRCDictionary = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (void)parseLRC {
    NSArray * lines = [_LRCString componentsSeparatedByString:@"\n"];
    [lines enumerateObjectsUsingBlock:^(NSString * line, NSUInteger idx, BOOL *stop) {
        NSScanner * scanner = [NSScanner scannerWithString:line];
        NSString * scannedString;
        [scanner scanString:@"[" intoString:&scannedString];
        NSMutableArray *keys = [NSMutableArray array];
        BOOL needToContinue = NO;
        while (scannedString) {
            NSUInteger start = scanner.scanLocation;
            [scanner scanUpToString:@"]" intoString:nil];
            NSUInteger end = scanner.scanLocation;
            NSString * key = [line substringWithRange:NSMakeRange(start, end - start)];
            if ([key hasPrefix:@"ti:"]) {
                self.title = [key substringFromIndex:3];
                break;
            }
            else if ([key hasPrefix:@"ar:"]) {
                self.artist = [key substringFromIndex:3];
                break;
            }
            else if ([key hasPrefix:@"al:"]) {
                self.album = [key substringFromIndex:3];
                break;
            }
            else if ([key hasPrefix:@"au:"]) {
                self.lyricist = [key substringFromIndex:3];
                break;
            }
            else if ([key hasPrefix:@"by:"]) {
                self.createAuthor = [key substringFromIndex:3];
                break;
            }
            else if ([key hasPrefix:@"re:"]) {
                self.createTool = [key substringFromIndex:3];
                break;
            }
            else if ([key hasPrefix:@"ve:"]) {
                self.createToolVersion = [key substringFromIndex:3];
                break;
            }
            else if ([key hasPrefix:@"offset:"]) {
                self.offset = [[key substringFromIndex:7] floatValue];
                break;
            }
            else if ([key hasPrefix:@"length:"]) {
                self.length = convertStringToTimeInterval([key substringFromIndex:7]);
                break;
            }
            else {
                needToContinue = YES;
                [keys addObject:key];
            }
            scannedString = nil;
            [scanner scanString:@"[" intoString:&scannedString];
        }
     if (needToContinue) {
         NSString * value = [line substringFromIndex:scanner.scanLocation+1];
         value = value ?: @"";
         [keys enumerateObjectsUsingBlock:^(NSString * timeline, NSUInteger idx, BOOL *stop) {
             NSTimeInterval time = convertStringToTimeInterval(timeline);
             [self.LRCDictionary setObject:value forKey:@(time + self.offset)];
         }];
     }
    }];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ %p> title:%@, artist:%@, album:%@, lyricist:%@, create author:%@, create tool:%@, create tool version:%@, offset:%f, length:%f, LRCDictionary:%@",
            [self class],
            self,
            self.title,
            self.artist,
            self.album,
            self.lyricist,
            self.createAuthor,
            self.createTool,
            self.createToolVersion,
            self.offset,
            self.length,
            self.LRCDictionary
            ];
}

@end
