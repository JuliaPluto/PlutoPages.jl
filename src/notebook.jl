### A Pluto.jl notebook ###
# v0.20.14

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    #! format: off
    return quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
    #! format: on
end

# ╔═╡ 658b1b24-a7b2-47ab-ba53-b570dfeb8bfa
begin
	# When the PlutoPages.jl package runs this notebook, it will override this variable.
	# Instead of `nothing`, the value will be a Tuple{String,Vector{String}} containg `(Base.activate_project(), LOAD_PATH)`.
	# 
	# But if you're reading this, then no override happened, because you are developing this notebook yourself. In this case, the project environment of PlutoPages should have been activated.
	const override_ap_lp = nothing

	# import Pkg here to help the dependency sorting algorithm
	import Pkg
end

# ╔═╡ b8024c95-6a63-4409-9c75-9bad6b301a92
begin
	# when the `override_ap_lp` cell gets overriden, the `import Pkg` disappears, here's the fix
	eval(:(import Pkg))
	
	if override_ap_lp === nothing
		Pkg.activate(dirname(@__DIR__))
	else
		ap, lp = override_ap_lp
		Pkg.activate(ap)
		copy!(LOAD_PATH, lp)
	end

	# huh why do we import PlutoPages into itself? That's so that we can load the dependencies of PlutoPages... yay!
	import PlutoPages

	ap_lp_ready = true
end

# ╔═╡ 6f2d5ce1-0f60-4551-8d39-62c66f72f175
begin
	@assert ap_lp_ready
	# all imports need to be in this cell!

	# and all imports have to come from the PlutoPages package! like so:

	# NOT:
	# import PlutoSliderServer
	
	# YES:
	import PlutoPages.PlutoSliderServer
	import PlutoPages.Pluto
	import PlutoPages.Gumbo
	import PlutoPages.ProgressLogging
	import PlutoPages.ThreadsX
	import PlutoPages.CommonMark
	import PlutoPages.YAML
	import PlutoPages.JSON
	
	using PlutoPages.HypertextLiteral
	using PlutoPages.MarkdownLiteral
	using PlutoPages.PlutoUI

	using PlutoPages.PlutoHooks
	using PlutoPages.PlutoLinks
	using PlutoPages.BetterFileWatching

	# except stdlibs, they are fine
	import Logging, SHA, Unicode
end

# ╔═╡ 2b7d1ee2-0f71-4091-aec2-cde62d2b6b36
md"""
# Package imports
"""

# ╔═╡ c5a0b072-7f49-4c0c-855e-773cfc03d308
TableOfContents(include_definitions=true)

# ╔═╡ cd576da6-59ae-4d1b-b812-1a35023b6875
md"""
# `Base.map` with progress and multithreading
"""

# ╔═╡ 86471faf-af03-4f35-8b95-c4011ceaf7c3
function progressmap_generic(mapfn, f, itr; kwargs...)
	l = length(itr)
	id = gensym()
	num_iterations = Threads.Atomic{Int}(0)
	
	function log(x)
		Threads.atomic_add!(num_iterations, x)
		Logging.@logmsg(ProgressLogging.ProgressLevel, "", progress=num_iterations[] / l, id=id)
	end

	log(0)
	
	output = mapfn(enumerate(itr); kwargs...) do (i,x)
		result = f(x)
		log(1)
		result
	end

	log(0)
	output
end

# ╔═╡ e0ae20f5-ffe7-4f0e-90be-168924526e03
"Like `Base.map`, but with ProgressLogging."
function progressmap(f, itr)
	progressmap_generic(map, f, itr)
end

# ╔═╡ d58f2a89-4631-4b19-9d60-5e590908b61f
"Like `Base.asyncmap`, but with ProgressLogging."
function progressmap_async(f, itr; kwargs...)
	progressmap_generic(asyncmap, f, itr; kwargs...)
end

# ╔═╡ 2221f133-e490-4e3a-82d4-bd1c6c979d1c
"Like `ThreadsX.map`, but with ProgressLogging."
function progressmap_threaded(f, itr; kwargs...)
	progressmap_generic(ThreadsX.map, f, itr; kwargs...)
end

# ╔═╡ 6c8e76ea-d648-449a-89de-cb6632cdd6b9
md"""
# Template systems

A **template** system is will turn an input file (markdown, julia, nunjucks, etc.) into an (HTML) output. This architecture is based on [eleventy](https://www.11ty.dev/docs/).

To register a template handler for a file extension, you add a method to `template_handler`, e.g.

```julia
function template_handler(
	::Val{Symbol(".md")}, 
	input::TemplateInput
)::TemplateOutput

	s = String(input.contents)
	result = run_markdown(s)
	
	return TemplateOutput(;
		contents=result.contents,
		front_matter=result.front_matter,
	)
end
```

See `TemplateInput` and `TemplateOutput` for more info!
"""

# ╔═╡ 4a2dc5a4-0bf2-4678-b984-4ecb7b397d72
md"""
## `.jlhtml`: HypertextLiteral.jl
"""

# ╔═╡ b3ce7742-fb47-4c17-bac2-e6a7710eb1a1
md"""
## `.md` and `.jlmd`: MarkdownLiteral.jl
"""

