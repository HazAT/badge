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

	badge

![assets/icon175x175_light_badged.png](assets/icon175x175_light_badged.png?raw=1) ![assets/icon175x175_fitrack_light_badged.png](assets/icon175x175_fitrack_light_badged.png?raw=1)

	badge --dark

![assets/icon175x175_dark_badged.png](assets/icon175x175_dark_badged.png?raw=1) ![assets/icon175x175_fitrack_dark_badged.png](assets/icon175x175_fitrack_dark_badged.png?raw=1)

	badge --shield="1.2-2031-orange" --no_badge

![assets/icon175x175_shield_1.2-2031-orange.png](assets/icon175x175_shield_1.2-2031-orange.png?raw=1) ![assets/icon175x175_fitrack_shield_1.2-2031-orange.png](assets/icon175x175_fitrack_shield_1.2-2031-orange.png?raw=1)

	badge --shield="Version-0.0.3-blue" --dark

![assets/icon175x175_shield_Version-0.0.3-blue.png](assets/icon175x175_shield_Version-0.0.3-blue.png?raw=1) ![assets/icon175x175_fitrack_shield_Version-0.0.3-blue.png](assets/icon175x175_fitrack_shield_Version-0.0.3-blue.png?raw=1)

# Installation

Install the gem

    sudo gem install badge

# Usage

Call ```badge``` in your iOS projects root folder

    badge
    
It will search all subfolders for your asset catalog app icon set and add the badge to the icon. 
*Be careful, it actually overwrites the icon files because this gem is meant to be used in and automated build environment.*

Here is the dark option:

	badge --dark

You can also use your custom overlay/badge image

    badge --custom="path_to/custom_badge.png"
    
Add a shield at the top of your icon for all possibilites head over to: [shields.io](http://shields.io/). You just have to add the string of shield (copied from the URL)

    badge --shield="Version-0.0.3-blue"
    
Add ```--no_badge``` as an option to hide the beta badge completely if you just want to add a shield. 

# Usage with fastlane

```ruby
lane :appstore do
  increment_build_number
  cocoapods
  
  badge(dark: true) #or
  #badge(custom: "/Users/HazA/Desktop/badge.png") #or
  #badge(shield: "Version-0.0.3-blue", no_badge: true)
    
  xctool
  snapshot
  sigh
  deliver
  sh "./customScript.sh"

  slack
end
```

If Jenkins has problems finding imagemagick on your mac add following env variable to your job:

	PATH=$PATH:/usr/local/bin


## Uninstall

	sudo gem uninstall badge

# Thanks
[@ThomasMirnig](https://twitter.com/ThomasMirnig) [@KrauseFx](https://twitter.com/KrauseFx) [fastlane](https://github.com/fastlane/fastlane)

# License
This project is licensed under the terms of the MIT license. See the LICENSE file.
