SET root=%cd%

:: mbedtls
msbuild /p:Platform="x64";RuntimeLibrary="MultiThreaded" deps/mbedtls/visualc/VS2010/mbedTLS.sln

:: libwebsockets
cd build\lws-windows
cmake ^
    -DWIN32=ON ^
    -DLWS_WITH_MBEDTLS=ON ^
    -DLWS_MBEDTLS_LIBRARIES="%root%/deps/mbedtls/visualc/VS2010/x64/Debug/mbedTLS.lib" ^
    -DLWS_MBEDTLS_INCLUDE_DIRS="%root%/deps/mbedtls/include" ^
    ..\..\deps\libwebsockets
msbuild /p:Platform="x64";RuntimeLibrary="MultiThreaded" libwebsockets.sln