# ╔═╡ 90f0c676-b33f-441c-8ea6-d59c44a11547
s_example = raw"""
---
title: "Hello worfdsld!"
description: "A longer description of the same thing"
authors: ["Fonsi"]
---

### Hello there!

My name is <em>fons</em>

<ul>
$(map(1:num) do i
	@mdx ""\"<li>That's $i cool</li>""\"
end)
</ul>

Want to embed some cool HTML? *Easy!* Just type the HTML! **or markdown**, it's all the same!! 👀

```math
\\sqrt{\\frac{1}{2}}
````

$(begin
a = 1
b = 2
export b
end)

"""

# ╔═╡ 5381e8b3-d4f9-4e58-8da3-f1ee0a9b7a6d
@bind s TextField((70,20); default=s_example)

# ╔═╡ 08b42df7-9120-4b42-80ee-8e438752b50c
# s_result.exported

# ╔═╡ adb1ddac-d992-49ca-820f-e1ed8ca33bf8
md"""
## `.jl`: PlutoSliderServer.jl
"""

# ╔═╡ bb905046-59b7-4da6-97ad-dbb9055d823a
const pluto_deploy_settings = PlutoSliderServer.get_configuration(PlutoSliderServer.default_config_path())

# ╔═╡ b638df55-fd74-4ae8-bdbd-ec7b18214b40
function prose_from_code(s::String)::String
	replace(replace(
		replace(
			replace(s, 
				# remove embedded project/manifest
				r"000000000001.+"s => ""),
			# remove cell delimiters
			r"^# [╔╟╠].*"m => ""), 
		# remove some code-only punctiation
		r"[\!\#\$\*\+\-\/\:\;\<\>\=\(\)\[\]\{\}\:\@\_]" => " "), 
	# collapse repeated whitespace
	r"\s+"s => " ")
end

# ╔═╡ 87b4431b-438b-4da4-9d06-79e7f3a2fe05
prose_from_code("""
[xs for y in ab(d)]
fonsi
""")

# ╔═╡ cd4e479c-deb7-4a44-9eb0-c3819b5c4067
find(f::Function, xs) = for x in xs
	if f(x)
		return x
	end
end

# ╔═╡ 2e527d04-e4e7-4dc8-87e6-8b3dd3c7688a
const FrontMatter = Dict{String,Any}

# ╔═╡ a166e8f3-542e-4068-a076-3f5fd4daa61c
Base.@kwdef struct TemplateInput
	contents::Vector{UInt8}
	relative_path::String
	absolute_path::String
	frontmatter::FrontMatter=FrontMatter()
end

# ╔═╡ 6288f145-444b-41cb-b9e3-8f273f9517fb
begin
	Base.@kwdef struct TemplateOutput
		contents::Union{Vector{UInt8},String,Nothing}
		file_extension::String="html"
		frontmatter::FrontMatter=FrontMatter()
		search_index_data::Union{Nothing,String}=nothing
	end
	TemplateOutput(t::TemplateOutput; kwargs...) = TemplateOutput(;
		contents=t.contents,
		file_extension=t.file_extension,
		frontmatter=t.frontmatter,
		search_index_data=t.search_index_data,
		kwargs...,
	)
end

# ╔═╡ ff55f7eb-a23d-4ca7-b428-ab05dcb8f090
# fallback method
function template_handler(::Any, input::TemplateInput)::TemplateOutput
	TemplateOutput(;
		contents=nothing,
		file_extension="nothing",
	)
end

# ╔═╡ 692c1e0b-07e1-41b3-abcd-2156bda65b41
"""
Turn a MarkdownLiteral.jl string into HTML contents and front matter.
"""
function run_mdx(s::String; 
		data::Dict{String,<:Any}=Dict{String,Any}(),
		cm::Bool=true,
		filename::AbstractString="unknown",
	)
	# take a look at https://github.com/JuliaPluto/MarkdownLiteral.jl if you want to use it this too!

	# Just HTL, CommonMark parsing comes in a later step
	code = "@htl(\"\"\"$(s)\"\"\")"

	m = Module()
	Core.eval(m, :(var"@mdx" = var"@md" = $(MarkdownLiteral.var"@mdx")))
	Core.eval(m, :(var"@htl" = $(HypertextLiteral.var"@htl")))
	# Core.eval(m, :(setpage = $(setpage)))
	Core.eval(m, :(using Markdown, InteractiveUtils))
	for (k,v) in data
		Core.eval(m, :($(Symbol(k)) = $(v)))
	end

	result = Base.include_string(m, code, filename)

	to_render, frontmatter = if !cm
		result, FrontMatter()
	else
	
		# we want to apply our own CM parser, so we do the MarkdownLiteral.jl trick manually:
		cm_parser = CommonMark.Parser()
	    CommonMark.enable!(cm_parser, [
	        CommonMark.AdmonitionRule(),
	        CommonMark.AttributeRule(),
	        CommonMark.AutoIdentifierRule(),
	        CommonMark.CitationRule(),
	        CommonMark.FootnoteRule(),
	        CommonMark.MathRule(),
	        CommonMark.RawContentRule(),
	        CommonMark.TableRule(),
	        CommonMark.TypographyRule(),
			# TODO: allow Julia in front matter by using Meta.parse as the TOML parser?
			# but you probably want to be able to use those variables inside the document, so they have to be evaluated *before* running the expr.
	        CommonMark.FrontMatterRule(yaml=YAML.load),
	    ])
	
		result_str = repr(MIME"text/html"(), result)
		ast = cm_parser(result_str)

		ast, CommonMark.frontmatter(ast)
	end
	
	contents = repr(MIME"text/html"(), to_render)

	# TODO: might be nice:
	# exported = filter(names(m; all=false, imported=false)) do s
	# 	s_str = string(s)
	# 	!(startswith(s_str, "#") || startswith(s_str, "anonymous"))
	# end
	
	(; 
		contents, 
		frontmatter, 
		# exported,
	)
