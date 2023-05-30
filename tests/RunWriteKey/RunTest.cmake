include(RunMC-Toolkit)

set(test_db "${RunMC-Toolkit_BINARY_DIR}/TestWorld")

extract_world("${test_db}"
    "${RunMC-Toolkit_SOURCE_DIR}/../minecraftWorlds/TestWorld01.mcworld")

run_MC-Toolkit(Help help writekey)
run_MC-Toolkit(NoArgs writekey)
run_MC-Toolkit(OneArg writekey "${test_db}")

run_MC-Toolkit(TwoArgs writekey "${test_db}" "test_record")
run_MC-Toolkit(TwoArgsPostTest dumpkey "${test_db}" "test_record")

run_MC-Toolkit(BadCommand writekey noexist nokey)

run_MC-Toolkit(BigKey writekey "${test_db}" "test_record")

run_MC-Toolkit(BadKey writekey "${test_db}" "@")

file(REMOVE_RECURSE "${test_db}")
