//
//  CardGameViewController.m
//  Matchismo
//
//  Created by ardacck@gmail.com on 25/11/13.
//  Copyright (c) 2013 ardarda online inc. All rights reserved.
//

#import "CardGameViewController.h"
#import "Deck.h"
#import "PlayingCardDeck.h"
#import "CardMatchingGame.h"

@interface CardGameViewController ()

@property (weak, nonatomic) IBOutlet UILabel *flipsLabel;
@property (nonatomic) int flipCount;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (weak, nonatomic) IBOutlet UISwitch *gameSwitch;
@property (strong, nonatomic) Deck *deck;
@property (weak, nonatomic) IBOutlet UILabel *flipDescription;
@property (strong, nonatomic) CardMatchingGame *game;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *cardButtons;
@property (weak, nonatomic) IBOutlet UISlider *historySlider;
@property (strong, nonatomic) NSMutableArray *flipHistory;
@end

@implementation CardGameViewController

-(CardMatchingGame *)game
{
    if (!_game) _game = [[CardMatchingGame alloc] initWithCardCount:[self.cardButtons count]
                                                          usingDeck:[self createDeck]];
    return _game;
}

- (Deck *)createDeck
{
    return [[PlayingCardDeck alloc]init];
}

- (IBAction)touchCardButton:(UIButton *)sender
{
    [self.gameSwitch setEnabled:NO];
    int gameMode = self.gameSwitch.isOn ? 3 : 2;
    int chosenButtonIndex = [self.cardButtons indexOfObject:sender];
    [self.game chooseCardAtIndex:chosenButtonIndex];
    self.game.mode = gameMode;
    [self updateUI];
}

- (void)updateUI
{
    for (UIButton *cardButton in self.cardButtons){
        int cardButtonIndex = [self.cardButtons indexOfObject:cardButton];
        Card *card = [self.game cardAtIndex:cardButtonIndex];
        [cardButton setTitle:[self titleForCard:card] forState:UIControlStateNormal];
        [cardButton setBackgroundImage:[self backgroundImageForCard:card]
                              forState:UIControlStateNormal];
        cardButton.enabled = !card.isMatched;
    }
    
    self.scoreLabel.text = [NSString stringWithFormat:@"Score: %d",self.game.score];
    
    if (self.game) {
        NSString *description = @"";
        
        if ([self.game.lastChosenCards count]) {
            NSMutableArray *cardContents = [NSMutableArray array];
            for (Card *card in self.game.lastChosenCards) {
                [cardContents addObject:card.contents];
            }
            description = [cardContents componentsJoinedByString:@" "];
        }
        if (self.game.lastScore > 0) {
            description = [NSString stringWithFormat:@"Matched %@ for %d points.", description, self.game.lastScore];
        } else if (self.game.lastScore < 0) {
            
            description = [NSString stringWithFormat:@"%@ don’t match! %d point penalty!", description, -self.game.lastScore];
        }
        self.flipDescription.text = description;
        self.flipDescription.alpha = 1;
        if (![description isEqualToString:@""] && ![[self.flipHistory lastObject] isEqualToString:description]) {
            [self.flipHistory addObject:description];
            [self setSliderRange];
        }
    }
}

- (NSString *)titleForCard:(Card *)card
{
    return card.isChosen ? card.contents : @"";
}

- (UIImage *)backgroundImageForCard:(Card *)card
{
    return [UIImage imageNamed:card.isChosen ? @"cardfront" : @"cardback"];
}

- (IBAction)touchResetButton:(UIButton *)sender
{
    [self resetGame];
    [self updateUI];
    self.scoreLabel.text = @"Score: 0";
    self.flipHistory = nil;
}

- (void)resetGame
{
    _game = nil;
    [self.gameSwitch setEnabled:YES];
}

- (IBAction)toggleSwitchButton:(id)sender
{
    if (self.gameSwitch.isOn) {
        NSLog(@"Switch is On!");
    }
}

- (IBAction)toggleSliderButton:(id)sender
{
    int sliderValue;
    sliderValue = self.historySlider.value;
    if ([self.flipHistory count]) {
        self.flipDescription.alpha =
        (sliderValue + 1 < [self.flipHistory count]) ? 0.6 : 1.0;
        self.flipDescription.text =
        [self.flipHistory objectAtIndex:sliderValue];
    }
}

- (void)setSliderRange
{
    int maxValue = (int)[self.flipHistory count] - 1;
    self.historySlider.maximumValue = maxValue;
    [self.historySlider setValue:maxValue animated:YES];
}

- (NSMutableArray *) flipHistory
{
    if (!_flipHistory) _flipHistory = [[NSMutableArray alloc]init];
    return _flipHistory;
}





@end


























