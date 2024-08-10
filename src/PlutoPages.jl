module PlutoPages

# import all the things that the notebook needs
import BetterFileWatching,
    CommonMark,
    Gumbo,
    HypertextLiteral,
    InteractiveUtils,
    JSON,
    LiveServer,
    Logging,
    Malt,
    Markdown,
    MarkdownLiteral,
    Pkg,
    Pluto,
    PlutoHooks,
    PlutoLinks,
    PlutoSliderServer,
    PlutoUI,
    ProgressLogging,
    RelocatableFolders,
    SHA,
    ThreadsX,
    Unicode,
    YAML









import Pluto
using RelocatableFolders
import LiveServer

include("./pluto control.jl")
include("./open in browser.jl")


# """
# Generate 
# """
# function generate()
    
    
    
# end

const PlutoPages_notebook_path = @path joinpath(dirname(@__DIR__), "src", "notebook.jl")


function run_plutopages_notebook(; 
    input_dir::String, 
    output_dir::String, 
    cache_dir::String,
    kwargs...
)
    @assert isabspath(input_dir)
    @assert isabspath(output_dir)
    @assert isabspath(cache_dir)
    run_with_replacements(
        PlutoPages_notebook_path,
        plutopages_replacements(; input_dir, output_dir, cache_dir, ap=Base.active_project(), lp=LOAD_PATH);
        kwargs...
    )
end

function plutopages_replacements(; 
    input_dir::String, 
    output_dir::String, 
    cache_dir::String,
    ap::String,
    lp::Vector{String},
)
    Dict(
        :input_dir => input_dir,
        :output_dir => output_dir,
        :cache_dir => cache_dir,
        :override_ap_lp => (ap, lp),
    )
end


function create_subdirs(root_dir::String)
    root_dir = Pluto.tamepath(root_dir)
    @assert isdir(root_dir)
    input_dir = joinpath(root_dir, "src")
    @assert isdir(input_dir) "Input directory is empty: $(input_dir).\n\nUse PlutoPages in a directory with a 'src' subdirectory. Your notebooks and markdown files go in there."

    (;
        input_dir,
        output_dir = mkpath(joinpath(root_dir, "_site")),
        cache_dir = mkpath(joinpath(root_dir, "_cache")),
    )
end

function develop(root_dir::String; kwargs...)
    develop(;create_subdirs(root_dir)..., kwargs...)
end



const isolated_cell_ids = (
    "cf27b3d3-1689-4b3a-a8fe-3ad639eb2f82",
    "7f7f1981-978d-4861-b840-71ab611faf74",
    "7d9cb939-da6b-4961-9584-a905ad453b5d",
    "4e88cf07-8d85-4327-b310-6c71ba951bba",
    "079a6399-50eb-4dee-a36d-b3dcb81c8456",
    "b0006e61-b037-41ed-a3e4-9962d15584c4",
    "06edb2d7-325f-4f80-8c55-dc01c7783054",
    "e0a25f24-a7de-4eac-9f88-cb7632de09eb",
)
const isolated_cell_query = join("&isolated_cell_id=$(i)" for i in isolated_cell_ids)

function dashboard_url_path(app)
    "edit?secret=$(app.session.secret)&id=$(fetch(app.notebook_task).notebook_id)$(isolated_cell_query)"
end

function dashboard_url(app)
    "http://localhost:$(app.pluto_server_port)/$(dashboard_url_path(app))"
end

function develop(; 
    input_dir::String, 
    output_dir::String, 
    cache_dir::String,
    inject_browser_reload_script::Bool=true,
)
    app = run_plutopages_notebook(; input_dir, output_dir, cache_dir, run_server=true)
    
    notebook = fetch(app.notebook_task)
    
    ccall(:jl_exit_on_sigint, Cvoid, (Cint,), 0)
    file_server_port = rand(8100:8900)
    
    file_server_task = Threads.@spawn LiveServer.serve(; port=file_server_port, dir=output_dir, inject_browser_reload_script)
    
    sleep(2)
    
    dev_server_url = "http://localhost:$(file_server_port)/"
    pluto_server_url = dashboard_url(app)


    @info """

    ✅✅✅

    Ready! To see the website, visit:
    ➡️   $(dev_server_url)

    To inspect the generation process, go to:
    ➡️   $(pluto_server_url)

    ✅✅✅
    
    Press Ctrl+C multiple times to stop the development server.

    """

    open_in_default_browser(dev_server_url)
    open_in_default_browser(pluto_server_url)

    wait(file_server_task)
    wait(app.pluto_server_instance)
    app
end



function generate(; 
    input_dir::String, 
    output_dir::String, 
    cache_dir::String,
    html_report_path::Union{Nothing,String}=tempname()*"_generation_report.html",
)
    app = run_plutopages_notebook(; input_dir, output_dir, cache_dir, run_server=false)
    notebook = fetch(app.notebook_task)
    
    bad = false
    for c in notebook.cells
        if c.errored
            bad = true
            @error("Cell errored", c.code, c.cell_id, Text(c.output.body))
        end
    end
    
    if html_report_path !== nothing
        write(html_report_path, Pluto.generate_html(notebook))
        @info "PlutoPages: 📄 HTML report written to:\n\n$(html_report_path)\n"
    end
    
    @info "PlutoPages: cleaning up..."
    shutdown(app)
    
    if bad
        error("Error in notebook, see previous logs. $(html_report_path === nothing ? "You can debug this better with an HTML report, check out the `html_report_path` kwarg." : "Read more in the HTML report:\n$(html_report_path)\n")")
    end
    
    return output_dir
end

generate(root_dir::String; kwargs...) = generate(;create_subdirs(root_dir)..., kwargs...)


function create_test_basic_site()
    original = joinpath(dirname(@__DIR__), "test", "basic_site")
    new_dir = mktempdir()
    cp(original, new_dir; force=true)
    new_dir
end




end