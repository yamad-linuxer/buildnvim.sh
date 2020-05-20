#!/usr/bin/env bash
set -e

# --<====================================================>--
#    THE FIRST COMMAND_LINE OPTION IS NEOVIM's SOURCE DIR
# --<====================================================>--

SOURCE_DIR=${1:-./}

BUILD_TMP_DIR=~/.nvim_builder_tmp

BUILD_DATE=`date +'%F'`

OUT_DIR="/opt/neovim/${BUILD_DATE}"

[[ -d /opt/neovim ]] || sudo mkdir -p /opt/neovim

if [[ -d "${OUT_DIR}" ]]; then
    for ((i=1;;i++)); do
        if [[ ! -d "${OUT_DIR}_${i}" ]]; then
            OUT_DIR="${OUT_DIR}_${i}"
            break
        fi
    done
fi

putlog () {
    echo " -<[ INFO ]>- : ${@}"
}

die () {
    echo " -<[ ERROR ]>- : ${@}" 1>&2
    exit 1
}


#    ----< MAIN PROCESS >----


[[ -d "${BUILD_TMP_DIR}" ]] && rm ${BUILD_TMP_DIR}
cp -r ${SOURCE_DIR} ${BUILD_TMP_DIR}

[[ -d "${SOURCE_DIR}/.git" ]] || \
    die "Git repository was not found in ${SOURCE_DIR}."

git pull
putlog "Pulled the git repository."

make -j5 CMAKE_INSTALL_PREFIX=${OUT_DIR}
putlog "Build new NeoVim done."

sudo make install
putlog "Installing NeoVim to ${OUT_DIR} done."

sudo update-alternatives --install /usr/local/bin/nvim neovim ${OUT_DIR}/bin/nvim 101
sudo update-alternatives --display neovim
putlog "Older nvim link was switched to new one."

