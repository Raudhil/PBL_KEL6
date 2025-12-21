@echo off
REM TerasWarga API Testing Suite Runner
REM Batch script untuk menjalankan API tests

echo.
echo =========================================
echo    TERASWARGA API TESTING SUITE
echo    Automated Test Runner
echo =========================================
echo.

echo [1/3] Checking Dart installation...
where dart >nul 2>&1
if %errorlevel% neq 0 (
    echo    ERROR: Dart SDK not found!
    echo    Please install Dart: https://dart.dev/get-dart
    exit /b 1
)
echo    Dart SDK found

echo.
echo [2/3] Installing dependencies...
cd test
call dart pub get
if %errorlevel% neq 0 (
    echo    ERROR: Failed to install dependencies
    exit /b 1
)
echo    Dependencies installed

echo.
echo [3/3] Running API tests...
echo =========================================
echo.

call dart run run_all_tests.dart

cd ..

echo.
echo =========================================
echo Test run completed!
echo.
echo Results saved to: results\test_results.json
echo.
pause
