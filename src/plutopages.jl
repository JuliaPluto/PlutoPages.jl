### A Pluto.jl notebook ###
# v0.19.32

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ b8024c95-6a63-4409-9c75-9bad6b301a92
begin	
	import PlutoSliderServer
	import Pluto
	using MarkdownLiteral
end

# ╔═╡ ce840b47-8406-48e6-abfb-1b00daab28dd
using HypertextLiteral

# ╔═╡ 7c53c1e3-6ccf-4804-8bc3-09126036608e
using PlutoHooks

# ╔═╡ 725cb996-68ac-4736-95ee-0a9754867bf3
using BetterFileWatching

# ╔═╡ 9d996c55-0e37-4ae9-a6a2-8c8761e8c6db
using PlutoLinks

# ╔═╡ 644552c6-4e32-4caf-90ef-bee259977094
import Logging

# ╔═╡ 66c97351-2294-4ac2-a93a-f334aaee8f92
import Gumbo

# ╔═╡ bcbda2d2-90a5-43e6-8400-d5472578f86a
import ProgressLogging

# ╔═╡ cd576da6-59ae-4d1b-b812-1a35023b6875
import ThreadsX

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

# ╔═╡ f4a4b741-8028-4626-9187-0b6a52f062b6
import CommonMark

# ╔═╡ 535efb29-73bd-4e65-8bbc-18b72ae8fe1f
import YAML

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
		result_str = repr(MIME"text/html"(), result)
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

# ╔═╡ 8f6393a4-e945-4f06-90f6-0a71f874c8e9
import SHA

# ╔═╡ 4fcdd524-86a8-4033-bc7c-4a7c04224eeb
import Unicode

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
const dir = joinpath(@__DIR__, "src")

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
	p = relpath(abs_path, dir)

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
	
	@use_task([dir]) do
		BetterFileWatching.watch_folder(dir) do e
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
allfiles = filter(PlutoSliderServer.list_files_recursive(dir)) do p
	# reference to retrigger when files change
	dir_changed_time
	manual_update_trigger
	
	!ignore(joinpath(dir, p))
end

# ╔═╡ d314ab46-b866-44c6-bfca-9a413bc06514
md"""
# Output folder generation
"""

# ╔═╡ e01ebbab-dc9a-4aaf-ae16-200d171fcbd9
const output_dir = mkpath(joinpath(@__DIR__, "_site"))

