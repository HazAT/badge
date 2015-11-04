badge - add a badge to your iOS app icon
============

[![Twitter: @DanielGri](https://img.shields.io/badge/contact-@DanielGri-blue.svg?style=flat)](https://twitter.com/DanielGri)
[![License](http://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/HazAT/badge/blob/master/LICENSE)
[![Gem](https://img.shields.io/gem/v/badge.svg?style=flat)](http://rubygems.org/gems/badge)

# Features

This gem helps to add a badge to your iOS app icon.

Yes that's it.
It's built to easily integrate with [fastlane](https://github.com/fastlane/fastlane).

![assets/icon175x175.png](assets/icon175x175.png?raw=1) ![assets/icon175x175_fitrack.png](assets/icon175x175_fitrack.png?raw=1)

becomes

![assets/icon175x175_badged.png](assets/icon175x175_badged.png?raw=1) ![assets/icon175x175_fitrack_badged.png](assets/icon175x175_fitrack_badged.png?raw=1)

# Installation

Install the gem

    sudo gem install badge

# Usage

Call ```badge``` in your iOS projects root folder

    badge
    
It will search all subfolders for your asset catalog app icon set and add the badge to the icon. 
*Be careful, it actually overwrites the icon files because this gem is meant to be used in and automated build environment.*

You can also use your custom overlay/badge image

    badge --custom="path_to/custom_badge.png"

# Usage with fastlane

```ruby
lane :appstore do
  increment_build_number
  cocoapods
  
  sh badge
  
  xctool
  snapshot
  sigh
  deliver
  sh "./customScript.sh"

  slack
end
```


## Uninstall

	sudo gem uninstall badge

# Thanks
[@KrauseFx](https://twitter.com/KrauseFx) [fastlane](https://github.com/fastlane/fastlane) tools.

# License
This project is licensed under the terms of the MIT license. See the LICENSE file.
