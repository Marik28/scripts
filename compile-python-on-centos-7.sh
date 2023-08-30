# скрипт нужно запускать под sudo
default_python_version=3.8.16
curdir=$(pwd)

abort () {
  echo "aborted!"
  cd "$curdir" || exit 1
  exit 1
}

set -x
cd /tmp || abort

if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
  echo "Usage: $(basename "$0") [PYTHON_VERSION]"
  echo "Installs all required packages and compiles python of version PYTHON_VERSION from source. Script should be executed by root user"
  echo "  PYTHON_VERSION: version of python to compile default $default_python_version"
  exit 0
fi

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  abort
fi

python_version="${1:-$default_python_version}"
# версия устанавливаемого python'а без номера патча
python_minor_version=$(echo python_version | grep -Po "^(\d+\.\d+)")
configure_params=()

old_versions=("3.6" "3.7")
[[ ! " ${old_versions[*]} " =~ " ${python_minor_version} " ]]
# 0 = true, 1 = false
use_openssl11=$?

# если версия новее, чем 3.7, то нужно
# собирать python с openssl v1.1
if [[ "$use_openssl11" == 0 ]]; then
  mkdir /usr/local/openssl11
  yum install -y openssl11 openssl11-devel
  ln -s /usr/lib64/openssl11 /usr/local/openssl11/lib
  ln -s /usr/include/openssl11 /usr/local/openssl11/include
  configure_params+=(--with-openssl=/usr/include/openssl11)
fi
#  https://stackoverflow.com/a/70468010/17684642
yum -y install epel-release
yum -y update
yum -y groupinstall "Development Tools"
# вместо groupinstall "Development Tools" можно поставить следующие пакеты
# yum install bison byacc cscope ctags cvs diffstat doxygen flex gcc gcc-c++ gcc-gfortran gettext git indent intltool libtool patch patchutils rcs redhat-rpm-config rpm-build subversion swig systemtap
yum -y install wget openssl-devel bzip2-devel libffi-devel xz-devel libsqlite3x-devel libuuid-devel ncurses-devel readline-devel
gcc --version
python_dir="Python-$python_version"
wget https://www.python.org/ftp/python/"$python_version"/"$python_dir".tgz
tar xvf "$python_dir".tgz
cd "$python_dir" || (echo "$python_dir does not exist, exiting" && abort)
# флаг --enable-optimizations может все разъебать, возможно лучше без него собирать питон
./configure "${configure_params[@]}"
make
make altinstall
echo "Installed python version=$python_version"

# executable скомпилированного python-а по дефолту кладется в /usr/local/bin
if [[ ":$PATH:" == *":/usr/local/bin:"* ]]; then
  echo "/usr/local/bin is already in PATH"
else
  sh -c 'echo "export PATH=/usr/local/bin:\$PATH" >> /etc/bashrc'
  source /etc/bashrc
  echo "added /usr/local/bin to PATH"
fi

# вот так типа нехорошо делать, но нужно, чтобы глобально все было новенькое
echo "it is recommended to upgrade pip and install necessary pip with following commands:"
echo "  python$python_minor_version -m pip install -U pip setuptools"
echo "  python$python_minor_version -m pip install wheel certifi"

cd "$curdir" || exit 1