end

# ╔═╡ 7717e24f-62ee-4852-9dec-d09b734d0693
s_result = run_mdx(s; data=Dict("num" => 3));

# ╔═╡ 9f945292-ff9e-4f29-93ea-69b10fc4428d
s_result.contents |> HTML

# ╔═╡ 83366d96-4cd3-4def-a0da-16a22b40124f
s_result.frontmatter

# ╔═╡ 94bb6730-a4ad-42d2-aa58-41b70a15cd0e
md"""
## `.css`, `.html`, `.js`, `.png`, etc: passthrough

"""

# ╔═╡ e15cf987-3615-4e96-8ccd-04cad3bcd48e
function template_handler(::Union{
		Val{Symbol(".css")},
		Val{Symbol(".html")},
		Val{Symbol(".js")},
		Val{Symbol(".png")},
		Val{Symbol(".svg")},
		Val{Symbol(".gif")},
		Val{Symbol(".json")},
		Val{Symbol(".mov")},
		Val{Symbol(".mp4")},
		Val{Symbol(".webm")},
		Val{Symbol(".wav")},
		Val{Symbol(".mp3")},
		Val{Symbol(".ogg")},
		Val{Symbol(".webp")},
	}, input::TemplateInput)::TemplateOutput

	TemplateOutput(;
		contents=input.contents,
		file_extension=lstrip(isequal('.'), splitext(input.relative_path)[2]),
	)
end

# ╔═╡ 940f3995-1739-4b30-b8cf-c27a671043e5
md"""
## Generated assets
"""

# ╔═╡ 5e91e7dc-82b6-486a-b745-34f97b6fb20c
struct RegisteredAsset
	url::String
	relative_path::String
	absolute_path::String
end

# ╔═╡ 070c710d-3746-4706-bd03-b5b00a576007
function myhash(data)
	s = SHA.sha256(data)
	string(reinterpret(UInt32, s)[1]; base=16, pad=8)
end

# ╔═╡ a5c22f80-58c7-4c63-95b8-ecb30bc896d0
myhash(rand(UInt8, 50))

# ╔═╡ 750782a1-3aeb-4816-8f6a-ec31055373c1
legalize(filename) = replace(
	Unicode.normalize(
		replace(filename, " " => "_");
		stripmark=true)
	, r"[^\w-]" => "")

# ╔═╡ f6b89b8c-3750-4dd2-940e-579be953c1c2
legalize(" ëasdfa sd23__--f//asd f?\$%^&*() .")

# ╔═╡ 29a81ad7-3803-4b7a-98ca-6e5b1077e1c7
md"""
# Input folder
"""

# ╔═╡ c52c9786-a25f-11ec-1fdc-9b13922d7ccb
const input_dir = joinpath(@__DIR__, "src")

# ╔═╡ cf27b3d3-1689-4b3a-a8fe-3ad639eb2f82
md"""
## File watching
"""

# ╔═╡ 7f7f1981-978d-4861-b840-71ab611faf74
@bind manual_update_trigger Button("Read input files again")

# ╔═╡ e1a87788-2eba-47c9-ab4c-74f3344dce1d
ignored_dirname(s; allow_special_dirs::Bool=false) = 
	startswith(s, "_") && (!allow_special_dirs || s != "_includes")

# ╔═╡ 485b7956-0774-4b25-a897-3d9232ef8590
const this_file = split(@__FILE__, "#==#")[1]

# ╔═╡ d38dc2aa-d5ba-4cf7-9f9e-c4e4611a57ac
function ignore(abs_path; allow_special_dirs::Bool=false)
	p = relpath(abs_path, input_dir)

	# (_cache, _site, _andmore)
	any(x -> ignored_dirname(x; allow_special_dirs), splitpath(p)) || 
		startswith(p, ".git") ||
		startswith(p, ".vscode") ||
		abs_path == this_file
end

# ╔═╡ 8da0c249-6094-49ab-9e59-d6e356818651
dir_changed_time = let
	valx, set_valx = @use_state(time())

	@info "Starting watch task"
	
	@use_task([input_dir]) do
		BetterFileWatching.watch_folder(input_dir) do e
			@debug "File event" e
			try
				is_caused_by_me = all(x -> ignore(x; allow_special_dirs=true), e.paths)

				if !is_caused_by_me
					@info "Reloading!" e
					set_valx(time())
				end
			catch e
				@error "Failed to trigger" exception=(e,catch_backtrace())
			end
		end
	end

	valx
