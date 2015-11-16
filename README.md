# MscGen language support in Atom

Syntax highlighting for MscGen and two similar sequence chart languages.

![animated gif demoing syntax highlighting and snippets](https://raw.githubusercontent.com/sverweij/atom-language-mscgen/master/screenshots/language-mscgen.gif)

## Features
- Contextualized syntax highlighting
- Inline expression folding
- Snippets:
    - `msc` - a skeleton sequence chart appropriate for the language
    - `arc` - a single arrow arc: `a =>> b [label="Message"];`
    - `ent` - an entity: `entity [label="Entity"]`
    - `loop` and `arc` - a loop and an arc template (only available in xù
        and msgenny)

## Supported grammars
The three languages supported by the [mscgen_js](https://sverweij.github.io/mscgen_js) library and interpreter:
- **MscGen** (`*.mscgen`, `*.mscin`, `*.msc`)    
  see http://www.mcternan.me.uk/mscgen
- **Xù** (`*.xu`)    
  Adds inline expressions like `alt` and `loop` to MscGen. See
  the [Xù wiki page](https://github.com/sverweij/mscgen_js/blob/master/wikum/xu.md) for more information.
- **MsGenny** (`*.msgenny`)    
  Xù with a simplified syntax. And a little less features.
  The [MsGenny wiki page](https://github.com/sverweij/mscgen_js/blob/master/wikum/msgenny.md) has more information.
  

## License
[GPL-3.0 ](LICENSE.md)
