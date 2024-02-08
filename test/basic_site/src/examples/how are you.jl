### A Pluto.jl notebook ###
# v0.18.2

#> [frontmatter]
#> title = "Basic syntax"
#> description = "A simple notebook demonstrating the Julia syntax essentials"
#> layout = "layout.jlhtml"
#> date = "2020-06-01"
#> tags = ["blog"]

using Markdown
using InteractiveUtils

# ╔═╡ 0d3aec92-edeb-11ea-3adb-cd0dc17cbdab


# ╔═╡ 3b038ee0-edeb-11ea-0977-97cc30d1c6ff
md"
# This is a test page for PlutoPages.jl

## Variables

We can define a variable using `=` (assignment). Then we can use its value in other expressions:
"

# ╔═╡ 3e8e0ea0-edeb-11ea-22e0-c58f7c2168ce
x = 3

# ╔═╡ 59b66862-edeb-11ea-2d62-71dcc79dbfab
y = 2x

# ╔═╡ 5e062a24-edeb-11ea-256a-d938f77d7815
md"By default Julia displays the output of the last operation. (You can suppress the output by adding `;` (a semicolon) at the end.)
"

# ╔═╡ 7e46f0e8-edeb-11ea-1092-4b5e8acd9ee0
md"We can ask what type a variable has using `typeof`:"

# ╔═╡ 8a695b86-edeb-11ea-08cc-17263bec09df
typeof(y)

# ╔═╡ 8e2dd3be-edeb-11ea-0703-354fb31c12f5
md"## Functions"

# ╔═╡ 96b5a28c-edeb-11ea-11c0-597615962f54
md"We can use a short-form, one-line function definition for simple functions:"

# ╔═╡ a7453572-edeb-11ea-1e27-9f710fd856a6
f(x) = 2 + x

# ╔═╡ b341db4e-edeb-11ea-078b-b71ac00089d7
md"Typing the function's name gives information about the function. To call it we must use parentheses:"

# ╔═╡ 23f9afd4-eded-11ea-202a-9f0f1f91e5ad
f

# ╔═╡ cc1f6872-edeb-11ea-33e9-6976fd9b107a
f(10)

# ╔═╡ ce9667c2-edeb-11ea-2665-d789032abd11
md"For longer functions we use the following syntax with the `function` keyword and `end`:"

# ╔═╡ d73d3400-edeb-11ea-2dea-95e8c4a6563b
function g(x, y)
	z = x + y
	return z^2
end

# ╔═╡ e04ccf10-edeb-11ea-36d1-d11969e4b2f2
g(1, 2)

# ╔═╡ e297c5cc-edeb-11ea-3bdd-090f415685ab
md"## For loops"

# ╔═╡ ec751446-edeb-11ea-31ba-2372e7c71b42
md"Use `for` to loop through a pre-determined set of values:"

# ╔═╡ fe3fa290-edeb-11ea-121e-7114e5c573c1
let s = 0
	
	for i in 1:10
		s += i    # Equivalent to s = s + i
	end
	
	s
end

# ╔═╡ 394b0ec8-eded-11ea-31fb-27392068ef8f
md"Here, `1:10` is a **range** representing the numbers from 1 to 10:"

# ╔═╡ 4dc00908-eded-11ea-25c5-0f7b2b7e18f9
typeof(1:10)

# ╔═╡ 6c44abb4-edec-11ea-16bd-557800b5f9d2
md"Above we used a `let` block to define a new local variable `s`. 
But blocks of code like this are usually better inside functions, so that they can be reused. For example, we could rewrite the above as follows:
"

# ╔═╡ 683af3e2-eded-11ea-25a5-0d90bf099d98
function mysum(n)
	s = 0
	
	for i in 1:n
		s += i    
	end
	
	return s
end

# ╔═╡ 76764ea2-eded-11ea-1aa6-296f3421de1c
mysum(100)

# ╔═╡ 93a231f4-edec-11ea-3b39-299b3be2da78
md"## Conditionals: `if`"

# ╔═╡ 82e63a24-eded-11ea-3887-15d6bfabea4b
md"We can evaluate whether a condition is true or not by simply writing the condition:"

# ╔═╡ 9b339b2a-eded-11ea-10d7-8fc9a907c892
a = 3

# ╔═╡ 9535eb40-eded-11ea-1651-e33c9c23dbfb
a < 5

# ╔═╡ a16299a2-eded-11ea-2b56-93eb7a1010a7
md"We see that conditions have a Boolean (`true` or `false`) value. 

We can then use `if` to control what we do based on that value:"

# ╔═╡ bc6b124e-eded-11ea-0290-b3760cb81024
if a < 5
	"small"
	
else
	"big"
	
end

# ╔═╡ cfb21014-eded-11ea-1261-3bc30952a88e
md"""Note that the `if` also returns the last value that was evaluated, in this case the string `"small"` or `"big"`, Since Pluto is reactive, changing the definition of `a` above will automatically cause this to be reevaluated!"""

