#!/usr/bin/env bash
set -e

# --<====================================================>--
#    THE FIRST COMMAND_LINE OPTION IS NEOVIM's SOURCE DIR
# --<====================================================>--

SOURCE_DIR=${1:-./}

BUILDER_TMP_DIR=~/.nvim_builder_tmp

OUT_DIR="/opt/neovim"

putlog () {
    echo " -<[ INFO ]>- : ${@}"
}

die () {
    echo " -<[ ERROR ]>- : ${@}" 1>&2
    exit 1
}

BUILD_DATE=`date +'%F'`

[[ -d "${OUT_DIR}" ]] || sudo mkdir -p "${OUT_DIR}"

if [[ -d "${OUT_DIR}/neovim_${BUILD_DATE}" ]]; then
    for ((i=1;;i++)); do
        if [[ ! -d "${OUT_DIR}/neovim_${BUILD_DATE}_${i}" ]]; then
            DIST_DIR="${OUT_DIR}/neovim_${BUILD_DATE}_${i}"
            break
        fi
    done
else
    DIST_DIR="${OUT_DIR}/neovim_${BUILD_DATE}"
fi


#    ----< MAIN PROCESS >----


[[ -d "${BUILDER_TMP_DIR}" ]] && rm -rf ${BUILDER_TMP_DIR}
cp -r ${SOURCE_DIR} ${BUILDER_TMP_DIR}

#[[ -d "${SOURCE_DIR}/.git" ]] || \
#    die "Git repository was not found in ${SOURCE_DIR}."

cd ${BUILDER_TMP_DIR}

#git pull
#putlog "Pulled the git repository."

make -j5 CMAKE_INSTALL_PREFIX=${DIST_DIR}
putlog "Build new NeoVim done."

sudo make install
putlog "Installing NeoVim to ${DIST_DIR} done."

sudo update-alternatives --display neovim || \
    sudo update-alternatives --install /usr/local/bin/nvim neovim /usr/bin/nvim 99


sudo update-alternatives --install /usr/local/bin/nvim neovim ${DIST_DIR}/bin/nvim 101
putlog "Older nvim link was switched to new one."

rm -rf ${BUILDER_TMP_DIR}
