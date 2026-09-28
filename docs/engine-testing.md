# Engine testing with Open Cloud

This repo runs its Luau tests inside a **real Roblox server instance** on every
pull request. GitHub builds the place with Rojo, uploads it to a throwaway
test place, and asks Roblox's Open Cloud Luau Execution API to run
`tasks/runEngineTests.luau` there. Results land in the Actions log and as a
comment on the pull request.

The pattern is adapted from Roblox's MIT-licensed
[place-ci-cd-demo](https://github.com/Roblox/place-ci-cd-demo).

## One-time setup (repo admin)

### 1. Create a throwaway test experience

1. Go to [Creator Hub](https://create.roblox.com/dashboard/creations) ->
   Experiences -> **Create new experience**. Any template is fine; CI
   overwrites the place's contents on every run. Name it something like
   `Brickbattle-Weapons-Tests` so nobody mistakes it for the real game.
2. Open the experience in Creator Hub and note two numbers:
   - **Universe ID** - in the page URL:
     `create.roblox.com/dashboard/creations/experiences/<universe ID>`
   - **Place ID** - under the experience's Places list (the start place),
     also visible in the place's play-page URL:
     `roblox.com/games/<place ID>/...`

### 2. Create an Open Cloud API key

1. Creator Hub -> **Open Cloud** -> **API Keys** -> **Create API Key**.
2. Name it something like `brickbattle-ci`.
3. Under **Access permissions**, select the test experience and add:
   - `universe.places` -> **Write** (lets CI upload place builds)
   - `universe.place.luau-execution-session` -> **Write** (lets CI run tests)
4. Leave IP restrictions open (`0.0.0.0/0`): GitHub Actions runners use
   changing IP addresses.
5. Create the key and copy it - Roblox shows it only once.

### 3. Hand the key and IDs to Instinct

- Paste the API key into the secure vault link Instinct sent you. Instinct
  stores it as the GitHub Actions secret `ROBLOX_API_KEY`.
- Send Instinct the universe ID and place ID (not secret). Instinct stores
  them as the repository variables `ROBLOX_TEST_UNIVERSE_ID` and
  `ROBLOX_TEST_PLACE_ID`.

Prefer to do it by hand instead? Repo -> **Settings** -> **Secrets and
variables** -> **Actions**: add the secret and the two variables with the
names above.

### 4. Done

Every pull request now builds the branch, publishes it to the test place,
and runs the suites in `tests/` in-engine. Suites for code that has not
merged yet report SKIP instead of FAIL, so the check stays green on branches
that predate a validator slice.

## What the tests can and cannot prove

A Luau execution session is a real server with real physics, but **no real
clients connect to it**. So this setup proves the server-side validator math
against genuine engine behavior (gravity, stepped integration, timing), and
nothing about the client-server trust boundary itself. Simulated multiplayer
clients need Studio's StudioTestService on a real machine - a separate layer.
