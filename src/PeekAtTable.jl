module PeekAtTable

# Write your package code here.
#=
look for way to split string with regex to remove ""
=#
using DataFrames, CSV, Colors, DelimitedFiles, PrettyTables
Base.@kwdef struct SetColors
    for_missing = Colors.color_names["red"]
    for_nothing = Colors.color_names["red"]
    for_strings = Colors.color_names["blue"]
    for_numbers = Colors.color_names["brown"]
    for_dates = Colors.color_names["green"]
    for_default = Colors.color_names["red"]
    for_user_added = []
end

Base.@kwdef struct AddTheseTypes
    to_strings = []
    to_numbers = []
    to_dates = []
    for_user_added = []
end
color_config = SetColors()
type_config = AddTheseTypes()

function set_palette(color_config)
    palette = []
    x = fieldnames(SetColors)
    for y in x[1:(end-2)]
        push!(palette, getproperty(color_config, y))
    end
    for y in color_config.for_user_added
        push!(palette, color_config.y)
    end
    return (palette)
end

function set_types(my_type_config)
    dict = ["Missing" => 1, "Nothing" => 2]
    for dict = [
        dict;
        ["Char", "AbstractChar", "AbstractString", "Core.Compiler.LazyString", "LazyString",
            "String", "SubString", "SubstitutionString"] .=> 3
    ]
        dict = [
            dict;
            ["Complex", "Number", "Base.MultiplicativeInverses.MultiplicativeInverse",
                "Base.MultiplicativeInverses.SignedMultiplicativeInverse",
                "Base.MultiplicativeInverses.UnsignedMultiplicativeInverse",
                "AbstractFloat", "AbstractIrrational", "Integer", "Rational", "BigFloat", "Float16",
                "Float32", "Float64", "Bool", "Signed", "Unsigned", "BigInt", "Int128", "Int16",
                "Int32", "Int64", "Int8", "UInt128", "UInt16", "UInt32", "UInt64", "UInt8"] .=> 4
        ]
        dict = [dict; ["Dates.Date"] .=> 5]
        x = dict[end][2]
        for y in my_type_config.for_user_added
            x += 1
            dict = [dict; y .=> x]
        end
    end
    return (Dict(dict))
end
const type_dict = set_types(type_config)
print(typeof(color_config))
const color_palette = set_palette(color_config)

function take_a_peek(data::DataFrame)

    x = []
    not_primitive = length(unique(values(type_dict))) + 1
    for a in eachcol(data)
        fred = "$(eltype(a))"
        fred = replace(fred, r"String\d+" => "String")
        if haskey(type_dict, fred)
            append!(x, type_dict[fred])
        elseif startswith(fred, "Union")
            fred = split(fred, r"\{|,|\}|\s+")
            fred = fred[2:end]
            filter!(!=(""), fred)
            y = fred .∈ Ref(["Missing", "Nothing"])
            if sum(y) == 1
                z = fred[findall(==(0), y)]
                z = get.(Ref(type_dict), z, not_primitive)
                b = type_dict[fred[findfirst(==(1), y)]]
                if length(unique(z)) != 1
                    z = not_primitive
                else
                    z = z[1]
                end
                #push!(x, (b, z))
            else
                push!(x, not_primitive)

            end
        else
            push!(x, not_primitive)
        end

    end
    return (x)
end



function take_a_peek(file_path::String)
     v = [1 2 3]
    writedlm(stdout, v, "ghm")
end

cd(joinpath(homedir(), "code", "julia", "JuliaCourseCodes-main", "02DSWJ", "Data", "04DataAnalysis"))
input = CSV.read("credit_input_data.csv", DataFrame)
take_a_peek(input) |> println
function print_a_peek_col(x::Tuple)
end
end
# open("output.html", "w") do io
#     pretty_table(io, input; backend = Val(:html), alignment=:c)
# end

end
