# kakoune-typescript

[typescript](https://www.typescriptlang.org/) support for [kakoune](http://kakoune.org/)

# Install

clone this repo (or simply copy the `typescript.kak` file) and then

    mv typescript.kak ~/.config/kak/autoload/typescript.kak
    
Open a `.ts` file, and you are good to go

# Possible improvements

- handle tuples declarations (`[e1, e2]: [T1, T2]`)
- handle higher order functions (last line of the screenshot)

I think there is a better way to detect arrow functions.
If anyone is inspired, PR are welcomed ;)

# Inspiration

This file is heavily inspired from the original [`javascript.kak` in the kakoune's repo](https://github.com/mawww/kakoune/blob/master/rc/base/javascript.kak)
