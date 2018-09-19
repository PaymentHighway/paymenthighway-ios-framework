
#!/bin/sh

jazzy \
      --clean \
      --sdk iphoneos \
      --framework-root ./PaymentHighway \
      --author "Payment Highway" \
      --author_url https://www.paymenthighway.io \
      --github_url https://github.com/PaymentHighway/paymenthighway-ios-framework \
      --output docs
