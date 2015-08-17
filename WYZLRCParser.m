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
    NSArray * secondAndMinutesComponents = [timeIntervalString componentsSeparatedByString:@":"];
    NSTimeInterval minute = [[secondAndMinutesComponents firstObject] doubleValue];
    NSTimeInterval second = 0;
    if(secondAndMinutesComponents.count >= 2){
        second = [secondAndMinutesComponents[1] doubleValue];
    }
    
    timeInterval = minute * 60 + second;
    
    return timeInterval;
}

@interface WYZLRCParser ()

@property (assign, nonatomic) NSStringEncoding encoding;
@property (strong, readwrite, nonatomic) NSError * error;
@property (copy, nonatomic) NSString *LRCString;

@end

@implementation WYZLRCParser

- (id)init {
    return nil;
}

- (instancetype)initWithFile:(NSString *)file {
    return [self initWithFile:file encoding:NSUTF8StringEncoding];
}

- (instancetype)initWithFile:(NSString *)file encoding:(NSStringEncoding)encoding {
    NSError* error = nil;
    NSString *LRCString = [NSString stringWithContentsOfFile:file encoding:self.encoding error:&error];
    self.encoding = encoding;
    return [self initWithLRCString:LRCString];
}

- (instancetype)initWithLRCString:(NSString *)LRCString {
    self = [super init];
    if (self) {
        _LRCString = LRCString;
        _LRCDictionary = [NSMutableDictionary dictionary];
    }
    return self;
}

+ (instancetype)parseWithFile:(NSString *)file {
    return [self parseWithFile:file encoding:NSUTF8StringEncoding];
}

+ (instancetype)parseWithFile:(NSString *)file encoding:(NSStringEncoding)encoding {
    WYZLRCParser * LRCParser = [[self alloc] initWithFile:file encoding:NSUTF8StringEncoding];
    [LRCParser parseLRC];
    
    return LRCParser;
}

+ (instancetype)parseWithLRCString:(NSString *)LRCString {
    WYZLRCParser * LRCParser = [[self alloc] initWithLRCString:LRCString];
    [LRCParser parseLRC];
    
    return LRCParser;
}

- (void)parseLRC {
    NSError * error;
    if (error) {
        self.error = error;
        return;
    }
    
    NSString* fliterString = [self.LRCString stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    NSArray * lines = [fliterString componentsSeparatedByString:@"\n"];
    [lines enumerateObjectsUsingBlock:^(NSString * line, NSUInteger idx, BOOL *stop) {
        NSScanner * scanner = [NSScanner scannerWithString:line];
        NSString * scannedString;
        [scanner scanString:@"[" intoString:&scannedString];
        NSMutableArray *keys = [NSMutableArray array];
        BOOL needToContinue = NO;
        while (scannedString) {
            NSString * key;
            [scanner scanUpToString:@"]" intoString:&key];
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
                self.offset = [[key substringFromIndex:7] floatValue] * 0.001;
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
            scanner.scanLocation += 1;
            [scanner scanString:@"[" intoString:&scannedString];
        }
        if (needToContinue) {
            NSString * value = [line substringFromIndex:scanner.scanLocation];
            value = value ?: @"";
            [keys enumerateObjectsUsingBlock:^(NSString * timeline, NSUInteger idx, BOOL *stop) {
                NSTimeInterval time = convertStringToTimeInterval(timeline);
                [self.LRCDictionary setObject:value forKey:@(time)];
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