# ╔═╡ 7a95681a-df77-408f-919a-2bee5afd7777
"""
This directory can be used to store cache files that are persisted between builds. Currently used as PlutoSliderServer.jl cache.
"""
const cache_dir = mkpath(joinpath(@__DIR__, "_cache"))

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
	num = get(p.output.frontmatter, "order", Inf)
	if num isa AbstractString
		num = tryparse(Float64, num)
		if isnothing(num)
			num = Inf
		end
	end
	return (
		num,
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

# ╔═╡ 1a303aa4-bed5-4d9b-855c-23355f4a88fe
md"""
## Writing to the output directory
"""

# ╔═╡ 834294ff-9441-4e71-b5c0-edaf32d860ee
import JSON

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
		<pluto-editor 
			statefile=$(reg_s.url) 
			notebookfile=$(reg_n.url) 
			slider_server_url=$(pluto_deploy_settings.Export.slider_server_url)
			binder_url=$(pluto_deploy_settings.Export.binder_url)
			disable_ui
		></pluto-editor>
		"""

		frontmatter = Pluto.frontmatter(input.absolute_path)
		
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
	# delete any old files
	for f in readdir(output_dir)
		rm(joinpath(output_dir, f); recursive=true)
	end

	# let's go! running all the template handlers
	progressmap_async(allfiles; ntasks=NUM_PARALLEL_WORKERS) do f
		absolute_path = joinpath(dir, f)
		
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
		layout_file = joinpath(dir, "_includes", layoutname)
		@assert isfile(layout_file) "$layout_file is not a valid layout path"


		content = if ishtml(output)
			HTML(SafeString(output.contents))
		else
			output.contents
		end

		metadata = Dict()
	    for data_file in readdir(joinpath(dir, "_data"); join=true)
		  key = splitext(basename(data_file))[1]
		  metadata[key] = include(data_file)
	    end
		
		input = TemplateInput(;
			contents=read(layout_file),
			absolute_path=layout_file,
			relative_path=relpath(layout_file, dir),
			frontmatter=merge(output.frontmatter, 
				FrontMatter(
					"content" => content,
					"page" => page,
					"collections" => collections,
					"root_url" => root_url,
					"metadata" => metadata
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
		tags=get(page.output.frontmatter, "tags", String[]),
		text=page.output.search_index_data,
	)
	for page in rendered_results if page.output.search_index_data !== nothing
]

# ╔═╡ 1be06e4b-6072-46c3-a63d-aa95e51c43b4
write(
	joinpath(output_dir, "pp_search_data.json"), 
	JSON.json(collected_search_index_data)
)

# ╔═╡ 9845db00-149c-45be-9e4f-55d1157afc87
process_results = map(rendered_results) do page
	input = page.input
	output = page.output
	
	if output !== nothing && output.contents !== nothing
		
		# TODO: use front matter for permalink

		output_path2 = joinpath(output_dir, page.full_url)
		mkpath(output_path2 |> dirname)
		# Our magic root url:
		# in Julia, you can safely call `String` and `replace` on arbitrary, non-utf8 data :)
		write(output_path2, 
			replace(SafeString(output.contents), root_url => relpath(output_dir, output_path2 |> dirname))
		)
	end
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

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
BetterFileWatching = "c9fd44ac-77b5-486c-9482-9798bd063cc6"
CommonMark = "a80b9123-70ca-4bc0-993e-6e3bcb318db6"
Gumbo = "708ec375-b3d6-5a57-a7ce-8257bf98657a"
HypertextLiteral = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
JSON = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
Logging = "56ddb016-857b-54e1-b83d-db4d58db5568"
MarkdownLiteral = "736d6165-7244-6769-4267-6b50796e6954"
Pluto = "c3e4b0f8-55cb-11ea-2926-15256bba5781"
PlutoHooks = "0ff47ea0-7a50-410d-8455-4348d5de0774"
PlutoLinks = "0ff47ea0-7a50-410d-8455-4348d5de0420"
PlutoSliderServer = "2fc8631c-6f24-4c5b-bca7-cbb509c42db4"
ProgressLogging = "33c8b6b6-d38a-422a-b730-caa89a2f386c"
SHA = "ea8e919c-243c-51af-8825-aaa63cd721ce"
ThreadsX = "ac1d9e8a-700a-412c-b207-f0111f4b6c0d"
Unicode = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"
YAML = "ddb6d928-2868-570f-bddf-ab3f9cf99eb6"

[compat]
BetterFileWatching = "~0.1.5"
CommonMark = "~0.8.12"
Gumbo = "~0.8.2"
HypertextLiteral = "~0.9.5"
JSON = "~0.21.4"
MarkdownLiteral = "~0.1.1"
Pluto = "~0.19.32"
PlutoHooks = "~0.0.5"
PlutoLinks = "~0.1.6"
PlutoSliderServer = "~0.3.28"
ProgressLogging = "~0.1.4"
ThreadsX = "~0.1.11"
YAML = "~0.4.9"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.9.4"
manifest_format = "2.0"
project_hash = "9b28c1b92a8f754c9024f28925f5f768986ff9bd"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "793501dcd3fa7ce8d375a2c878dca2296232686e"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.2.2"

[[deps.AbstractTrees]]
git-tree-sha1 = "faa260e4cb5aba097a73fab382dd4b5819d8ec8c"
uuid = "1520ce14-60c1-5f80-bbc7-55ef81b5835c"
version = "0.4.4"

[[deps.Adapt]]
deps = ["LinearAlgebra", "Requires"]
git-tree-sha1 = "02f731463748db57cc2ebfbd9fbc9ce8280d3433"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.7.1"

    [deps.Adapt.extensions]
    AdaptStaticArraysExt = "StaticArrays"

    [deps.Adapt.weakdeps]
    StaticArrays = "90137ffa-7385-5640-81b9-e52037218182"

[[deps.ArgCheck]]
git-tree-sha1 = "a3a402a35a2f7e0b87828ccabbd5ebfbebe356b4"
uuid = "dce04be8-c92d-5529-be00-80e4d2c0e197"
version = "2.3.0"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.BangBang]]
deps = ["Compat", "ConstructionBase", "InitialValues", "LinearAlgebra", "Requires", "Setfield", "Tables"]
git-tree-sha1 = "e28912ce94077686443433c2800104b061a827ed"
uuid = "198e06fe-97b7-11e9-32a5-e1d131e6ad66"
version = "0.3.39"

    [deps.BangBang.extensions]
    BangBangChainRulesCoreExt = "ChainRulesCore"
    BangBangDataFramesExt = "DataFrames"
    BangBangStaticArraysExt = "StaticArrays"
    BangBangStructArraysExt = "StructArrays"
    BangBangTypedTablesExt = "TypedTables"

    [deps.BangBang.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
    StaticArrays = "90137ffa-7385-5640-81b9-e52037218182"
    StructArrays = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
    TypedTables = "9d95f2ec-7b3d-5a63-8d20-e2491e220bb9"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.Baselet]]
git-tree-sha1 = "aebf55e6d7795e02ca500a689d326ac979aaf89e"
uuid = "9718e550-a3fa-408a-8086-8db961cd8217"
version = "0.1.1"

[[deps.BetterFileWatching]]
deps = ["Deno_jll", "JSON"]
git-tree-sha1 = "0d7ee0a1acad90d544fa87cc3d6f463e99abb77a"
uuid = "c9fd44ac-77b5-486c-9482-9798bd063cc6"
version = "0.1.5"

[[deps.BitFlags]]
git-tree-sha1 = "2dc09997850d68179b69dafb58ae806167a32b1b"
uuid = "d1d4a3ce-64b1-5f1a-9ba4-7e7e69966f35"
version = "0.1.8"

[[deps.CodeTracking]]
deps = ["InteractiveUtils", "UUIDs"]
git-tree-sha1 = "c0216e792f518b39b22212127d4a84dc31e4e386"
uuid = "da1fd8a2-8d9e-5ec2-8556-3022fb5608a2"
version = "1.3.5"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "cd67fc487743b2f0fd4380d4cbd3a24660d0eec8"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.3"

[[deps.CommonMark]]
deps = ["Crayons", "JSON", "PrecompileTools", "URIs"]
git-tree-sha1 = "532c4185d3c9037c0237546d817858b23cf9e071"
uuid = "a80b9123-70ca-4bc0-993e-6e3bcb318db6"
version = "0.8.12"

[[deps.Compat]]
deps = ["UUIDs"]
git-tree-sha1 = "8a62af3e248a8c4bad6b32cbbe663ae02275e32c"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.10.0"
weakdeps = ["Dates", "LinearAlgebra"]

    [deps.Compat.extensions]
    CompatLinearAlgebraExt = "LinearAlgebra"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.0.5+0"

[[deps.CompositionsBase]]
git-tree-sha1 = "802bb88cd69dfd1509f6670416bd4434015693ad"
uuid = "a33af91c-f02d-484b-be07-31d278c5ca2b"
version = "0.1.2"

    [deps.CompositionsBase.extensions]
    CompositionsBaseInverseFunctionsExt = "InverseFunctions"

    [deps.CompositionsBase.weakdeps]
    InverseFunctions = "3587e190-3f89-42d0-90ee-14403ec27112"

[[deps.ConcurrentUtilities]]
deps = ["Serialization", "Sockets"]
git-tree-sha1 = "8cfa272e8bdedfa88b6aefbbca7c19f1befac519"
uuid = "f0e56b4a-5159-44fe-b623-3e5288b988bb"
version = "2.3.0"

[[deps.Configurations]]
deps = ["ExproniconLite", "OrderedCollections", "TOML"]
git-tree-sha1 = "4358750bb58a3caefd5f37a4a0c5bfdbbf075252"
uuid = "5218b696-f38b-4ac9-8b61-a12ec717816d"
version = "0.17.6"

[[deps.ConstructionBase]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "c53fc348ca4d40d7b371e71fd52251839080cbc9"
uuid = "187b0558-2788-49d3-abe0-74a17ed4e7c9"
version = "1.5.4"

    [deps.ConstructionBase.extensions]
    ConstructionBaseIntervalSetsExt = "IntervalSets"
    ConstructionBaseStaticArraysExt = "StaticArrays"

    [deps.ConstructionBase.weakdeps]
    IntervalSets = "8197267c-284f-5f27-9208-e0e47529a953"
    StaticArrays = "90137ffa-7385-5640-81b9-e52037218182"

[[deps.Crayons]]
git-tree-sha1 = "249fe38abf76d48563e2f4556bebd215aa317e15"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.1.1"

[[deps.DataAPI]]
git-tree-sha1 = "8da84edb865b0b5b0100c0666a9bc9a0b71c553c"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.15.0"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.DefineSingletons]]
git-tree-sha1 = "0fba8b706d0178b4dc7fd44a96a92382c9065c2c"
uuid = "244e2a9f-e319-4986-a169-4d1fe445cd52"
version = "0.1.2"

[[deps.Deno_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "cd6756e833c377e0ce9cd63fb97689a255f12323"
uuid = "04572ae6-984a-583e-9378-9577a1c2574d"
version = "1.33.4+0"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.ExceptionUnwrapping]]
deps = ["Test"]
git-tree-sha1 = "e90caa41f5a86296e014e148ee061bd6c3edec96"
uuid = "460bff9d-24e4-43bc-9d9f-a8973cb893f4"
version = "0.1.9"

[[deps.Expat_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "4558ab818dcceaab612d1bb8c19cee87eda2b83c"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.5.0+0"

[[deps.ExproniconLite]]
git-tree-sha1 = "fbc390c2f896031db5484bc152a7e805ecdfb01f"
uuid = "55351af7-c7e9-48d6-89ff-24e801d99491"
version = "0.10.5"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FromFile]]
deps = ["Downloads", "Requires"]
git-tree-sha1 = "5df4ca248bed8c35164d6a7ae006073bbf8289ff"
uuid = "ff7dd447-1dcb-4ce3-b8ac-22a812192de7"
version = "0.1.5"

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[deps.FuzzyCompletions]]
deps = ["REPL"]
git-tree-sha1 = "c8d37d615586bea181063613dccc555499feb298"
uuid = "fb4132e2-a121-4a70-b8a1-d5b831dcdcc2"
version = "0.5.3"

[[deps.Git]]
deps = ["Git_jll"]
git-tree-sha1 = "51764e6c2e84c37055e846c516e9015b4a291c7d"
uuid = "d7ba0133-e1db-5d97-8f8c-041e4b3a1eb2"
version = "1.3.0"

[[deps.GitHubActions]]
deps = ["JSON", "Logging"]
git-tree-sha1 = "8750718611144f23584ca265d899baa1bf1a4531"
uuid = "6b79fd1a-b13a-48ab-b6b0-aaee1fee41df"
version = "0.1.7"

[[deps.Git_jll]]
deps = ["Artifacts", "Expat_jll", "JLLWrappers", "LibCURL_jll", "Libdl", "Libiconv_jll", "OpenSSL_jll", "PCRE2_jll", "Zlib_jll"]
git-tree-sha1 = "bb8f7cc77ec1152414b2af6db533d9471cfbb2d1"
uuid = "f8c6e375-362e-5223-8a59-34ff63f689eb"
version = "2.42.0+0"

[[deps.Glob]]
git-tree-sha1 = "97285bbd5230dd766e9ef6749b80fc617126d496"
uuid = "c27321d9-0574-5035-807b-f59d2c89b15c"
version = "1.3.1"

[[deps.Gumbo]]
deps = ["AbstractTrees", "Gumbo_jll", "Libdl"]
git-tree-sha1 = "a1a138dfbf9df5bace489c7a9d5196d6afdfa140"
uuid = "708ec375-b3d6-5a57-a7ce-8257bf98657a"
version = "0.8.2"

[[deps.Gumbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "29070dee9df18d9565276d68a596854b1764aa38"
uuid = "528830af-5a63-567c-a44a-034ed33b8444"
version = "0.10.2+0"

[[deps.HTTP]]
deps = ["Base64", "CodecZlib", "ConcurrentUtilities", "Dates", "ExceptionUnwrapping", "Logging", "LoggingExtras", "MbedTLS", "NetworkOptions", "OpenSSL", "Random", "SimpleBufferStream", "Sockets", "URIs", "UUIDs"]
git-tree-sha1 = "abbbb9ec3afd783a7cbd82ef01dcd088ea051398"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "1.10.1"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "7134810b1afce04bbc1045ca1985fbe81ce17653"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.5"

[[deps.InitialValues]]
git-tree-sha1 = "4da0f88e9a39111c2fa3add390ab15f3a44f3ca3"
uuid = "22cec73e-a1b8-11e9-2c92-598750a2cf9c"
version = "0.3.1"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JLLWrappers]]
deps = ["Artifacts", "Preferences"]
git-tree-sha1 = "7e5d6779a1e09a36db2a7b6cff50942a0a7d0fca"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.5.0"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "31e996f0a15c7b280ba9f76636b3ff9e2ae58c9a"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.4"

[[deps.JuliaInterpreter]]
deps = ["CodeTracking", "InteractiveUtils", "Random", "UUIDs"]
git-tree-sha1 = "e49bce680c109bc86e3e75ebcb15040d6ad9e1d3"
uuid = "aa1ae85d-cabe-5617-a682-6adf51b2e16a"
version = "0.9.27"

[[deps.LazilyInitializedFields]]
git-tree-sha1 = "8f7f3cabab0fd1800699663533b6d5cb3fc0e612"
uuid = "0e77f7df-68c5-4e49-93ce-4cd80f5598bf"
version = "1.2.2"

[[deps.LeftChildRightSiblingTrees]]
deps = ["AbstractTrees"]
git-tree-sha1 = "fb6803dafae4a5d62ea5cab204b1e657d9737e7f"
uuid = "1d6d02ad-be62-4b6b-8a6d-2f90e265016e"
version = "0.2.0"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.4"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "8.4.0+0"

[[deps.LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.11.0+1"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "f9557a255370125b405568f9767d6d195822a175"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.17.0+0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.LoggingExtras]]
deps = ["Dates", "Logging"]
git-tree-sha1 = "c1dd6d7978c12545b4179fb6153b9250c96b0075"
uuid = "e6f89c97-d47a-5376-807f-9c37f3926c36"
version = "1.0.3"

[[deps.LoweredCodeUtils]]
deps = ["JuliaInterpreter"]
git-tree-sha1 = "c165f205e030208760ebd75b5e1f7706761d9218"
uuid = "6f1432cf-f94c-5a45-995e-cdbf5db27b0b"
version = "2.3.1"

[[deps.MIMEs]]
git-tree-sha1 = "65f28ad4b594aebe22157d6fac869786a255b7eb"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "0.1.4"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "9ee1618cbf5240e6d4e0371d6f24065083f60c48"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.11"

[[deps.Malt]]
deps = ["Distributed", "Logging", "RelocatableFolders", "Serialization", "Sockets"]
git-tree-sha1 = "18cf4151e390fce29ca846b92b06baf9bc6e002e"
uuid = "36869731-bdee-424d-aa32-cab38c994e3b"
version = "1.1.1"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MarkdownLiteral]]
deps = ["CommonMark", "HypertextLiteral"]
git-tree-sha1 = "0d3fa2dd374934b62ee16a4721fe68c418b92899"
uuid = "736d6165-7244-6769-4267-6b50796e6954"
version = "0.1.1"

[[deps.MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "MozillaCACerts_jll", "NetworkOptions", "Random", "Sockets"]
git-tree-sha1 = "c067a280ddc25f196b5e7df3877c6b226d390aaf"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.1.9"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.2+0"

[[deps.MicroCollections]]
deps = ["BangBang", "InitialValues", "Setfield"]
git-tree-sha1 = "629afd7d10dbc6935ec59b32daeb33bc4460a42e"
uuid = "128add7d-3638-4c79-886c-908ea0c25c34"
version = "0.1.4"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2022.10.11"

[[deps.MsgPack]]
deps = ["Serialization"]
git-tree-sha1 = "fc8c15ca848b902015bd4a745d350f02cf791c2a"
uuid = "99f44e22-a591-53d1-9472-aa23ef4bd671"
version = "1.2.0"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.21+4"

[[deps.OpenSSL]]
deps = ["BitFlags", "Dates", "MozillaCACerts_jll", "OpenSSL_jll", "Sockets"]
git-tree-sha1 = "51901a49222b09e3743c65b8847687ae5fc78eb2"
uuid = "4d8831e6-92b7-49fb-bdf8-b643e874388c"
version = "1.4.1"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "cc6e1927ac521b659af340e0ca45828a3ffc748f"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "3.0.12+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "dfdf5519f235516220579f949664f1bf44e741c5"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.6.3"

[[deps.PCRE2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "efcefdf7-47ab-520b-bdef-62a2eaa19f15"
version = "10.42.0+0"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "a935806434c9d4c506ba941871b327b96d41f2bf"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.8.0"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.9.2"

[[deps.Pluto]]
deps = ["Base64", "Configurations", "Dates", "Downloads", "FileWatching", "FuzzyCompletions", "HTTP", "HypertextLiteral", "InteractiveUtils", "Logging", "LoggingExtras", "MIMEs", "Malt", "Markdown", "MsgPack", "Pkg", "PrecompileSignatures", "PrecompileTools", "REPL", "RegistryInstances", "RelocatableFolders", "Scratch", "Sockets", "TOML", "Tables", "URIs", "UUIDs"]
git-tree-sha1 = "0b61bd2572c7c797a0e0c78c40b8cee740996ebb"
uuid = "c3e4b0f8-55cb-11ea-2926-15256bba5781"
version = "0.19.32"

[[deps.PlutoHooks]]
deps = ["InteractiveUtils", "Markdown", "UUIDs"]
git-tree-sha1 = "072cdf20c9b0507fdd977d7d246d90030609674b"
uuid = "0ff47ea0-7a50-410d-8455-4348d5de0774"
version = "0.0.5"

[[deps.PlutoLinks]]
deps = ["FileWatching", "InteractiveUtils", "Markdown", "PlutoHooks", "Revise", "UUIDs"]
git-tree-sha1 = "8f5fa7056e6dcfb23ac5211de38e6c03f6367794"
uuid = "0ff47ea0-7a50-410d-8455-4348d5de0420"
version = "0.1.6"

[[deps.PlutoSliderServer]]
deps = ["AbstractPlutoDingetjes", "Base64", "BetterFileWatching", "Configurations", "Distributed", "FromFile", "Git", "GitHubActions", "Glob", "HTTP", "JSON", "Logging", "Pkg", "Pluto", "SHA", "Sockets", "TOML", "TerminalLoggers", "UUIDs"]
git-tree-sha1 = "8c8546a8996f410c88348ebef6331cac6d073757"
uuid = "2fc8631c-6f24-4c5b-bca7-cbb509c42db4"
version = "0.3.28"

[[deps.PrecompileSignatures]]
git-tree-sha1 = "18ef344185f25ee9d51d80e179f8dad33dc48eb1"
uuid = "91cefc8d-f054-46dc-8f8c-26e11d7c5411"
version = "3.0.3"

[[deps.PrecompileTools]]
deps = ["Preferences"]
git-tree-sha1 = "03b4c25b43cb84cee5c90aa9b5ea0a78fd848d2f"
uuid = "aea7be01-6a6a-4083-8856-8a6e6704d82a"
version = "1.2.0"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "00805cd429dcb4870060ff49ef443486c262e38e"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.4.1"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.ProgressLogging]]
deps = ["Logging", "SHA", "UUIDs"]
git-tree-sha1 = "80d919dee55b9c50e8d9e2da5eeafff3fe58b539"
uuid = "33c8b6b6-d38a-422a-b730-caa89a2f386c"
version = "0.1.4"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.Referenceables]]
deps = ["Adapt"]
git-tree-sha1 = "e681d3bfa49cd46c3c161505caddf20f0e62aaa9"
uuid = "42d2dcc6-99eb-4e98-b66c-637b7d73030e"
version = "0.1.2"

[[deps.RegistryInstances]]
deps = ["LazilyInitializedFields", "Pkg", "TOML", "Tar"]
git-tree-sha1 = "ffd19052caf598b8653b99404058fce14828be51"
uuid = "2792f1a3-b283-48e8-9a74-f99dce5104f3"
version = "0.1.0"

[[deps.RelocatableFolders]]
deps = ["SHA", "Scratch"]
git-tree-sha1 = "ffdaf70d81cf6ff22c2b6e733c900c3321cab864"
uuid = "05181044-ff0b-4ac5-8273-598c1e38db00"
version = "1.0.1"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[deps.Revise]]
deps = ["CodeTracking", "Distributed", "FileWatching", "JuliaInterpreter", "LibGit2", "LoweredCodeUtils", "OrderedCollections", "Pkg", "REPL", "Requires", "UUIDs", "Unicode"]
git-tree-sha1 = "6990168abf3fe9a6e34ebb0e05aaaddf6572189e"
uuid = "295af30f-e4ad-537b-8983-00126c2a3abe"
version = "3.5.10"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Scratch]]
deps = ["Dates"]
git-tree-sha1 = "3bac05bc7e74a75fd9cba4295cde4045d9fe2386"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.2.1"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.Setfield]]
deps = ["ConstructionBase", "Future", "MacroTools", "StaticArraysCore"]
git-tree-sha1 = "e2cc6d8c88613c05e1defb55170bf5ff211fbeac"
uuid = "efcf1570-3423-57d1-acb7-fd33fddbac46"
version = "1.1.1"

[[deps.SimpleBufferStream]]
git-tree-sha1 = "874e8867b33a00e784c8a7e4b60afe9e037b74e1"
uuid = "777ac1f9-54b0-4bf8-805c-2214025038e7"
version = "1.1.0"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SplittablesBase]]
deps = ["Setfield", "Test"]
git-tree-sha1 = "e08a62abc517eb79667d0a29dc08a3b589516bb5"
uuid = "171d559e-b47b-412a-8079-5efa626c420e"
version = "0.1.15"

[[deps.StaticArraysCore]]
git-tree-sha1 = "36b3d696ce6366023a0ea192b4cd442268995a0d"
uuid = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
version = "1.4.2"

[[deps.StringEncodings]]
deps = ["Libiconv_jll"]
git-tree-sha1 = "b765e46ba27ecf6b44faf70df40c57aa3a547dcb"
uuid = "69024149-9ee7-55f6-a4c4-859efe599b68"
version = "0.3.7"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "OrderedCollections", "TableTraits"]
git-tree-sha1 = "cb76cf677714c095e535e3501ac7954732aeea2d"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.11.1"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[deps.TerminalLoggers]]
deps = ["LeftChildRightSiblingTrees", "Logging", "Markdown", "Printf", "ProgressLogging", "UUIDs"]
git-tree-sha1 = "f133fab380933d042f6796eda4e130272ba520ca"
uuid = "5d786b92-1e48-4d6f-9151-6b4477ca9bed"
version = "0.1.7"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.ThreadsX]]
deps = ["ArgCheck", "BangBang", "ConstructionBase", "InitialValues", "MicroCollections", "Referenceables", "Setfield", "SplittablesBase", "Transducers"]
git-tree-sha1 = "34e6bcf36b9ed5d56489600cf9f3c16843fa2aa2"
uuid = "ac1d9e8a-700a-412c-b207-f0111f4b6c0d"
version = "0.1.11"

[[deps.TranscodingStreams]]
git-tree-sha1 = "1fbeaaca45801b4ba17c251dd8603ef24801dd84"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.10.2"
weakdeps = ["Random", "Test"]

    [deps.TranscodingStreams.extensions]
    TestExt = ["Test", "Random"]

[[deps.Transducers]]
deps = ["Adapt", "ArgCheck", "BangBang", "Baselet", "CompositionsBase", "ConstructionBase", "DefineSingletons", "Distributed", "InitialValues", "Logging", "Markdown", "MicroCollections", "Requires", "Setfield", "SplittablesBase", "Tables"]
git-tree-sha1 = "e579d3c991938fecbb225699e8f611fa3fbf2141"
uuid = "28d57a85-8fef-5791-bfe6-a80928e7c999"
version = "0.4.79"

    [deps.Transducers.extensions]
    TransducersBlockArraysExt = "BlockArrays"
    TransducersDataFramesExt = "DataFrames"
    TransducersLazyArraysExt = "LazyArrays"
    TransducersOnlineStatsBaseExt = "OnlineStatsBase"
    TransducersReferenceablesExt = "Referenceables"

    [deps.Transducers.weakdeps]
    BlockArrays = "8e7c35d0-a365-5155-bbbb-fb81a777f24e"
    DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
    LazyArrays = "5078a376-72f3-5289-bfd5-ec5146d43c02"
    OnlineStatsBase = "925886fa-5bf2-5e8e-b522-a9147a512338"
    Referenceables = "42d2dcc6-99eb-4e98-b66c-637b7d73030e"

[[deps.Tricks]]
git-tree-sha1 = "eae1bb484cd63b36999ee58be2de6c178105112f"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.8"

[[deps.URIs]]
git-tree-sha1 = "67db6cc7b3821e19ebe75791a9dd19c9b1188f2b"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.5.1"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.YAML]]
deps = ["Base64", "Dates", "Printf", "StringEncodings"]
git-tree-sha1 = "e6330e4b731a6af7959673621e91645eb1356884"
uuid = "ddb6d928-2868-570f-bddf-ab3f9cf99eb6"
version = "0.4.9"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.13+0"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.8.0+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.52.0+1"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+0"
"""

# ╔═╡ Cell order:
# ╠═b8024c95-6a63-4409-9c75-9bad6b301a92
# ╠═644552c6-4e32-4caf-90ef-bee259977094
# ╠═66c97351-2294-4ac2-a93a-f334aaee8f92
# ╠═bcbda2d2-90a5-43e6-8400-d5472578f86a
# ╠═cd576da6-59ae-4d1b-b812-1a35023b6875
# ╟─e0ae20f5-ffe7-4f0e-90be-168924526e03
# ╟─d58f2a89-4631-4b19-9d60-5e590908b61f
# ╟─2221f133-e490-4e3a-82d4-bd1c6c979d1c
# ╟─86471faf-af03-4f35-8b95-c4011ceaf7c3
# ╟─6c8e76ea-d648-449a-89de-cb6632cdd6b9
# ╠═a166e8f3-542e-4068-a076-3f5fd4daa61c
# ╠═6288f145-444b-41cb-b9e3-8f273f9517fb
# ╠═ff55f7eb-a23d-4ca7-b428-ab05dcb8f090
# ╟─4a2dc5a4-0bf2-4678-b984-4ecb7b397d72
# ╠═ce840b47-8406-48e6-abfb-1b00daab28dd
# ╠═995c6810-8df2-483d-a87a-2277af0d43bd
# ╟─b3ce7742-fb47-4c17-bac2-e6a7710eb1a1
# ╠═f4a4b741-8028-4626-9187-0b6a52f062b6
# ╠═535efb29-73bd-4e65-8bbc-18b72ae8fe1f
# ╠═7e86cfc7-5439-4c7a-9c3b-381c776d8371
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
# ╠═8f6393a4-e945-4f06-90f6-0a71f874c8e9
# ╠═4fcdd524-86a8-4033-bc7c-4a7c04224eeb
# ╟─070c710d-3746-4706-bd03-b5b00a576007
# ╟─a5c22f80-58c7-4c63-95b8-ecb30bc896d0
# ╟─750782a1-3aeb-4816-8f6a-ec31055373c1
# ╟─f6b89b8c-3750-4dd2-940e-579be953c1c2
# ╟─29a81ad7-3803-4b7a-98ca-6e5b1077e1c7
# ╠═c52c9786-a25f-11ec-1fdc-9b13922d7ccb
# ╠═7c53c1e3-6ccf-4804-8bc3-09126036608e
# ╠═725cb996-68ac-4736-95ee-0a9754867bf3
# ╠═9d996c55-0e37-4ae9-a6a2-8c8761e8c6db
# ╟─cf27b3d3-1689-4b3a-a8fe-3ad639eb2f82
# ╟─7f7f1981-978d-4861-b840-71ab611faf74
# ╟─7d9cb939-da6b-4961-9584-a905ad453b5d
# ╠═e1a87788-2eba-47c9-ab4c-74f3344dce1d
# ╠═d38dc2aa-d5ba-4cf7-9f9e-c4e4611a57ac
# ╠═485b7956-0774-4b25-a897-3d9232ef8590
# ╠═8da0c249-6094-49ab-9e59-d6e356818651
# ╟─d314ab46-b866-44c6-bfca-9a413bc06514
# ╠═e01ebbab-dc9a-4aaf-ae16-200d171fcbd9
# ╟─7a95681a-df77-408f-919a-2bee5afd7777
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
# ╟─1a303aa4-bed5-4d9b-855c-23355f4a88fe
# ╠═834294ff-9441-4e71-b5c0-edaf32d860ee
# ╠═1be06e4b-6072-46c3-a63d-aa95e51c43b4
# ╠═9845db00-149c-45be-9e4f-55d1157afc87
# ╟─eef54261-767a-4ce4-b549-0b1828379f7e
# ╟─cda8689d-9ae5-42c4-8e7e-715cf44c33bb
# ╟─4013400c-acb4-40fa-a826-fd0cbae09e7e
# ╟─5b325b50-8984-44c6-8677-3c6bc5c2b0b1
# ╟─70fa9af8-31f9-4e47-b36b-828c88166b3d
# ╠═d17c96fb-8459-4527-a139-05fdf74cdc39
# ╠═9268f35e-1a4e-414e-a7ea-3f5796e0bbf3
# ╠═e0a25f24-a7de-4eac-9f88-cb7632de09eb
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
