badge - add a badge to your tvOS/iOS/Android app icon
============

[![Twitter: @DanielGri](https://img.shields.io/badge/contact-@DanielGri-blue.svg?style=flat)](https://twitter.com/DanielGri)
[![License](http://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/HazAT/badge/blob/master/LICENSE)
[![Gem](https://img.shields.io/gem/v/badge.svg?style=flat)](http://rubygems.org/gems/badge)
[![fastlane Plugin Badge](https://rawcdn.githack.com/fastlane/fastlane/master/fastlane/assets/plugin-badge.svg)](https://rubygems.org/gems/fastlane-plugin-badge)

# Features

This gem helps to add a badge to your tvOS/iOS/Android app icon.

Yes that's it.
It's built to easily integrate with [fastlane](https://github.com/fastlane/fastlane).

![assets/icon175x175.png](assets/icon175x175.png?raw=1) ![assets/icon175x175_fitrack.png](assets/icon175x175_fitrack.png?raw=1)
---
```
badge
```

![assets/icon175x175_light_badged.png](assets/icon175x175_light_badged.png?raw=1) ![assets/icon175x175_fitrack_light_badged.png](assets/icon175x175_fitrack_light_badged.png?raw=1)
---
```
badge --dark
```

![assets/icon175x175_dark_badged.png](assets/icon175x175_dark_badged.png?raw=1) ![assets/icon175x175_fitrack_dark_badged.png](assets/icon175x175_fitrack_dark_badged.png?raw=1)
---
```
badge --alpha
```

![assets/icon175x175_alpha_light_badged.png](assets/icon175x175_alpha_light_badged.png?raw=1) ![assets/icon175x175_fitrack_alpha_light_badged.png](assets/icon175x175_fitrack_alpha_light_badged.png?raw=1)
---
```
badge --shield "1.2-2031-orange" --no_badge
```

![assets/icon175x175_shield_1.2-2031-orange.png](assets/icon175x175_shield_1.2-2031-orange.png?raw=1) ![assets/icon175x175_fitrack_shield_1.2-2031-orange.png](assets/icon175x175_fitrack_shield_1.2-2031-orange.png?raw=1)
---
```
badge --shield "1.2-2031-orange" --no_badge --shield_no_resize
```

![assets/icon175x175_shield_1.2-2031-orange-no-resize.png](assets/icon175x175_shield_1.2-2031-orange-no-resize.png?raw=1) ![assets/icon175x175_fitrack_shield_1.2-2031-orange-no-resize.png](assets/icon175x175_fitrack_shield_1.2-2031-orange-no-resize.png?raw=1)
---
```
badge --shield "Version-0.0.3-blue" --dark
```

![assets/icon175x175_shield_Version-0.0.3-blue.png](assets/icon175x175_shield_Version-0.0.3-blue.png?raw=1) ![assets/icon175x175_fitrack_shield_Version-0.0.3-blue.png](assets/icon175x175_fitrack_shield_Version-0.0.3-blue.png?raw=1)
---
```
badge --shield "Version-0.0.3-blue" --dark --shield_geometry "+0+25%" --shield_scale 0.75
```

![assets/icon175x175_shield_Version-0.0.3-blue-geo-scale.png](assets/icon175x175_shield_Version-0.0.3-blue-geo-scale.png?raw=1) ![assets/icon175x175_fitrack_shield_Version-0.0.3-blue-geo-scale.png](assets/icon175x175_fitrack_shield_Version-0.0.3-blue-geo-scale.png?raw=1)
---
```
badge --grayscale --shield "Version-0.0.3-blue" --dark
```

![assets/icon175x175_grayscale.png](assets/icon175x175_grayscale.png?raw=1) ![assets/icon175x175_fitrack_grayscale.png](assets/icon175x175_fitrack_grayscale.png?raw=1)
---

# Installation

Install the gem

    sudo gem install badge


# Usage

Call ```badge``` in your projects root folder

    badge

It will search all subfolders for your asset catalog app icon set and add the badge to the icons.

You can also run badge on your Android, tvOS icons, or any other iconset.
You have to use the `--glob "/**/*.appiconset/*.{png,PNG}"` parameter to adjust where to find your icons.

:warning: Note that you have to use a `/` in the beginning of the custom path, even if you're not starting from the root path, f.ex. if your icons are in `res/ios/beta/Appicon/*`, your badge call would be `badge --glob "/res/ios/beta/Appicon/*"`

The keep the alpha channel in the icons use `--alpha_channel`

*Be careful, it actually overwrites the icon files.*

Here is the dark option (also available in combination with ```--alpha```):

	badge --dark

You can also use your custom overlay/badge image

    badge --custom "path_to/custom_badge.png"

Add a shield at the top of your icon for all possibilites head over to: [shields.io](http://shields.io/). You just have to add the string of shield (copied from the URL)

    badge --shield "Version-0.0.3-blue"
    
Sometimes the response from shields.io takes a long time and can timeout. You can adjust the timeout to shields.io with `--shield_io_timeout 10` accordingly.

`--shield_gravity North` changes the postion of the shield on the icon. Choices include: NorthWest, North, NorthEast, West, Center, East, SouthWest, South, SouthEast.

`--shield_parameters "colorA=abcdef&style=flat"` changes the parameters of the shield image. It uses a string of key-value pairs separated by ampersand as specified on shields.io, eg: colorA=abcdef&style=flat.

In version [0.4.0](https://github.com/HazAT/badge/releases/tag/0.4.0) the default behavior of the shield graphic has been changed. The shield graphic will always be resized to **aspect fill** the icon instead of just adding the shield on the icon. The disable to new behaviour use `--shield_no_resize` which now only puts the shield on the icon again.

Add ```--no_badge``` as an option to hide the beta badge completely if you just want to add a shield.

Use `badge --help` to get list all possible parameters.

# Usage with fastlane

Please use the fastlane plugin: https://github.com/HazAT/fastlane-plugin-badge
It has the same parameters as this gem.

```ruby
lane :appstore do
  increment_build_number
  cocoapods

  add_badge(dark: true) #or
  #add_badge(alpha: true) #or
  #add_badge(custom: "/Users/HazA/Desktop/badge.png") #or
  #add_badge(shield: "Version-0.0.3-blue", no_badge: true)

  xctool
  snapshot
  sigh
  deliver
  sh "./customScript.sh"

  slack
end
```

# Common problems

If Jenkins has problems finding imagemagick on your mac add following env variable to your job:

	PATH=$PATH:/usr/local/bin

Make sure you have imagemagick installed on your machine e.g. for Mac its:

	brew install imagemagick

## Uninstall

	sudo gem uninstall badge

# Thanks
[@ThomasMirnig](https://twitter.com/ThomasMirnig) [@KrauseFx](https://twitter.com/KrauseFx) [fastlane](https://github.com/fastlane/fastlane)

# License
This project is licensed under the terms of the MIT license. See the LICENSE file.
