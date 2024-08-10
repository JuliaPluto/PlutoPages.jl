using PlutoPages
using Test

@testset "PlutoPages.jl" begin

    input_dir = PlutoPages.create_test_basic_site()
    
    dirs = PlutoPages.create_subdirs(input_dir)
    
    html_report_path = tempname(cleanup=false)
    
    result = PlutoPages.generate(; dirs..., html_report_path)
    @test result == dirs.output_dir
    
    @info "Done!" dirs readdir(dirs.input_dir) readdir(dirs.output_dir)
    
    @test isdir(dirs.output_dir)
    @test isdir(joinpath(dirs.output_dir, "generated_assets"))
    
    @test isfile(joinpath(dirs.output_dir, "index.html"))
    @test isfile(joinpath(dirs.output_dir, "htmlpage", "index.html"))
    @test isfile(joinpath(dirs.output_dir, "en", "docs", "index.html"))
    @test isfile(joinpath(dirs.output_dir, "en", "docs", "packages", "index.html"))
    @test isfile(joinpath(dirs.output_dir, "en", "blog", "something", "index.html"))
    @test isfile(joinpath(dirs.output_dir, "en", "blog", "yayy", "index.html"))
    
    @test isfile(html_report_path)
end
