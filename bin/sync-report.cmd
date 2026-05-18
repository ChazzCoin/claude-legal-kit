@echo off
where /q py && (py "%~dp0sync-report" %*) || (python "%~dp0sync-report" %*)
