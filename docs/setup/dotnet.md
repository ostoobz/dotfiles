# .NET SDKs, several versions at once

You end up with more than one .NET SDK installed side by side, and each repository building with
the version it asks for, without switching anything by hand.

Run and confirmed: SDK 8 and 9 together, a `net8.0` and a `net9.0` test project both building and
running.

## How .NET wants this to work

.NET's own model is one install root holding every SDK and runtime. The `dotnet` command there
picks an SDK per directory: the one named by the nearest `global.json` above you, otherwise the
newest installed. A project then runs on the runtime its `TargetFramework` names.

Trouble starts when versions live in separate roots (one per version manager entry, or one from
Homebrew and one from somewhere else). Each `dotnet` then sees only its own SDK and runtime, so a
`net8.0` test fails to start under a newer SDK with "framework not found".

mise's built-in .NET support follows the one-root model, which is why it is used here.

## Steps

1. Declare the versions in `config/mise/config.toml`:

   ```toml
   dotnet = ["9.0", "8.0"]
   ```

2. Install:

   ```sh
   mise install
   ```

   Both land in `~/.local/share/mise/dotnet-root`. No password needed.

3. In a repository with local tools (`.config/dotnet-tools.json`): `dotnet tool restore`.

## Check it worked

Open a new terminal, then:

```sh
command -v dotnet     # …/mise/dotnet-root/dotnet or …/mise/shims/dotnet
dotnet --list-sdks    # every version you declared, all under the same root
dotnet --version      # run inside a repository: the SDK that directory selects
```

## Things to know

- **mise does not choose the SDK; .NET does.** The order of versions in `config.toml` means
  nothing. To pin a repository, give it a `global.json`.
- **A newer SDK builds older targets.** With 8 and 9 installed and no `global.json`, a `net8.0`
  project builds with SDK 9 and runs on the 8.0 runtime. That is normally fine; if a build server
  uses SDK 8 for it, compiler warnings can differ.
- **One `dotnet` on the machine.** mise sets `DOTNET_ROOT` and tells .NET not to look elsewhere. A
  second install (Homebrew's `dotnet`, an installer package) is invisible to it, and anything that
  runs that other `dotnet` directly sees only its own version. If you keep one, make sure mise's
  comes first on `PATH`.
- **Workloads** (`dotnet workload install …`, for mobile or WebAssembly ahead-of-time builds) go
  into the same root and need no password. Not covered here; add a section after a first real run.
- **Global .NET tools**: `mise use dotnet:<package>`.
