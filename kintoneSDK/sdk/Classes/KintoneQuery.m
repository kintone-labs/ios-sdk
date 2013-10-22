//
//  KintoneQuery.m
//
//  Copyright 2013 Cybozu
//
//  Licensed under the Apache License, Version 2.0 (the "License"); you may not
//  use this file except in compliance with the License.  You may obtain a copy
//  of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
//  WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
//  License for the specific language governing permissions and limitations under
//  the License.
//

#import "KintoneQuery.h"

#import "KintoneField.h"

/*
typedef enum KintoneQueryOperatorType : NSUInteger {
    KintoneNotInQueryOperatorType = 0
} KintoneQueryType;
 */

@implementation KintoneQuery
{
    NSMutableDictionary *_query;
}

/*
 KintoneQuery *q = [KintoneQuery new];
 [q where:
   [q and:
     [q eq:... value:...]
     [q like:... value:...]
   ]
 ];
 [q orderBy:"title" asc:YES];
 [q limit:100];
 [q offset:10];
 
 [q kintoneQuery];
 
 // kintoneQuery: title like "API" and product = "kintone" and (cost > 10 or priority in ("S", "A") ) order by date desc limit 5 offset 10
 // Create the following object to execute above query.
 {
   "where":[
     "and",
     ["like",title,"API"],
     ["eq",product,"kintone"],
     [
       "or",
       ["gt",cost,10],
       ["in",priority,["S","A"]]
     ]
   ],
   "orderBy":["date",NO],
   "limit":5,
   "offset":10
 }
 */

- (KintoneQuery *)init
{
    if (self = [super init]) {
        _query = [NSMutableDictionary dictionary];
    }
    
    return self;
}

static NSDictionary *operatorTypeToStringDictionary()
{
    static NSDictionary *dict = nil;
    if (dict == nil) {
        dict = @{@(KintoneEqualQueryOperatorType)              : @"=",
                 @(KintoneNotEqualQueryOperatorType)           : @"!=",
                 @(KintoneGreaterThanQueryOperatorType)        : @">",
                 @(KintoneLessThanQueryOperatorType)           : @"<",
                 @(KintoneGreaterThanOrEqualQueryOperatorType) : @">=",
                 @(KintoneLessThanOrEqualQueryOperatorType)    : @"<=",
                 @(KintoneInQueryOperatorType)                 : @"in",
                 @(KintoneNotInQueryOperatorType)              : @"not in",
                 @(KintoneLikeQueryOperatorType)               : @"like",
                 @(KintoneNotLikeQueryOperatorType)            : @"not like"};
    }
    
    return dict;
}

+ (NSString *)operatorTypeToString:(KintoneQueryOperatorType)operatorType
{
    return operatorTypeToStringDictionary()[@(operatorType)];
}

- (void)where:(NSArray *)query
{
    _query[@"where"] = query;
}

- (void)orderBy:(KintoneField *)field asc:(BOOL)asc
{
    _query[@"orderBy"] = @[field, [NSNumber numberWithBool:asc]];
}

- (void)limit:(int)limit
{
    _query[@"limit"] = [NSNumber numberWithInt:limit];
}

- (void)offset:(int)offset
{
    _query[@"offset"] = [NSNumber numberWithInt:offset];
}

- (NSArray *)and:(NSArray *)condition, ...
{
    NSMutableArray *andArray = [NSMutableArray arrayWithObject:@"and"];
    va_list args;
    va_start(args, condition);
    NSArray *array = condition;
    while (array) {
        [andArray addObject:array];
        array = va_arg(args, NSArray *);
    }
    va_end(args);
    
    NSAssert(andArray.count >= 3, @"invalid query: %@", andArray);

    return andArray;
}

- (NSArray *)or:(NSArray *)condition, ...
{
    NSMutableArray *andArray = [NSMutableArray arrayWithObject:@"or"];
    va_list args;
    va_start(args, condition);
    NSArray *array = condition;
    while (array) {
        [andArray addObject:array];
        array = va_arg(args, NSArray *);
    }
    va_end(args);
    
    NSAssert(andArray.count >= 3, @"invalid query: %@", andArray);
    
    return andArray;
}

- (NSArray *)eq:(KintoneField *)field value:(id)value
{
    assert(field != nil);
    return @[[NSNumber numberWithInt:KintoneEqualQueryOperatorType], field, value];
}

- (NSArray *)notEq:(KintoneField *)field value:(id)value
{
    assert(field != nil);
    return @[[NSNumber numberWithInt:KintoneNotEqualQueryOperatorType], field, value];
}

