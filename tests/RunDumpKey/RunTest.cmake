include(RunMC-Toolkit)

set(test_db "${RunMC-Toolkit_BINARY_DIR}/TestWorld")

extract_world("${test_db}"
    "${RunMC-Toolkit_SOURCE_DIR}/../minecraftWorlds/TestWorld01.mcworld")

run_MC-Toolkit(Help help dumpkey)
run_MC-Toolkit(NoArgs dumpkey)
run_MC-Toolkit(OneArg dumpkey "${test_db}")

run_MC-Toolkit(TwoArgs dumpkey "${test_db}" "HelloWorld")

run_MC-Toolkit(BadCommand dumpkey noexist nokey)

run_MC-Toolkit(UnknownKey dumpkey "${test_db}" "%40missing")

run_MC-Toolkit(BadKey dumpkey "${test_db}" "@")

file(REMOVE_RECURSE "${test_db}")
