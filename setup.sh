#/usr/bin/env bash

# supported architectures:
#   - amd64
#   - arm64
# supported distros / systems:
#   - debian / raspbian / ubuntu
#   - arch linux
#   - rocky linux / rhel
#   - macos (untested, use at your own risk!)

input () {
    read -p "$1" input;
    if [ -n "$input" ]; then
        eval "$3"="$input"
    else
        eval "$3"="$2";
    fi;
}

install_dependencies_debian() {
    echo "Installing dependencies using apt-get";

    if [ "$(whoami)" = "root" ]; then
        apt-get update;
        apt-get install sudo -y;
    fi;

    # use the nodesource setup script (for nodejs)
    # https://docs.metahkg.org/docs/deploy/setup/requirements#debian-1
    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -;

    sudo apt-get update;
    sudo apt-get install -y ca-certificates curl git nodejs docker.io nginx gnupg

    # enable yarn
    # https://docs.metahkg.org/docs/deploy/setup/requirements#debian-1
    sudo corepack enable

    # docker-compose
    # https://docs.metahkg.org/docs/deploy/setup/requirements#debian-2
    sudo curl -L "https://github.com/docker/compose/releases/download/$(curl --silent "https://api.github.com/repos/docker/compose/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose

    # mongosh and mongodb database tools
    # https://docs.metahkg.org/docs/deploy/setup/requirements#debian-4

    # import public key
    wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | sudo apt-key add -

    # add mongodb apt repository
    echo "deb http://repo.mongodb.org/apt/debian bullseye/mongodb-org/6.0 main" | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list

    # update packages list
    sudo apt-get update

    # install mongosh and mongodb database tools
    sudo apt-get install mongodb-org-shell mongodb-org-tools -y
}

install_dependencies_arch () {
    if [ "$(whoami)" = "root" ]; then
        pacman -Sy sudo;
    fi;
    sudo pacman -Sy --noconfirm ca-certificates git nodejs docker docker-compose nginx-mainline;

    # enable yarn
    # https://docs.metahkg.org/docs/deploy/setup/requirements#arch-1
    sudo corepack enable

    # install mongosh and mongodb database tools
    # https://docs.metahkg.org/docs/deploy/setup/requirements#arch-4

    local ORIG_DIR="$PWD"

    mkdir -p "$HOME"/Downloads
    cd "$HOME"/Downloads
    # go to downloads folder (or any other folders)

    git clone https://aur.archlinux.org/mongosh-bin.git
    git clone https://aur.archlinux.org/mongodb-tools-bin.git
    # clone the aur repositories

    cd "$HOME"/Downloads/mongosh-bin
    makepkg -si
    # install mongosh

    cd "$HOME"/Downloads/mongodb-tool-bin
    makepkg -si
    # install mongodb tools

    cd "$HOME"/Downloads/
    rm -rf mongodb-tools-bin mongosh-bin
    # remove the repositories after installation

    cd "$ORIG_DIR"
}

install_dependencies_redhat () {
    if [ "$(whoami)" = "root" ]; then
        dnf install sudo -y;
    fi;
    sudo dnf install ca-certificates curl git nodejs docker nginx -y;

    # enable yarn
    # https://docs.metahkg.org/docs/deploy/setup/requirements#rhel-1
    sudo corepack enable

    # docker-compose
    # https://docs.metahkg.org/docs/deploy/setup/requirements#rhel-2
    sudo curl -L "https://github.com/docker/compose/releases/download/$(curl --silent "https://api.github.com/repos/docker/compose/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose;
    sudo chmod +x /usr/local/bin/docker-compose;

    # install mongosh and mongodb database tools
    # https://docs.metahkg.org/docs/deploy/setup/requirements#rhel-4
    echo """[mongodb-org-6.0]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/${VER:0:1}/mongodb-org/6.0/x86_64/
gpgcheck=1
enabled=1
    gpgkey=https://www.mongodb.org/static/pgp/server-6.0.asc""" | sudo tee /etc/yum.repos.d/mongodb-org-6.0.repo;
    sudo dnf install mongodb-org-shell mongodb-org-tools -y;
}

