-- Base config taken from `neovim/nvim-lspconfig`

local function get_jdtls_cache_dir()
    return vim.fn.stdpath("cache") .. "/jdtls"
end

local function get_jdtls_workspace_dir()
    return get_jdtls_cache_dir() .. "/workspace"
end

local function get_jdtls_jvm_args()
    local env = os.getenv("JDTLS_JVM_ARGS")
    local args = {}
    for a in string.gmatch((env or ""), "%S+") do
        local arg = string.format("--jvm-arg=%s", a)
        table.insert(args, arg)
    end
    return unpack(args)
end

local root_markers1 = {
    -- Multi-module projects
    "mvnw",
    "gradlew",
    "build.gradle",
    "build.gradle.kts",
    -- Use git directory as last resort for multi-module maven projects
    -- In multi-module maven projects it is not really possible to determine what is the parent directory
    -- and what is submodule directory. And jdtls does not break if the parent directory is at higher level than
    -- actual parent pom.xml so propagating all the way to root git directory is fine
    ".git",
}

local root_markers2 = {
    -- Single-module projects
    "build.xml", -- Ant
    "pom.xml", -- Maven
    "settings.gradle", -- Gradle
    "settings.gradle.kts", -- Gradle
}

vim.uv.os_setenv("JAVA_HOME", "/Library/Java/JavaVirtualMachines/temurin-25.jdk/Contents/Home")

-- Set Lombok JAR path for jdtls to recognize Lombok annotations.
local mason_registry_ok, mason_registry = pcall(require, "mason-registry")
if mason_registry_ok and mason_registry.is_installed("jdtls") then
    local InstallLocation = require("mason-core.installer.InstallLocation")
    local jdtls_path = InstallLocation.global():package("jdtls")
    local lombok_path = jdtls_path .. "/lombok.jar"

    -- Get existing JDTLS_JVM_ARGS from environment.
    local existing_args = os.getenv("JDTLS_JVM_ARGS") or ""

    -- Build new args with max memory and Lombok agent.
    local new_args = "-Xmx1g -javaagent:" .. lombok_path

    -- Append existing args if they exist.
    if existing_args ~= "" then
        new_args = new_args .. " " .. existing_args
    end

    vim.uv.os_setenv("JDTLS_JVM_ARGS", new_args)
end

local function add_mason_package_jars(bundles, package_name, jar_pattern)
    if mason_registry_ok and mason_registry.is_installed(package_name) then
        local InstallLocation = require("mason-core.installer.InstallLocation")
        local package_path = InstallLocation.global():package(package_name)
        local jars = vim.split(vim.fn.glob(package_path .. "/" .. jar_pattern), "\n")
        vim.list_extend(bundles, jars)
    end
end

local function get_jdtls_plugin_bundles()
    local bundles = {}

    -- Add java-debug bundles.
    add_mason_package_jars(bundles, "java-debug-adapter", "extension/server/com.microsoft.java.debug.plugin-*.jar")

    -- Add java-test bundles.
    add_mason_package_jars(bundles, "java-test", "extension/server/*.jar")

    return bundles
end

---@type vim.lsp.Config
return {
    ---@param client vim.lsp.Client
    ---@param bufnr number
    on_attach = function(client, bufnr)
        -- Register buffer-local test commands.
        vim.api.nvim_buf_create_user_command(bufnr, "JdtTestClass", function()
            require("jdtls").test_class()
        end, {
            desc = "Run/debug all tests in current class",
        })

        vim.api.nvim_buf_create_user_command(bufnr, "JdtTestNearest", function()
            require("jdtls").test_nearest_method()
        end, {
            desc = "Run/debug test method under cursor",
        })

        vim.api.nvim_buf_create_user_command(bufnr, "JdtTestPick", function()
            require("jdtls").pick_test()
        end, {
            desc = "Pick a test to run/debug",
        })
    end,
    ---@param dispatchers? vim.lsp.rpc.Dispatchers
    ---@param config vim.lsp.ClientConfig
    cmd = function(dispatchers, config)
        local workspace_dir = get_jdtls_workspace_dir()
        local data_dir = workspace_dir

        if config.root_dir then
            data_dir = data_dir .. "/" .. vim.fn.fnamemodify(config.root_dir, ":p:h:t")
        end

        local config_cmd = {
            "jdtls",
            "-data",
            data_dir,
            get_jdtls_jvm_args(),
        }

        return vim.lsp.rpc.start(config_cmd, dispatchers, {
            cwd = config.cmd_cwd,
            env = config.cmd_env,
            detached = config.detached,
        })
    end,
    filetypes = { "java" },
    root_markers = vim.fn.has("nvim-0.11.3") == 1 and { root_markers1, root_markers2 }
        or vim.list_extend(root_markers1, root_markers2),
    init_options = {
        bundles = get_jdtls_plugin_bundles(),
    },
    settings = {
        java = {
            autobuild = {
                enabled = false,
            },
            maxConcurrentBuilds = 8,
            signatureHelp = {
                enabled = true,
            },
            references = {
                includeDecompiledSources = true,
            },
            referencesCodeLens = {
                enabled = true,
            },
            implementationCodeLens = "all",
            contentProvider = {
                preferred = "fernflower",
            },
            completion = {
                enabled = true,
                favoriteStaticMembers = {
                    "org.junit.Assert.*",
                    "org.junit.Assume.*",
                    "org.junit.jupiter.api.Assertions.*",
                    "org.junit.jupiter.api.Assumptions.*",
                    "org.junit.jupiter.api.DynamicContainer.*",
                    "org.junit.jupiter.api.DynamicTest.*",
                    "org.mockito.Mockito.*",
                    "org.mockito.ArgumentMatchers.*",
                },
                filteredTypes = {
                    "com.sun.*",
                    "io.micrometer.shaded.*",
                    "java.awt.*",
                    "jdk.*",
                    "sun.*",
                },
            },
            configuration = {
                runtimes = {
                    {
                        name = "JavaSE-25",
                        path = "/Library/Java/JavaVirtualMachines/temurin-25.jdk/Contents/Home",
                    },
                },
                updateBuildConfiguration = "interactive",
            },
            maven = {
                downloadSources = true,
                updateSnapshots = false,
            },
            eclipse = {
                downloadSources = true,
            },
            import = {
                gradle = {
                    enabled = true,
                },
                maven = {
                    enabled = true,
                },
            },
            cleanup = {
                actionsOnSave = {
                    "addOverride",
                    "invertEquals",
                    "lambdaExpression",
                    "instanceofPatternMatch",
                    "stringConcatToTextBlock",
                    "switchExpression",
                },
            },
            sources = {
                organizeImports = {
                    starThreshold = 9999,
                    staticStarThreshold = 9999,
                },
            },
            symbols = {
                includeSourceMethodDeclarations = true,
            },
            inlayHints = {
                parameterNames = {
                    enabled = "literals",
                },
            },
            codeGeneration = {
                generateComments = true,
                insertionLocation = "beforeCursor",
                toString = {
                    template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
                },
                hashCodeEquals = {
                    useJava7Objects = true,
                    useInstanceOf = true,
                },
                useBlocks = true,
                addFinalForNewDeclaration = "fields",
            },
        },
    },
}
