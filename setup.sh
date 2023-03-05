#!/usr/bin/env bash

# supported architectures:
#   - amd64
#   - arm64
# supported distros / systems:
#   - debian / raspbian / ubuntu
#   - arch linux
#   - rocky linux / rhel
#   - macos (darwin)
# tested on debian and rocky linux docker images
# tested on an amd64 machine running arch linux
# macos is untested, use at your own risk

input () {
    # parse arguments
    # https://stackoverflow.com/a/14203146
    local POSITIONAL_ARGS=()

    while [[ $# -gt 0 ]]; do
        case $1 in
            -s|--secure)
                local SECURE="1"
                shift
            ;;
            -p|--prompt)
                local PROMPT="$2"
                shift
                shift
            ;;
            -d|--default)
                local DEFAULT="$2"
                shift
                shift
            ;;
            -o|--options)
                IFS=', ' read -r -a OPTIONS <<< "$2";
                shift
                shift
            ;;
            --allow-empty)
                local ALLOW_EMPTY="1"
                shift
            ;;
            --allow-other)
                local ALLOW_OTHER="1"
                shift
            ;;
            *)
                local POSITIONAL_ARGS+=("$1") # save positional arg
                shift # past argument
            ;;
        esac
    done

    set -- "${POSITIONAL_ARGS[@]}" # restore positional parameters

    local VAR=$1

    local CMD="read"

    if [ -n "${PROMPT}" ]; then
        if [ -n "${OPTIONS}" ]; then
          local OPTIONS_STR=""
          for i in "${OPTIONS[@]}"; do
            local OPTIONS_STR+="$i, "
          done;
          local OPTIONS_STR=${OPTIONS_STR::-2}
          local PROMPT+=" ($OPTIONS_STR)"
        fi;
        if [ -n "${DEFAULT}" ]; then
          local PROMPT+=" [${DEFAULT}]"
        fi;
        local PROMPT+=": "
        local CMD+=" -p \"${PROMPT}\" "
    fi;

    if [ "${SECURE}" = "1" ]; then
        local CMD+=" -s "
    fi;

    read_var() {
        eval "$CMD input";

        if [ "$SECURE" = "1" ]; then
            echo "";
        fi;

        if [ -z "$input" ]; then
            if [ -n "$DEFAULT" ]; then
                input="$DEFAULT";
            elif [ "${ALLOW_EMPTY}" != "1" ]; then
                echo "Empty is not allowed for variable $VAR";
                read_var;
            fi;
        fi;

        if [ -n "${OPTIONS}" ]; then
            if ! [ "$ALLOW_EMPTY" = "1" ] && [ -z "$input" ]; then
                while [[ ! " ${OPTIONS[*]} " =~ " ${input} " ]] && [ "${ALLOW_OTHER}" != "1" ]; do
                    echo "${input} is not a valid option"
                    read_var;
                done;
            fi;
        fi;
        eval "$VAR"="\"$input\""
    }

    read_var;
    unset OPTIONS
}

install_dependencies_debian() {
    echo "Installing dependencies using apt-get...";

    if [ "$(whoami)" = "root" ]; then
        apt-get update;
        apt-get install sudo -y;
    fi;

    sudo apt-get update;
    sudo apt-get install -y ca-certificates curl wget git docker.io nginx gnupg;

    echo "Installing node.js from nodesource..."
    # use the nodesource setup script (for nodejs)
    # https://docs.metahkg.org/docs/deploy/setup/requirements#debian-1
    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -;
    sudo apt-get update;
    sudo apt-get install -y nodejs;

    # enable yarn
    # https://docs.metahkg.org/docs/deploy/setup/requirements#debian-1
    sudo corepack enable

    echo "Installing docker-compose..."
    # docker-compose
    # https://docs.metahkg.org/docs/deploy/setup/requirements#debian-2
    sudo curl -L "https://github.com/docker/compose/releases/download/$(curl --silent "https://api.github.com/repos/docker/compose/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose

    # mongosh and mongodb database tools
    # https://docs.metahkg.org/docs/deploy/setup/requirements#debian-4

    echo "Installing mongosh and mongodb database tools..."
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
    echo "Installing dependencies using pacman...";

    if [ "$(whoami)" = "root" ]; then
        echo "You cannot run as root on arch linux."
        exit 1
    fi;
    sudo pacman -Sy --noconfirm ca-certificates git nodejs docker docker-compose nginx-mainline;

    # enable yarn
    # https://docs.metahkg.org/docs/deploy/setup/requirements#arch-1
    sudo corepack enable

    echo "Installing mongosh and mongodb database tools..."
    # install mongosh and mongodb database tools
    # https://docs.metahkg.org/docs/deploy/setup/requirements#arch-4

    local ORIG_DIR="$PWD"

    # installing mongosh and mongodb database tools
    cd /tmp
    # go to downloads folder (or any other folders)

    git clone https://aur.archlinux.org/mongosh-bin.git
    git clone https://aur.archlinux.org/mongodb-tools-bin.git
    # clone the aur repositories

    cd /tmp/mongosh-bin
    makepkg -si --noconfirm
    # install mongosh

    cd /tmp/mongodb-tools-bin
    makepkg -si --noconfirm
    # install mongodb tools

    cd /tmp
    rm -rf mongodb-tools-bin mongosh-bin
    # remove the repositories after installation

    cd "$ORIG_DIR"
}

