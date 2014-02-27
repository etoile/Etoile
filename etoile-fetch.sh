#!/bin/bash

etoilefetch() {
	DESTDIR=$1
	REPONAME=$2

	echo "Entering $DESTDIR..."

	if [[ ! -e "$DESTDIR" ]]; then
		echo "Error, $DESTDIR is missing. Skipping $REPONAME"	
	else
		cd "$DESTDIR"
	
		if [[ ! -e "$REPONAME" ]]; then
			echo "Repo $REPONAME is not present. Fetching it..."
			git clone http://github.com/etoile/$REPONAME
		else
			echo "Have $REPONAME"
		fi
	
		cd "$OLDPWD"
	fi
}

# Languages

etoilefetch . Languages
etoilefetch Languages ObjC2JS
etoilefetch Languages SourceCodeKit
etoilefetch Languages ParserKit

# Frameworks

etoilefetch Frameworks CoreObject
etoilefetch Frameworks EtoileFoundation
etoilefetch Frameworks UnitKit
etoilefetch Frameworks EtoileUI
etoilefetch Frameworks EtoilePaint
etoilefetch Frameworks EtoileText
etoilefetch Frameworks IconKit
etoilefetch Frameworks ScriptKit
etoilefetch Frameworks SystemConfig
etoilefetch Frameworks XMPPKit

# Bundles

# Services

etoilefetch Services/Private ObjectManager
etoilefetch Services/Private ProjectManager
etoilefetch Services/Private Worktable
etoilefetch Services/Private System
etoilefetch Services/User DictionaryReader
etoilefetch Services/User FontManager
etoilefetch Services/User Inbox
etoilefetch Services/User StepChat
etoilefetch Services/User StructuredTextEditor

# Developer

etoilefetch Developer/Services DocGenerator
etoilefetch Developer/Services ModelBuilder

# Dependencies

etoilefetch Dependencies libdispatch-objc2

# Bootstrap

ln -s ../Frameworks/UnitKit Bootstrap
ln -s ../Frameworks/EtoileFoundation Bootstrap

