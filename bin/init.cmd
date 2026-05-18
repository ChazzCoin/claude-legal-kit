@echo off
where /q py && (py "%~dp0init" %*) || (python "%~dp0init" %*)
