/**
Copyright: Copyright (c) 2020, Joakim Brännström. All rights reserved.
License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
Author: Joakim Brännström (joakim.brannstrom@gmx.com)
*/
module proc.tty;

import std.stdio : File;
static import std.process;

import proc;

/// Spawn a process where stdin/stdout/stderr is pseudo-terminals.
PipeProcess ttyProcess(scope const(char[])[] args, const string[string] env = null,
        std.process.Config config = std.process.Config.none, scope const(char)[] workDir = null) @trusted {
    import proc.libc;

    int master;
    int slave;
    auto res = openpty(&master, &slave, null, null, null);
    if (res != 0) {
        throw new Exception("failed to open a pseudo terminal");
    }

    File ioSlave;
    ioSlave.fdopen(slave, "rw");

    File ioMaster;
    ioMaster.fdopen(master, "rw");

    auto p = std.process.spawnProcess(args, ioSlave, ioSlave, ioSlave, env, config, workDir);

    return PipeProcess(p, ioMaster, ioMaster, ioMaster);
}

@("stdin, stdout and stderr shall be pseudo terminals")
unittest {
    import core.sys.posix.unistd;

    auto p = ttyProcess(["sleep", "1s"]);
    auto res = p.wait;
    assert(p.wait == 0);

    assert(isatty(p.stdin.file.fileno) == 1);
    assert(isatty(p.stdout.file.fileno) == 1);
    assert(isatty(p.stderr.file.fileno) == 1);
}

@("shall open the command read in a fake tty")
unittest {
    import std.stdio;

    auto p = ttyProcess(["/bin/bash", "-c", "read && echo $REPLY"]);
    p.stdin.write("foo\n");

    auto res = p.stdout.read(1024);
    assert(res.length >= 4);
    assert(res[0 .. 3] == cast(const(ubyte)[]) "foo");

    assert(p.wait == 0);
}

@("the execute command shall detect stdin as a fake tty")
unittest {
    auto p = ttyProcess([
            "/bin/bash", "-c", "if [ -t 0 ]; then exit 0; fi; exit 1"
            ]);
    auto res = p.wait;
    assert(p.wait == 0);
}

@("the execute command shall detect stdout as a fake tty")
unittest {
    auto p = ttyProcess([
            "/bin/bash", "-c", "if [ -t 1 ]; then exit 0; fi; exit 1"
            ]);
    auto res = p.wait;
    assert(p.wait == 0);
}

@("the execute command shall detect stderr as a fake tty")
unittest {
    auto p = ttyProcess([
            "/bin/bash", "-c", "if [ -t 2 ]; then exit 0; fi; exit 1"
            ]);
    auto res = p.wait;
    assert(p.wait == 0);
}