# ╔═╡ ffee7d80-eded-11ea-26b1-1331df204c67
md"## Arrays"

# ╔═╡ cae4137e-edee-11ea-14af-59a32227de1b
md"### 1D arrays (`Vector`s)"

# ╔═╡ 714f4fca-edee-11ea-3410-c9ab8825d836
md"We can make a `Vector` (1-dimensional, or 1D array) using square brackets:"

# ╔═╡ 82cc2a0e-edee-11ea-11b7-fbaa5ad7b556
v = [1, 2, 3]

# ╔═╡ 85916c18-edee-11ea-0738-5f5d78875b86
typeof(v)

# ╔═╡ 881b7d0c-edee-11ea-0b4a-4bd7d5be2c77
md"The `1` in the type shows that this is a 1D array.

We access elements also using square brackets:"

# ╔═╡ a298e8ae-edee-11ea-3613-0dd4bae70c26
v[2]

# ╔═╡ a5ebddd6-edee-11ea-2234-55453ea59c5a
v[2] = 10

# ╔═╡ a9b48e54-edee-11ea-1333-a96181de0185
md"Note that Pluto does not automatically update cells when you modify elements of an array, but the value does change."

# ╔═╡ 68c4ead2-edef-11ea-124a-03c2d7dd6a1b
md"A nice way to create `Vector`s following a certain pattern is to use an **array comprehension**:"

# ╔═╡ 84129294-edef-11ea-0c77-ffa2b9592a26
v2 = [i^2 for i in 1:10]

# ╔═╡ d364fa16-edee-11ea-2050-0f6cb70e1bcf
md"### 2D arrays (matrices)"

# ╔═╡ db99ae9a-edee-11ea-393e-9de420a545a1
md"We can make small matrices (2D arrays) with square brackets too:"

# ╔═╡ 04f175f2-edef-11ea-0882-712548ebb7a3
M = [1 2
	 3 4]

# ╔═╡ 0a8ac112-edef-11ea-1e99-cf7c7808c4f5
typeof(M)

# ╔═╡ 1295f48a-edef-11ea-22a5-61e8a2e1d005
md"The `2` in the type confirms that this is a 2D array."

# ╔═╡ 3e1fdaa8-edef-11ea-2f03-eb41b2b9ea0f
md"This won't work for larger matrices, though. For that we can use e.g."

# ╔═╡ 48f3deca-edef-11ea-2c18-e7419c9030a0
zeros(5, 5)

# ╔═╡ a8f26af8-edef-11ea-2fc7-2b776f515aea
md"Note that `zeros` gives `Float64`s by default. We can also specify a type for the elements:"

# ╔═╡ b595373e-edef-11ea-03e2-6599ef14af20
zeros(Int, 4, 5)

# ╔═╡ 4cb33c04-edef-11ea-2b35-1139c246c331
md"We can then fill in the values we want by manipulating the elements, e.g. with a `for` loop."

# ╔═╡ 54e47e9e-edef-11ea-2d75-b5f550902528
md"A nice alternative syntax to create matrices following a certain pattern is an array comprehension with a *double* `for` loop:"

# ╔═╡ 6348edce-edef-11ea-1ab4-019514eb414f
[i + j for i in 1:5, j in 1:6]

# ╔═╡ e03be0e6-160c-46ac-a417-32e7299be02d
md"""
# Acknowledgement
"""

# ╔═╡ 2548306d-ed5d-4793-b925-7b36e932841c
Markdown.MD(
	Markdown.Admonition("warning", "This notebook is taken from", 
[md"""
		
_**Computational Thinking**, a live online Julia/Pluto textbook._ ([computationalthinking.mit.edu](https://computationalthinking.mit.edu), [original notebook](https://github.com/mitmath/18S191/blob/Fall20/lecture_notebooks/Basic%20Julia%20syntax.jl))
"""] 
	))

# ╔═╡ 6e618eb2-037a-4688-bc7b-53fda57993a1
using PlutoUI

# ╔═╡ f15d5b3e-7639-4d20-9cfd-ef6bc07451c3
TableOfContents()

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
PlutoUI = "~0.7.34"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.7.2"
manifest_format = "2.0"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "8eaf9f1b4921132a4cff3f36a1d9ba923b14a481"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.4"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "024fe24d83e4a5bf5fc80501a314ce0d1aa35597"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.0"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.Downloads]]
deps = ["ArgTools", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[deps.HypertextLiteral]]
git-tree-sha1 = "2b078b5a615c6c0396c77810d92ee8c6f470d238"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.3"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "f7be53659ab06ddc986428d3a9dcc95f6fa6705a"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.2"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "3c837543ddb02250ef42f4738347454f95079d4e"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.3"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"

