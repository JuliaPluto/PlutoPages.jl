# PlutoPages.jl

This repository will contain "PlutoPages", the site generation system that powers https://github.com/mitmath/computational-thinking

Currently this code is in https://github.com/mitmath/computational-thinking/blob/Fall23/PlutoPages.jl

Contact https://github.com/LucaFerranti for more info!


## During development
Use `PlutoPages.develop` to start developing your website. It will launch two browser tabs: one with the PlutoPages development dashboard, and one with a preview of your website. 

When you make edits to the website source files, they should get detected automatically, and the site is regenerated. If changes are not detected, go to the PlutoPages dashboard and click "Read input files again".

```julia
import PlutoPages

# replace this with the path of your own website
my_site_source = PlutoPages.create_test_basic_site()

PlutoPages.develop(my_site_source)
```


## Generating the site
Use `PlutoPages.generate` if you want to generate your website once, without a development server.



```julia
import PlutoPages

# replace this with the path of your own website
my_site_source = PlutoPages.create_test_basic_site()

output_dir = PlutoPages.generate(my_site_source)
```