end

# ╔═╡ 7d9cb939-da6b-4961-9584-a905ad453b5d
allfiles = filter(PlutoSliderServer.list_files_recursive(input_dir)) do p
	# reference to retrigger when files change
	dir_changed_time
	manual_update_trigger
	
	!ignore(joinpath(input_dir, p))
end

# ╔═╡ d314ab46-b866-44c6-bfca-9a413bc06514
md"""
# Output folder generation
"""

# ╔═╡ e01ebbab-dc9a-4aaf-ae16-200d171fcbd9
const output_dir = mkpath(joinpath(@__DIR__, "_site"))

# ╔═╡ 37b2cecc-e4c7-4b80-b7d9-71c68f3c0339


# ╔═╡ 7a95681a-df77-408f-919a-2bee5afd7777
# This directory can be used to store cache files that are persisted between builds. Currently used as PlutoSliderServer.jl cache.
const cache_dir = mkpath(joinpath(@__DIR__, "_cache"))

# ╔═╡ f3d225b8-b9a5-4639-97eb-7785b1a78f5a
md"""
## Running a dev web server
"""

# ╔═╡ c3a495c1-3e1f-42a1-ac08-8dc0b9175fe9
# import PlutoPages.Deno_jll

# ╔═╡ 3b2d1919-41d9-4bba-9774-c8497bba5003
# dev_server_port = 4507

# ╔═╡ 6f7f66e8-ed10-4cc4-8672-a06861111aec
# dev_server_url = "http://localhost:$(dev_server_port)/"

# ╔═╡ d09ee809-33d8-44f8-aa7a-be4b3fdc21eb


# ╔═╡ a0a80dce-2199-45b6-b4e9-d4168f520c85
# @htl("<div style='font-size: 2rem;'>Go to <a href=$(dev_server_url)><code>$(dev_server_url)</code></a> to preview the site.</div>")

# ╔═╡ 4e88cf07-8d85-4327-b310-6c71ba951bba
md"""
## Running the templates

(This can take a while if you are running this for the first time with an empty cache.)
"""

# ╔═╡ f700357f-e21c-4d23-b56c-be4f9c90465f
const NUM_PARALLEL_WORKERS = 4

# ╔═╡ aaad71bd-5425-4783-952c-82e4d4fa7bb8
md"""
## URL generation
"""

# ╔═╡ 76c2ac85-2e89-4396-a498-a4ceb1cc80bd
Base.@kwdef struct Page
	url::String
	full_url::String
	input::TemplateInput
	output::TemplateOutput
end

# ╔═╡ a510857f-528b-43e8-be78-69e554d165a6
function short_url(s::String)
	a = replace(s, r"index.html$" => "")
	isempty(a) ? "." : a
end

# ╔═╡ 1c269e16-65c7-47ae-aeab-001f1b205e14
ishtml(output::TemplateOutput) = output.file_extension == "html"

# ╔═╡ 898eb093-444c-45cf-88d7-3dbe9708ae31
function final_url(input::TemplateInput, output::TemplateOutput)::String
	if ishtml(output)
		# Examples:
		#   a/b.jl   	->    a/b/index.html
		#   a/index.jl  ->    a/index.html
		
		in_dir, in_filename = splitdir(input.relative_path)
		in_name, in_ext = splitext(in_filename)

		if in_name == "index"
			joinpath(in_dir, "index.html")
		else
			joinpath(in_dir, in_name, "index.html")
		end
	else
		ext = lstrip(isequal('.'), output.file_extension)
		join((splitext(input.relative_path)[1], ".", ext))
	end
end

# ╔═╡ 76193b12-842c-4b82-a23e-fb7403274234
md"""
## Collections from `tags`
"""

# ╔═╡ 4f563136-fc7b-4322-92ba-78c0183c40cc
struct Collection
	tag::String
	pages::Vector{Page}
end

# ╔═╡ 41ab51f9-0b33-4548-b08a-ad1ef7d38f1b
function sort_by(p::Page)
	bn = basename(p.input.relative_path)
	order_val = get(p.output.frontmatter, "order", nothing)
	order = something(order_val isa String ? tryparse(Float64, order_val) : order_val, Inf)
	
	return (
		order,
		splitext(bn)[1] != "index",
		# TODO: sort based on dates if we ever need that
		bn,
	)
end

# ╔═╡ b0006e61-b037-41ed-a3e4-9962d15584c4
md"""
## Layouts
"""

# ╔═╡ f2fbcc70-a714-4eda-8786-7ee5692e3268
with_doctype(p::Page) = Page(p.url, p.full_url, p.input, with_doctype(p.output))

# ╔═╡ 57fd383b-d791-4170-a353-f839356f9d7a
with_doctype(output::TemplateOutput) = if ishtml(output) && output.contents !== nothing
	TemplateOutput(output;
		contents="<!DOCTYPE html>" * String(output.contents)
	)
else
	output
end

# ╔═╡ 05f735e0-01cc-4276-a3f9-8420296e68be
md"""
## Search index
"""

