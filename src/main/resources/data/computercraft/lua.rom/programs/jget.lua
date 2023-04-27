do --settings block
    settings.define("JGET.outdir", { description = "Directory packages are installed into", default = "./packages/" })
    settings.define("JGET.endpoint",
        { description = "Location of JGET webserver. Uses master server as default",
            default = "https://jget.vercel.app/api/package/" })
end

local endpoint = settings.get("JGET.endpoint")
local outdir = shell.resolve(settings.get("JGET.outdir"))

function Set(list)
    local set = {}
    for _, l in ipairs(list) do set[l] = true end
    return set
end

local function ensure(dirname)
    if not fs.exists(dirname) then
        fs.makeDir(dirname)
    end
end

local function install(dirname, files)
    ensure(dirname)
    for fname, value in pairs(files) do
        local file_path = fs.combine(dirname, fname)
        if type(value) == "string" then
            --its a file
            local file = fs.open(file_path, "w")
            file.write(value)
            file.close()

        else
            --its a directory
            install(file_path, value)
        end

    end
end

local function get_installed_packages()
    return fs.list(outdir)
end

local function list()
    if (not fs.exists(outdir)) then
        print("no packages installed")
        return
    end
    print("installed packages:")
    print(textutils.serialise(get_installed_packages()))
end

local function get(arg)
    local package = arg[2]

    if package == nil then
        print("Please provide a package to install")
        return
    end

    print("getting package " .. package)


    local target_url = endpoint .. package

    local response, reason, failRes = http.get {
        url = target_url, method = "GET",
    }

    if not response then
        if not failRes then
            print("error: " .. reason)
            return
        end

        local data = textutils.unserialiseJSON(failRes.readAll())

        print("error: " .. data.message)
        return
    end


    if response.getResponseCode() ~= 200 then
        print("error: code ".. response.getResponseCode())
        return
    end

    local data = textutils.unserialiseJSON(response.readAll())

    if not data then
        print("error")
    end


    local files = textutils.unserialiseJSON(data["files"])

    ensure(outdir)

    local install_dir = fs.combine(outdir, package)
    install(install_dir, files)

    print("success!")
end

local function init(args)
    local package_name = args[2]

    if not package_name then
        write("Please provide a package")
        return
    end

    ensure("packages/")
    ensure("packages/" .. package_name)


    print("Initialised package " .. package_name)
    print("in packages/" .. package_name)
end

local function get_files(path)
    local data = {}
    local file_names = fs.list(path)
    for _, file_name in ipairs(file_names) do
        if not (file_name == "packages") then
            local file_path = fs.combine(path, file_name)
            if fs.isDir(file_path) then
                data[file_name] = get_files(file_path)
            else
                local file = fs.open(file_path, "r")
                data[file_name] = file.readAll()
                file.close()
            end
        end
    end
    return data
end

local function put(args)
    local package_name = args[2]

    if not package_name then
        write("Please provide a package")
        return
    end

    local package_dir = "packages/" .. package_name

    if not fs.exists(shell.resolve(package_dir)) then
        print("The directory `" .. package_dir .. "` does not exist")
        print("If your package is written somewhere else, please move it there")
        return
    end

    local data = {}
    local current_directory = shell.resolve("./packages/" .. package_name)

    local files = get_files(current_directory)

    data["files"] = textutils.serialiseJSON(files)

    json_data = textutils.serialiseJSON(data)

    --make put request
    -- Todo update this
    local target_url = endpoint .. package_name

    print(target_url)

    local args = {
        url = target_url, body = json_data, method = "PUT",
        headers = { ["Content-Type"] = "application/json" }
    }
    local response, reason, _ = http.post(args)

    if not response then
        print("Error: " .. reason)
        return
    end

    if response.getResponseCode() == 200 then
        print("Package uploaded successfully")
    else
        print("Error: code " .. response.getResponseCode())
    end

end

local help_dict = {
    ["list"] = [[
list
- lists all packages installed in the current directory

useage:
'jget list'
]]   ,
    ["get"] = [[
get
- requests the specified package from the JGET repo
- installed the package in the outdir (by default "./packages/")

useage:
'jget get <package name>'
]]   ,
    ["put"] = [[
put
- specify a package to to be uploaded
- looks for the package files in `<outdir>/<package name>/`
    - i.e. `packages/<package name>/`

- Package is uploaded to JGET repo

- This is an "upsert" operation;
- if the package already exists on the repo then the package will be updated

    useage:
'jget put <package name>'
]]   ,
    ["init"] = [[
init
- creates a directory in the `/packages/` folder
- the directory name is a

    useage:
'jget init <package name>'
]]   ,
    ["help"] = [[
help
- you are already using this command!
- given a command, will print availible help information for that command

- if you're looking for more information about using JGET, checkout the documentation:
https://jget.trevor.business/get_jget/

useage:
'jget help <command>'
]]   ,
}

local function jget_help(arg)
    local command = arg[2]

    if not command then
        print()
        print("You need to enter the command you want help on. Use 'jget' for list of commands")
        print()
        print("or type 'jget help help' for information on how to use this command")
        print()
        return
    end

    if help_dict[command] then
        print()
        print(help_dict[command])
    else
        print()
        print("Command not recognised. Use 'jget' for list of commands")
        print()
        print("or type 'jget help help' for information on how to use this command")
        print()
    end
end

local commands = {
    ["list"] = list,
    ["get"] = get,
    ["put"] = put,
    ["init"] = init,
    ["help"] = jget_help
}


local function main(args)
    local command = arg[1]
    if not command then
        print("")
        print("please enter a command")
        print("one of:")
        print("----")
        for name, _ in pairs(commands) do
            print(name)
        end
        print()
        return
    end

    if commands[command] then
        commands[command](args)
    else
        print("unrecognised command: " .. command)
    end
end

main(arg)
