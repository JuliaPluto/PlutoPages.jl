import Pluto: Pluto, PlutoDependencyExplorer


function replace_definitions!(notebook::Pluto.Notebook, inputs::Dict{Symbol,<:Any})
    for (name, value) in pairs(inputs)
        # Find the cell that currently defines a variable with this name.
        cs = PlutoDependencyExplorer.where_assigned(notebook.topology, Set([name]))
        if length(cs) != 1
            error("The variable $(name) is not defined in this notebook: it cannot be used as input to the app.")
        else
            c = only(cs)::Pluto.Cell

            c.code = "const $(name) = $(repr(value))"
            c.code_folded = true
        end
    end
    
    notebook
end


function open_notebook_with_replacements!(session::Pluto.ServerSession, notebook_path::AbstractString, inputs::Dict{Symbol,<:Any})
    notebook = Pluto.SessionActions.open(
        session, notebook_path; 
        run_async=false,
        execution_allowed=false, # start in "Safe mode", to allow us to inject some code before running the notebook :)
    )
    
    notebook.topology = Pluto.static_resolve_topology(Pluto.updated_topology(notebook.topology, notebook, notebook.cells))
    
    replace_definitions!(notebook, inputs)
end



function run_with_replacements(notebook_path::AbstractString, inputs::Dict{Symbol,<:Any};
    run_server::Bool=false,
)
    port_channel = Channel{UInt16}(1)

    function on_event(e::Pluto.ServerStartEvent)
        put!(port_channel, e.port)
    end
    function on_event(e) end

    options=Pluto.Configuration.from_flat_kwargs(;
        workspace_use_distributed=true,
        disable_writing_notebook_files=true,
        launch_browser=false,
        show_file_system=false,
        dismiss_update_notification=true,
        on_event,
        port_hint=6872,
    )
    session = Pluto.ServerSession(;options)

    @info "PlutoPages: Starting Pluto notebook..."
    notebook_task = Threads.@spawn try
        notebook = open_notebook_with_replacements!(session, notebook_path, inputs)

        log_progress = Ref(true)
        let
            last_progress = (0,0)
            Threads.@spawn while log_progress[]
                progress = (
                    notebook.process_status == Pluto.ProcessStatus.ready ? 
                        length(notebook.cells) - count(c -> c.running || c.queued, notebook.cells) : 
                        0,
                    length(notebook.cells)
                )
                if progress != last_progress
                    @info "Notebook: $(progress[1])/$(progress[2]) done..."
                    last_progress = progress
                end
                sleep(.5)
            end
        end

        # disable "Safe preview" mode
        notebook.process_status = Pluto.ProcessStatus.starting
        foreach(c -> c.queued = true, notebook.cells)
        # run all cells
        Pluto.update_save_run!(session, notebook, notebook.cells; run_async=false)
        @info "Pluto app: notebook finished!"
        log_progress[] = false

        notebook
    catch e
        @error "Error while running notebook" exception=(e,catch_backtrace())
    end

    pluto_server_instance = if run_server
        @info "PlutoPages: Starting Pluto server... \n(Ignore the message 'Go to ... in your browser to start writing.')"
        Pluto.run!(session)
    end

    pluto_server_port = run_server ? take!(port_channel) : nothing
    @info "Pluto app: waiting for notebook to finish..."

    return (;
        session,
        notebook_task,
        pluto_server_instance,
        pluto_server_port,
    )
end



function shutdown(app)
    # uhhh this will wait for it to finish but whatever
    notebook = fetch(app.notebook_task)
    
    Pluto.SessionActions.shutdown(app.session, notebook)
    
    if app.pluto_server_instance !== nothing
        Base.close(app.pluto_server_instance)
    end
end