[[deps.LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.LinearAlgebra]]
deps = ["Libdl", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"

[[deps.Parsers]]
deps = ["Dates"]
git-tree-sha1 = "13468f237353112a01b2d6b32f3d0f80219944aa"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.2.2"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "UUIDs"]
git-tree-sha1 = "8979e9802b4ac3d58c503a20f2824ad67f9074dd"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.34"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl", "OpenBLAS_jll"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
"""

# ╔═╡ Cell order:
# ╟─f5450eab-0f9f-4b7f-9b80-992d3c553ba9
# ╟─0d3aec92-edeb-11ea-3adb-cd0dc17cbdab
# ╟─3b038ee0-edeb-11ea-0977-97cc30d1c6ff
# ╠═3e8e0ea0-edeb-11ea-22e0-c58f7c2168ce
# ╠═59b66862-edeb-11ea-2d62-71dcc79dbfab
# ╟─5e062a24-edeb-11ea-256a-d938f77d7815
# ╟─7e46f0e8-edeb-11ea-1092-4b5e8acd9ee0
# ╠═8a695b86-edeb-11ea-08cc-17263bec09df
# ╟─8e2dd3be-edeb-11ea-0703-354fb31c12f5
# ╟─96b5a28c-edeb-11ea-11c0-597615962f54
# ╠═a7453572-edeb-11ea-1e27-9f710fd856a6
# ╟─b341db4e-edeb-11ea-078b-b71ac00089d7
# ╠═23f9afd4-eded-11ea-202a-9f0f1f91e5ad
# ╠═cc1f6872-edeb-11ea-33e9-6976fd9b107a
# ╟─ce9667c2-edeb-11ea-2665-d789032abd11
# ╠═d73d3400-edeb-11ea-2dea-95e8c4a6563b
# ╠═e04ccf10-edeb-11ea-36d1-d11969e4b2f2
# ╟─e297c5cc-edeb-11ea-3bdd-090f415685ab
# ╟─ec751446-edeb-11ea-31ba-2372e7c71b42
# ╠═fe3fa290-edeb-11ea-121e-7114e5c573c1
# ╟─394b0ec8-eded-11ea-31fb-27392068ef8f
# ╠═4dc00908-eded-11ea-25c5-0f7b2b7e18f9
# ╟─6c44abb4-edec-11ea-16bd-557800b5f9d2
# ╠═683af3e2-eded-11ea-25a5-0d90bf099d98
# ╠═76764ea2-eded-11ea-1aa6-296f3421de1c
# ╟─93a231f4-edec-11ea-3b39-299b3be2da78
# ╟─82e63a24-eded-11ea-3887-15d6bfabea4b
# ╠═9b339b2a-eded-11ea-10d7-8fc9a907c892
# ╠═9535eb40-eded-11ea-1651-e33c9c23dbfb
# ╟─a16299a2-eded-11ea-2b56-93eb7a1010a7
# ╠═bc6b124e-eded-11ea-0290-b3760cb81024
# ╟─cfb21014-eded-11ea-1261-3bc30952a88e
# ╟─ffee7d80-eded-11ea-26b1-1331df204c67
# ╟─cae4137e-edee-11ea-14af-59a32227de1b
# ╟─714f4fca-edee-11ea-3410-c9ab8825d836
# ╠═82cc2a0e-edee-11ea-11b7-fbaa5ad7b556
# ╠═85916c18-edee-11ea-0738-5f5d78875b86
# ╟─881b7d0c-edee-11ea-0b4a-4bd7d5be2c77
# ╠═a298e8ae-edee-11ea-3613-0dd4bae70c26
# ╠═a5ebddd6-edee-11ea-2234-55453ea59c5a
# ╟─a9b48e54-edee-11ea-1333-a96181de0185
# ╟─68c4ead2-edef-11ea-124a-03c2d7dd6a1b
# ╠═84129294-edef-11ea-0c77-ffa2b9592a26
# ╟─d364fa16-edee-11ea-2050-0f6cb70e1bcf
# ╟─db99ae9a-edee-11ea-393e-9de420a545a1
# ╠═04f175f2-edef-11ea-0882-712548ebb7a3
# ╠═0a8ac112-edef-11ea-1e99-cf7c7808c4f5
# ╟─1295f48a-edef-11ea-22a5-61e8a2e1d005
# ╟─3e1fdaa8-edef-11ea-2f03-eb41b2b9ea0f
# ╠═48f3deca-edef-11ea-2c18-e7419c9030a0
# ╟─a8f26af8-edef-11ea-2fc7-2b776f515aea
# ╠═b595373e-edef-11ea-03e2-6599ef14af20
# ╟─4cb33c04-edef-11ea-2b35-1139c246c331
# ╟─54e47e9e-edef-11ea-2d75-b5f550902528
# ╠═6348edce-edef-11ea-1ab4-019514eb414f
# ╟─e03be0e6-160c-46ac-a417-32e7299be02d
# ╟─2548306d-ed5d-4793-b925-7b36e932841c
# ╠═6e618eb2-037a-4688-bc7b-53fda57993a1
# ╠═f15d5b3e-7639-4d20-9cfd-ef6bc07451c3
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
