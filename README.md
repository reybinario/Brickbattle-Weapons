# Vulcan Brickbattle Weapons

## Introduction

Vulcan Brickbattle Weapons ("Vulcan") is intended to be the most optimized and performance-focused brickbattle weapons set available to Roblox.
It uses new Roblox features such as buffers, unreliable remotes, native code generation, and more. Vulcan also comes with an API designed for
deep-level interaction with the system. Below you can find documentation on getting ready to contribute to the project, as well as a Whitepaper
defining design philosophies found within the weapon set.

## Getting Started

If you've never coded outside of Roblox Studio before, this will be a nice guide to help you get started. If you have any questions, just ask [ChatGPT](https://chat.openai.com/). It can answer most of them for you.

### 1. Install VS Code

VS Code is a light weight code editor made by Microsoft. It's available [here](https://code.visualstudio.com/download).

### 2. Install Git

Git is a tool that software developers use to manage their code (source control). It helps us with versioning, combining and merging code written by different people, and other things. It's available [here](https://git-scm.com/downloads).

Git is mostly used as a CLI, or command-line interface. With CLI's, you enter commands into a terminal (special text box) rather than clicking visual buttons in order to make your computer do things. We use a lot of CLI's here, and I so I recommend familiarizing yourself with the concept.

* Don't understand Git? Follow [this](https://git-scm.com/docs/gittutorial), or [this](https://www.atlassian.com/git/tutorials/what-is-version-control) if you have more time.
* Have Mac/Linux and don't understand Linux-based command line interfaces (CLIs)? Follow [this](https://ryanstutorials.net/linuxtutorial/).
* Have Windows? Follow [this](https://www.tutorialspoint.com/powershell/index.htm) to understand basic PowerShell commands and usage.

### 3. Install Aftman

[Aftman](https://github.com/LPGhatguy/aftman?tab=readme-ov-file#installation) is used for tool management.

### 4. Download the code

1. Open up your terminal (Terminal in Mac, Powershell in Windows).
2. Use `cd` to enter the folder/directory you want to download the code to

```zsh
cd ~/projects
```

or make a new directory via `mkdir`

```zsh
mkdir projects
cd projects
```

3. Download the code with this git command:

```zsh
git clone https://github.com/reybinario/Brickbattle-Weapons.git
```

4. Run Aftman to install tools

```zsh
cd Brickbattle-Weapons
aftman install
```

Aftman just installed a bunch of tools for you. They are:

* [wally](https://github.com/UpliftGames/wally) for package management. ([What's that?](https://dev.to/stackblitz/explain-like-im-five-package-managers-1a7a))
* [wally-package-types](https://github.com/JohnnyMorganz/wally-package-types) fixes the issue of wally thunks not including exported types, necessary for proper Luau type checking support.
* [zap](https://zap.redblox.dev/) for network code generation. In this package, we don't manage our own remotes, Zap does it for us.
* and finally, [Rojo](https://rojo.space/), see below.

### 5. Use Rojo for VS Code -> Roblox Studio Sync

Please go through Rojo's [tutorial](https://rojo.space/docs/v7/). You can also try the [VS Code plugin](https://marketplace.visualstudio.com/items?itemName=evaera.vscode-rojo).

### 6. Download Plugins

#### VS Code

I recommend the following for Roblox:

* [Luau Language Server](https://marketplace.visualstudio.com/items?itemName=JohnnyMorganz.luau-lsp) for code inference/completion.
* [StyLua](https://marketplace.visualstudio.com/items?itemName=JohnnyMorganz.stylua) for code formatting and styling.
* [Selene](https://marketplace.visualstudio.com/items?itemName=Kampfkarren.selene-vscode) for code linting ([what's that?](https://stackoverflow.com/questions/8503559/what-is-linting)).
* [Roblox UI](https://marketplace.visualstudio.com/items?itemName=filiptibell.roblox-ui) for data model visualization (explorer/properties).
* [Zap Syntax Highlighting](https://marketplace.visualstudio.com/items?itemName=naxblox.zap-nax) for highlighting of keywords in the .zap file.

Some others I recommend for general development:

* [Git Lens](https://marketplace.visualstudio.com/items?itemName=eamodio.gitlens)
* [Material Icons](https://marketplace.visualstudio.com/items?itemName=PKief.material-icon-theme)

#### Roblox Studio Plugins

* [Rojo](https://create.roblox.com/store/asset/13916111004?externalSource=www&assetType=Plugin) is needed on the Roblox Studio side to handle sync.

### 7. Build and test

Start syncing with Rojo by running the following command in your terminal:

```zsh
rojo serve
```

and clicking the Roblox Studio Rojo plugin and clicking "connect". Then, make sure your code is committed in Roblox Studio if
you're using TeamCreate, and click play!

### 8. Make changes and send your code for review

#### 1. Make and save changes

Git uses branches to manage source control. A branch is just a copy of the code that you're working on,
so the original doesn't get effected. To create a new branch, run the following:

```zsh
git checkout -b my_new_branch
```

Now you're ready to make your edits. For the purposes of this guide, add your name to the below list in this README.md file:

* reybinario
* Hecatarch

Save the file and run the command below to stage it. This just marks the file(s) as ready to be operated
on by Git.

```zsh
git add .
```

Then, commit your code. Add a good commit message, it should follow the [conventional commit](https://www.conventionalcommits.org/en/v1.0.0/#summary) pattern.

```zsh
git commit -m "feat: add new flamethrower tool"
```

#### 2. Create a pull request

Lastly, use the [GitHub CLI tool](https://cli.github.com/) to create a request to pull in your code to the repository:

```zsh
gh auth login
gh pr create
```

Note: you may need to set-up a token so you can push to GitHub.

#### 3. Code review and updating a PR

What happens next? Your code will be reviewed my myself (the repository owner). If edits are needed, you'll repeat by the previous process, but will probably use

```zsh
git commit --amend --no-edit
```

instead of a regular commit so you don't add an extra unnecessary commit in our Git history. And

```zsh
git push
```

since you won't need to create another PR, just need to push your changes to your branch that's living in the GitHub repository.

And that's it! You should be ready to code, iterate, and contribute to this package now.

## Whitepaper

### Introduction

### System Overview

### Technical Details

### Alternatives

### Future Work

### Glossary
