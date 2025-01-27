app-test:
	fvm flutter test -r expanded
gen-code:
	fvm flutter pub run build_runner build --delete-conflicting-outputs