install_dependencies_darwin() {
    # install homebrew
    # https://brew.sh/
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # add mongodb formula repository
    brew tap mongodb/brew

    brew update
    brew install nodejs yarn docker docker-compose nginx mongodb-database-tools mongodb-community-shell
}

check_arch () {
    ARCH=$(uname -m)

    if [ ""$ARCH"" != "x86_64" ] && [ ""$ARCH"" != "aarch64" ]; then
        echo "Error: Unsupported architecture "$ARCH""
        echo "Use --no-check-arch to bypass this check"
        exit 1
    fi;
}


check_os () {
    case ""$OSTYPE"" in
        "linux-gnu")
            # check the linux distribution and version
            # code from unix stack exchange user Mikel https://unix.stackexchange.com/users/3169/mikel
            # CC-BY-SA 3.0 <https://creativecommons.org/licenses/by-sa/3.0/>
            # https://unix.stackexchange.com/a/6348
            if [ -f /etc/os-release ]; then
                # freedesktop.org and systemd
                . /etc/os-release
                DISTRO="$NAME"
                VER="$VERSION_ID"
                elif type lsb_release >/dev/null 2>&1; then
                # linuxbase.org
                DISTRO=$(lsb_release -si)
                VER=$(lsb_release -sr)
            else
                echo "Error: Unsupported linux distribution or version too old";
                exit 1;
            fi;
            # check if this is a raspberry pi
            if [ "$DISTRO" = "Debian GNU/Linux" ] && [ -n "$(cat /proc/cpuinfo | grep 'Raspberry Pi')" ]; then
                DISTRO="Raspbian"
            fi;
            case "$DISTRO" in
                "Debian GNU/Linux")
                    OS="debian"
                ;;
                "Raspbian")
                    OS="debian"
                ;;
                "Ubuntu")
                    OS="debian"
                ;;
                "Arch Linux")
                    OS="arch"
                ;;
                "Rocky Linux")
                    OS="redhat"
                ;;
                "Red Hat Enterprise Linux"*)
                    OS="redhat"
                ;;
                *)
                    echo "Error: Unsupported linux distribution "$NAME"";
                    exit 1;
                ;;
            esac
        ;;
        "darwin")
            OS="darwin"
        ;;
        *)
            echo "Error: Unsupported OS "$OSTYPE""
            exit 1;
        ;;
    esac;
}

install_dependencies() {
    case ""$OS"" in
        "debian")
    esac
}

