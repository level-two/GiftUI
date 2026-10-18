# Closed parser-only fixture inventory

888 inherited cases retain all fields and oracles unchanged.
New cases are fully materialized in new-cases.json; all are unexecuted.

| ID | Oracle | Mutation |
| --- | --- | --- |
| ARM-A4-P01 | accept | Exact archived ARMv6 A4 output; trusted precompile identities are fixture inputs, not a compiler result. |
| ARM-A4-P02 | accept | Exact absence of declaration excerpt and gutter retains primary-only dependency evidence. |
| ARM-A4-N001 | reject | Missing ARMv6 opt-in cannot borrow macOS permission. |
| ARM-A4-N002 | reject | Missing compiler precompile identity rejects even exact text. |
| ARM-A4-N003 | reject | Missing trusted input rejects. |
| ARM-A4-N004 | reject | Missing context rejects. |
| ARM-A4-N005 | reject | Wrong context profile macos-static |
| ARM-A4-N006 | reject | Wrong context profile macos-dynamic |
| ARM-A4-N007 | reject | Wrong context profile nrf52840-embedded |
| ARM-A4-N008 | reject | Wrong context profile raspberry-pi-armv7 |
| ARM-A4-N009 | reject | Wrong context module AnalyzerPresentation |
| ARM-A4-N010 | reject | Wrong context module GiftUI |
| ARM-A4-N011 | reject | Wrong context stage client-emit-object |
| ARM-A4-N012 | reject | Wrong context stage AnalyzerSchema |
| ARM-A4-N013 | reject | Delete complete control field category |
| ARM-A4-N014 | reject | Delete complete control field dependency_note_sources |
| ARM-A4-N015 | reject | Delete complete control field diagnostic_rules |
| ARM-A4-N016 | reject | Delete complete control field diagnostic_source |
| ARM-A4-N017 | reject | Delete complete control field expected_nonzero |
| ARM-A4-N018 | reject | Delete complete control field files |
| ARM-A4-N019 | reject | Delete complete control field first_expected_stage |
| ARM-A4-N020 | reject | Delete complete control field id |
| ARM-A4-N021 | reject | Delete complete control field inherit |
| ARM-A4-N022 | reject | Delete complete control field kind |
| ARM-A4-N023 | reject | Delete complete control field later_stages |
| ARM-A4-N024 | reject | Delete complete control field primary_message_patterns_all |
| ARM-A4-N025 | reject | Delete complete control field remove_only |
| ARM-A4-N026 | reject | Delete complete control field required_symbol |
| ARM-A4-N027 | reject | Delete complete control field armv6_a4_display_only_note |
| ARM-A4-N028 | reject | Wrong complete control field id |
| ARM-A4-N029 | reject | Wrong complete control field kind |
| ARM-A4-N030 | reject | Wrong complete control field category |
| ARM-A4-N031 | reject | Wrong complete control field remove_only |
| ARM-A4-N032 | reject | Wrong complete control field required_symbol |
| ARM-A4-N033 | reject | Wrong complete control field first_expected_stage |
| ARM-A4-N034 | reject | Wrong complete control field expected_nonzero |
| ARM-A4-N035 | reject | Unknown complete control field |
| ARM-A4-N036 | reject | Wrong ARMv6 opt-in field policy_id |
| ARM-A4-N037 | reject | Wrong ARMv6 opt-in field source_path |
| ARM-A4-N038 | reject | Wrong ARMv6 opt-in field input_sha256 |
| ARM-A4-N039 | reject | Noncanonical exit True |
| ARM-A4-N040 | reject | Noncanonical exit 0 |
| ARM-A4-N041 | reject | Noncanonical exit 2 |
| ARM-A4-N042 | reject | Noncanonical exit -1 |
| ARM-A4-N043 | reject | Noncanonical exit '1' |
| ARM-A4-N044 | reject | Delete trusted precompile field campaign_root |
| ARM-A4-N045 | reject | Delete trusted precompile field compiler |
| ARM-A4-N046 | reject | Delete trusted precompile field target |
| ARM-A4-N047 | reject | Delete trusted precompile field sdk |
| ARM-A4-N048 | reject | Delete trusted precompile field planned_stage |
| ARM-A4-N049 | reject | Delete trusted precompile field source_inputs |
| ARM-A4-N050 | reject | Wrong compiler path |
| ARM-A4-N051 | reject | Wrong compiler sha256 |
| ARM-A4-N052 | reject | Wrong SDK path |
| ARM-A4-N053 | reject | Wrong SDK archive_sha256 |
| ARM-A4-N054 | reject | Wrong SDK toolchain_pin_path |
| ARM-A4-N055 | reject | Wrong SDK toolchain_pin_sha256 |
| ARM-A4-N056 | reject | Wrong trusted target armv7 |
| ARM-A4-N057 | reject | Wrong trusted campaign root |
| ARM-A4-N058 | reject | Unknown precompile field |
| ARM-A4-N059 | reject | Wrong planned stage name |
| ARM-A4-N060 | reject | Wrong planned stage environment_overrides |
| ARM-A4-N061 | reject | Changed planned argv operand 0 /Users/eugene/work/GiftUI/.toolchains/host/swift-6.4.0-RELEASE-osx/usr/bin/swiftc |
| ARM-A4-N062 | reject | Changed planned argv operand 1 -swift-version |
| ARM-A4-N063 | reject | Changed planned argv operand 2 6 |
| ARM-A4-N064 | reject | Changed planned argv operand 3 -Osize |
| ARM-A4-N065 | reject | Changed planned argv operand 4 -whole-module-optimization |
| ARM-A4-N066 | reject | Changed planned argv operand 5 -enable-experimental-feature |
| ARM-A4-N067 | reject | Changed planned argv operand 6 LifetimeDependence |
| ARM-A4-N068 | reject | Changed planned argv operand 7 -enable-experimental-feature |
| ARM-A4-N069 | reject | Changed planned argv operand 8 Lifetimes |
| ARM-A4-N070 | reject | Changed planned argv operand 9 -package-name |
| ARM-A4-N071 | reject | Changed planned argv operand 10 giftui |
| ARM-A4-N072 | reject | Changed planned argv operand 11 -module-cache-path |
| ARM-A4-N073 | reject | Changed planned argv operand 12 /Users/eugene/work/GiftUI/.build/raspberry-pi/contracts/p08-analyzer-abi-continuation-campaign9/raspberry-pi-armv6/scratch/negative-A4/cache |
| ARM-A4-N074 | reject | Changed planned argv operand 13 -disable-sandbox |
| ARM-A4-N075 | reject | Changed planned argv operand 14 -target |
| ARM-A4-N076 | reject | Changed planned argv operand 15 armv6-unknown-linux-gnueabihf |
| ARM-A4-N077 | reject | Changed planned argv operand 16 -sdk |
| ARM-A4-N078 | reject | Changed planned argv operand 17 /Users/eugene/work/GiftUI/.toolchains/sdk/swift-6.4.0-RELEASE-raspios-bookworm-armv6/raspios-bookworm |
| ARM-A4-N079 | reject | Changed planned argv operand 18 -resource-dir |
| ARM-A4-N080 | reject | Changed planned argv operand 19 /Users/eugene/work/GiftUI/.toolchains/sdk/swift-6.4.0-RELEASE-raspios-bookworm-armv6/raspios-bookworm/usr/lib/swift_static |
| ARM-A4-N081 | reject | Changed planned argv operand 20 -use-ld=lld |
| ARM-A4-N082 | reject | Changed planned argv operand 21 -Xcc |
| ARM-A4-N083 | reject | Changed planned argv operand 22 --gcc-toolchain=/Users/eugene/work/GiftUI/.toolchains/sdk/swift-6.4.0-RELEASE-raspios-bookworm-armv6/raspios-bookworm/usr |
| ARM-A4-N084 | reject | Changed planned argv operand 23 -Xcc |
| ARM-A4-N085 | reject | Changed planned argv operand 24 -march=armv6 |
| ARM-A4-N086 | reject | Changed planned argv operand 25 -Xcc |
| ARM-A4-N087 | reject | Changed planned argv operand 26 -mfloat-abi=hard |
| ARM-A4-N088 | reject | Changed planned argv operand 27 -Xcc |
| ARM-A4-N089 | reject | Changed planned argv operand 28 -mfpu=vfp |
| ARM-A4-N090 | reject | Changed planned argv operand 29 -load-plugin-executable |
| ARM-A4-N091 | reject | Changed planned argv operand 30 /Users/eugene/work/GiftUI/.build/rfc014-p02-swift64/tool/debug/GiftUIMacros-tool#GiftUIMacros |
| ARM-A4-N092 | reject | Changed planned argv operand 31 -I |
| ARM-A4-N093 | reject | Changed planned argv operand 32 /Users/eugene/work/GiftUI/.build/raspberry-pi/contracts/p08-analyzer-abi-continuation-campaign9/raspberry-pi-armv6/scratch/negative-A4 |
| ARM-A4-N094 | reject | Changed planned argv operand 33 -I |
| ARM-A4-N095 | reject | Changed planned argv operand 34 /Users/eugene/work/GiftUI/.build/raspberry-pi/contracts/spec-006-rfc-014-swift64/f5043b879e490dab-k9hbqn_m/raspberry-pi-armv6 |
| ARM-A4-N096 | reject | Changed planned argv operand 35 -parse-as-library |
| ARM-A4-N097 | reject | Changed planned argv operand 36 -module-name |
| ARM-A4-N098 | reject | Changed planned argv operand 37 SignalAnalyzerDomain |
| ARM-A4-N099 | reject | Changed planned argv operand 38 -emit-module |
| ARM-A4-N100 | reject | Changed planned argv operand 39 -emit-object |
| ARM-A4-N101 | reject | Changed planned argv operand 40 /Users/eugene/work/GiftUI/.build/raspberry-pi/contracts/p08-analyzer-abi-continuation-campaign9/raspberry-pi-armv6/scratch/negative-A4/inputs/SignalPrimitiveValues.swift |
| ARM-A4-N102 | reject | Changed planned argv operand 41 /Users/eugene/work/GiftUI/.build/raspberry-pi/contracts/p08-analyzer-abi-continuation-campaign9/raspberry-pi-armv6/scratch/negative-A4/inputs/AcquisitionState.swift |
| ARM-A4-N103 | reject | Changed planned argv operand 42 /Users/eugene/work/GiftUI/.build/raspberry-pi/contracts/p08-analyzer-abi-continuation-campaign9/raspberry-pi-armv6/scratch/negative-A4/inputs/SignalAnalyzerDiagnostic.swift |
| ARM-A4-N104 | reject | Changed planned argv operand 43 -emit-module-path |
| ARM-A4-N105 | reject | Changed planned argv operand 44 /Users/eugene/work/GiftUI/.build/raspberry-pi/contracts/p08-analyzer-abi-continuation-campaign9/raspberry-pi-armv6/scratch/negative-A4/SignalAnalyzerDomain.swiftmodule |
| ARM-A4-N106 | reject | Changed planned argv operand 45 -o |
| ARM-A4-N107 | reject | Changed planned argv operand 46 /Users/eugene/work/GiftUI/.build/raspberry-pi/contracts/p08-analyzer-abi-continuation-campaign9/raspberry-pi-armv6/scratch/negative-A4/SignalAnalyzerDomain.o |
| ARM-A4-N108 | reject | Missing trusted source /Users/eugene/work/GiftUI/.build/raspberry-pi/contracts/p08-analyzer-abi-continuation-campaign9/raspberry-pi-armv6/scratch/negative-A4/inputs/SignalPrimitiveValues.swift |
| ARM-A4-N109 | reject | Wrong trusted source bytes /Users/eugene/work/GiftUI/.build/raspberry-pi/contracts/p08-analyzer-abi-continuation-campaign9/raspberry-pi-armv6/scratch/negative-A4/inputs/SignalPrimitiveValues.swift |
| ARM-A4-N110 | reject | Wrong trusted source sha256 /Users/eugene/work/GiftUI/.build/raspberry-pi/contracts/p08-analyzer-abi-continuation-campaign9/raspberry-pi-armv6/scratch/negative-A4/inputs/SignalPrimitiveValues.swift |
| ARM-A4-N111 | reject | Missing trusted source /Users/eugene/work/GiftUI/.build/raspberry-pi/contracts/p08-analyzer-abi-continuation-campaign9/raspberry-pi-armv6/scratch/negative-A4/inputs/AcquisitionState.swift |
| ARM-A4-N112 | reject | Wrong trusted source bytes /Users/eugene/work/GiftUI/.build/raspberry-pi/contracts/p08-analyzer-abi-continuation-campaign9/raspberry-pi-armv6/scratch/negative-A4/inputs/AcquisitionState.swift |
| ARM-A4-N113 | reject | Wrong trusted source sha256 /Users/eugene/work/GiftUI/.build/raspberry-pi/contracts/p08-analyzer-abi-continuation-campaign9/raspberry-pi-armv6/scratch/negative-A4/inputs/AcquisitionState.swift |
| ARM-A4-N114 | reject | Missing trusted source /Users/eugene/work/GiftUI/.build/raspberry-pi/contracts/p08-analyzer-abi-continuation-campaign9/raspberry-pi-armv6/scratch/negative-A4/inputs/SignalAnalyzerDiagnostic.swift |
| ARM-A4-N115 | reject | Wrong trusted source bytes /Users/eugene/work/GiftUI/.build/raspberry-pi/contracts/p08-analyzer-abi-continuation-campaign9/raspberry-pi-armv6/scratch/negative-A4/inputs/SignalAnalyzerDiagnostic.swift |
| ARM-A4-N116 | reject | Wrong trusted source sha256 /Users/eugene/work/GiftUI/.build/raspberry-pi/contracts/p08-analyzer-abi-continuation-campaign9/raspberry-pi-armv6/scratch/negative-A4/inputs/SignalAnalyzerDiagnostic.swift |
| ARM-A4-N117 | reject | Different primary/trusted path coherently selects foreign root |
| ARM-A4-N118 | reject | Noncanonical root dotdot |
| ARM-A4-N119 | reject | Different declared dependency file |
| ARM-A4-N120 | reject | Trusted input path differs |
| ARM-A4-N121 | reject | Trusted input bytes differ |
| ARM-A4-N122 | reject | Trusted input is text |
| ARM-A4-N123 | reject | Input with edited declaration row |
| ARM-A4-N124 | reject | Diagnostic mutation primary line |
| ARM-A4-N125 | reject | Diagnostic mutation primary column |
| ARM-A4-N126 | reject | Diagnostic mutation primary path |
| ARM-A4-N127 | reject | Diagnostic mutation primary message |
| ARM-A4-N128 | reject | Diagnostic mutation declaration line |
| ARM-A4-N129 | reject | Diagnostic mutation declaration symbol |
| ARM-A4-N130 | reject | Diagnostic mutation excerpt spacing |
| ARM-A4-N131 | reject | Diagnostic mutation gutter spacing |
| ARM-A4-N132 | reject | Diagnostic mutation gutter marker |
| ARM-A4-N133 | reject | Diagnostic mutation gutter message |
| ARM-A4-N134 | reject | Diagnostic mutation use evidence |
| ARM-A4-N135 | reject | Diagnostic mutation adjacency |
| ARM-A4-N136 | reject | Extra stderr diagnostic 'warning: unexpected\n' |
| ARM-A4-N137 | reject | Extra stderr diagnostic 'note: extra\n' |
| ARM-A4-N138 | reject | Extra stderr diagnostic 'remark: extra\n' |
| ARM-A4-N139 | reject | Extra stderr diagnostic 'error: unrelated\n' |
| ARM-A4-N140 | reject | Extra stderr diagnostic 'Stack dump:\n' |
| ARM-A4-N141 | reject | Extra stderr diagnostic 'Please submit a bug report\n' |
| ARM-A4-N142 | reject | Extra stderr diagnostic 'LLVM ERROR: fatal\n' |
| ARM-A4-N143 | reject | Extra stderr diagnostic ' 1 \| package struct SignalChannelID: Hashable, Sendable {\n   \|                `- note: type declared here\n' |
| ARM-A4-N144 | reject | Extra stderr diagnostic '/Users/eugene/work/GiftUI/.build/raspberry-pi/contracts/p08-analyzer-abi-continuation-campaign9/raspberry-pi-armv6/scratch/negative-A4/inputs/SignalPrimitiveValues.swift:1:1: note: type declared here\n' |
| ARM-A4-N145 | reject | Move stderr into stdout |
| ARM-A4-N146 | reject | Cross stream gutter |
| ARM-A4-N147 | reject | Gutter without primary |
| ARM-A4-N148 | reject | Declaration excerpt alone is not note absence form |
| ARM-A4-N149 | reject | Gutter alone without excerpt |
| ARM-A4-N150 | reject | Note absence with wrong target evidence |
| ARM-A4-N151 | reject | No opt-in and no trusted context fails exact ARM gutter |
| ARM-A4-N152 | reject | MacOS A4 opt-in cannot accept ARM form |
| ARM-A4-N153 | reject | ARM opt-in cross application to macos-static-A7-opt-in-control.json |
| ARM-A4-N154 | reject | ARM opt-in cross application to macos-static-A8-opt-in-control.json |
| ARM-A4-N155 | reject | ARM opt-in cross application to storage-opt-in-control.json |
| ARM-A4-N156 | reject | ARM opt-in cross application to count-opt-in-control.json |
| ARM-A4-N157 | reject | ARM opt-in cross application to continuation-opt-in-control.json |
| ARM-A4-N158 | reject | ARM opt-in cross application to leading-opt-in-control.json |
| ARM-A4-N159 | reject | ARM opt-in wrong control negative-A1 |
| ARM-A4-N160 | reject | ARM opt-in wrong control negative-A2 |
| ARM-A4-N161 | reject | ARM opt-in wrong control negative-A3 |
| ARM-A4-N162 | reject | ARM opt-in wrong control negative-A5 |
| ARM-A4-N163 | reject | ARM opt-in wrong control negative-A6 |
| ARM-A4-N164 | reject | ARM opt-in wrong control private-storage |
| ARM-A4-N165 | reject | ARM opt-in wrong control private-count |
| ARM-A4-N166 | reject | ARM opt-in wrong control private-helper-continuation |
| ARM-A4-N167 | reject | ARM opt-in wrong control private-helper-leading |