install_dependencies_redhat () {
    echo "Installing dependencies using dnf...";

    if [ "$(whoami)" = "root" ]; then
        dnf install sudo -y;
    fi;
    sudo dnf install ca-certificates curl git nodejs docker nginx -y;

    # enable yarn
    # https://docs.metahkg.org/docs/deploy/setup/requirements#rhel-1
    sudo corepack enable

    echo "Installing docker-compose..."
    # docker-compose
    # https://docs.metahkg.org/docs/deploy/setup/requirements#rhel-2
    sudo curl -L "https://github.com/docker/compose/releases/download/$(curl --silent "https://api.github.com/repos/docker/compose/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose;
    sudo chmod +x /usr/local/bin/docker-compose;

    echo "Installing mongosh and mongodb database tools..."
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
    echo "installing homebrew...";

    # install homebrew
    # https://brew.sh/
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    echo "installing dependencies using homebrew...";

    # add mongodb formula repository
    brew tap mongodb/brew

    brew update
    brew install nodejs yarn docker docker-compose nginx mongodb-database-tools mongodb-community-shell
}

check_arch () {
    ARCH=$(uname -m)

    case $ARCH in
        'x86_64'|'amd64')
            ARCH='amd64'
        ;;
        'aarch64'|'arm64')
            ARCH='arm64'
        ;;
        *)
            echo "Error: Unsupported architecture $ARCH"
            echo "Use --no-check-arch to bypass this check"
            exit 1
        ;;
    esac

    echo "Detected architecture: $ARCH"
}


check_os () {
    case "$OSTYPE" in
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
            if [ "$DISTRO" = "Debian GNU/Linux" ] && grep -q 'Raspberry Pi' < /proc/cpuinfo; then
                DISTRO="Raspbian"
            fi;
            case "$DISTRO" in
                "Debian GNU/Linux"|"Raspbian"|"Ubuntu")
                    OS="debian"
                ;;
                "Arch Linux")
                    OS="arch"
                ;;
                "Rocky Linux"|"Red Hat Enterprise Linux"*)
                    OS="redhat"
                ;;
                *)
                    echo "Error: Unsupported linux distribution $NAME";
                    echo "Use --no-check-os --skip-install to bypass check"
                    exit 1;
                ;;
            esac
            echo "Detected linux distribution: $DISTRO"
        ;;
        "darwin"*)
            OS="darwin"
            echo "Detected OS: darwin"
        ;;
        *)
            echo "Error: Unsupported OS $OSTYPE"
            echo "Use --no-check-os --skip-install to bypass check"
            exit 1;
        ;;
    esac;
}

install_dependencies() {
    case "$OS" in
        "debian")
            install_dependencies_debian;
        ;;
        "arch")
            install_dependencies_arch;
        ;;
        "redhat")
            install_dependencies_redhat;
        ;;
        "darwin")
            install_dependencies_darwin;
        ;;
    esac
}