config_env() {
    # configuration
    if [ -f "docker/.env" ]; then
        source docker/.env;
        elif [ -f "docker/temp.env" ]; then
        source docker/temp.env
    else
        echo "docker/temp.env not found"
        echo "Are you in the right directory?"
        echo "Please rerun using:"
        echo "./setup.sh --skip-install"
        exit 1;
    fi;

    # if is a raspberry pi
    if [ "$DISTRO" = "Raspbian" ]; then
        MONGO_IMAGE="registry.gitlab.com/metahkg/bin/mongodb-arm64-bin:6.0"
    fi;

    input "Port for metahkg [${PORT}]: " "$PORT" PORT;

    echo ""
    echo "Mongdb options: these are used for configuring the mongodb container. Their's no need to deploy an external mongodb instance."
    input "Port for mongodb [${MONGO_PORT}]: " "$MONGO_PORT" MONGO_PORT;
    input "Mongodb username [${MONGO_USER}]: " "$MONGO_USER" MONGO_USER;
    input "Mongodb password [${MONGO_PASSWORD}]: " "$MONGO_PASSWORD" MONGO_PASSWORD;
    input "Mongodb image [${MONGO_IMAGE}]: " "$MONGO_IMAGE" MONGO_IMAGE;
    echo ""

    input "Do you want to use Mongo Express (a mongodb gui, https://github.com/mongo-express/mongo-express)? (y/n) [n]: " no MONGO_EXPRESS;
    if [ ""$MONGO_EXPRESS"" = "y" ]; then
        input "Port for mongo express [${MONGO_EXPRESS_PORT}]: " "$MONGO_EXPRESS_PORT" MONGO_EXPRESS_PORT;
        echo ""
    fi;

    echo "Redis options: these are used for configuring the redis container. Their's no need to deploy an external redis instance."
    input "Redis port [${REDIS_PORT}]: " "$REDIS_PORT" REDIS_PORT;
    input "Redis password [${REDIS_PASSWORD}]: " "$REDIS_PASSWORD" REDIS_PASSWORD;
    echo ""

    input "Domain for metahkg [${DOMAIN}]: " "$DOMAIN" DOMAIN;
    input "Domain for metahkg links (a link shortener for metahkg) [${LINKS_DOMAIN}]: " "$LINKS_DOMAIN" LINKS_DOMAIN;
    input "Domain for metahkg images (used for uploading and serving images, and as image proxy) [${IMAGES_DOMAIN}]: " "$IMAGES_DOMAIN" IMAGES_DOMAIN;
    input "Enable CORS for the main metahkg api server (true/false) [${CORS}]: " "$CORS" CORS;

    echo ""
    echo "Do you want to use mailgun or a custom smtp server to send emails?";
    echo "For mailgun you would need to obtain an api key at https://mailgun.com.";
    echo "For smtp you would need to obtain the credentials yourself.";
    echo "An example using gmail: https://forwardemail.net/en/guides/send-mail-as-gmail-custom-domain.";
    input "Your choice (mailgun/smtp) [mailgun]: " mailgun EMAIL_PROVIDER;

    case ""$EMAIL_PROVIDER"" in
        mailgun)
            input "Mailgun api key (obtain one at https://mailgun.com, or leave empty and set up SMTP) [${MAILGUN_KEY}]: " "$MAILGUN_KEY" MAILGUN_KEY;
            input "Mailgun domain [${MAILGUN_DOMAIN:-"$DOMAIN"}]: " ${MAILGUN_DOMAIN:-"$DOMAIN"} MAILGUN_DOMAIN;
        ;;
        smtp)
            input "SMTP host [${SMTP_HOST}]: " "$SMTP_HOST" SMTP_HOST;
            input "SMTP port [${SMTP_PORT}]: " "$SMTP_PORT" SMTP_PORT;
            input "Use SSL for SMTP connections (normally false) [${SMTP_SSL}]: " "$SMTP_SSL" SMTP_SSL;
            input "Enable starttls for SMTP connections (does not fail if tls is not available) [${SMTP_TLS}]: " "$SMTP_TLS" SMTP_TLS;
            if [ ""$SMTP_TLS"" = "true" ]; then
                input "Require starttls for SMTP connections (fails if tls is not available) [${SMTP_REQUIRE_TLS}]: " "$SMTP_REQUIRE_TLS" SMTP_REQUIRE_TLS;
            fi;
            input "SMTP username [${SMTP_USERNAME}]: " "$SMTP_USERNAME" SMTP_USERNAME;
            input "SMTP password [${SMTP_PASSWORD}]: " "$SMTP_PASSWORD" SMTP_PASSWORD;
            input "SMTP email (email address for sending emails) [${SMTP_EMAIL}]: " "$SMTP_EMAIL" SMTP_EMAIL;
        ;;
        *)
            echo "Invalid email provider "$EMAIL_PROVIDER"";
            exit 1;
        ;;
    esac
    echo ""

    input "Register mode (normal/none, see https://docs.metahkg.org/docs/customize/registermode/) [normal]: " "$REGISTER_MODE" REGISTER_MODE;
    input "Whitelisted email domains for registration (separated by a comma, no white space, leave empty for allow all domains) [${REGISTER_DOMAINS}]: " "$REGISTER_DOMAINS" REGISTER_DOMAINS;
    input "Visibility (public/internal) [${VISIBILITY}]: " "$VISIBILITY" VISIBILITY;

    echo ""
    echo "Recaptcha options: create a recaptcha site key and secret pair at https://www.google.com/recaptcha/admin"
    input "Recaptcha site key [${RECAPTCHA_SITE_KEY}]: " "$RECAPTCHA_SITE_KEY" RECCAPTCHA_SITE_KEY;
    input "Recaptcha secret [${RECAPTCHA_SECRET}]: " "$RECAPTCHA_SECRET" RECCAPTCHA_SECRET;
    echo ""

    echo "VAPID options: generate a VAPID key pair using web-push, see https://www.npmjs.com/package/web-push#command-line"
    input "VAPID public key [${VAPID_PUBLIC_KEY}]: " "$VAPID_PUBLIC_KEY" VAPID_PUBLIC_KEY;
    input "VAPID private key [${VAPID_PRIVATE_KEY}]: " "$VAPID_PRIVATE_KEY" VAPID_PRIVATE_KEY;
    echo ""

    echo "GCM options: see https://www.connecto.io/kb/knwbase/getting-gcm-sender-id-and-gcm-api-key/"
    input "GCM api key [${GCM_API_KEY}]: " "$GCM_API_KEY" GCM_API_KEY;
    input "GCM sender id [${GCM_SENDER_ID}]: " "$GCM_SENDER_ID" GCM_SENDER_ID;
    echo ""

    input "Passphrase for the (will-be-generated) private key (used for jwt signing) [${KEY_PASSPHRASE}]: " "$KEY_PASSPHRASE" KEY_PASSPHRASE;

    input "Do you want to use protonvpn for network requests in some of the services? (y/n) [n]: " no PROTONVPN;
    if [ ""$PROTONVPN"" = "y" ]; then
        echo "For protonvpn options, please see https://github.com/tprasadtp/protonvpn-docker for more information."
        input "Protonvpn username [${PROTONVPN_USERNAME}]: " "$PROTONVPN_USERNAME" PROTONVPN_USERNAME;
        input "Protonvpn password [${PROTONVPN_PASSWORD}]: " "$PROTONVPN_PASSWORD" PROTONVPN_PASSWORD;
        input "Protonvpn server [${PROTONVPN_SERVER}]: " "$PROTONVPN_SERVER" PROTONVPN_SERVER;
        input "Protonvpn tier [${PROTONVPN_TIER}]: " "$PROTONVPN_TIER" PROTONVPN_TIER;
    fi;
    echo ""

    input "Compose project name (skip normally) [${COMPOSE_PROJECT_NAME}]: " "$COMPOSE_PROJECT_NAME" COMPOSE_PROJECT_NAME;
    input "Environment (production/dev) (use production normally) (dev would enable hot reload, incompatible with prebuilt images) [${env}]: " "$env" env;
    input "Branch (master/dev) (use master normally) (things are more likely to break in the dev branch) [${branch}]: " "$branch" branch;
    input "Version (latest / any major or minor version that is available in all sub-repositories, e.g. 6) [${version}]: " "$version" version;

    echo ""
    if [ -f "docker/.env" ]; then
        echo "docker/.env exists"
        input "overwrite? (y/n) [n]: " n OVERWRITE;
        if [ ""$OVERWRITE"" = "y" ]; then
            DEST="docker/.env"
        else
            if [ -f "docker/.env.new" ]; then
                for i in {1..100}; do
                    if ! [ -f "docker/.env.new.${i}" ]; then
                        DEST="docker/.env.new.${i}"
                        break
                    fi;
                done;
            else
                DEST="docker/.env.new"
            fi;
        fi;
    else
        DEST="docker/.env"
    fi;

    echo """PORT=${PORT}
MONGO_PORT=${MONGO_PORT}
MONGO_USER=${MONGO_USER}
MONGO_PASSWORD=${MONGO_PASSWORD}
MONGO_IMAGE=${MONGO_IMAGE}
MONGO_EXPRESS_PORT=${MONGO_EXPRESS_PORT}
REDIS_PORT=${REDIS_PORT}
REDIS_PASSWORD=${REDIS_PASSWORD}
DOMAIN=${DOMAIN}
LINKS_DOMAIN=${LINKS_DOMAIN}
IMAGES_DOMAIN=${IMAGES_DOMAIN}
RLP_PROXY_DOMAIN=${RLP_PROXY_DOMAIN}
CORS=${CORS}
MAILGUN_KEY=${MAILGUN_KEY}
MAILGUN_DOMAIN=${MAILGUN_DOMAIN}
SMTP_HOST=${SMTP_HOST}
SMTP_PORT=${SMTP_PORT}
SMTP_SSL=${SMTP_SSL}
SMTP_TLS=${SMTP_TLS}
SMTP_REQUIRE_TLS=${SMTP_REQUIRE_TLS}
SMTP_USER=${SMTP_USER}
SMTP_PASSWORD=${SMTP_PASSWORD}
SMTP_EMAIL=${SMTP_EMAIL}
REGISTER_MODE=${REGISTER_MODE}
REGISTER_DOMAINS=${REGISTER_DOMAINS}
VISIBILITY=${VISIBILITY}
RECAPTCHA_SITE_KEY=${RECAPTCHA_SITE_KEY}
RECAPTCHA_SECRET=${RECAPTCHA_SECRET}
VAPID_PUBLIC_KEY=${VAPID_PUBLIC_KEY}
VAPID_PRIVATE_KEY=${VAPID_PRIVATE_KEY}
GCM_API_KEY=${GCM_API_KEY}
GCM_SENDER_ID=${GCM_SENDER_ID}
KEY_PASSPHRASE=${KEY_PASSPHRASE}
PROTONVPN_USERNAME=${PROTONVPN_USERNAME}
PROTONVPN_PASSWORD=${PROTONVPN_PASSWORD}
PROTONVPN_SERVER=${PROTONVPN_SERVER}
PROTONVPN_TIER=${PROTONVPN_TIER}
COMPOSE_PROJECT_NAME=${COMPOSE_PROJECT_NAME}
env=${env}
branch=${branch}
version=${version}
    """ > "$DEST"
}

