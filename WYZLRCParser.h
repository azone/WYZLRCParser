//
//  WYZLRCParser.h
//  Long Weibo Sharing
//
//  Created by Yozone Wang on 13-6-1.
//  Copyright (c) 2013年 Yozone Wang. All rights reserved.
//

#import <Foundation/Foundation.h>

// 具体查看：http://en.wikipedia.org/wiki/LRC_(file_format)

@interface WYZLRCParser : NSObject

@property (strong, nonatomic) NSString * title; // 歌名 ti:
@property (strong, nonatomic) NSString * artist; // 歌手 ar:
@property (strong, nonatomic) NSString * album;  // 专辑 al:
@property (strong, nonatomic) NSString * lyricist; // 作词 au:

@property (strong, nonatomic) NSString * createAuthor; // LRC创建者 by:
@property (strong, nonatomic) NSString * createTool; // 创建LRC所用到的工具 re:
@property (strong, nonatomic) NSString * createToolVersion; // 工具的版本号 ve:

@property (assign, nonatomic) float offset; // 歌词偏移量 +、-开始 offset:
@property (assign, nonatomic) float length; // 歌曲长度 length:

@property (strong, nonatomic) NSMutableDictionary * LRCDictionary;

@property (strong, readonly, nonatomic) NSError * error;

- (instancetype)initWithFile:(NSString *)file;
- (instancetype)initWithFile:(NSString *)file encoding:(NSStringEncoding)encoding;
- (instancetype)initWithLRCString:(NSString *)LRCString;

+ (instancetype)parseWithFile:(NSString *)file;
+ (instancetype)parseWithFile:(NSString *)file encoding:(NSStringEncoding)encoding;
+ (instancetype)parseWithLRCString:(NSString *)LRCString;

- (void)parseLRC;

@end
