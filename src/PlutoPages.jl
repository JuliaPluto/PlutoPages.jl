module PlutoPages

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
    run_with_replacements(
        PlutoPages_notebook_path,
        plutopages_replacements(; input_dir, output_dir, cache_dir);
        kwargs...
    )
end

function plutopages_replacements(; 
    input_dir::String, 
    output_dir::String, 
    cache_dir::String,
)
    Dict(
        :input_dir => input_dir,
        :output_dir => output_dir,
        :cache_dir => cache_dir,
    )
end


function create_subdirs(root_dir::String)
    @assert(isdir(root_dir))
    @assert(isdir(joinpath(root_dir, "src")))
    
    (;
        input_dir = joinpath(root_dir, "src"),
        output_dir = mkpath(joinpath(root_dir, "_site")),
        cache_dir = mkpath(joinpath(root_dir, "_cache")),
    )
end

function develop(root_dir::String)
    develop(;create_subdirs(root_dir)...)
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


function develop(; 
    input_dir::String, 
    output_dir::String, 
    cache_dir::String,
)
    app = run_plutopages_notebook(; input_dir, output_dir, cache_dir, run_server=true)
    
    notebook = fetch(app.notebook_task)
    
    ccall(:jl_exit_on_sigint, Cvoid, (Cint,), 0)
    @info "PlutoPages: Press Ctrl+C multiple times to stop the server."
    file_server_port = rand(8100:8900)
    
    file_server_task = Threads.@spawn LiveServer.serve(port=file_server_port, dir=output_dir)
    
    sleep(2)
    
    dev_server_url = "http://localhost:$(file_server_port)/"
    pluto_server_url = "http://localhost:$(app.pluto_server_port)/edit?secret=$(app.session.secret)&id=$(notebook.notebook_id)$(isolated_cell_query)"
    
        
    @info """

    ✅✅✅

    Ready! To see the website, visit:
    ➡️   $(dev_server_url)

    To inspect the generation process, go to:
    ➡️   $(pluto_server_url)

    ✅✅✅

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
)
    app = run_plutopages_notebook(; input_dir, output_dir, cache_dir, run_server=false)
    notebook = fetch(app.notebook_task)
    
    bad = false
    for c in notebook.cells
        if c.errored
            bad = true
            @error("Cell errored", c.code, c.output.body)
        end
    end
    if bad
        error("Error in notebook")
    end
    
    @info "PlutoPages: cleaning up..."
    shutdown(app)
    
    return output_dir
end

generate(root_dir::String) = generate(;create_subdirs(root_dir)...)


function create_test_basic_site()
    original = joinpath(dirname(@__DIR__), "test", "basic_site")
    new_dir = mktempdir()
    cp(original, new_dir; force=true)
    new_dir
end




end