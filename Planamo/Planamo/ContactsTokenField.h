/*
 * ContactsTokenField.h
 * ----------------------
 * Text field used to add contacts from datasource, mimicing the "TO:"
 * field in email message composers found on iOS. Specifically tailored
 * for adding contacts from address book (stored in Core Data) - finds
 * contacts based on unique phone numbers
 * 
 * This is a heavily modified version of ContactsTokenField (found at https://github.com/arashpayan/ContactsTokenField)
 *
 * Additional features:
 *  - Uses Core Data (fetched results controller)
 *  - Cannot add duplicate
 *  - Add new person table cell (TODO)
 *  - Link to address book (multiple contacts selector) - TODO
 */

@protocol ContactsTokenFieldDataSource;
@protocol ContactsTokenFieldDelegate;
@class ContactsShadowView;
@class ContactsSolidLine;
@class ContactsTextField;
#import <UIKit/UIKit.h>

@interface ContactsTokenField : UIControl <UITableViewDataSource, UITextFieldDelegate, UITableViewDelegate> {
    id<ContactsTokenFieldDelegate> tokenFieldDelegate;
    ContactsShadowView *shadowView;
    ContactsTextField *textField;
    UIView *backingView;
    UIView *tokenContainer;
    UIFont *font;
    UITableView *resultsTable;
    NSString *labelText;
    UILabel *label;
    NSUInteger numberOfResults;
    UIView *rightView;
    ContactsSolidLine *solidLine;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) UIFont *font;
@property (nonatomic, copy) NSString *labelText;
@property (nonatomic, readonly) UITableView *resultsTable;
@property (nonatomic, retain) UIView *rightView;
@property (nonatomic, readonly) NSString *text;
@property (nonatomic, assign) id<ContactsTokenFieldDelegate> tokenFieldDelegate;
@property (nonatomic, retain) NSMutableArray *tokens;

- (void)addObject:(id)object;
- (void)removeObject:(id)object;
- (NSUInteger)objectCount;
- (id)objectAtIndex:(NSUInteger)index;

@end

@interface ContactsTokenView : UIView {
    NSString *title;
    ContactsTokenField *tokenField;
    id object;
    BOOL highlighted;
}

@property (nonatomic, assign) BOOL highlighted;
@property (nonatomic, retain) id object;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, assign) ContactsTokenField *tokenField;
+ (ContactsTokenView*)tokenWithTitle:(NSString*)aTitle object:(id)anObject;
- (id)initWithTitle:(NSString*)aTitle object:(id)anObject;

@end

@protocol ContactsTokenFieldDelegate <NSObject>

@optional
/* Called when the user adds an object from the results list. */
- (void)tokenField:(ContactsTokenField*)tokenField didAddObject:(id)object;
/* Called when the user deletes an object from the token field. */
- (void)tokenField:(ContactsTokenField*)tokenField didRemoveObject:(id)object;
- (void)tokenFieldDidEndEditing:(ContactsTokenField*)tokenField;
/* Called when the user taps the 'enter'. */
- (void)tokenFieldDidReturn:(ContactsTokenField*)tokenField;
- (BOOL)tokenField:(ContactsTokenField*)tokenField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString*)string;

@end