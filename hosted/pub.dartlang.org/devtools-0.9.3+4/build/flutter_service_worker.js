'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';
const RESOURCES = {
  "version.json": "f08fd841370fd2bec0a20516b6f4c645",
"index.html": "0e550ff2e596200a166a73158ecf89b3",
"/": "0e550ff2e596200a166a73158ecf89b3",
"main_fallback.dart.js": "0a78cce87038c33f716aa64ca30a5f90",
"main.dart.js": "4c4ec88fa4693b93f4bbbb9fdfb4ec6f",
"index_fallback.html": "ba64d915f0597dc5ec3b029cff7b8c48",
"favicon.png": "ae21624ef35db645fca3c2553421f5fe",
"devtools_analytics.js": "359a205ca5d2479246eee912f44fd3e8",
"manifest.json": "9f2208d3303a34594e332da25d9132e6",
"widgets.json": "7b27a7c156926ac66079458141b9feb8",
"assets/web/widgets.json": "7b27a7c156926ac66079458141b9feb8",
"assets/AssetManifest.json": "2e496470020e3a19c727b4855d9234ae",
"assets/NOTICES": "20efe44041563c6680404a77e1c92d29",
"assets/FontManifest.json": "dafd4a77703ac1663c4df22cfd50c1dd",
"assets/icons/observatory@2x.png": "4f5435d75c69e7b35fd30f642b28c0cd",
"assets/icons/bazel_run@2x.png": "b1a914fbcf48bc4e0d3b35d95e3ee287",
"assets/icons/repaint_rainbow.png": "787f7eb253fa516714c162ab7411315e",
"assets/icons/hot-restart@2x.png": "0850aa256e3d864f4d6aa23cf68e699a",
"assets/icons/timeline@2x.png": "044a8a35dbaa6f3fb4ef5cd64756b1b3",
"assets/icons/flutter_inspect.png": "c7d021902cdd8baf8ff0581b05300bbc",
"assets/icons/attachDebugger@2x.png": "c6b48f1a6edf49d444fad893653cde62",
"assets/icons/flutter_64@2x.png": "31ba1c09cfd2c66879e6d7fe8468205c",
"assets/icons/flutter_test.png": "ed5edbeba30a69da4d1081614b9522e3",
"assets/icons/refresh@2x.png": "9968994854dd82f2a1d413fb2ed9cebb",
"assets/icons/flutter_badge.png": "75ed887d7b88287f7432e38117f0e8da",
"assets/icons/hot-restart-white.png": "cc04e9b639bb44cd128d6d313c39283d",
"assets/icons/debug_paint@2x.png": "c1821eb82fbe418ac8751473c992b6c4",
"assets/icons/memory/reset_icon_white@2x.png": "ff2bc17f854e39568538947dd92f09eb",
"assets/icons/memory/ic_filter_list_alt_black@2x.png": "6296e29222f3d96189d7b2fa85185018",
"assets/icons/memory/communities_white@2x.png": "5a42b14876c4a4837a54f1a2687aa9e7",
"assets/icons/memory/reset_icon.png": "e84251117741b2d12b9f36d78c502530",
"assets/icons/memory/settings.png": "fce912c8fc95518cb2a01a2666699778",
"assets/icons/memory/alloc_icon.png": "ff8d2823bc6a4e0a5daba30232ed579b",
"assets/icons/memory/communities_white.png": "d43934ea633338b8c74c4cbb06a5c213",
"assets/icons/memory/ic_delete_outline_black@2x.png": "6effb40113caac0436161aa3f76c56b4",
"assets/icons/memory/alloc_icon@2x.png": "c9953a1256a8a80a26591957857072f5",
"assets/icons/memory/ic_filter_list_alt_black.png": "2428e54d768c84a4762a3157bdd4ec79",
"assets/icons/memory/reset_icon@2x.png": "4ef35d010c7da152c6d2625a979f153b",
"assets/icons/memory/ic_filter_alt_black_1x_web_24dp@2x.png": "2428e54d768c84a4762a3157bdd4ec79",
"assets/icons/memory/ic_search.png": "3ae481e0963d84dc500e5bc2a16dad44",
"assets/icons/memory/ic_search@2x.png": "b2b093a97825a446b1d839056894940a",
"assets/icons/memory/reset_icon@2x.psd": "35963a722a2dd63015b8d2e1060a14bf",
"assets/icons/memory/ic_delete_outline_black.png": "6effb40113caac0436161aa3f76c56b4",
"assets/icons/memory/settings@2x.png": "dbc084367cf000c11f6e99d0567fde9c",
"assets/icons/memory/snapshot_color.png": "8df3b10be937a176c92525b45d43a75c",
"assets/icons/memory/snapshot_color@2x.png": "67f45bfd98d5e507ffc9765f1cc8786b",
"assets/icons/flutter_badge@2x.png": "704de34ee538acf8a33affd40413ce95",
"assets/icons/reload_debug.png": "25174df7af338a404352a6c3ef3db4a9",
"assets/icons/flutter_inspect@2x.png": "82e208f934ddf23a55aeead145b0a664",
"assets/icons/flutter.png": "6a8302a74f9a3ed272937486f921026e",
"assets/icons/gutter/colors.png": "51d32728d990baf55d1c8603118d6262",
"assets/icons/gutter/colors@2x.png": "776e366471592ddb63fe5fc594a39e5c",
"assets/icons/inspector/formattedTextField.png": "e801db1e0d9a7eab6916399620a84fe8",
"assets/icons/inspector/balloonInformation@2x.png": "ad007ba7f02b955016c507c9d64cdc9f",
"assets/icons/inspector/class.png": "b51c515d49600ad24ad45076275c31e8",
"assets/icons/inspector/colors.png": "51d32728d990baf55d1c8603118d6262",
"assets/icons/inspector/class@2x.png": "5ceef3bbe50abd73121b1357e6b27260",
"assets/icons/inspector/expand_property.png": "b3d7c4bd44289f0968c38ec89cdd79be",
"assets/icons/inspector/diagram@2x.png": "ad3ea98cb1bd5027fc0156b250fc00f6",
"assets/icons/inspector/renderer.png": "abba70711218f98be1cbd80463e00915",
"assets/icons/inspector/value@2x.png": "7bc864d1ec9dd967e79ddd7355e2b177",
"assets/icons/inspector/threads.png": "a140b95dd7103f1a923591bbd93edfc4",
"assets/icons/inspector/atrule.png": "221cb98d10e94d2b44c775f36224e12d",
"assets/icons/inspector/threads@2x.png": "19276711cd1286b34012108ed641d05e",
"assets/icons/inspector/formattedTextField@2x.png": "dd93276cf8763dcdcfe4145b61b9d077",
"assets/icons/inspector/extAnnotation@2x.png": "341f7f0934f50f8c643f8d328dc3d606",
"assets/icons/inspector/collapse_property@2x.png": "471a3b684c8d048fc407a8a83ecdd0f2",
"assets/icons/inspector/value.png": "add6641dc0440d02088a040125cf1c20",
"assets/icons/inspector/resume.png": "7580821b2fc68f2b4e3a04b9040e7886",
"assets/icons/inspector/textArea@2x.png": "f73ed1021eb2ce3d258d0396f2ffd562",
"assets/icons/inspector/extAnnotation.png": "2d3e029256b29d1e02634593e7283f4f",
"assets/icons/inspector/any_type@2x.png": "95983aecd59c10ca5fdc827fe1b79182",
"assets/icons/inspector/any_type.png": "e5fc0b367cff9a3aaac7c497042d5819",
"assets/icons/inspector/expand_property@2x.png": "a363d20c39ebb501b89e09ed0c3935e8",
"assets/icons/inspector/atrule@2x.png": "e518c17f245dcbc5806e1afd4e5c2971",
"assets/icons/inspector/resume@2x.png": "af62d4f95654101ecd37f1cba0faf088",
"assets/icons/inspector/textArea.png": "ec26da4275a1dbb50c42336bcc8040e3",
"assets/icons/inspector/collapse_property.png": "63ec0cf8f0873997e73f881bf1eee51b",
"assets/icons/inspector/balloonInformation.png": "66959b2a139e824df331bee8dfa4f0d8",
"assets/icons/inspector/renderer@2x.png": "072d5476b18f1cc51bff0ee9aff27914",
"assets/icons/inspector/colors@2x.png": "2bcef4f4f40029c74db9eb6f40fcc7c1",
"assets/icons/inspector/diagram.png": "ace353bcabbdfadf7f45368f5c096451",
"assets/icons/inspector/scrollbar.png": "513d5066fcb77212849b599b0d30967a",
"assets/icons/inspector/scrollbar@2x.png": "a95734ab0f8e6f93583f297c729dbc1b",
"assets/icons/general/locateHover_dark.png": "1062dff85c14cce54ca5e04d179353e4",
"assets/icons/general/pause_black.png": "0c80e28a9604e6b7fe53759b4e6886b5",
"assets/icons/general/locateHover@2x.png": "eb111d907e1c3e49883ceab21f8620ac",
"assets/icons/general/resume_white_disabled@2x.png": "8a893125faabed96b2ebd2ef8f63ddfa",
"assets/icons/general/locate@2x_dark.png": "d8512f13a8e8d439c7e9ca9dcdbff992",
"assets/icons/general/pause_black@2x.png": "c3788f4e7b793732e98766dad7a06d7c",
"assets/icons/general/locate@2x.png": "f740c86f8c9a6c1764248cfdafe146eb",
"assets/icons/general/pause_black_disabled@2x.png": "f381ea1d29ca222692a5ebffba2b10e5",
"assets/icons/general/locate_dark.png": "9b366b605ba591cc0b497ead678d6650",
"assets/icons/general/resume_white@2x.png": "b7a04fbc72a61cd185608888c70329aa",
"assets/icons/general/resume_white.png": "521c2e6a11fc72fba4a4d13dca59a53b",
"assets/icons/general/resume_black_disabled.png": "4a546a3295607f2d83deca6a2a099764",
"assets/icons/general/pause_white_disabled.png": "42b4bf47a5f685db593a40506eaecd8d",
"assets/icons/general/information.png": "65c12280149d93f4d67499d492c4b783",
"assets/icons/general/performance_overlay@2x.png": "41eafe0c92f5b36f8a44e4e859bed25c",
"assets/icons/general/pause_white.png": "86031638d9669173bf9735145a5841d3",
"assets/icons/general/lightbulb_outline.png": "bbcdd7fc5d7b8a3fa3c97dd46b451aa5",
"assets/icons/general/pause_white_disabled@2x.png": "8bd2e45cfb1a88e9893635c46c036e2e",
"assets/icons/general/tbShown.svg": "3780e46534a05a9f16c5d5887314b96a",
"assets/icons/general/performance_overlay.png": "41eafe0c92f5b36f8a44e4e859bed25c",
"assets/icons/general/locateHover@2x_dark.png": "5322b4d44ea4ee02aa445fb022539c2a",
"assets/icons/general/pause_white@2x.png": "954808b748c00535beff9177f2ac21cb",
"assets/icons/general/lightbulb_outline@2x.png": "3a999b7b3d5432c691a5e200dc86232b",
"assets/icons/general/locate.png": "895b8ec8017234555f34b03bdb597caa",
"assets/icons/general/pause_black_disabled.png": "7dbdece627bd96762137b5e12d3b23c8",
"assets/icons/general/resume_white_disabled.png": "1af530bdb784ec4ee96f27ebf9e8136d",
"assets/icons/general/resume_black_disabled@2x.png": "a04748510be66d9fd21422d40643c231",
"assets/icons/general/tbShown_dark.svg": "71f94e65889d8befa7f9600f1793ddfd",
"assets/icons/general/locateHover.png": "266be4b27119d9b6a195729b6c60df11",
"assets/icons/general/resume_black.png": "343a442a2d48725d6d263e510a9485d4",
"assets/icons/general/resume_black@2x.png": "15b596a73d9362f2e84cfbac6581b0c9",
"assets/icons/flutter_test@2x.png": "2395ee067da4de674745d943a9d204c8",
"assets/icons/template_new_package.png": "0557aa1c93139137ad85f22fe2758a2a",
"assets/icons/attachDebugger.png": "05ddbfda18764ac8ffca47adc532adcd",
"assets/icons/flutter_13@2x.png": "f2e619b6ca36e53951d6be3b850e60fc",
"assets/icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"assets/icons/cancel.png": "8bb2114c6c2203f0cbd4aa45a62672dc",
"assets/icons/debug_banner.png": "f0669ee6cfba83e137744025addd2e3b",
"assets/icons/template_new_plugin.png": "a94257e34875df546fb19e089ce721b1",
"assets/icons/hot-reload-white.png": "6dc8bdd405672a75d0f925cb72465932",
"assets/icons/debug_banner@2x.png": "f0669ee6cfba83e137744025addd2e3b",
"assets/icons/reload_both@2x.png": "9efaa38f3578de57e3f98b6dcd22bdc6",
"assets/icons/restart.png": "bd34e2904e6c0c911f4bb6d5add9b527",
"assets/icons/cancel@2x.png": "c509b4ad1eebf5ef952a56c2e1abdb12",
"assets/icons/hot-reload-white@2x.png": "4a05189ee22691ea8af86173b520455d",
"assets/icons/hot-reload@2x.png": "994ce33f77d7673e0c2b6f40013a4510",
"assets/icons/restart@2x.png": "b30dd7498339df8975ef657e73fac8d3",
"assets/icons/hot-restart-white@2x.png": "5407e1c2596f79a5fbe373bffe01939b",
"assets/icons/phone@2x.png": "19a0c9d18f17958c7cd847915936642b",
"assets/icons/bazel_run.png": "f6c7f8d3c28f847b72f427dd309073d9",
"assets/icons/widget_tree@2x.png": "fb22bd86feb953f625467bfbc2003c6e",
"assets/icons/history.png": "4e0f5a3963b2a5cc899d7e58f58ff042",
"assets/icons/repaint_rainbow@2x.png": "787f7eb253fa516714c162ab7411315e",
"assets/icons/hot-reload.png": "865893b75879a84123cc535af4f8122c",
"assets/icons/timeline.png": "dda9878e3cb617682b9c782cb6509daf",
"assets/icons/observatory_overflow@2x.png": "cb6ded75e5a9993305da466c5e19c41e",
"assets/icons/template_new_module.png": "cf79c79f983e0237d72d41f597e7b5b8",
"assets/icons/actions/forceRefresh_dark.svg": "788520d88103c871f95bfe8e65980564",
"assets/icons/actions/forceRefresh@2x.png": "8a3f17c81bc6719dca319d40e5041274",
"assets/icons/actions/forceRefresh.png": "8a3f17c81bc6719dca319d40e5041274",
"assets/icons/observatory.png": "5cba4b21e3c417a1bf6fdbe66dd1cae6",
"assets/icons/flutter_64.png": "7e24794e1094e8066c054c9d11827c92",
"assets/icons/phone.png": "17bdad06461783db7a974058095c209e",
"assets/icons/observatory_overflow.png": "94a85472af26fe159772b52fbd232b71",
"assets/icons/memory_dashboard.png": "0a2bfd9286470d3edc303dc1f5955088",
"assets/icons/reload_debug@2x.png": "ce6dd61540892dd86d472f874c98b3e2",
"assets/icons/reload_both.png": "128be73080038135fb7dc407a46b66a0",
"assets/icons/reload_run@2x.png": "c94136df1be445e7eb295856a84e5232",
"assets/icons/memory_dashboard@2x.png": "42f218904aab471bd8410b7c840cc3bd",
"assets/icons/widget_tree.png": "431c30792f362b13784385e8c986e780",
"assets/icons/widget_tree@4x.png": "24d21973e29cc4649920c4ca5ea73ef1",
"assets/icons/custom/info.png": "0c1e06b8e610f660af6db7ace50cabb9",
"assets/icons/custom/class.png": "23d2ddc0e92945b9201420a79afe6cec",
"assets/icons/custom/class@2x.png": "5dff2762ee809fdbbafcccd4df4f6288",
"assets/icons/custom/fields.png": "a7dfff5ff17cbc115deb88a79684902b",
"assets/icons/custom/method_abstract@2x.png": "6a31c47219fcef0e31494ad343ed232c",
"assets/icons/custom/class_abstract.png": "2c6175cb1fe9e9717058188e3df36068",
"assets/icons/custom/interface@2x.png": "9e8421464905cc8237d9ed5269e4b21d",
"assets/icons/custom/interface.png": "c6fb38ed3bde0d617bc417276c033951",
"assets/icons/custom/property@2x.png": "5804ab4f3a03d069e56dc95876698012",
"assets/icons/custom/fields@2x.png": "f544485148bd04876a929add391389e6",
"assets/icons/custom/method.png": "17e80716a27ddd219532a76d290cdbef",
"assets/icons/custom/info@2x.png": "a481c659091c88aaa30a2397018e02dc",
"assets/icons/custom/property.png": "1f9efc724a939974822b09c5bac85d0e",
"assets/icons/custom/method@2x.png": "032597397a9d05feda57ddb97a36b461",
"assets/icons/custom/method_abstract.png": "1bfdaa72952b1b751980d551d28249cd",
"assets/icons/custom/class_abstract@2x.png": "cda5f695060c2ab440ac67d445a06edb",
"assets/icons/reload_run.png": "da0fcd427f812db380a1125949635bc7",
"assets/icons/perf/YellowProgr_7.png": "783a4d5b40c05df47dd0c474bb56ca2c",
"assets/icons/perf/RedProgr_5@2x.png": "113589bc7e627485bf2f9d2d3a45e5f0",
"assets/icons/perf/YellowProgr_6.png": "ec2c01a57f8509c2780989c5c9115509",
"assets/icons/perf/YellowProgr_4.png": "6bde8eef6a9edecaad4138c8c397f5a7",
"assets/icons/perf/GreenOK@2x.png": "5bf559e3f9fa7ded272a64d43c63cb7a",
"assets/icons/perf/GreyProgr_6@2x.png": "925d9c779906838fd779af8571ab9ff1",
"assets/icons/perf/YellowStr@2x_dark.png": "de510f09b0fff82ef614d7b8420aa1e2",
"assets/icons/perf/YellowProgr_3@2x.png": "b7c27a3108a8b59ef5e60ceb8c797600",
"assets/icons/perf/YellowProgr_5.png": "fb0985324122c64459250c706bbd0e45",
"assets/icons/perf/YellowProgr_1.png": "931d7a17f44871bf2131e575e68caee5",
"assets/icons/perf/GreyProgr_4@2x.png": "71516e40666d1d49e9bb8e418fe8fcbf",
"assets/icons/perf/GreyProgr_8@2x.png": "76ead0039c3b5d40ca242208f061eb43",
"assets/icons/perf/YellowProgr_1@2x.png": "e6410d82dc4ea321ab99989b85bf5b11",
"assets/icons/perf/YellowProgr_2.png": "275229f6ffce2cd40046b67bb8f12ec5",
"assets/icons/perf/RedProgr_7@2x.png": "773e2642c463c59abd4361ef40cc9278",
"assets/icons/perf/GreyProgr@2x.png": "55ab615af7918cf9679e336d232d6532",
"assets/icons/perf/red_progress.gif": "183c0960cdeae01bf48dfc038fc82b46",
"assets/icons/perf/GreyProgr_8.png": "8c9f87d07f1320385f0ccfe9ef41bdbc",
"assets/icons/perf/YellowProgr_3.png": "8891817a81bc7deca524d2bccfaa603d",
"assets/icons/perf/YellowProgr_5@2x.png": "0438cd52c76214cdf237228af034554d",
"assets/icons/perf/RedProgr.png": "1cdb016b1836be5ba0c96825c56220b0",
"assets/icons/perf/yellow_progress.gif": "81b651493d7bec4409e94c9244da90e8",
"assets/icons/perf/YellowStr_dark.png": "b3f1c5158f62fa01c2cd21134d8cb356",
"assets/icons/perf/RedProgr_3@2x.png": "6637dcf3b02c3597cae6249eb2ba59f4",
"assets/icons/perf/RedProgr_1@2x.png": "3c8d054241de2bab0a9354612121cdbd",
"assets/icons/perf/RedProgr_8.png": "122c859ad570c00de7535b761ec87c21",
"assets/icons/perf/YellowProgr_7@2x.png": "d0e4d618f5f336ca2260468578f9d640",
"assets/icons/perf/GreyProgr_2@2x.png": "4793e5364e0d59bbed0205afd4658d6d",
"assets/icons/perf/RedExcl.png": "cca59862a366809289e1f922e0b9e016",
"assets/icons/perf/YellowProgr_2@2x.png": "6a38afa0e7667e15ac3864e976bc86b1",
"assets/icons/perf/RedProgr_6.png": "f9113c84d24e0870b5ca67ed422d8392",
"assets/icons/perf/GreyProgr_7@2x.png": "c01ea52ee631d000208eefa07fd94af4",
"assets/icons/perf/RedProgr_7.png": "7de867c115e9aecf52b49ff87b552853",
"assets/icons/perf/grey_progress.gif": "e3f69f349356b291fcf4e36d0a4520c7",
"assets/icons/perf/RedProgr_5.png": "6c467695d7161fc0e49371aaea1e90ef",
"assets/icons/perf/RedProgr_8@2x.png": "d0ea4872eca720e084daf441c844a0f1",
"assets/icons/perf/RedProgr_4.png": "9d6c573bbcb6f914334b46ebe927beb4",
"assets/icons/perf/RedProgr_4@2x.png": "f540c7facb3118337561740f37cf145b",
"assets/icons/perf/RedProgr_6@2x.png": "6c03fcc0a888e884a20f9b13615f934a",
"assets/icons/perf/YellowProgr.png": "eb995c5e6e71ecdb9eeff1bda3254433",
"assets/icons/perf/RedProgr_1.png": "fa81c9d18b726e639dc165deb064ce70",
"assets/icons/perf/YellowProgr@2x.png": "08974875e52895fd5ba2fcbc68d11bc0",
"assets/icons/perf/GreenOK.png": "29e53c41c07adf8108ae440363a1f1ff",
"assets/icons/perf/RedProgr@2x.png": "5b7f5e5e8c54762974778f18e3b6a4f3",
"assets/icons/perf/RedProgr_3.png": "a47575aad5e69b7f104906027e6a87a9",
"assets/icons/perf/GreyProgr_5@2x.png": "7468e52d82d7567b1dc30e4417724931",
"assets/icons/perf/RedProgr_2.png": "0230a95ceb8b5bec4fd19d4645ba6387",
"assets/icons/perf/GreyProgr_5.png": "9f244fdc860444f6f389be12b5fab0de",
"assets/icons/perf/RedProgr_2@2x.png": "2c9732aec4cf7f1fcb0fe9f94540377d",
"assets/icons/perf/YellowStr@2x.png": "feeb20f721020bc3c60eefda0154da65",
"assets/icons/perf/GreyProgr.png": "e6add7e1d045042900d1d00552a33845",
"assets/icons/perf/RedExcl@2x.png": "872ca936762bf516f99b7ca2482b8ef2",
"assets/icons/perf/GreyProgr_4.png": "f441611492868ab01d7b8680a1db7d3e",
"assets/icons/perf/GreyProgr_6.png": "c2a9cc94ae5546f83d0f92c979c5ce1b",
"assets/icons/perf/GreyProgr_1@2x.png": "55ab615af7918cf9679e336d232d6532",
"assets/icons/perf/YellowProgr_4@2x.png": "5715936de3b824350221f4a1c3e4f095",
"assets/icons/perf/YellowProgr_8@2x.png": "8b5179241867d9bab7dc8a53649597a5",
"assets/icons/perf/GreyProgr_7.png": "8546e961345b3026d84b2afa50f61895",
"assets/icons/perf/GreyProgr_3@2x.png": "7ff0758836fca86d41eae6afbf538e79",
"assets/icons/perf/YellowProgr_8.png": "fa7cc1166731596e4876cfea714d92f3",
"assets/icons/perf/GreyProgr_3.png": "799c8ea45fc2644042fdd2142448473a",
"assets/icons/perf/YellowProgr_6@2x.png": "23a63f74f6325a5386289ddded040678",
"assets/icons/perf/GreyProgr_2.png": "04c0175aa8ce80a6ca8a20d9eb3308a8",
"assets/icons/perf/YellowStr.png": "aac8d0b52e9558a1e743c17a604be03d",
"assets/icons/perf/GreyProgr_1.png": "b4e3c3667da88e11cc223df9cd25ac9b",
"assets/icons/debug_paint.png": "c1821eb82fbe418ac8751473c992b6c4",
"assets/icons/feedback.png": "7646ea4d8b319023ff9821e4b5228716",
"assets/icons/hot-restart.png": "b7527e2a55e166ac5d2cda4c8a7cda1a",
"assets/icons/feedback@2x.png": "3fe67ddc2a05c25d67a70f4062035555",
"assets/icons/flutter@2x.png": "d279eea967055d8bcaafcecc96b9ea44",
"assets/icons/refresh.png": "fe16b19fbf55e943021c1d773d039ec8",
"assets/icons/flutter_13.png": "c76a0e121afbba68061ce1bfe2f369a2",
"assets/icons/history@2x.png": "4e0f5a3963b2a5cc899d7e58f58ff042",
"assets/icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"assets/icons/template_new_project.png": "8839e9568fe27dd8763f65827279646c",
"assets/fonts/Roboto_Mono/RobotoMono-Medium.ttf": "7cfbd4284ec01b7ace2f8edb5cddae84",
"assets/fonts/Roboto_Mono/RobotoMono-Regular.ttf": "b4618f1f7f4cee0ac09873fcc5a966f9",
"assets/fonts/Roboto_Mono/RobotoMono-Light.ttf": "9d1044ccdbba0efa9a2bfc719a446702",
"assets/fonts/Roboto_Mono/RobotoMono-Bold.ttf": "7c13b04382bb3c4a6a50211300a1b072",
"assets/fonts/Roboto_Mono/RobotoMono-Thin.ttf": "288302ea531af8be59f6ac2b5bbbfdd3",
"assets/fonts/Octicons.ttf": "73b8cff012825060b308d2162f31dbb2",
"assets/fonts/Roboto/Roboto-Medium.ttf": "d08840599e05db7345652d3d417574a9",
"assets/fonts/Roboto/Roboto-Light.ttf": "fc84e998bc29b297ea20321e4c90b6ed",
"assets/fonts/Roboto/Roboto-Regular.ttf": "3e1af3ef546b9e6ecef9f3ba197bf7d2",
"assets/fonts/Roboto/Roboto-Bold.ttf": "ee7b96fa85d8fdb8c126409326ac2d2b",
"assets/fonts/Roboto/Roboto-Thin.ttf": "89e2666c24d37055bcb60e9d2d9f7e35",
"assets/fonts/Roboto/Roboto-Black.ttf": "ec4c9962ba54eb91787aa93d361c10a8",
"assets/fonts/MaterialIcons-Regular.otf": "1288c9e28052e028aba623321f7826ac",
"assets/assets/img/legend/android_other_glyph.png": "b212be59d8946085750299a6862e5b69",
"assets/assets/img/legend/gc_manual_glyph.png": "3d2fc92bbc337862077535b50a7b9f03",
"assets/assets/img/legend/reset_glyph.png": "87b8768b5ea6148d4b454e404ba9cc15",
"assets/assets/img/legend/rss_glyph.png": "22d1ec830c8156cad0f75f93c98ea79c",
"assets/assets/img/legend/android_graphics_glyph.png": "19085508e35efec54701791d700a587b",
"assets/assets/img/legend/snapshot_manual_glyph.png": "08606adb70ddb52972fa73b4d137f133",
"assets/assets/img/legend/monitor_glyph.png": "83600711aca90accf5c19583bafdc872",
"assets/assets/img/legend/android_total_glyph.png": "da4570c053c61e5c0fb40cf1fb389dde",
"assets/assets/img/legend/capacity_glyph.png": "5c4acf39c2bd5dc30f796de851f7fcac",
"assets/assets/img/legend/android_code_glyph.png": "2307dd51fc850f1ec2b386441d2e088a",
"assets/assets/img/legend/external_glyph.png": "e5a00cf44aa52332d679550e7d72539d",
"assets/assets/img/legend/android_java_glyph.png": "701492133b0189bee0b221e700f4922d",
"assets/assets/img/legend/android_stack_glyph.png": "abb65c562cd5e2135ab06411df810aa5",
"assets/assets/img/legend/android_native_glyph.png": "340e2e06f6ecc61d175a36741bce1802",
"assets/assets/img/legend/snapshot_auto_glyph.png": "e9fa7f1567f1c12429b52c9f4b6c8677",
"assets/assets/img/legend/gc_vm_glyph.png": "a4de8605fa4f9e3d299a015cf432c609",
"assets/assets/img/legend/used_glyph.png": "75808a6862b87ea7f3340da5b7c7dc6e",
"assets/assets/img/star.png": "2b1babb5a3c9284b1d8352a894cc815f",
"assets/assets/img/layout_explorer/negative_space_dark.png": "82e6869910765b88b8736f130fd972bd",
"assets/assets/img/layout_explorer/main_axis_alignment/column_spaceAround.png": "d84a3cdbb3e9d6f3c1a65a9d01148cab",
"assets/assets/img/layout_explorer/main_axis_alignment/row_spaceAround.png": "9e9b8dac4b96218d6044ec36b4265101",
"assets/assets/img/layout_explorer/main_axis_alignment/row_spaceEvenly.png": "e3b904bb030de3f1dc2401aeba94d9a5",
"assets/assets/img/layout_explorer/main_axis_alignment/column_end.png": "aeb15f23b9194c367c5b51fad3d4b93e",
"assets/assets/img/layout_explorer/main_axis_alignment/column_spaceEvenly.png": "c8b5836b57e1a31595d7e8280054dab9",
"assets/assets/img/layout_explorer/main_axis_alignment/end.png": "146ee7ef9b3117a96ec4b5a825bc4044",
"assets/assets/img/layout_explorer/main_axis_alignment/row_spaceBetween.png": "2ce44d15cbc6f6eb4209ccbb73499515",
"assets/assets/img/layout_explorer/main_axis_alignment/center.png": "b7f9b38c788e3664ed132cbc137bda99",
"assets/assets/img/layout_explorer/main_axis_alignment/column_start.png": "99b7b6ea79c0b05103f34cce14396f4f",
"assets/assets/img/layout_explorer/main_axis_alignment/spaceEvenly.png": "4a5ff5ea170ebceaa51539283b05b8a7",
"assets/assets/img/layout_explorer/main_axis_alignment/row_end.png": "858726242cd94a22ccd91b815e0cca24",
"assets/assets/img/layout_explorer/main_axis_alignment/row_start.png": "70efb9159ed00a9a071dcc74b671ac54",
"assets/assets/img/layout_explorer/main_axis_alignment/spaceBetween.png": "778053f426e7b976f14646a88a109d75",
"assets/assets/img/layout_explorer/main_axis_alignment/column_spaceBetween.png": "0a7cba893b350ee92e4831739f81a15e",
"assets/assets/img/layout_explorer/main_axis_alignment/row_center.png": "ae4385c1201ad2a3f7a62df87561f38b",
"assets/assets/img/layout_explorer/main_axis_alignment/spaceAround.png": "1dc4535fec813a437becdf858ce70de2",
"assets/assets/img/layout_explorer/main_axis_alignment/start.png": "66c10848d8c33095c36bfbafb3401c43",
"assets/assets/img/layout_explorer/main_axis_alignment/column_center.png": "8c26475f866fbbaddcd0987946a72f32",
"assets/assets/img/layout_explorer/negative_space_light.png": "5ae227b5f6b819becbcd9eb3b95986ed",
"assets/assets/img/layout_explorer/cross_axis_alignment/row_stretch.png": "41605dd05507bce094aa251f945d3e07",
"assets/assets/img/layout_explorer/cross_axis_alignment/baseline.png": "bdd4f7c12b43b03b67d880f29d86a220",
"assets/assets/img/layout_explorer/cross_axis_alignment/column_end.png": "4cce130517c6958f8bf578e23e770fed",
"assets/assets/img/layout_explorer/cross_axis_alignment/end.png": "a85b3bbb0da27e0aaa471adf2554708d",
"assets/assets/img/layout_explorer/cross_axis_alignment/nobaseline.png": "c591def4d62de313ed913f7d95d70774",
"assets/assets/img/layout_explorer/cross_axis_alignment/center.png": "06ee46b4827d383e2c70ab0b64e48b08",
"assets/assets/img/layout_explorer/cross_axis_alignment/stretch.png": "b5fb850467ee7506b7ae183329fdeb22",
"assets/assets/img/layout_explorer/cross_axis_alignment/column_start.png": "ba2854a71f06c7ab529a8f477b62b6df",
"assets/assets/img/layout_explorer/cross_axis_alignment/row_end.png": "46570b8c05c437243bb030f0c944950e",
"assets/assets/img/layout_explorer/cross_axis_alignment/row_start.png": "82e40210f8cb12c593c26f71a9fa62f5",
"assets/assets/img/layout_explorer/cross_axis_alignment/row_center.png": "adc7dbdac9e1df897997b3f6e2138173",
"assets/assets/img/layout_explorer/cross_axis_alignment/start.png": "b38f2686df7018d2533cccf18b067dcf",
"assets/assets/img/layout_explorer/cross_axis_alignment/column_center.png": "6c55fa8800db0a0649bcb6c60d725c86",
"assets/assets/img/layout_explorer/cross_axis_alignment/column_stretch.png": "cf75e7319e97aa87391b7aa00bc1a19e",
"assets/assets/scripts/inspector_polyfill_script.dart": "1a1cc350f5e829d8eb6edd01f0cb25a1",
"unsupported-browser.html": "0b7cbdffafe3e7533afb08b8fb9b0c03"
};

// The application shell files that are downloaded before a service worker can
// start.
const CORE = [
  "/",
"main.dart.js",
"index.html",
"assets/NOTICES",
"assets/AssetManifest.json",
"assets/FontManifest.json"];
// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value + '?revision=' + RESOURCES[value], {'cache': 'reload'})));
    })
  );
});

// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});

// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache.
        return response || fetch(event.request).then((response) => {
          cache.put(event.request, response.clone());
          return response;
        });
      })
    })
  );
});

self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});

// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey in Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}

// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