# parse arguments
# https://stackoverflow.com/a/14203146
POSITIONAL_ARGS=()

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            echo "Metahkg setup script"
            echo "Usage:"
            echo "./setup.sh [--no-check-arch] [--no-check-os] [--skip-install]"
            echo "--no-check-arch: disable architecture checking"
            echo "--no-check-os: disable OS checking"
            echo "--skip-install: skip installation of dependencies"
            exit 0
        ;;
        "--skip-install"|"--config"|"-c")
            SKIP_INSTALL="1"
            shift
        ;;
        "--no-check-os")
            if [ ""$SKIP_INSTALL"" != "1" ]; then
                echo "--no-check-os must be used with --skip-install";
                exit 1;
            fi;
            NO_CHECK_OS="1"
            shift
        ;;
        "--no-check-arch")
            NO_CHECK_ARCH="1"
            shift
        ;;
        *)
            POSITIONAL_ARGS+=("$1") # save positional arg
            shift # past argument
        ;;
    esac
done

set -- "${POSITIONAL_ARGS[@]}" # restore positional parameters

if [ "$NO_CHECK_ARCH" != "1" ]; then
    check_arch;
fi;
if [ "$NO_CHECK_OS" != "1" ]; then
    check_os;
fi;
if [ "$SKIP_INSTALL" != "1" ]; then
    install_dependencies;
fi;

config_env;

input "Do you want to use prebuilt docker images (if not, you will build the images from source)? (y/n) [y]: " y PREBUILT;

echo ""
echo "Metahkg is now configured."
echo "You can now start metahkg by running:"
CMD="yarn docker"
if [ ""$PROTONVPN"" = "y" ]; then
    CMD+=":vpn"
fi;
if [ ""$MONGO_EXPRESS"" = "y" ]; then
    CMD+=":express"
fi;
if [ ""$PREBUILT"" = "y" ]; then
    CMD+=":prebuilt"
fi;
echo ""$CMD""
echo ""

echo "You can reconfigure using:";
echo "./setup.sh --config";
echo "If you encounter errors please report to our telegram group:";
echo "https://t.me/+WbB7PyRovUY1ZDFl";