- (NSArray *)greaterThan:(KintoneField *)field value:(id)value
{
    assert(field != nil);
    return @[[NSNumber numberWithInt:KintoneGreaterThanQueryOperatorType], field, value];
}

- (NSArray *)lessThan:(KintoneField *)field value:(id)value
{
    assert(field != nil);
    return @[[NSNumber numberWithInt:KintoneLessThanQueryOperatorType], field, value];
}

- (NSArray *)greaterThanOrEqual:(KintoneField *)field value:(id)value
{
    assert(field != nil);
    return @[[NSNumber numberWithInt:KintoneGreaterThanOrEqualQueryOperatorType], field, value];
}

- (NSArray *)lessThanOrEqual:(KintoneField *)field value:(id)value
{
    assert(field != nil);
    return @[[NSNumber numberWithInt:KintoneLessThanOrEqualQueryOperatorType], field, value];
}

- (NSArray *)in:(KintoneField *)field value:(NSArray *)value
{
    assert(field != nil);
    return @[[NSNumber numberWithInt:KintoneInQueryOperatorType], field, value];
}

- (NSArray *)notIn:(KintoneField *)field value:(NSArray *)value
{
    assert(field != nil);
    return @[[NSNumber numberWithInt:KintoneNotInQueryOperatorType], field, value];
}

- (NSArray *)like:(KintoneField *)field value:(NSString *)value
{
    assert(field != nil);
    return @[[NSNumber numberWithInt:KintoneLikeQueryOperatorType], field, value];
}

- (NSArray *)notLike:(KintoneField *)field value:(NSString *)value
{
    assert(field != nil);
    return @[[NSNumber numberWithInt:KintoneNotLikeQueryOperatorType], field, value];
}

- (NSString *)kintoneQuery
{
    NSMutableString *query = [NSMutableString string];

    // where clause
    NSString *where = [self whereKintoneQuery:_query[@"where"]];
    if (where) {
        [query appendString:where];
    }
    
    // order by
    NSArray *orderBy = _query[@"orderBy"];
    if (orderBy) {
        [query appendString:[self orderByKintoneQuery:orderBy]];
    }
    
    // limit
    NSNumber *limit = _query[@"limit"];
    if (limit) {
        [query appendString:[self limitKintoneQuery:limit.intValue]];
    }
    
    // offset
    NSNumber *offset = _query[@"offset"];
    if (offset) {
        [query appendString:[self offsetKintoneQuery:offset.intValue]];
    }
    
    [CBLog sdkLogVerbose:@"kintoneQuery: %@", query];
    
    return query;
}

- (NSString *)whereKintoneQuery:(NSArray *)where
{
    NSString *query = nil;
    
    // create a query like "(condition1 and condition2 and condition3)"
    if (where != nil && where.count > 0) {
        id first = [where objectAtIndex:0];
        if ([first isKindOfClass:[NSString class]] && ([first isEqualToString:@"and"] || [first isEqualToString:@"or"])) {
            NSArray *conditions = [where subarrayWithRange:NSMakeRange(1, where.count - 1)];
            NSMutableArray *conditionQueries = [NSMutableArray arrayWithCapacity:conditions.count];
            for (NSArray *condition in conditions) {
                [conditionQueries addObject:[self whereKintoneQuery:condition]];
            }
            query = [NSString stringWithFormat:@"(%@)", [conditionQueries componentsJoinedByString:[NSString stringWithFormat:@" %@ ", first]]];
        }
        else {
            query = [self conditionKintoneQuery:where];
        }
    }
    
    return query;
}

- (NSString *)conditionKintoneQuery:(NSArray *)condition
{
    NSAssert(condition.count == 3, @"invalid query: %@", condition);

    KintoneField *field = (KintoneField *)condition[1];
    KintoneQueryOperatorType operatorType = [condition[0] intValue];
    NSString *query = [field conditionQuery:operatorType value:condition[2]];
    
    return query;
}

- (NSString *)orderByKintoneQuery:(NSArray *)orderBy
{
    // order by <column> [asc|desc]
    KintoneField *field = (KintoneField *)orderBy[0];
    return [NSString stringWithFormat:@" order by %@ %@", field.code, ([orderBy[1] boolValue] ? @"asc" : @"desc")];
}

- (NSString *)limitKintoneQuery:(int)limit
{
    assert(limit > 0);
    return [NSString stringWithFormat:@" limit %d", limit];
}

- (NSString *)offsetKintoneQuery:(int)offset
{
    assert(offset >= 0);
    return [NSString stringWithFormat:@" offset %d", offset];
}

@end