# ╔═╡ 6460cf11-ae78-47e3-9ac1-649295e76ddc
md"""
## `pluto_export.json`
We generate a [ `pluto_export.json` just like PSS.jl](https://github.com/JuliaPluto/PlutoSliderServer.jl/pull/68).
"""

# ╔═╡ 1a303aa4-bed5-4d9b-855c-23355f4a88fe
md"""
## Writing to the output directory
"""

# ╔═╡ eef54261-767a-4ce4-b549-0b1828379f7e
SafeString(x) = String(x)

# ╔═╡ cda8689d-9ae5-42c4-8e7e-715cf44c33bb
SafeString(x::Vector{UInt8}) = String(copy(x))

# ╔═╡ 995c6810-8df2-483d-a87a-2277af0d43bd
function template_handler(
	::Union{Val{Symbol(".jlhtml")}}, 
	input::TemplateInput)::TemplateOutput
	s = SafeString(input.contents)
	result = run_mdx(s; 
		data=input.frontmatter, 
		cm=false,
		filename=input.absolute_path,
	)
	
	return TemplateOutput(;
		contents=result.contents,
		search_index_data=Gumbo.text(Gumbo.parsehtml(result.contents).root),
		frontmatter=result.frontmatter,
	)
end

# ╔═╡ 7e86cfc7-5439-4c7a-9c3b-381c776d8371
function template_handler(
	::Union{
		Val{Symbol(".jlmd")},
		Val{Symbol(".md")}
	}, 
	input::TemplateInput)::TemplateOutput
	s = SafeString(input.contents)
	result = run_mdx(s; 
		data=input.frontmatter,
		filename=input.absolute_path,
	)
	
	return TemplateOutput(;
		contents=result.contents,
		search_index_data=Gumbo.text(Gumbo.parsehtml(result.contents).root),
		frontmatter=result.frontmatter,
	)
end

# ╔═╡ 4013400c-acb4-40fa-a826-fd0cbae09e7e
reprhtml(x) = repr(MIME"text/html"(), x)

# ╔═╡ 5b325b50-8984-44c6-8677-3c6bc5c2b0b1
"A magic token that will turn into a relative URL pointing to the website root when used in output."
const root_url = "++magic#root#url~$(string(rand(UInt128),base=62))++"

# ╔═╡ 0d2b7382-2ddf-48c3-90c8-bc22de454c97
"""
```julia
register_asset(contents, original_name::String)
```

Place an asset in the `/generated_assets/` subfolder of the output directory and return a [`RegisteredAsset`](@ref) referencing it for later use. (The original filename will be sanitized, and a content hash will be appended.)

To be used inside `process_file` methods which need to generate additional files. You can use `registered_asset.url` to get a location-independent href to the result.
"""
function register_asset(contents, original_name::String)
	h = myhash(contents)
	n, e = splitext(basename(original_name))
	
	
	mkpath(joinpath(output_dir, "generated_assets"))
	newpath = joinpath(output_dir, "generated_assets", "$(legalize(n))_$(h)$(e)")
	write(newpath, contents)
	rel = relpath(newpath, output_dir)
	return RegisteredAsset(joinpath(root_url, rel), rel, newpath)
end

# ╔═╡ e2510a44-df48-4c05-9453-8822deadce24
function template_handler(
	::Val{Symbol(".jl")}, 
	input::TemplateInput
)::TemplateOutput

	
	if Pluto.is_pluto_notebook(input.absolute_path)
		temp_out = mktempdir()
		Logging.with_logger(Logging.NullLogger()) do
			PlutoSliderServer.export_notebook(
				input.absolute_path;
				Export_create_index=false,
				Export_cache_dir=cache_dir,
				Export_baked_state=false,
				Export_baked_notebookfile=false,
				Export_output_dir=temp_out,
			)
		end
		d = readdir(temp_out)

		statefile = find(contains("state") ∘ last ∘ splitext, d)
		notebookfile = find(!contains("html") ∘ last ∘ splitext, d)

		reg_s = register_asset(read(joinpath(temp_out, statefile)), statefile)
		reg_n = register_asset(read(joinpath(temp_out, notebookfile)), notebookfile)

		# TODO these relative paths can't be right...
		h = @htl """
		<pluto-editor $((
			statefile=reg_s.url,
			notebookfile=reg_n.url,
			slider_server_url=pluto_deploy_settings.Export.slider_server_url,
			binder_url=pluto_deploy_settings.Export.binder_url,
			disable_ui=true,
		))></pluto-editor>
		"""

		frontmatter = Pluto.frontmatter(input.absolute_path)
		frontmatter["plutopages_statefile_url"] = reg_s.url
		frontmatter["plutopages_notebook_url"] = reg_n.url
		
		return TemplateOutput(;
			contents = repr(MIME"text/html"(), h),
			search_index_data=prose_from_code(SafeString(input.contents)),
			frontmatter,
		)
	else
		
		s = SafeString(input.contents)
	
		h = @htl """
		<pre class="language-julia"><code>$(s)</code></pre>
		"""
		
		return TemplateOutput(;
			contents=repr(MIME"text/html"(), h),
			search_index_data=prose_from_code(s),
		)
	end
end

