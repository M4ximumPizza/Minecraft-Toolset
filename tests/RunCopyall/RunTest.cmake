include(RunMC-Toolkit)

run_MC-Toolkit(Help help copyall)

run_MC-Toolkit(NoArgs copyall)
run_MC-Toolkit(OneArg copyall noexist)

run_MC-Toolkit(BadCommand1 copyall noexist noexist)

set(test_db "${RunMC-Toolkit_BINARY_DIR}/TestWorld")
set(copy_db "${RunMC-Toolkit_BINARY_DIR}/CopyWorld")

extract_world("${test_db}"
    "${RunMC-Toolkit_SOURCE_DIR}/../minecraftWorlds/TestWorld01.mcworld")

run_MC-Toolkit(BadCommand2 copyall "${test_db}" noexist)

file(MAKE_DIRECTORY "${copy_db}/db") 

run_MC-Toolkit(TwoArgs copyall "${test_db}" "${copy_db}")
run_MC-Toolkit(TwoArgsPostTest listkeys "${copy_db}")


file(REMOVE_RECURSE "${test_db}" "${copy_db}")
