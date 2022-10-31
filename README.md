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

## About

This open-source project was created primarily because of me being unable to register a lihkg account as a high school student.

Currently, it aims to be a fully featured alternative to lihkg. However, I might also add other useful features.

As contrasted with lihkg, metahkg is open to everyone and anyone can create an account with a email address, no matter issued by a university or not.

## Repos

This repository is a collection of four repositories:

- metahkg-web
- metahkg-server
- metahkg-links
- metahkg-api

Projects on the same branch should follow a same major version. Note that there might be delays, make sure to pull new changes from the sub-repositories, as this repository is not frequently updated.

## Versioning

All sub-projects here follow a same versioning, based on metahkg-server's versioning, compatibility is guaranteed for a same major version.

e.g. metahkg-server v2.5.1 would be compatibile with metahkg-api v2.5.x and metahkg-web v2.5.x, and vice versa.

## Branches

Two (or one) major versions are maintained at each time, one at the master branch and another at the dev branch. The version at dev branch is in development, and rather unstable, while that in master branch is considered stable but will only receive bug fixes until the next major version is ready. All new features are developed in dev branch.

[metahkg.org](https://metahkg.org) runs the latest master branch code, while [dev.metahkg.org](https://dev.metahkg.org) runs the dev branch.

## Metahkg Api Wrapper

We have an api wrapper [here](https://gitlab.com/metahkg/metahkg-api) (in metahkg-api), for easily accessing the api. Please use the api wrapper with a same major version of metahkg-server.

## Docs

[Metahkg docs](https://docs.metahkg.org)

## Cloning

Please clone with:

```bash
git clone --recurse-submodules https://gitlab.com/metahkg/metahkg.git
# and then
cd metahkg && git submodule foreach git pull
```

## Deploying

### Docker

It is recommended to use docker for deployment (also supports hot reload).

[Docs](https://docs.metahkg.org/docs/category/deploy-metahkg)

### Manually

**_WARNING:_** This is NOT RECOMMENDED and might be OUTDATED!

For manual deployment, see DEPLOY.md.