# ╔═╡ 079a6399-50eb-4dee-a36d-b3dcb81c8456
template_results = let
	if isdir(joinpath(output_dir, "generated_assets"))
		rm(joinpath(output_dir, "generated_assets"); recursive=true)
	end
	
	# let's go! running all the template handlers
	progressmap_async(allfiles; ntasks=NUM_PARALLEL_WORKERS) do f
		absolute_path = joinpath(input_dir, f)
		
		input = TemplateInput(;
			contents=read(absolute_path),
			absolute_path,
			relative_path=f,
			frontmatter=FrontMatter(
				"root_url" => root_url,
			),
		)
		
		output = try
			template_handler(Val(Symbol(splitext(f)[2])), input)
		catch e
			@error "Template handler failed" f exception=(e,catch_backtrace())
			rethrow()
		end

		input, output
	end
end

# ╔═╡ 318dc59e-15f6-4b25-bcf5-1ab6b0d87af7
pages = Page[
	let
		u = final_url(input, output)
		Page(
			 short_url(u), u, input, output,
		)
	end
	for (input, output) in template_results if output.contents !== nothing
]

# ╔═╡ f93da14a-e4c8-4c28-ab01-4a5ba1a3cf47
collections = let
	result = Dict{String,Set{Page}}()

	for page in pages
		for t in get(page.output.frontmatter, "tags", String[])
			old = get!(result, t, Set{Page}())
			push!(old, page)
		end
	end


	Dict{String,Collection}(
		k => Collection(k, sort(collect(v); by=sort_by)) for (k,v) in result
	)
end

# ╔═╡ c2ee20be-16f5-47a8-851a-67a361bb0316
"""
```julia
process_layouts(page::Page)::Page
```

Recursively apply the layout specified in the frontmatter, returning a new `Page` with updated `output`.
"""
function process_layouts(page::Page)::Page
	output = page.output
	
	if haskey(output.frontmatter, "layout")
		@assert output.file_extension == "html" "Layout is not (yet) supported on non-HTML outputs."
		
		layoutname = output.frontmatter["layout"]
		@assert layoutname isa String
		layout_file = joinpath(input_dir, "_includes", layoutname)
		@assert isfile(layout_file) "$layout_file is not a valid layout path"


		content = if ishtml(output)
			HTML(SafeString(output.contents))
		else
			output.contents
		end
		
		input = TemplateInput(;
			contents=read(layout_file),
			absolute_path=layout_file,
			relative_path=relpath(layout_file, input_dir),
			frontmatter=merge(output.frontmatter, 
				FrontMatter(
					"content" => content,
					"page" => page,
					"collections" => collections,
					"root_url" => root_url,
				),
			)
		)

		result = template_handler(Val(Symbol(splitext(layout_file)[2])), input)
		
		@assert result.file_extension == "html" "Non-HTML output from Layouts is not (yet) supported."


		
		old_frontmatter = copy(output.frontmatter)
		delete!(old_frontmatter, "layout")
		new_frontmatter = merge(old_frontmatter, result.frontmatter)

		process_layouts(Page(
			page.url,
			page.full_url,
			page.input,
			TemplateOutput(
				result;
				search_index_data=output.search_index_data,
				frontmatter=new_frontmatter,
			),
		))
	else
		page
	end
end

# ╔═╡ 06edb2d7-325f-4f80-8c55-dc01c7783054
rendered_results = progressmap(with_doctype ∘ process_layouts, pages)

# ╔═╡ d8e9b950-6e71-40e2-bac1-c3ba85bc83ee
collected_search_index_data = [
	(
		url=page.url::String,
		title=get(
			page.output.frontmatter, "title", 
			splitext(basename(page.input.relative_path))[1]
		)::String,
		description=string(get(page.output.frontmatter, "description", "")),
		tags=get(page.output.frontmatter, "tags", String[]),
		text=page.output.search_index_data,
	)
	for page in rendered_results if page.output.search_index_data !== nothing
]

# ╔═╡ 608ed895-3a62-4c11-8026-40120ab05af1
config_json_data = let
	page = find(p -> basename(p.url) == "pluto_export_configuration.json", rendered_results)
	page === nothing ? Dict{String,Any}() : JSON.parse(SafeString(page.input.contents))
end

# ╔═╡ bcf1ebd7-c5b7-44c9-9135-c632b4fae1b6
index_json_from_pss = (
	isdefined(PlutoSliderServer, :index_json_data) ?
	PlutoSliderServer.index_json_data :
	PlutoSliderServer.var"../IndexJSON.jl".json_data
	)(
		PlutoSliderServer.NotebookSession[];
		settings=pluto_deploy_settings, 
		start_dir="doesnotmatter", 
		config_data=config_json_data
	)

# ╔═╡ 52fc3e5e-21a6-4357-9e63-8a70a6e6deb8
function index_json_data(page::Page)
	r(s) = replace(s, root_url => ".")
	
	(
		id=page.url,
		hash=PlutoSliderServer.plutohash(page.input.contents),
		statefile_path=r(page.output.frontmatter["plutopages_statefile_url"]),
		notebookfile_path=r(page.output.frontmatter["plutopages_notebook_url"]),
		html_path=page.full_url,
		frontmatter=page.output.frontmatter,
	)
end

