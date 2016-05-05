badge - add a badge to your iOS/Android app icon
============

[![Twitter: @DanielGri](https://img.shields.io/badge/contact-@DanielGri-blue.svg?style=flat)](https://twitter.com/DanielGri)
[![License](http://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/HazAT/badge/blob/master/LICENSE)
[![Gem](https://img.shields.io/gem/v/badge.svg?style=flat)](http://rubygems.org/gems/badge)

# Features

This gem helps to add a badge to your iOS/Android app icon.

Yes that's it.
It's built to easily integrate with [fastlane](https://github.com/fastlane/fastlane).

![assets/icon175x175.png](assets/icon175x175.png?raw=1) ![assets/icon175x175_fitrack.png](assets/icon175x175_fitrack.png?raw=1)

	badge

![assets/icon175x175_light_badged.png](assets/icon175x175_light_badged.png?raw=1) ![assets/icon175x175_fitrack_light_badged.png](assets/icon175x175_fitrack_light_badged.png?raw=1)

	badge --dark

![assets/icon175x175_dark_badged.png](assets/icon175x175_dark_badged.png?raw=1) ![assets/icon175x175_fitrack_dark_badged.png](assets/icon175x175_fitrack_dark_badged.png?raw=1)

    badge --alpha

![assets/icon175x175_alpha_light_badged.png](assets/icon175x175_alpha_light_badged.png?raw=1) ![assets/icon175x175_fitrack_alpha_light_badged.png](assets/icon175x175_fitrack_alpha_light_badged.png?raw=1)

	badge --shield="1.2-2031-orange" --no_badge

![assets/icon175x175_shield_1.2-2031-orange.png](assets/icon175x175_shield_1.2-2031-orange.png?raw=1) ![assets/icon175x175_fitrack_shield_1.2-2031-orange.png](assets/icon175x175_fitrack_shield_1.2-2031-orange.png?raw=1)

	badge --shield="1.2-2031-orange" --no_badge --shield_no_resize

![assets/icon175x175_shield_1.2-2031-orange-no-resize.png](assets/icon175x175_shield_1.2-2031-orange-no-resize.png?raw=1) ![assets/icon175x175_fitrack_shield_1.2-2031-orange-no-resize.png](assets/icon175x175_fitrack_shield_1.2-2031-orange-no-resize.png?raw=1)

	badge --shield="Version-0.0.3-blue" --dark

![assets/icon175x175_shield_Version-0.0.3-blue.png](assets/icon175x175_shield_Version-0.0.3-blue.png?raw=1) ![assets/icon175x175_fitrack_shield_Version-0.0.3-blue.png](assets/icon175x175_fitrack_shield_Version-0.0.3-blue.png?raw=1)

	badge --shield="Version-0.0.3-blue" --dark --shield_no_resize

![assets/icon175x175_shield_Version-0.0.3-blue-no-resize.png](assets/icon175x175_shield_Version-0.0.3-blue-no-resize.png?raw=1) ![assets/icon175x175_fitrack_shield_Version-0.0.3-blue-no-resize.png](assets/icon175x175_fitrack_shield_Version-0.0.3-blue-no-resize.png?raw=1)
# Installation

Install the gem

    sudo gem install badge


# Usage

Call ```badge``` in your iOS projects root folder

    badge
    
It will search all subfolders for your asset catalog app icon set and add the badge to the icons. 

But you can also run badge on your Android icons.
You have to use the `--glob="/**/*.appiconset/*.{png,PNG}"` parameter to adjust where to find your icons.

The keep the alpha channel in the icons use `--alpha_channel`
    
*Be careful, it actually overwrites the icon files.*

Here is the dark option (also available in combination with ```--alpha```):

	badge --dark

You can also use your custom overlay/badge image

    badge --custom="path_to/custom_badge.png"
    
Add a shield at the top of your icon for all possibilites head over to: [shields.io](http://shields.io/). You just have to add the string of shield (copied from the URL)

    badge --shield="Version-0.0.3-blue"
    
Sometimes the response from shield.io takes a long time and can timeout. You can adjust the timeout to shield.io with `--shield_io_timeout=10` accordingly.

`--shield_gravity=North` changes the postion of the shield on the icon. Choices include: NorthWest, North, NorthEast, West, Center, East, SouthWest, South, SouthEast.

In version [0.4.0](https://github.com/HazAT/badge/releases/tag/0.4.0) the default behavior of the shield graphic has been changed. The shield graphic will always be resized to **aspect fill** the icon instead of just adding the shield on the icon. The disable to new behaviour use `--shield_no_resize` which now only puts the shield on the icon again.

Add ```--no_badge``` as an option to hide the beta badge completely if you just want to add a shield. 

Use `badge existing_project --help` to get list all possible parameters.

# Usage with fastlane

I try to keep fastlane integration up-to-date with the gem version. So generally you can use every parameter with fastlane which is also available directly in the gem. It mainly depends how fast the pull requests get merged and a new version of fastlane is available. If there is a problem you can always fallback to the fastlane `sh "cd ..; badge --dark"` command to use everything like it is used in the command line.

```ruby
lane :appstore do
  increment_build_number
  cocoapods

  badge(dark: true) #or
  #badge(alpha: true) #or
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
