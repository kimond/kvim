# kvim

## Getting started
Update your init.lua with

```lua
require("lazy").setup({
  spec = {
     ...
    { "kimond/kvim", import = "kvim.plugins" },
     ...
  },
})
```
For LazyVim users, update `config/lazy.lua` instead.
