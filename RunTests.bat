@echo off

haxe Tests.hxml
cd bin
neko Tests.n
cd ..