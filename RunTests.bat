@echo off

haxe Tests.hxml
cd bin
neko Tests.n --no-log
cd ..