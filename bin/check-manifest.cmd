@echo off
where /q py && (py "%~dp0check-manifest" %*) || (python "%~dp0check-manifest" %*)