# ╔═╡ d7a01c06-7174-4e6d-b02d-79c953ecdb79
index_json = let
	nbz = filter(rendered_results) do page
		haskey(page.output.frontmatter, "plutopages_statefile_url")
	end
	
	(;
		index_json_from_pss...,
		notebooks=Dict(page.url => index_json_data(page) for page in nbz),
	)
end

# ╔═╡ 9845db00-149c-45be-9e4f-55d1157afc87
process_results = let
	old_paths = map(readdir(output_dir)) do f
		joinpath(output_dir, f)
	end
	
	# create the new files
	write_outputs = map(rendered_results) do page
		input = page.input
		output = page.output
		
		if output !== nothing && output.contents !== nothing
			
			# TODO: use front matter for permalink

			output_path = joinpath(output_dir, page.full_url)
			mkpath(output_path |> dirname)
			# Our magic root url:
			# in Julia, you can safely call `String` and `replace` on arbitrary, non-utf8 data :)
			write(output_path, 
				replace(SafeString(output.contents), root_url => relpath(output_dir, output_path |> dirname))
			)
			
			output_path
		end
	end
	new_paths = filter(!isnothing, write_outputs)

	# write the extra json files
	for (p,d) in [
		("pluto_export.json", index_json),
		("pp_search_data.json", collected_search_index_data),
	]
		output_path = joinpath(output_dir, p)
		push!(new_paths, output_path)
		write(output_path, JSON.json(d))
	end
	
	to_delete = filter(old_paths) do f
		if occursin("generated_assets", f)
			false
		elseif isfile(f)
			f ∉ new_paths
		elseif isdir(f)
			!any(new_paths) do p
				startswith(p, joinpath(f, ""))
			end
		else
			true
		end
	end
	# delete any old files
	for f in to_delete
		rm(f; recursive=true)
	end
	
	write_outputs
end

# ╔═╡ 70fa9af8-31f9-4e47-b36b-828c88166b3d
md"""
# Verify output
"""

# ╔═╡ d17c96fb-8459-4527-a139-05fdf74cdc39
allfiles_output = let
	process_results
	PlutoSliderServer.list_files_recursive(output_dir)
end

# ╔═╡ 9268f35e-1a4e-414e-a7ea-3f5796e0bbf3
allfiles_output2 = filter(allfiles_output) do f
	!startswith(f, "generated_assets")
end

# ╔═╡ e0a25f24-a7de-4eac-9f88-cb7632de09eb
begin
	@assert length(allfiles_output2) ≥ length(pages)

	@htl("""
	<script>
	const {default: confetti} = await import( 'https://cdn.skypack.dev/canvas-confetti');
	confetti();
	let hello = $(rand());
	</script>
	""")
end

