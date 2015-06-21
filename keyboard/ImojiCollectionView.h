//
//  ImojiCollectionView.h
//  imoji-keyboard
//
//  Created by Jeff on 6/7/15.
//  Copyright (c) 2015 Jeff. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <ImojiSDK/ImojiSDK.h>

@class IMImojiSession;

@interface ImojiCollectionView : UICollectionView

+ (instancetype)imojiCollectionViewWithSession:(IMImojiSession *)session;

- (void)loadImojiCategories:(IMImojiSessionCategoryClassification)classification;

@end
