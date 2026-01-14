#include <iostream>

#include "config.hpp"
#include "hc.hpp"

#include "CLI11.hpp"
#include "json.hpp"

using Cfg       = HengCore::Config::Config;
using Excutable = HengCore::Excutable;
using json      = nlohmann::json;

int main(int argc, char *argv[])
{
    Cfg arg{};
    CLI::App app{"Heng-Core arguments parsing"};
    app.add_option("-t,--tl", arg.timeLimit, "time limit");
    app.add_option("-m,--ml", arg.memLimit, "memory limit");
    app.add_option("-u,--uid", arg.uid, "uid");
    app.add_option("-g,--gid", arg.gid, "gid");
    app.add_option("-p,--pidl", arg.maxPid, "max pid");
    app.add_option("--cpu", arg.maxCpu, "max cpu");
    app.add_option("-i,--stdin", arg.stdinPath, "stdin path");
    app.add_option("-o,--stdout", arg.stdoutPath, "stdout path");
    app.add_option("-e,--stderr", arg.stderrPath, "stderr path");
    app.add_option("-f", arg.outFd, "output fd");
    app.add_option("-c,--cwd", arg.cwd, "cwd");
    app.add_option("-a,--args", arg.outFd, "output fd");
    app.add_option("--bin", arg.bin, "executable")->required();

    CLI11_PARSE(app, argc, argv);
    
    // initialize excuter
    Excutable excutable(arg);

    // check if run under root permission
    if(getuid() || getgid())
    {

#ifdef DEBUG
        std::cerr
          << "I need root permission to operate cgroup!"
          << std::endl;
#endif
        return -1;
    }

#ifdef DEBUG
    std::cout << nlohmann::json(arg).dump(4) << std::endl;
#endif

    if(excutable.exec())
    {
        if(arg.outFd != -1)
        {
            std::string result =
              json(excutable.getResult()).dump();
            // dup2(arg.outFd, fileno(stdout));
            if(write(arg.outFd,
                     result.c_str(),
                     result.size())
               != ssize_t(result.size()))
            {
                return 1;
            }
        }
        else
        {
            std::string result =
              json(excutable.getResult()).dump(4);
            std::cout << result << std::endl;
        }
    }
    else
    {
        return -1;
    }
    return 0;
}
