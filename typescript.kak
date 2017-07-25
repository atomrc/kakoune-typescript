# Detection
# ‾‾‾‾‾‾‾‾‾

hook global BufCreate .*[.](ts|tsx) %{
    set buffer filetype typescript
}

# Highlighters
# ‾‾‾‾‾‾‾‾‾‾‾‾

add-highlighter -group / regions -default code typescript \
    double_string '"'  (?<!\\)(\\\\)*"         '' \
    single_string "'"  (?<!\\)(\\\\)*'         '' \
    literal       "`"  (?<!\\)(\\\\)*`         '' \
    comment       //   '$'                     '' \
    comment       /\*  \*/                     '' \
    regex         /    (?<!\\)(\\\\)*/[gimuy]* '' \
    functionDecl '(?<=function)' '\).*{'       '' \
    functionDecl '\([^)]*\)\s*='  '>'       '' \
    jsx          '<[/]\w'      '>'             '' \
    division '[\w\)\]](/|(\h+/\h+))' '\w'      '' \ # Help Kakoune to better detect /…/ literals

# Regular expression flags are: g → global match, i → ignore case, m → multi-lines, u → unicode, y → sticky
# https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/RegExp

add-highlighter -group /typescript/double_string fill string
add-highlighter -group /typescript/single_string fill string
add-highlighter -group /typescript/regex         fill meta
add-highlighter -group /typescript/comment       fill comment
add-highlighter -group /typescript/literal       fill string
add-highlighter -group /typescript/literal       regex \${.*?} 0:value

add-highlighter -group /typescript/code regex \b(document|false|null|parent|self|this|true|undefined|window)\b 0:value
add-highlighter -group /typescript/code regex "-?[0-9]*\.?[0-9]+" 0:value
add-highlighter -group /typescript/code regex \b(Array|Boolean|Date|Function|Number|Object|RegExp|String|Symbol)\b 0:type

# Keywords are collected at
# https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Lexical_grammar#Keywords
add-highlighter -group /typescript/code regex \b(async|await|break|case|catch|class|const|continue|debugger|default|delete|do|else|export|extends|finally|for|function|if|import|in|instanceof|let|new|of|return|super|switch|throw|try|typeof|var|void|while|with|yield)\b 0:keyword

add-highlighter -group /typescript/functionDecl regex ':\s*([a-zA-Z<>]+)' 1:type
add-highlighter -group /typescript/functionDecl regex '[(,]+\s*([\w$]+)\s*:?' 1:variable
#add-highlighter -group /typescript/functionDecl fill comment

# Commands
# ‾‾‾‾‾‾‾‾

def -hidden typescript-filter-around-selections %{
    # remove trailing white spaces
    try %{ exec -draft -itersel <a-x> s \h+$ <ret> d }
}

def -hidden typescript-indent-on-char %<
    eval -draft -itersel %<
        # align closer token to its opener when alone on a line
        try %/ exec -draft <a-h> <a-k> ^\h+[]}]$ <ret> m s \`|.\' <ret> 1<a-&> /
    >
>

def -hidden typescript-indent-on-new-line %<
    eval -draft -itersel %<
        # copy // comments prefix and following white spaces
        try %{ exec -draft k <a-x> s ^\h*\K#\h* <ret> y gh j P }
        # preserve previous line indent
        try %{ exec -draft \; K <a-&> }
        # filter previous line
        try %{ exec -draft k : typescript-filter-around-selections <ret> }
        # indent after lines beginning / ending with opener token
        try %_ exec -draft k <a-x> <a-k> ^\h*[[{]|[[{]$ <ret> j <a-gt> _
    >
>

# Initialization
# ‾‾‾‾‾‾‾‾‾‾‾‾‾‾

hook -group typescript-highlight global WinSetOption filetype=typescript %{ add-highlighter ref typescript }

hook global WinSetOption filetype=typescript %{
    hook window InsertEnd  .* -group typescript-hooks  typescript-filter-around-selections
    hook window InsertChar .* -group typescript-indent typescript-indent-on-char
    hook window InsertChar \n -group typescript-indent typescript-indent-on-new-line
}

hook -group typescript-highlight global WinSetOption filetype=(?!typescript).* %{ remove-highlighter typescript }

hook global WinSetOption filetype=(?!typescript).* %{
    remove-hooks window typescript-indent
    remove-hooks window typescript-hooks
}
