
#!/bin/sh

jazzy \
      --clean \
      --sdk iphoneos \
      --framework-root ./PaymentHighway\
      --author Payment Highway \
      --exclude ./Sqate/Properties/SqateProperties.swift  \
      --author_url https://www.paymenthighway.io \
      --output docs
