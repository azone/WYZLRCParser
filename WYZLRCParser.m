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
    NSTimeInterval hundredthsOfSecond = [microSecondComponents[1] doubleValue] * 0.01;
    NSTimeInterval minute = [secondAndMinutesComponents[0] doubleValue];
    NSTimeInterval second = [secondAndMinutesComponents[1] doubleValue];
    
    timeInterval = minute * 60 + second + hundredthsOfSecond;
    
    return timeInterval;
}

@interface WYZLRCParser ()

@property (strong, nonatomic) NSString * file;
@property (assign, nonatomic) NSStringEncoding encoding;
@property (strong, readwrite, nonatomic) NSError * error;

@end

@implementation WYZLRCParser

- (id)init {
    return nil;
}

- (instancetype)initWithFile:(NSString *)file {
    return [self initWithFile:file encoding:NSUTF8StringEncoding];
}

- (instancetype)initWithFile:(NSString *)file encoding:(NSStringEncoding)encoding {
    self = [super init];
    if (self) {
        self.file = file;
        self.encoding = encoding;
        self.LRCDictionary = [NSMutableDictionary dictionary];
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

- (void)parseLRC {
    NSError * error;
    NSString * LRCString = [NSString stringWithContentsOfFile:self.file encoding:self.encoding error:&error];
    if (error) {
        self.error = error;
        return;
    }
    NSArray * lines = [LRCString componentsSeparatedByString:@"\n"];
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
            NSString * value = [line substringFromIndex:scanner.scanLocation+1];
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
