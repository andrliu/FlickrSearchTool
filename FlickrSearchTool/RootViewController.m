//
//  ViewController.m
//  FlickrSearchTool
//
//  Created by Andrew Liu on 6/8/15.
//  Copyright (c) 2015 Andrew Liu. All rights reserved.
//

#import "RootViewController.h"
#import "FlickrManager.h"
#import "CustomCollectionViewCell.h"

#define margin 5.0f
#define layerWidth 2.0f
#define heightOfNaviBar 64.0f

@interface RootViewController () <UISearchBarDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property int pageNumber;
@property int totalPageNumber;
@property NSArray *arrayOfPhotoURL;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *nextButton;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *ActivityIndicator;

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initialSetting];
}

- (void)initialSetting {
    self.title = @"Flickr Search Tool";
    self.backButton.enabled = NO;
    self.nextButton.enabled = NO;
}

- (void)search {
    [self.ActivityIndicator startAnimating];
    NSString *page = [NSString stringWithFormat:@"%d", self.pageNumber];
    [FlickrManager search:self.title in:page retrievePhotoURLWithCompletion:^(NSString *totalPages, NSArray *arrayOfPhotoURL, NSError *error) {
        if (!error && arrayOfPhotoURL.count >= 1) {
            self.totalPageNumber = [totalPages intValue];
            if (self.pageNumber == 1) {
                self.backButton.enabled = NO;
                self.nextButton.enabled = YES;
            }
            else if (self.pageNumber == self.totalPageNumber) {
                self.backButton.enabled = YES;
                self.nextButton.enabled = NO;
            }
            else {
                self.backButton.enabled = YES;
                self.nextButton.enabled = YES;
            }
            self.arrayOfPhotoURL = arrayOfPhotoURL;
            [self.collectionView reloadData];
            [self.collectionView setContentOffset:CGPointMake(0.0f, -heightOfNaviBar) animated:YES];
            [self.ActivityIndicator stopAnimating];
        }
        else if (!error && arrayOfPhotoURL.count == 0) {
            [self displayAlert:@"No Results"];
            [self initialSetting];
            self.arrayOfPhotoURL = arrayOfPhotoURL;
            [self.collectionView reloadData];
            [self.ActivityIndicator stopAnimating];
        }
        else {
            [self displayAlert:error.localizedDescription];
            [self initialSetting];
            self.arrayOfPhotoURL = @[];
            [self.collectionView reloadData];
            [self.ActivityIndicator stopAnimating];
        }
    }];
}

- (void)displayAlert:(NSString *)errorMessage {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                   message:errorMessage
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle: @"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:nil];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Button Actions
- (IBAction)previousPageOnButtonPressed:(UIBarButtonItem *)sender {
    self.pageNumber--;
    [self search];
}

- (IBAction)nextPageOnButtonPressed:(UIBarButtonItem *)sender {
    self.pageNumber++;
    [self search];
}

#pragma mark - Gesture Actions
- (IBAction)dismissKeyboard:(UITapGestureRecognizer *)sender {
    self.searchBar.text = @"";
    [self.searchBar resignFirstResponder];
}

#pragma mark - UICollectionView Delegate Methods
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.arrayOfPhotoURL.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CustomCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell"
                                                                           forIndexPath:indexPath];
    NSString *urlString = self.arrayOfPhotoURL[indexPath.item];
    if (urlString) {
        [FlickrManager load:urlString retrievePhotoImagesWithCompletion:^(UIImage *image, NSError *error) {
            if (!error) {
                cell.imageView.image = image;
                cell.layer.borderColor = [UIColor darkGrayColor].CGColor;
                cell.layer.borderWidth = layerWidth;
            }
            else {
                [self displayAlert:error.localizedDescription];
            }
        }];
    }
    return cell;
}

#pragma mark - UICollectionView Delegate FlowLayout Methods
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(-heightOfNaviBar+margin, margin, margin, margin);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(self.collectionView.frame.size.width/2-margin*1.5f, self.collectionView.frame.size.width
                      /2-margin*1.5f);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return margin;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return margin;
}

#pragma mark - UISearchBar Delegate Methods
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.ActivityIndicator startAnimating];
    self.title = searchBar.text;
    self.pageNumber = 1;
    searchBar.text = @"";
    [self search];
    [searchBar resignFirstResponder];
}

@end
