BUILD_PATH=./build/JupyterApp.xcarchive

JupyterApp.app: build
	xcodebuild archive -scheme JupyterLab -archivePath $(BUILD_PATH) -sdk macosx SKIP_INSTALL=NO BUILD_LIBRARIES_FOR_DISTRIBUTION=YES
	cp -r $(BUILD_PATH)/Products/Applications/JupyterApp.app ./JupyterApp.app
	rm -rf ./build

install: JupyterApp.app
	cp -r ./JupyterApp.app /Applications/JupyterApp.app

build:
	mkdir build

clean:
	rm -rf ./build