config_env() {
    # configuration
    if [ -f "docker/example.env" ]; then
        source docker/example.env
    else
        echo "docker/example.env not found"
        echo "Are you in the right directory?"
        echo "Please rerun using:"
        echo "./setup.sh --config"
        exit 1;
    fi;
    if [ -f "docker/.env" ]; then
        source docker/.env;
    fi;

    # if is a raspberry pi
    if [ "$DISTRO" = "Raspbian" ]; then
        MONGO_IMAGE="registry.gitlab.com/metahkg/bin/mongodb-arm64-bin:6.0"
    fi;

    input -p "Port for metahkg" -d "$PORT" PORT;

    echo ""
    echo "Mongdb options: these are used for configuring the mongodb container. Their's no need to deploy an external mongodb instance."
    input -p "Port for mongodb" -d "$MONGO_PORT" MONGO_PORT;
    input -p "Mongodb username" -d "$MONGO_USER" MONGO_USER;
    input -p "Mongodb password" -d "$MONGO_PASSWORD" MONGO_PASSWORD;
    input --allow-empty --allow-other -o "mongo:6.0, registry.gitlab.com/metahkg/bin/mongodb-arm64-bin:6.0" -p "Mongodb image" -d "$MONGO_IMAGE" MONGO_IMAGE;
    echo ""

    input -p "Do you want to use Mongo Express (a mongodb gui, https://github.com/mongo-express/mongo-express)?" -o "y, n" -d "n" MONGO_EXPRESS;
    if [ "$MONGO_EXPRESS" = "y" ]; then
        input -p "Port for mongo express" -d "$MONGO_EXPRESS_PORT" MONGO_EXPRESS_PORT;
    fi;

    echo ""
    echo "Redis options: these are used for configuring the redis container. Their's no need to deploy an external redis instance."
    input -p "Redis port" -d "$REDIS_PORT" REDIS_PORT;
    input -p "Redis password" -d "$REDIS_PASSWORD" REDIS_PASSWORD;
    echo ""

    input -p "Domain for metahkg" -d "$DOMAIN" DOMAIN;
    input -p "Domain for metahkg links (a link shortener for metahkg)" -d "$LINKS_DOMAIN" LINKS_DOMAIN;
    input -p "Domain for metahkg images (used for uploading and serving images, and as image proxy)" -d "$IMAGES_DOMAIN" IMAGES_DOMAIN;
    input -p "Domain for rlp proxy (used for getting url metadata)" -d "$RLP_PROXY_DOMAIN" RLP_PROXY_DOMAIN;
    input -p "Domain for metahkg redirect (used for scanning URLs, and redirect)" -d "$REDIRECT_DOMAIN" REDIRECT_DOMAIN;

    echo ""
    input -p "Enable CORS for the main metahkg api server" -o "true, false" -d "$CORS" CORS;

    echo ""
    echo "Do you want to use mailgun or a custom smtp server to send emails?";
    echo "For mailgun you would need to obtain an api key at https://mailgun.com.";
    echo "For smtp you would need to obtain the credentials yourself.";
    echo "An example using gmail: https://forwardemail.net/en/guides/send-mail-as-gmail-custom-domain.";
    input -p "Your choice" -o "mailgun, smtp" -d mailgun EMAIL_PROVIDER;

    case "$EMAIL_PROVIDER" in
        mailgun)
            input -p "Mailgun api key (obtain one at https://mailgun.com)" -d "$MAILGUN_KEY" MAILGUN_KEY;
            input -p "Mailgun domain" -d "${MAILGUN_DOMAIN:-$DOMAIN}" MAILGUN_DOMAIN;
        ;;
        smtp)
            input -p "SMTP host" -d "$SMTP_HOST" SMTP_HOST;
            input -p "SMTP port" -d "$SMTP_PORT" SMTP_PORT;
            input -p "Use SSL for SMTP connections (normally false)" -o "true, false" -d "$SMTP_SSL" SMTP_SSL;
            input --allow-empty -p "Enable starttls for SMTP connections (does not fail if tls is not available)" -o "true, false" -d "$SMTP_TLS" SMTP_TLS;
            if [ "$SMTP_TLS" = "true" ]; then
                input --allow-empty -p "Require starttls for SMTP connections (fails if tls is not available)" -o "true, false" -d "$SMTP_REQUIRE_TLS" SMTP_REQUIRE_TLS;
            fi;
            input -p "SMTP username" -d "$SMTP_USERNAME" SMTP_USERNAME;
            input -p "SMTP password" -d "$SMTP_PASSWORD" SMTP_PASSWORD;
            input -p "SMTP email (email address for sending emails)" -d "$SMTP_EMAIL" SMTP_EMAIL;
        ;;
    esac
    echo ""

    input -p "Register mode (see https://docs.metahkg.org/docs/customize/registermode/)" -o "normal, none" -d "$REGISTER_MODE" REGISTER_MODE;
    input --allow-empty -p "Whitelisted email domains for registration (separated by a comma, no white space, leave empty for allow all domains)" -d "$REGISTER_DOMAINS" REGISTER_DOMAINS;
    input -p "Visibility" -o "public, internal" -d "$VISIBILITY" VISIBILITY;

    echo ""
    echo "Recaptcha options: create a recaptcha site key and secret pair at https://www.google.com/recaptcha/admin"
    input -p "Recaptcha site key" -d "$RECAPTCHA_SITE_KEY" RECAPTCHA_SITE_KEY;
    input -p "Recaptcha secret" -d "$RECAPTCHA_SECRET" RECAPTCHA_SECRET;

    echo ""
    echo "VAPID options: generate a VAPID key pair using web-push, see https://www.npmjs.com/package/web-push#command-line"
    input -p "VAPID public key" -d "$VAPID_PUBLIC_KEY" VAPID_PUBLIC_KEY;
    input -p "VAPID private key" -d "$VAPID_PRIVATE_KEY" VAPID_PRIVATE_KEY;

    echo ""
    echo "GCM options: see https://www.connecto.io/kb/knwbase/getting-gcm-sender-id-and-gcm-api-key/"
    input -p "GCM api key" -d "$GCM_API_KEY" GCM_API_KEY;
    input -p "GCM sender id" -d "$GCM_SENDER_ID" GCM_SENDER_ID;

    echo ""
    echo "Google safebrowsing: see https://developers.google.com/safe-browsing/v4/get-started"
    echo "Get an api key at https://console.cloud.google.com/apis/api/safebrowsing.googleapis.com/credentials"
    input -p "Google safebrowsing api key" -d "$SAFEBROWSING_API_KEY" SAFEBROWSING_API_KEY;

    echo ""
    input -p "Passphrase for the (will-be-generated) private key (used for jwt signing)" -d "$KEY_PASSPHRASE" KEY_PASSPHRASE;

    input -p "Do you want to use protonvpn for network requests in some of the services?" -o "y, n" -d n PROTONVPN;
    if [ "$PROTONVPN" = "y" ]; then
        echo ""
        echo "For protonvpn options, please see https://github.com/tprasadtp/protonvpn-docker for more information."
        input -p "Protonvpn username (NOT your account username)" -d "$PROTONVPN_USERNAME" PROTONVPN_USERNAME;
        input -p "Protonvpn password (NOT your account password)" -d "$PROTONVPN_PASSWORD" PROTONVPN_PASSWORD;
        input --allow-other -p "Protonvpn server" -o "JP, NL, US, RANDOM, P2P" -d "$PROTONVPN_SERVER" PROTONVPN_SERVER;
        input -p "Protonvpn tier" -o "0, 1, 2, 3" -d "$PROTONVPN_TIER" PROTONVPN_TIER;
    fi;

    echo ""

    echo "Memory / swap limit options: these are used for all containers.";
    echo "For example, if you set memory limit to be 500mb, then each container could use at maximum 500mB of memory";
    echo "If you are in a dev environment, you may want to set a higher memory limit, ~2gb is recommended.";
    echo "Otherwise, ~500mb is recommended.";
    input --allow-other -p "Memory limit (for each container)" -o "250mb, 500mb, 1gb, 2gb, 4gb, 8gb" -d "$MEM_LIMIT" MEM_LIMIT;
    input --allow-other -p "Swap limit (for each container)" -o "250mb, 500mb, 1gb, 2gb, 4gb, 8gb" -d "$MEMSWAP_LIMIT" MEMSWAP_LIMIT;

    echo ""

    input -p "Compose project name (skip normally)" -d "$COMPOSE_PROJECT_NAME" COMPOSE_PROJECT_NAME;
    input -p "Environment (choose production normally, choosing dev would enable hot reload, but incompatible with prebuilt images)" -o "production, dev" -d "$env" env;
    input -p "Branch (use master normally)" -o "master, dev" -d "$branch" branch;
    input --allow-other -p "Version (latest / any major or minor version that is available in all sub-repositories)" -o "latest, 6, 5" -d "$version" version;

    echo ""
    if [ -f "docker/.env" ]; then
        echo "docker/.env exists"
        input -p "overwrite?" -o "y, n" -d n OVERWRITE;
        if [ "$OVERWRITE" = "y" ]; then
            local DEST="docker/.env"
        else
            if [ -f "docker/.env.new" ]; then
                local i=1
                while [ -f "docker/.env.new.${i}" ]; do
                    ((i++))
                done;
                local DEST="docker/.env.new.${i}"
            else
                local DEST="docker/.env.new"
            fi;
        fi;
    else
        local DEST="docker/.env"
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
REDIRECT_DOMAIN=${REDIRECT_DOMAIN}
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
SAFEBROWSING_API_KEY=${SAFEBROWSING_API_KEY}
KEY_PASSPHRASE=${KEY_PASSPHRASE}
PROTONVPN_USERNAME=${PROTONVPN_USERNAME}
PROTONVPN_PASSWORD=${PROTONVPN_PASSWORD}
PROTONVPN_SERVER=${PROTONVPN_SERVER}
PROTONVPN_TIER=${PROTONVPN_TIER}
MEM_LIMIT=${MEM_LIMIT}
MEMSWAP_LIMIT=${MEMSWAP_LIMIT}
COMPOSE_PROJECT_NAME=${COMPOSE_PROJECT_NAME}
env=${env}
branch=${branch}
version=${version}
""" > "$DEST"

    echo "New configuration file written to $DEST";
    if [ "$DEST" != "docker/.env" ]; then
        echo "You will have to merge docker/.env and $DEST"
        echo "Or you can replace docker/.env with $DEST, using:"
        echo "cp $DEST docker/.env"
    fi;
}

# parse arguments
# https://stackoverflow.com/a/14203146
POSITIONAL_ARGS=()

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            echo "Metahkg setup script"
            echo "Usage:"
            echo "./setup.sh [--no-check-arch] [--no-check-os] [--skip-install|--config|-c]"
            echo "--no-check-arch: disable architecture checking"
            echo "--no-check-os: disable OS checking"
            echo "--skip-install|--config|-c: skip installation of dependencies (directy jump to configure)"
            exit 0
        ;;
        "--skip-install"|"--config"|"-c")
            SKIP_INSTALL="1"
            shift
        ;;
        "--no-check-os")
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
    if [ "$NO_CHECK_OS" = "1" ] && [ "$SKIP_INSTALL" != "1" ]; then
        echo "--no-check-os must be used with [--skip-install|--config|-c]";
        exit 1;
    fi;
done

set -- "${POSITIONAL_ARGS[@]}" # restore positional parameters

if [ "$NO_CHECK_ARCH" != "1" ]; then
    check_arch;
fi;
if [ "$NO_CHECK_OS" != "1" ]; then
    check_os;
    echo ""
fi;
if [ "$SKIP_INSTALL" != "1" ]; then
    install_dependencies;
    echo ""
fi;

config_env;

mkdir -p docker/certs docker/images docker/imageproxy docker/imgpush
if ! [ -f "docker/version.txt" ]; then touch docker/version.txt; fi;

input -p "Do you want to use prebuilt docker images (if not, you will build the images from source)?" -o "y, n" -d y PREBUILT;

echo ""
echo "Metahkg is now configured."
echo "You can start metahkg by running:"
CMD="yarn docker"
if [ "$PROTONVPN" = "y" ]; then
    CMD+=":vpn"
fi;
if [ "$MONGO_EXPRESS" = "y" ]; then
    CMD+=":express"
fi;
if [ "$PREBUILT" = "y" ]; then
    CMD+=":prebuilt"
fi;
echo "$CMD"
echo "Then, you can access metahkg at http://localhost:${PORT}"
echo ""

echo "To complete the installation, further steps are required."
echo "See https://docs.metahkg.org/docs/category/configure-nginx"
echo ""

echo "You can reconfigure using:";
echo "./setup.sh --config";

echo "If you encounter errors please report to our telegram group:";
echo "https://t.me/+WbB7PyRovUY1ZDFl";
