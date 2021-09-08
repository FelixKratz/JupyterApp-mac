BUILD_PATH=./build/JupyterApp.xcarchive

$(BUILD_PATH)/Products/Applications/JupyterApp.app: build
	xcodebuild archive -scheme JupyterLab -archivePath $(BUILD_PATH) -sdk macosx SKIP_INSTALL=NO BUILD_LIBRARIES_FOR_DISTRIBUTION=YES

install: $(BUILD_PATH)/Products/Applications/JupyterApp.app
	cp -r $(BUILD_PATH)/Products/Applications/JupyterApp.app /Applications/JupyterApp.app

build:
	mkdir build
