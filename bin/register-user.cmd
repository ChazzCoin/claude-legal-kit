@echo off
where /q py && (py "%~dp0register-user" %*) || (python "%~dp0register-user" %*)
