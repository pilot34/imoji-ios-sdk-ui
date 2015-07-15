//
//  ImojiCollectionView.m
//  imoji-keyboard
//
//  Created by Jeff on 6/7/15.
//  Copyright (c) 2015 Jeff. All rights reserved.
//

#import <Masonry/View+MASAdditions.h>
#import "ImojiCollectionView.h"
#import "ImojiTextUtil.h"

typedef NS_ENUM(NSUInteger, ImojiCollectionViewContentType) {
    ImojiCollectionViewContentTypeImojis,
    ImojiCollectionViewContentTypeImojiCategories
};


NSUInteger const ImojiCollectionViewNumberOfItemsToLoad = 60;
NSString *const ImojiCategoryCollectionViewCellReuseId = @"ImojiCategoryCollectionViewCellResuseId";
CGFloat const ImojiCollectionViewImojiCategoryLeftRightInset = 10.0f;

@interface ImojiCategoryCollectionViewCell : UICollectionViewCell

- (void)loadImojiCategory:(NSString *)categoryTitle imojiImojiImage:(UIImage *)imojiImage;

@property(nonatomic, strong) UIImageView *imojiView;
@property(nonatomic, strong) UILabel *titleView;

@end


@interface ImojiCollectionView () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property(nonatomic, strong) IMImojiSession *session;
@property(nonatomic, strong) NSMutableArray *content;
@property(nonatomic) ImojiCollectionViewContentType contentType;

@end

@implementation ImojiCollectionView {
    
}

- (instancetype)initWithSession:(IMImojiSession *)session {
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self = [super initWithFrame:CGRectZero collectionViewLayout:layout];
    if (self) {
        self.session = session;
        self.dataSource = self;
        self.delegate = self;
        
        self.backgroundColor = [UIColor clearColor];
        
        self.content = [NSMutableArray arrayWithCapacity:ImojiCollectionViewNumberOfItemsToLoad];
        
        [self registerClass:[ImojiCategoryCollectionViewCell class] forCellWithReuseIdentifier:ImojiCategoryCollectionViewCellReuseId];
    }
    
    return self;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.content.count * 30;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    id cellContent = self.content[(NSUInteger) indexPath.row % self.content.count];

    //if (self.contentType == ImojiCollectionViewContentTypeImojiCategories) {
        IMImojiCategoryObject *categoryObject = cellContent;
        ImojiCategoryCollectionViewCell *cell = [self dequeueReusableCellWithReuseIdentifier:ImojiCategoryCollectionViewCellReuseId forIndexPath:indexPath];
        
        [cell loadImojiCategory:categoryObject.title imojiImojiImage:nil];
        //NSLog(@"loading category: %@", categoryObject.title);
    
        [self.session renderImoji:categoryObject.previewImoji
                          options:self.renderingOptions
                         callback:^(UIImage *image, NSError *error) {
                             if (!error) {
                                 [cell loadImojiCategory:categoryObject.title imojiImojiImage:image];
                             }
                         }];
        return cell;
    //}
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    id cellContent = self.content[(NSUInteger) indexPath.row % self.content.count];
    
    if (self.contentType == ImojiCollectionViewContentTypeImojiCategories) {
        IMImojiCategoryObject *categoryObject = cellContent;
        
        /*
        NSMutableArray* identifierArray = [NSMutableArray arrayWithCapacity:1];
        [identifierArray addObject:categoryObject.identifier];
        [self.session fetchImojisByIdentifiers:identifierArray
                       fetchedResponseCallback:^(IMImojiObject *imoji) {
                           if (!error) {
                               
                           }
                       }];
         */
    }
    
    return;
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return CGSizeMake(self.frame.size.height / 2, self.frame.size.height / 2);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}


- (void)loadImojiCategories:(IMImojiSessionCategoryClassification) classification {
    self.contentType = ImojiCollectionViewContentTypeImojiCategories;
    //[self.content addObject:self.loadingIndicatorObject];
    [self.content removeAllObjects];
    [self reloadData];
    
    [self.session getImojiCategoriesWithClassification:classification
                                              callback:^(NSArray *imojiCategories, NSError *error) {
                                                  [self.content addObjectsFromArray:imojiCategories];
                                                  NSLog(@"loading categories: %@", self.content);
                                                  [self reloadData];
                                              }];
}



- (IMImojiObjectRenderingOptions *)renderingOptions {
    IMImojiObjectRenderingOptions *opts = [IMImojiObjectRenderingOptions optionsWithRenderSize:IMImojiObjectRenderSizeThumbnail
                                                    borderColor:[UIColor whiteColor]
            //                                          borderWidthPercentage:@(.07f)
            //                                                    shadowColor:[UIColor colorWithRed:.25 green:.25 blue:.25f alpha:0.3f]
            //                                           shadowBlurPercentage:@(0.05f)
            ];
    opts.targetSize = [NSValue valueWithCGSize:CGSizeMake(self.frame.size.height, self.frame.size.height)];
    return opts;
}

+ (instancetype)imojiCollectionViewWithSession:(IMImojiSession *)session {
    return [[ImojiCollectionView alloc] initWithSession:session];
}


+ (UIImage *)placeholderImageWithRadius:(CGFloat)radius {
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(radius, radius), NO, 0.f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:1.0f green:0.0f blue:0.0f alpha:.3f].CGColor);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGContextSetLineWidth(context, 0);
    CGContextFillEllipseInRect(context, CGRectMake(0, 0, radius, radius));
    
    UIImage *layer = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return layer;
}
@end



@implementation ImojiCategoryCollectionViewCell

- (void)loadImojiCategory:(NSString *)categoryTitle imojiImojiImage:(UIImage *)imojiImage {
    float imageHeightRatio = 1.f;
    float textHeightRatio = 0.f;
    int inBetweenPadding = 3;
    
    if (!self.imojiView) {
        self.imojiView = [UIImageView new];
        self.imojiView.contentMode = UIViewContentModeScaleAspectFit;
        
        float padding = (self.frame.size.height - (imageHeightRatio*self.frame.size.height) - (textHeightRatio*self.frame.size.height) - inBetweenPadding)/2.f;
        
        [self addSubview:self.imojiView];
        [self.imojiView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.height.width.equalTo(self.mas_height).multipliedBy(imageHeightRatio);
            make.top.equalTo(self.mas_top).offset(padding);
        }];
    }
    
    if (!self.titleView) {
        self.titleView = [UILabel new];
        
        [self addSubview:self.titleView];
        [self.titleView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.centerX.equalTo(self);
            make.height.equalTo(self.mas_height).multipliedBy(textHeightRatio);
            make.top.equalTo(self.imojiView.mas_bottom).offset(inBetweenPadding);
        }];
    }
    
    if (imojiImage) {
        self.imojiView.image = imojiImage;
    } else {
        self.imojiView.image = [ImojiCollectionView placeholderImageWithRadius:50];
    }
    
    self.titleView.attributedText = [ImojiTextUtil attributedString:categoryTitle
                                                       withFontSize:15.0f
                                                          textColor:[UIColor blackColor]
                                                      textAlignment:NSTextAlignmentCenter];
}

@end