# ╔═╡ Cell order:
# ╟─2b7d1ee2-0f71-4091-aec2-cde62d2b6b36
# ╟─658b1b24-a7b2-47ab-ba53-b570dfeb8bfa
# ╟─b8024c95-6a63-4409-9c75-9bad6b301a92
# ╠═6f2d5ce1-0f60-4551-8d39-62c66f72f175
# ╠═c5a0b072-7f49-4c0c-855e-773cfc03d308
# ╟─cd576da6-59ae-4d1b-b812-1a35023b6875
# ╟─e0ae20f5-ffe7-4f0e-90be-168924526e03
# ╟─d58f2a89-4631-4b19-9d60-5e590908b61f
# ╟─2221f133-e490-4e3a-82d4-bd1c6c979d1c
# ╟─86471faf-af03-4f35-8b95-c4011ceaf7c3
# ╟─6c8e76ea-d648-449a-89de-cb6632cdd6b9
# ╠═a166e8f3-542e-4068-a076-3f5fd4daa61c
# ╠═6288f145-444b-41cb-b9e3-8f273f9517fb
# ╠═ff55f7eb-a23d-4ca7-b428-ab05dcb8f090
# ╟─4a2dc5a4-0bf2-4678-b984-4ecb7b397d72
# ╠═995c6810-8df2-483d-a87a-2277af0d43bd
# ╟─b3ce7742-fb47-4c17-bac2-e6a7710eb1a1
# ╠═7e86cfc7-5439-4c7a-9c3b-381c776d8371
# ╠═90f0c676-b33f-441c-8ea6-d59c44a11547
# ╠═5381e8b3-d4f9-4e58-8da3-f1ee0a9b7a6d
# ╠═9f945292-ff9e-4f29-93ea-69b10fc4428d
# ╠═83366d96-4cd3-4def-a0da-16a22b40124f
# ╠═08b42df7-9120-4b42-80ee-8e438752b50c
# ╠═7717e24f-62ee-4852-9dec-d09b734d0693
# ╠═692c1e0b-07e1-41b3-abcd-2156bda65b41
# ╟─adb1ddac-d992-49ca-820f-e1ed8ca33bf8
# ╠═e2510a44-df48-4c05-9453-8822deadce24
# ╠═bb905046-59b7-4da6-97ad-dbb9055d823a
# ╠═b638df55-fd74-4ae8-bdbd-ec7b18214b40
# ╠═87b4431b-438b-4da4-9d06-79e7f3a2fe05
# ╟─cd4e479c-deb7-4a44-9eb0-c3819b5c4067
# ╠═2e527d04-e4e7-4dc8-87e6-8b3dd3c7688a
# ╟─94bb6730-a4ad-42d2-aa58-41b70a15cd0e
# ╠═e15cf987-3615-4e96-8ccd-04cad3bcd48e
# ╟─940f3995-1739-4b30-b8cf-c27a671043e5
# ╠═0d2b7382-2ddf-48c3-90c8-bc22de454c97
# ╠═5e91e7dc-82b6-486a-b745-34f97b6fb20c
# ╟─070c710d-3746-4706-bd03-b5b00a576007
# ╟─a5c22f80-58c7-4c63-95b8-ecb30bc896d0
# ╟─750782a1-3aeb-4816-8f6a-ec31055373c1
# ╟─f6b89b8c-3750-4dd2-940e-579be953c1c2
# ╟─29a81ad7-3803-4b7a-98ca-6e5b1077e1c7
# ╠═c52c9786-a25f-11ec-1fdc-9b13922d7ccb
# ╟─cf27b3d3-1689-4b3a-a8fe-3ad639eb2f82
# ╟─7f7f1981-978d-4861-b840-71ab611faf74
# ╟─7d9cb939-da6b-4961-9584-a905ad453b5d
# ╠═e1a87788-2eba-47c9-ab4c-74f3344dce1d
# ╠═d38dc2aa-d5ba-4cf7-9f9e-c4e4611a57ac
# ╠═485b7956-0774-4b25-a897-3d9232ef8590
# ╠═8da0c249-6094-49ab-9e59-d6e356818651
# ╟─d314ab46-b866-44c6-bfca-9a413bc06514
# ╠═e01ebbab-dc9a-4aaf-ae16-200d171fcbd9
# ╠═37b2cecc-e4c7-4b80-b7d9-71c68f3c0339
# ╟─7a95681a-df77-408f-919a-2bee5afd7777
# ╟─f3d225b8-b9a5-4639-97eb-7785b1a78f5a
# ╠═c3a495c1-3e1f-42a1-ac08-8dc0b9175fe9
# ╠═3b2d1919-41d9-4bba-9774-c8497bba5003
# ╠═6f7f66e8-ed10-4cc4-8672-a06861111aec
# ╠═d09ee809-33d8-44f8-aa7a-be4b3fdc21eb
# ╟─a0a80dce-2199-45b6-b4e9-d4168f520c85
# ╟─4e88cf07-8d85-4327-b310-6c71ba951bba
# ╠═f700357f-e21c-4d23-b56c-be4f9c90465f
# ╠═079a6399-50eb-4dee-a36d-b3dcb81c8456
# ╟─aaad71bd-5425-4783-952c-82e4d4fa7bb8
# ╠═76c2ac85-2e89-4396-a498-a4ceb1cc80bd
# ╠═898eb093-444c-45cf-88d7-3dbe9708ae31
# ╟─a510857f-528b-43e8-be78-69e554d165a6
# ╟─1c269e16-65c7-47ae-aeab-001f1b205e14
# ╟─318dc59e-15f6-4b25-bcf5-1ab6b0d87af7
# ╟─76193b12-842c-4b82-a23e-fb7403274234
# ╠═4f563136-fc7b-4322-92ba-78c0183c40cc
# ╠═f93da14a-e4c8-4c28-ab01-4a5ba1a3cf47
# ╠═41ab51f9-0b33-4548-b08a-ad1ef7d38f1b
# ╟─b0006e61-b037-41ed-a3e4-9962d15584c4
# ╠═c2ee20be-16f5-47a8-851a-67a361bb0316
# ╠═06edb2d7-325f-4f80-8c55-dc01c7783054
# ╟─f2fbcc70-a714-4eda-8786-7ee5692e3268
# ╟─57fd383b-d791-4170-a353-f839356f9d7a
# ╟─05f735e0-01cc-4276-a3f9-8420296e68be
# ╠═d8e9b950-6e71-40e2-bac1-c3ba85bc83ee
# ╟─6460cf11-ae78-47e3-9ac1-649295e76ddc
# ╟─52fc3e5e-21a6-4357-9e63-8a70a6e6deb8
# ╟─608ed895-3a62-4c11-8026-40120ab05af1
# ╟─bcf1ebd7-c5b7-44c9-9135-c632b4fae1b6
# ╟─d7a01c06-7174-4e6d-b02d-79c953ecdb79
# ╟─1a303aa4-bed5-4d9b-855c-23355f4a88fe
# ╟─9845db00-149c-45be-9e4f-55d1157afc87
# ╟─eef54261-767a-4ce4-b549-0b1828379f7e
# ╟─cda8689d-9ae5-42c4-8e7e-715cf44c33bb
# ╟─4013400c-acb4-40fa-a826-fd0cbae09e7e
# ╟─5b325b50-8984-44c6-8677-3c6bc5c2b0b1
# ╟─70fa9af8-31f9-4e47-b36b-828c88166b3d
# ╠═d17c96fb-8459-4527-a139-05fdf74cdc39
# ╠═9268f35e-1a4e-414e-a7ea-3f5796e0bbf3
# ╠═e0a25f24-a7de-4eac-9f88-cb7632de09eb
