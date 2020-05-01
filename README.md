# proc [![Build Status](https://dev.azure.com/wikodes/wikodes/_apis/build/status/joakim-brannstrom.proc?branchName=master)](https://dev.azure.com/wikodes/wikodes/_build/latest?definitionId=10&branchName=master)

**proc** is a library to run single processes and manage trees of them. It
provides conveniences such as timeouts, output drains and sandboxing for single
processes. The process tree handling map up all running processes on the system
for convenient analyze such as killing a subtree.

# Getting Started

proc depends on the following software packages:

 * [D compiler](https://dlang.org/download.html) (dmd 2.079+, ldc 1.11.0+)

It is recommended to install the D compiler by downloading it from the official distribution page.
```sh
# link https://dlang.org/download.html
curl -fsS https://dlang.org/install.sh | bash -s dmd
```

Download the D compiler of your choice, extract it and add to your PATH shell
variable.
```sh
# example with an extracted DMD
export PATH=/path/to/dmd/linux/bin64/:$PATH
```

Once the dependencies are installed it is time to download the source code to install proc.
```sh
git clone https://github.com/joakim-brannstrom/proc.git
cd proc
dub build -b release
```

Done! Have fun.
Don't be shy to report any issue that you find.
