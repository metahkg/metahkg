# Metahkg

This is the monorepo for metahkg.

stable: [metahkg.org](https://metahkg.org)

dev build (probably daily): [dev.metahkg.org](https://dev.metahkg.org)

[![React](https://badges.aleen42.com/src/react.svg)](http://reactjs.org/)
[![Nodejs](https://badges.aleen42.com/src/node.svg)](https://nodejs.org)
[![Typescript](https://badges.aleen42.com/src/typescript.svg)](https://www.typescriptlang.org/)

[![Gitlab](https://badges.aleen42.com/src/gitlab.svg)](https://gitlab.com/metahkg/metahkg)
[![Github](https://badges.aleen42.com/src/github.svg)](https://github.com/metahkg/metahkg)
[![GitHub license](https://img.shields.io/github/license/metahkg/metahkg)](https://github.com/metahkg/metahkg/blob/master/LICENSE)

[![Telegram](https://patrolavia.github.io/telegram-badge/chat.svg)](https://t.me/+WbB7PyRovUY1ZDFl)
[![Discord](https://img.shields.io/discord/992390401740775555)](https://discord.gg/yrf2v8KGdc)

## About

This open-source project was created primarily because of me being unable to register a lihkg account as a high school student.

Currently, it aims to be a fully featured alternative to lihkg. However, I might also add other useful features.

As contrasted with lihkg, metahkg is open to everyone and anyone can create an account with a email address, no matter issued by a university or not.

## Repos

This repository is a collection of three submodules:

- metahkg-web
- metahkg-server
- metahkg-links

They are dependent of one another, and compatibility is guaranteed if they are all on a same branch (i.e. master or dev).
Note that there might be delays on updating.

## Versioning

Metahkg is now in rapid release. Metahkg-web and metahkg-server should follow a same version.

## Metahkg Api Wrapper

We have an api wrapper [here](https://gitlab.com/metahkg/metahkg-api) for easily accessing the api. Please use the api wrapper with a same version of metahkg-server. [metahkg.org](https://metahkg.org) runs the latest master branch code, while [dev.metahkg.org](https://dev.metahkg.org) runs the dev branch.

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

## Manually

**_WARNING:_** This is NOT RECOMMENDED and might be OUTDATED!

For manual deployment, see DEPLOY.md.
