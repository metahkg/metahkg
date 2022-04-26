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

## About

This open-source project was created primarily because of me being unable to register a lihkg account as a high school student.

Currently, it aims to be a fully featured alternative to lihkg. However, I might also add other useful features.

As contrasted with lihkg, metahkg is open to everyone and anyone can create an account with a email address, no matter issued by a university or not.

## Docs

Metahkg docs:

- [master branch](https://master.docs.metahkg.org)
- [dev branch](https://dev.docs.metahkg.org)

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

Docs:

- master branch [master.docs.metahkg.org/docker](https://master.docs.metahkg.org/docker)
- dev branch [dev.docs.metahkg.org/docker](https://dev.docs.metahkg.org/docker)

## Manually

**_WARNING:_** This is NOT RECOMMENDED and might be OUTDATED!

For manual deployment, see DEPLOY.md.
