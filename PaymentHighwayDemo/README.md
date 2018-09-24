
# Payment Highway Demo

This example app demonstrates how to integrate Payment Highway SDK for add card and payment.

## Mobile Application Backend

As the secret Payment Highway credentials cannot be stored within the mobile application, a merchant backend is required for handling the authenticated communications to the service, such as fetching the card tokens and initializing the transactions. This is also where the information regarding the card tokens and payments are stored.

The bundled demo application uses a pre-made dummy merchant backend, which connects to the [Payment Highway development sandbox](https://dev.paymenthighway.io/#development-sandbox). Each merchant needs to implement this backend themselves.

For more info see the code [here]().

In client side you need to implement the BackendAdapter interface. Payment Highway iOS framework includes `endpoint` helper that migh be used for the REST api.

The demo includes an implementation example for a `BackendAdapter` in the folder `BackendAdapterExample`.

## Environment

Payment Highway has `sandbox` and `production` environments.

In `DEBUG` mode the default environment is `sandbox`.

You can change the Environment for example in your AppDelegate:
```swift
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        Environment.current = .sandbox
        return true
    }
```

## Add a credit card

In order to add credit card and get a payment token you need a `PaymentContext`.

PaymentHighway iOS SDK (debug) in connected with the [Payment Highway development sandbox](https://dev.paymenthighway.io/#development-sandbox).

Therefore the demo app uses the provided sandbox merchant id and account id.

Example how istantiate a `PaymentContext`:
```swift
    let merchantId = MerchantId(id: "test_merchantId")
    let accountId = AccountId(id: "test")

    let paymentConfig = PaymentConfig(merchantId: merchantId, accountId: accountId)
    let paymentContext = PaymentContext(config: paymentConfig, backendAdapter: BackendAdapterExample())
```

If you have the card data available (for example from your own form) then you can call `addCard`:
```swift
    let card = CardData(pan: cardNumberFromForm, cvc: cvcFromForm, expirationDate: expirationDateFromForm)

    paymentContext.addCard(card: card) { (result) in
        switch result {
        case .success(let transactionToken):
            // do the payment with the transaction Token
        case .failure(let error):
            // manage the error
        }
    }
```

## AddCardViewController

Payment Highway SDK provide UI Form to input a credit card.

It renders a `Cancel` and `Add card` buttons so it must be presented inside a `UINavigationController`.

`AddCardViewController` has theme parameter(optional) where you can customize the appearance of the UI Elements. Payment Highway provide a default Theme implemenation: `DefaultTheme`. See below.

`Presenter` helper can be used to show the View Controller.

AddCardViewController as api showError(message) to show simple toast view with the error message.

### Presenter

`Presenter` is a helper to present a View Controller in 3 modalities:
1. Full screen
2. Popup half screen 
3. Popup custom where you can define the height of the screen that the view controller use

### AddCardDelegate

You need to provide the delegate implementation to manage the submission of a card or the cancellation of the operation.

```swift
public protocol AddCardDelegate: class {
    func cancel()
    func addCard(_ card: CardData)
}
```

Example how `Presenter` can be used with a basic `add card delegate`implementation:

```swift
class YourViewController: UIViewController, AddCardDelegate {
    var presenter: Presenter<AddCardViewController>?
    var yourTheme: Theme
    var paymentContext: PaymentContext<BackendAdapterExample>
    
    func showAddCard() {
        let addViewController = AddCardViewController(theme: yourTheme)
        // Set the add card delegate
        addCardViewController.addCardDelegate = self
        presenter = Presenter(presentationType: .fullScreen)
        presenter!.present(presentingViewController: self, presentedViewController: addViewController)
    }

    func cancel() {
        // dismiss the add card view controller
        self.presenter?.dismissPresentedController(animated: true) { () in
            self.presenter = nil
        }
    }

    func addCard(_ card: CardData) {
        paymentContext.addCard(card: card) { (result) in
            switch result {
            case .success(let transactionToken):
                self.presenter?.dismissPresentedController(animated: true) { () in
                    self.presenter = nil
                }
                // use the transaction token for payment
            case .failure(let error):
                self.presenter?.presentedViewController?.showError(message: "\(error)")
            }
        }
    }
}
````
Note: You need a strong reference to the presenter. Presenter keep a reference to the presented View Controller. You can access it via instance variable `presentedViewController`.


## How customize appearence of the Payment Highway UI Elements

You can define your own appearence attributes for the Payment Highway UI Elements.

You can customize from the default theme, modify the default theme or just have your theme implementing the protocol `Theme`.

Example to create own theme from `DefaultTheme`
```swift
class MyTheme: DefaultTheme {
    override init() {
        primaryBackgroundColor = UIColor(hexInt: 0x0000ff)
        secondaryBackgroundColor = UIColor(hexInt: 0xff0000)
    }
}
```

Example to modify the `DefaultTheme`
```swift
let modifiedTheme = DefaultTheme.instance
modifiedTheme.primaryBackgroundColor = UIColor(hexInt: 0x0000ff)
secondaryBackgroundColor = UIColor(hexInt: 0xff0000)
```

Implementation of own `Theme`
```swift
class MyTheme: Theme {
    
    var primaryBackgroundColor: UIColor = UIColor(hexInt: 0x0000ff)
    var secondaryBackgroundColor: UIColor = UIColor(hexInt: 0xff0000)
    ...
} 
```

note: UIColor(hexInt) is a convenience UIColor helper to initialize with a hex color




