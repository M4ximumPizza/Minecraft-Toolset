cmake_policy(SET CMP0007 NEW)

include(RunMC-Toolkit)

run_MC-Toolkit(Help help rmkeys)
run_MC-Toolkit(NoArgs rmkeys)

set(test_db "${RunMC-Toolkit_BINARY_DIR}/TestWorld")

extract_world("${test_db}"
    "${RunMC-Toolkit_SOURCE_DIR}/../minecraftWorlds/TestWorld01.mcworld")

run_MC-Toolkit(OneArg rmkeys "${test_db}")
run_MC-Toolkit(OneArgPostTest listkeys "${test_db}")

run_MC-Toolkit(MultiArgs rmkeys "${test_db}"
    "@5:0:0:54" "@5:0:0:118" "AutonomousEntities" "@5:0:0:47-5")
run_MC-Toolkit(MultiArgsPostTest listkeys "${test_db}")

run_MC-Toolkit(BadCommand rmkeys noexist)

run_MC-Toolkit(PercentDecode rmkeys "${test_db}"
    "Test%09%AF%af" "Test%!0" "Test%0~" "Test%" "Test%F"
)

run_MC-Toolkit(BadKeys rmkeys "${test_db}"
    ""
    "@" "@0" "@0:" "@0:0" "@0:0:" "@0:0:0" "@0:0:0:" "@0:0:0:0-"
    "@a" "@0a" "@0:a" "@0:0a" "@0:0:a" "@0:0:0a" "@0:0:0:a" "@0:0:0:0a" "@0:0:0:0-a" "@0:0:0:0-0a"
)

file(REMOVE_RECURSE "${test_db}")
