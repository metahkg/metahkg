# Metahkg

stable: [metahkg.org](https://metahkg.org)

dev build: [dev.metahkg.org](https://dev.metahkg.org)

[![React](https://badges.aleen42.com/src/react.svg)](http://reactjs.org/)
[![Nodejs](https://badges.aleen42.com/src/node.svg)](https://nodejs.org)
[![Typescript](https://badges.aleen42.com/src/typescript.svg)](https://www.typescriptlang.org/)

[![Gitlab](https://badges.aleen42.com/src/gitlab.svg)](https://gitlab.com/metahkg/metahkg)
[![Github](https://badges.aleen42.com/src/github.svg)](https://github.com/metahkg/metahkg)
[![License](https://img.shields.io/gitlab/license/metahkg/metahkg)](https://gitlab.com/metahkg/metahkg/-/tree/master/LICENSE.md)

[![Telegram](https://patrolavia.github.io/telegram-badge/chat.svg)](https://t.me/+WbB7PyRovUY1ZDFl)
[![Discord](https://badges.aleen42.com/src/discord.svg)](https://discord.gg/yrf2v8KGdc)

Maintainers wanted! See https://l.metahkg.org/239.

## TL;DR

```bash
branch=dev
git clone --recurse-submodules -b $branch https://gitlab.com/metahkg/metahkg.git
cd metahkg && git pull origin $branch && git submodule foreach git checkout $branch && git submodule foreach git pull
./setup.sh
```

## About

This open-source project was created primarily because of me being unable to register a lihkg account as a high school student.

Currently, it aims to be a fully featured alternative to lihkg. However, I might also add (and I have added) other useful features.

As contrasted with lihkg, metahkg is open to everyone and anyone can create an account with a email address, no matter issued by a university or not.

## Repos

This repository contains eight sub-repositories written in different languages and frameworks:

### Core

- metahkg-web (typescript, react)
- metahkg-server (typescript, nodejs, fastify)
- metahkg-links (typescript,nodejs, fastify)
- metahkg-api (typescript, auto-generated)
- rlp-proxy-rewrite (typescript, nodejs, fastify)
- metahkg-redirect (typescript, next.js)

Projects on the same branch should follow a same minor version. Note that there might be delays, make sure to pull new changes from the sub-repositories, as this repository is not frequently updated.

### Forks

- forks/imageproxy (go)
- forks/imgpush (python, flask)

## Versioning

All sub-projects here follow a same versioning, major.minor.patch.

Packages with the same minor version are fully compatibile.
Packages with the same major but not minor version are highly compatibile.
Packages with different major versions have little to no compatibility.

e.g. metahkg-server v2.5.1 would be fully compatibile with metahkg-api v2.5.x and metahkg-web v2.5.x, and vice versa.

## Branches

`dev` branch is the development branch, where new features and versions are developed.
`master` branch is a maintained snapshot (bug fixes only) of the `dev` branch, and would be updated to a different snapshot after some development in the `dev` branch.

If you wish to contribute, please develop base on the `dev` branch. See [CONTRIBUTING.md](./CONTRIBUTING.md) for more information.

[metahkg.org](https://metahkg.org) runs the latest `master` branch code, while [dev.metahkg.org](https://dev.metahkg.org) runs the latest `dev` branch code. They are updated to use the latest docker images every hour.

## Metahkg Api Client

We have a typescript api client [here](https://gitlab.com/metahkg/metahkg-api) (in metahkg-api), for easily accessing the api. Please use the api client with a same minor version of metahkg-server.

## Docs

[Metahkg docs](https://docs.metahkg.org)

## Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md)

## Todo / Roadmap

See [epics](https://gitlab.com/groups/metahkg/-/epics?state=opened&page=1&sort=start_date_desc) or [TODO.md](./TODO.md).

## Issues

Report a bug / submit a feature request by [creating an issue](https://gitlab.com/groups/metahkg/-/issues).

## Cloning

Please clone with:

```bash
git clone --recurse-submodules https://gitlab.com/metahkg/metahkg.git
cd metahkg
git submodule update --init --recursive
git submodule foreach git checkout dev
git submodule foreach git pull
```

## Deploying

Metahkg currently only supports using docker for deployment.

### Docker

[Docs](https://docs.metahkg.org/docs/category/deploy-metahkg)

#### Script

```bash
./setup.sh
```
