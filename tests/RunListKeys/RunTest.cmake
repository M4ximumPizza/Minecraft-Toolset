include(RunMC-Toolkit)

set(test_db "${RunMC-Toolkit_BINARY_DIR}/TestWorld")

extract_world("${test_db}"
    "${RunMC-Toolkit_SOURCE_DIR}/../minecraftWorlds/TestWorld01.mcworld")

run_MC-Toolkit(NoArgs listkeys)
run_MC-Toolkit(OneArg listkeys "${test_db}")

run_MC-Toolkit(BadCommand listkeys noexist)

run_MC-Toolkit(Help help listkeys)

file(REMOVE_RECURSE "${test_db}")
