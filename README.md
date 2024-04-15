# PlutoPages.jl

This repository will contain "PlutoPages", the site generation system that powers https://plutojl.org and https://github.com/mitmath/computational-thinking

Contact https://github.com/LucaFerranti for more info!


# Overview
PluoPages.jl is a site generation system inspired by [https://www.11ty.dev/](https://www.11ty.dev/). It's a tool that turns a folder of files (Pluto notebook, Markdown files, images, and more) into a complete static website, that you can host using a service like GitHub Pages or Netlify. 

PlutoPages searches for input files, and turns them into web pages. There are three **template systems**:
- **`.jlhtml` files** are rendered by [HypertextLiteral.jl](https://github.com/JuliaPluto/HypertextLiteral.jl)
- **`.jlmd` files** are rendered by [MarkdownLiteral.jl](https://github.com/JuliaPluto/MarkdownLiteral.jl)
- **`.jl` files** are rendered by [PlutoSliderServer.jl](https://github.com/JuliaPluto/PlutoSliderServer.jl)

The `/src/` folder is scanned for files, and all files are turned into HTML pages. 

Paths correspond to URLs. For example, `src/en/docs/install.jlmd` will become available at `plutojl.org/en/docs/install/`. For files called *"index"*, the URL will point to its parent, e.g. `src/en/docs/index.jlmd` becomes `plutojl.org/en/docs/`. Remember that changing URLs is very bad! You can't share Pluto with your friends if the links break.

You can generate & preview your website locally (more on this later), and there is a github action that you can use to generate the website when we push to the `main` branch, to deploy your website automatically when you change the code.

# Content

## Literal templates
We use *Julia* as our templating system! Because we use HypertextLiteral and MarkdownLiteral, you can write regular Markdown files and HTML files, but you can also include `$(interpolation)` to spice up your documents! For example:

```markdown
# Hey there!

This is some *text*. Here is a very big number: $(1 + 1).
```

Besides small inline values, you can also write big code blocks, with `$(begin ... end)`, and you can output HTML. Take a look at some of our files to learn more!

## Pluto notebooks

Pluto notebooks will be rendered to HTML and included in the page. What you see is what you get!

We are not running a slider server currently, but we will probably add it in the future!

Notebook outputs are **cached** (for a long time) by the file hash. This means that a notebook file will only ever run once, which makes it much faster to work on the website. If you need to re-run your notebook, add a space somewhere in the code :)

## `.css`, `.html`, `.gif`, etc

Web assets go through the system unchanged.

# Front matter

Like many SSG systems, we use [*front matter*](https://www.11ty.dev/docs/data-frontmatter/) to add metadata to pages. In `.jlmd` files, this is done with a front matter block, e.g.:
```markdown
---
title: "🌼 How to install"
description: "Instructions to install Pluto.jl"
tags: ["docs", "introduction"]
layout: "md.jlmd"
---

# Let's install Pluto

here is how you do it
```

Every page **should probably** include:
- *`title`*: Will be used in the sidebar, on Google, in the window header, and on social media.
- *`description`*: Will be used on hover, on Google, and on social media.
- *`tags`*: List of *tags* that are used to create collections out of pages. Our sidebar uses collections to know which pages to list. (more details in `sidebar data.jl`)
- *`layout`*: The name of a layout file in `src/_includes`. For basic Markdown or HTML, you probably want `md.jlmd`. For Pluto, you should use `layout.jlhtml`.

## How to write front matter
For `.jlmd` files, see the example above. 

For `.jl` notebooks, use the [Frontmatter GUI](https://github.com/fonsp/Pluto.jl/pull/2104) built into Pluto.

For `.jlhtml`, we still need to figure something out 😄.

# Running locally

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


# Developing PlutoPages.jl itself


You need to manually run the notebook with Pluto:
1. Go to this folder, and run `julia --project=pluto-deployment-environment`. Then `import Pkg; Pkg.instantiate();`.
1. `import Pluto; Pluto.run()` and open the `PlutoPages.jl` notebook in this repository. The first run can take some time, as it builds up the notebook outputs cache. Leave it running.
2. In a second terminal, go to this folder, and run `julia --project=pluto-deployment-environment`, then:
    ```julia
	import Deno_jll
	run(`$(Deno_jll.deno()) run --allow-read --allow-net https://deno.land/std@0.102.0/http/file_server.ts _site`)
    ```
3. Go to the URL printed to your terminal. 
4. Whenever you edit a file, PlutoPages will automatically regenerate! Refresh your browser tab. If it does not pick up the change, go to the generation dashboard and click the "Read input files again" button.
