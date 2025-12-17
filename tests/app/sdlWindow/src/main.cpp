// #define TARGET_SDL_WINDOW
#include "ofMain.h"
#include "ofApp.h"
#include "ofAppSDLWindow.h"

//========================================================================
int main( ){

	//Use ofGLFWWindowSettings for more options like multi-monitor fullscreen
	ofGLWindowSettings settings;
	settings.setSize(1024, 768);
	settings.windowMode = OF_WINDOW; //can also be OF_FULLSCREEN

	ofInit();
	auto w = std::make_shared<ofAppSDLWindow>()	;
	ofGetMainLoop()->addWindow(w);
	w->setup(settings);

	ofRunApp(w, std::make_shared<ofApp>());
	ofRunMainLoop();

}
