include(RunMC-Toolkit)

run_MC-Toolkit(Help help repair)

run_MC-Toolkit(NoArgs repair)
run_MC-Toolkit(BadCommand repair noexist)

set(test_db "${RunMC-Toolkit_BINARY_DIR}/TestWorld")

extract_world("${test_db}"
    "${RunMC-Toolkit_SOURCE_DIR}/../minecraftWorlds/TestWorld01.mcworld")

run_MC-Toolkit(OneArg repair "${test_db}")

file(REMOVE_RECURSE "${test_db}")
